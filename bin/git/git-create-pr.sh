#!/bin/bash
set -e

MESSAGE=${1:?"missing arg 1 for MESSAGE"}
BRANCH_NAME=${2:?"missing arg 2 for BRANCH_NAME"}
EXECUTE=${3:-false}

COMMIT_MESSAGE="🤖 $MESSAGE"
LOG_FILE="${TMPDIR}prs-created.txt"

if $EXECUTE; then
  echo "Creating PR..."
  {
    git push --set-upstream origin "$BRANCH_NAME" &>/dev/null || :
    gh pr create --title "$COMMIT_MESSAGE" --body "$COMMIT_MESSAGE" >>$LOG_FILE || :
  } &>/dev/null
  cat "${LOG_FILE}"
else
  echo "Not creating PR..."
fi
