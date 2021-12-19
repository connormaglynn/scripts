#!/bin/bash
FILE=${1-namespaces}

set -e

while read -r line;
do
  echo "Processing Cronjobs for $line"
    kubectl -n "$line" get cronjobs -ojson | jq '.items[] | select(.spec.jobTemplate.spec.ttlSecondsAfterFinished != null ) | .metadata.name'
  echo "done  Cronjobs for $line"

  echo "Processing Jobs for $line"
    kubectl -n "$line" get jobs -ojson | jq -r '.items[] | select(.spec.ttlSecondsAfterFinished !=  null ) | .metadata.name'
  echo "done  Jobs for $line"
  echo "---------------------------------------------------------------"
done < "$FILE"
