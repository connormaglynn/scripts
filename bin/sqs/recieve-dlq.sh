#!/usr/bin/env bash

###
#
# A script to copy the contents of the PCMS DLQ into a local directory so the failure reason can be investigated.
#
# The following command line utilities are required:
#  * aws cli
#  * kubectl
#  * jq
#
# Access to the Kubernetes namespace being interrogated is also required.
#
###

ENV=${1:-dev}
DATA_DIR=${2:-dlq-messages}

getSecret() {
  kubectl get secret pcms-sqs-dl-output -o json | jq -r ".data.$1" | base64 --decode
}

is-in-context() {
  kubectl config use-context $1
  namespace=$(kubectl get namespaces -o name | sed 's#namespace/##' | grep "hmpps-pin-phone-monitor-$ENV")
  words=$(echo "$namespace" | wc -w)
  if [[ $words -ne 1 ]]; then
    return 1
  else
    return 0
  fi
}

# Gather secrets
export AWS_DEFAULT_REGION=eu-west-2

if is-in-context live.cloud-platform.service.justice.gov.uk; then
  echo "Setting current context namespace to $namespace"
  kubectl config set-context --current --namespace="$namespace"
elif is-in-context live-1.cloud-platform.service.justice.gov.uk; then
  echo "Setting current context namespace to $namespace"
  kubectl config set-context --current --namespace="$namespace"
fi

AWS_ACCESS_KEY_ID=$(getSecret 'access_key_id')
AWS_SECRET_ACCESS_KEY=$(getSecret 'secret_access_key')
URL=$(getSecret 'sqs_url')

# clear previous run's data
rm -rf "$DATA_DIR" 2> /dev/null
mkdir "$DATA_DIR"

extractField() {
  echo "$1" | jq -r '.Messages[0].Body' | jq -r '.Message' | jq ".$2"
}

# copy all DLQ messages (NOTE - we do not acknowledge the received messages so they will be returned to the DLQ)
MSG_COUNT=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws sqs get-queue-attributes "--queue-url=$URL" --attribute-names ApproximateNumberOfMessages | jq ".Attributes.ApproximateNumberOfMessages" | tr -d '"')
echo "Found $MSG_COUNT dlq messages"
# shellcheck disable=SC2086
for i in $(seq $MSG_COUNT)
do
  contents=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws sqs receive-message "--queue-url=$URL" --max-number-of-message 1)
  echo "$contents" > "$DATA_DIR/DLQ-$i.json"
  echo "Processed dlq message: $MSG_COUNT"
done
