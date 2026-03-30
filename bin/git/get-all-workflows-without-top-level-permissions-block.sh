#!/bin/bash
set -eu

ORG=${1:?"missing arg 1 for ORG i.e. ministryofjustice"}
TEAM=${2:?"missing arg 2 for TEAM i.e. modernisaiton-platform"}

FILE="${TMPDIR}repos.txt"

source get-repositories-by-team.sh "${ORG}" "${TEAM}" >"${FILE}"

while read -r REPO; do
  source git-checkout-clean-main.sh "${REPO}"

  find .github/workflows \
    -type f \
    \( -name '*.yml' -o -name '*.yaml' \) \
    -print0 2>/dev/null |
    while IFS= read -r -d '' f; do
      # Check for top-level permissions block.
      # `.permissions` will be `null` if missing.
      if yq -e '.permissions == null' "$f" >/dev/null 2>&1; then
        echo "https://github.com/${ORG}/${REPO}/blob/main/${f#./}"
      fi
    done
done <"$FILE"
