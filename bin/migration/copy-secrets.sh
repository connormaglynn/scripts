#!/bin/bash
set -eu
NAMESPACE=${1?No NAMESPACE specified}
SECRETS_FILE=~/git/scripts/secrets/secrets.txt

FROM_CONTEXT=live-1.cloud-platform.service.justice.gov.uk
TO_CONTEXT=live.cloud-platform.service.justice.gov.uk

while read -r line; do
  echo "Processing $line"

  kubectl --context $FROM_CONTEXT -n "$NAMESPACE" get secret "$line" -ojson | jq -r '. | {apiVersion, kind, metadata, data, type} | del(.metadata.annotations."kubectl.kubernetes.io/last-applied-configuration", .metadata.namespace, .metadata.creationTimestamp, .metadata.resourceVersion, .metadata.selfLink, .metadata.uid)' | kubectl --context $TO_CONTEXT -n $NAMESPACE create -f -
  echo "done copy"
  kubectl --context $TO_CONTEXT -n "$NAMESPACE" get secret "$line"

  echo "----------------------------------"
done < "$SECRETS_FILE"
