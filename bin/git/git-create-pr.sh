#!/bin/bash
set -e

TICKET=${1:?"missing arg 1 for TICKET"}
MESSAGE=${2:?"missing arg 2 for MESSAGE"}
BRANCH_NAME=${3:?"missing arg 3 for BRANCH_NAME"}
EXECUTE=${4:-false}

COMMIT_MESSAGE="$TICKET: 🤖 $MESSAGE"
LOG_FILE=~/Desktop/prs-created.txt

if $EXECUTE
then
  echo "Creating PR..."
  {
    git push --set-upstream origin "$BRANCH_NAME" &> /dev/null
    gh pr create --title "$COMMIT_MESSAGE" --body "$COMMIT_MESSAGE" >> $LOG_FILE
  } &> /dev/null
else
  echo "Not creating PR..."
fi
