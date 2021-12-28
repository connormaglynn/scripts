#!/bin/bash
set -eu

# this script depends on the following being installed:
# - git

TICKET=${1:?"missing arg 1 for TICKET"}
VERSION=${2:?"missing arg 2 for VERSION"}
SERVICES=${3:?"missing arg 3 for SERVICES"}
COMMIT=${4:-false}
PR=${5:-false}

BRANCH_NAME="$TICKET-update-hmmps-circle-orb-version-to-$VERSION"
MESSAGE="⬆️ $TICKET: update hmpps-circle-orb version to $VERSION"
FILE=~/git/scripts/services/all/$SERVICES.txt

while read -r line; do
  source git-checkout-clean-main.sh "$line"

  echo "updating $line to version $VERSION"
  sed -i "" "s/.*hmpps: ministryofjustice\/hmpps@.*/  hmpps: ministryofjustice\/hmpps@$VERSION/" ./.circleci/config.yml

  source git-commit-to-branch.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$COMMIT"
  source git-create-pr.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$PR"

  echo "---------------------------------------------------------------"
done < "$FILE"
