#!/bin/bash
set -e

TICKET=${1:?"missing arg 1 for TICKET"}
MESSAGE=${2:?"missing arg 2 for MESSAGE"}
BRANCH_NAME=${3:?"missing arg 3 for BRANCH_NAME"}
EXECUTE=${4:-false}

COMMIT_MESSAGE="🤖 $TICKET: $MESSAGE"

{
  ./gradlew || npm install
} &> /dev/null
git --no-pager diff

if $EXECUTE
then
  echo "Committing changes..."
  {
    git branch -D "$BRANCH_NAME" || git checkout -b "$BRANCH_NAME"
    git checkout -b "$BRANCH_NAME"
    git add -A
    git commit -m "$COMMIT_MESSAGE"
  } &> /dev/null
else
  echo "Not committing changes..."
fi
