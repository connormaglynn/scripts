#!/bin/bash
set -e
NAMESPACEFILE_FILE=${1-namespaces}

for namespace in $(cat "$NAMESPACEFILE_FILE"); do
  echo "Processing Cronjobs for $namespace"
    kubectl -n "$namespace" get cronjobs -ojson | jq '.items[] | select(.spec.jobTemplate.spec.ttlSecondsAfterFinished != null ) | .metadata.name'
  echo "done  Cronjobs for $namespace"

  echo "Processing Jobs for $namespace"
    kubectl -n "$namespace" get jobs -ojson | jq -r '.items[] | select(.spec.ttlSecondsAfterFinished !=  null ) | .metadata.name'
  echo "done  Jobs for $namespace"
  echo "---------------------------------------------------------------"
done
