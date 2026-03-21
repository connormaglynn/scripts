#!/bin/bash

set -eu

ACTION=${1:?"missing arg 2 for ACTION"}
NEW_SHA=${2:?"missing arg 2 for NEW_SHA"}
NEW_COMMENT=${2:?"missing arg 3 for NEW_COMMENT"}
COMMIT=${3:-false}
PR=${4:-false}
MESSAGE="Update terraform-static-analysis to ${NEW_COMMENT}"
BRANCH_NAME="update-terraform-static-analysis-to-${NEW_COMMENT}"

FILE=~/git/scripts/mp-repos.txt

while read -r REPO; do
  source git-checkout-clean-main.sh "$REPO"

  echo $REPO

  wfdir=.github/workflows
  if [[ ! -d "$wfdir" ]]; then
    print "No workflows directory found at: $REPO/$wfdir (skipping)"
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
