#!/bin/bash

set -eu

ORG=${1:?"missing arg 1 for ORG i.e. ministryofjustice"}
TEAM=${2:?"missing arg 2 for TEAM i.e. modernisaiton-platform"}

FILE="${TMPDIR}repos.txt"

source get-repositories-by-team.sh "${ORG}" "${TEAM}" >"${FILE}"

while read -r REPO; do
  source git-checkout-clean-main.sh "${REPO}"

  find . \
    -type f \
    \( -name '*.yml' -o -name '*.yaml' \) \
    -not -path './.git/*' \
    -print0 |
    while IFS= read -r -d '' f; do
      # Extract all `uses:` values anywhere in the YAML file
      yq -r '.. | select(has("uses")) | .uses | select(type == "!!str")' "$f" 2>/dev/null |
        sed "s|^|https://github.com/${ORG}/${REPO}/blob/main/${f#./}: |"
    done
done <"$FILE"
