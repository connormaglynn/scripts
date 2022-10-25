#!/bin/bash

# Check all parameters are passed in
if [ $# -eq 0  ]
then
  echo "Please call the script as 'get-secrets {secret} {namespace}'"
  exit 1
fi


# Set parameters to local variables
secret=$1
namespace=$2

kubectl -n "$namespace" get secret "$secret" -o json | jq '.data | map_values(@base64d)'
