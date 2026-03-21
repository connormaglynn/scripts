#!/bin/bash

set -eu

ORG=${1:?"missing arg 1 for ORG i.e. ministryofjustice"}
TEAM=${2:?"missing arg 2 for TEAM i.e. modernisaiton-platform"}

FILE="${TMPDIR}repos.txt"

source get-repositories-by-team.sh "${ORG}" "${TEAM}" >"${FILE}"

while read -r REPO; do
  source git-checkout-clean-main.sh "${REPO}"

  wfdir=".github/workflows"
  if [[ ! -d "$wfdir" ]]; then
    echo "No workflows directory found at: $REPO/$wfdir (skipping)"
    continue
  fi

  for f in .github/workflows/*.yml; do
    yq -r '.jobs[].steps[]?.uses? | select(. != null)' "$f" |
      sed "s|^|https://github.com/${ORG}/${REPO}/blob/main/$f: |"
  done
done <"$FILE"
