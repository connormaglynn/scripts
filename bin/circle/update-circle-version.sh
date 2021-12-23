#!/bin/bash

# this script depends on the following being installed:
# - git

TICKET=${1:?"missing arg 1 for TICKET"}
VERSION=${2:?"missing arg 2 for VERSION"}
SERVICES=${3:?"missing arg 3 for SERVICES"}
BRANCH_NAME="$TICKET-update-hmmps-circle-orb-version-to-$VERSION"
COMMIT_MESSAGE="⬆️ $TICKET: update hmpps-circle-orb version to $VERSION"
LOG_FILE=~/Desktop/prs-created.txt

FILE=~/git/scripts/services/all/$SERVICES.txt

set -eu

while read -r line; do

  cd ~/git
  if [ ! -d "$HOME/git/$line" ]
  then
      git clone "https://github.com/ministryofjustice/$line.git" &> /dev/null
  fi

  {
    cd ~/git/"$line"
    git stash
    git checkout main
    git pull
  } &> /dev/null

  echo "updating $line to version $VERSION"
  sed -i "" "s/.*ministryofjustice\/hmpps.*/  hmpps: ministryofjustice\/hmpps@$VERSION/" ./.circleci/config.yml

  git --no-pager diff

  echo "Committing changes for $line"
  {
    cd ~/git/"$line"
    git checkout -b "$BRANCH_NAME"
    git add .
    git commit -m "$COMMIT_MESSAGE"
  } &> /dev/null

  echo "Creating PR for changes for $line"
  git push --set-upstream origin "$BRANCH_NAME" &> /dev/null
  gh pr create --title "$COMMIT_MESSAGE" --body "$COMMIT_MESSAGE" >> "$LOG_FILE"

  echo "---------------------------------------------------------------"
done < "$FILE"

echo $LOG_FILE
