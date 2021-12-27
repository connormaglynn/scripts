#!/bin/bash

# this script depends on the following being installed:
# - git

set -e

REPO=${1:?"missing arg 1 for REPO"}

cd "$HOME"/git
if [ ! -d "$HOME/git/$REPO" ]
then
    git clone "https://github.com/ministryofjustice/$REPO.git" &> /dev/null
fi

{
  cd ~/git/"$REPO"
  git stash
  git checkout main || git checkout master
  git pull
} &> /dev/null
