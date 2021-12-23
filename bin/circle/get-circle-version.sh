#!/bin/bash

# this script depends on the following being installed:
# - yq
# - git

SERVICES=${1:?"missing arg 1 for SERVICES"}

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

  echo "$line"
  CIRCLEORB=$(yq e '.orbs.hmpps' ./.circleci/config.yml)
  echo "Circle Orb: $CIRCLEORB"

  echo "---------------------------------------------------------------"
done < "$FILE"
