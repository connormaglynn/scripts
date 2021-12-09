#!/bin/bash
LINE="-----------------------------------------------------------------------------------------------------------------"

# Check all parameters are passed in
if [ $# -eq 0  ]
then
  echo $LINE
  echo "- Please call the script as 'connect-to-db {namespace} {secret with db connection details(defaults to [dps-rds-instance-output])}'"
  echo $LINE
  exit 1
fi

# Set parameters to local variables
NAMESPACE=$1
SECRET_WITH_DB_CONNECTION_DETAILS=$2
DEFAULT_SECRET="dps-rds-instance-output"

# Check the namespace exists
echo $LINE
echo "1. Checking the namespace exists"
if [[ -z $(kubectl get namespaces | grep $NAMESPACE) ]]; then
  echo "- the namespace [ $NAMESPACE ] doesn't exist. Exiting the program"
  echo $LINE
  exit 1
fi
echo "- [ $NAMESPACE ] exists. Continuing..."
echo $LINE

# Get secrets for connect to DB
echo "2. Get secrets for DB connection"
DB_SECRETS=$(kubectl --namespace $NAMESPACE get secret ${SECRET_WITH_DB_CONNECTION_DETAILS:-$DEFAULT_SECRET} -o json | jq '.data | map_values(@base64d)') 
DB_ADDRESS=$(echo $DB_SECRETS | jq -r '.rds_instance_address')
echo "- DB Secrets: $DB_SECRETS"
echo "- Connecting to: $DB_ADDRESS"
echo $LINE

# Check if port-forwarding pod exists, create if not
echo "3. Create a port-forward-pod if one doesn't already exist in [ $NAMESPACE ]"
PORT_FORWARD_POD=$(kubectl -n $NAMESPACE get pods | grep port-forward-pod)
if [ -z "$PORT_FORWARD_POD" ]
then
  echo "- No port-forward-pod - creating one in [ $NAMESPACE ]..."
  kubectl --namespace "$NAMESPACE" \
    run port-forward-pod \
      --image=ministryofjustice/port-forward \
      --env="REMOTE_HOST=$DB_ADDRESS" \
      --env="REMOTE_PORT=5432" \
      --env="LOCAL_PORT=5432"
else
  echo "- port-forward-pod already exists in [ $NAMESPACE ]. Continuing..."
fi
echo $LINE

# Verify port forward pod exists
echo "4. Verify port-forward-pod exists in [ $NAMESPACE ]"
echo "- Waiting for port-forward-pod to load..."
sleep 5
echo "- port-forward-pod should exist..."
kubectl -n $NAMESPACE get pods
echo $LINE

# Connect to the port-forward-pod. Keep reconnecting (due to timeouts) until the user decides to stop re-connecting
echo "5. Connect to port-forward-pod in [ $NAMESPACE ]"
condition=r
while [ "$condition" = "r" ]
do
  echo "- Connecting to port-forward-pod..."
  echo "- Press [ CTRL+C ] to manually exit the connection..."
  kubectl -n $NAMESPACE port-forward port-forward-pod 5433:5432
  echo "- The connection has timed out or has been manually disconected. Enter 'r' to reconnect - or any other key to delete the pod..."
  read condition
done
echo $LINE

# When user is done, delete the pod
echo "6. Delete port-forward-pod in [ $NAMESPACE ]"
kubectl -n $NAMESPACE delete pod port-forward-pod
echo "- port-forward-pod should now be deleted" 
kubectl -n $NAMESPACE get pods
echo $LINE

exit 1
