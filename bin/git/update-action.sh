#!/bin/bash

set -eu

ORG=${1:?"missing arg 1 for ACTION"}
TEAM=${2:?"missing arg 2 for ACTION"}
ACTION=${3:?"missing arg 3 for ACTION"}
NEW_SHA=${4:?"missing arg 4 for NEW_SHA"}
NEW_COMMENT=${5:?"missing arg 5 for NEW_COMMENT"}
COMMIT=${6:-false}
PR=${7:-false}
MESSAGE="Update ${ACTION} to ${NEW_COMMENT}"
BRANCH_NAME="update-action-to-${NEW_COMMENT}"

FILE="${TMPDIR}repos.txt"

source get-repositories-by-team.sh "${ORG}" "${TEAM}" >"${FILE}"

while read -r REPO; do
  source git-checkout-clean-main.sh "$REPO"

  echo $REPO

  wfdir=.github/workflows
  if [[ ! -d "$wfdir" ]]; then
    echo "No workflows directory found at: $REPO/$wfdir (skipping)"
    continue
  fi

  for f in "$wfdir"/*.yml; do
    [[ -f "$f" ]] || continue

    sed -i '' -E \
      "s|^([[:space:]]*uses:[[:space:]]*${ACTION}@)[^[:space:]#]+([[:space:]]*(#.*)?)$|\\1${NEW_SHA} # ${NEW_COMMENT}|" \
      $f
  done

  source git-commit-to-branch.sh "$MESSAGE" "$BRANCH_NAME" "$COMMIT"
  source git-create-pr.sh "$MESSAGE" "$BRANCH_NAME" "$PR"

  echo "---------------------------------------------------"

done <"$FILE"
