#!/bin/bash
set -eu

# This script depends on the following
# - git
# - gh

TICKET=${1:?"missing arg 1 for TICKET"}
SERVICES=${2:?"missing arg 2 for SERVICES"}
COMMIT=${3:-false}
PR=${4:-false}

BRANCH_NAME="$TICKET-fix-security-vulnerability"
MESSAGE="Fix Security Vulnerabilities"

FILE=~/git/scripts/services/node/$SERVICES.txt

while read -r line; do
  source git-checkout-clean-main.sh "$line"

  echo "$line"
  echo "Before:"
  better-npm-audit audit || :

  echo -e "\nRunning npm audit fix\n"
  npm audit fix &> /dev/null || :

  echo "After:"
  better-npm-audit audit || :

  source git-commit-to-branch.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$COMMIT"
  source git-create-pr.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$PR"

  echo "---------------------------------------------------------------"
done < "$FILE"
