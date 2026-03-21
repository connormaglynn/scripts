#!/bin/bash

# this script depends on the following being installed:
# - git

set -e

REPO=${1:?"missing arg 1 for REPO"}

DIR="${TMPDIR}git"

# if no temp git directory, create it
if [ ! -d "${DIR}" ]; then
  mkdir $DIR
fi

cd ${DIR}

# if no temp repo directory, clone i
if [ ! -d "${DIR}/${REPO}" ]; then
  git clone "https://github.com/ministryofjustice/${REPO}.git" &>/dev/null
fi

{
  cd "${DIR}/${REPO}"
  git stash
  git checkout main || git checkout master
  git pull
} &>/dev/null
