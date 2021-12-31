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
MESSAGE="Fix Json Schema Security Vulnerability"

FILE=~/git/scripts/services/node/$SERVICES.txt
LOG_FILE=~/Desktop/npm-audit.txt

while read -r line; do
  source git-checkout-clean-main.sh "$line"

  echo "$line"

  echo "$line" >> $LOG_FILE
  echo "Before:" >> $LOG_FILE
  better-npm-audit audit || true >> $LOG_FILE

  echo "Running npm audit fix"
  {
    npm audit fix || true
  } &> /dev/null

  echo "After:" >> $LOG_FILE
  better-npm-audit audit || true >> $LOG_FILE
  echo "---------------------------------------------------------------" >> $LOG_FILE


  source git-commit-to-branch.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$COMMIT"
  source git-create-pr.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$PR"

  echo "---------------------------------------------------------------"
done < "$FILE"
