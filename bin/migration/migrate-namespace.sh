#!/bin/bash
set -eu
# This script depends on the following
# - git installed and configured
# - gh installed and configured
# - cloud-platform-environments repo existing in '~/git/cloud-platform-environments'
# - BRANCH_NAME & COMMIT_MESSAGE will probably need to have a new ticket number for another migration
# 
# You will need to pass in a file that is a list of namespaces that exist, as a parameter one namespace per line i.e:
#     manage-soc-cases-dev
#     licences-dev

TICKET=${1:?"missing arg 2 for TICKET"}
SERVICES=${2:?"missing arg 2 for SERVICES"}
COMMIT=${3:-false}
PR=${4:-false}

FILE=~/git/scripts/namespaces/all/$SERVICES.txt

source git-checkout-clean-main.sh "cloud-platform-environments"
while read -r line; do
  BRANCH_NAME="${TICKET}_migrate_${line}_to_live"
  MESSAGE="Migrate $line to live"

  echo "$line"
  {
    git stash
    git checkout main
    git pull
    cd ~/git/cloud-platform-environments/namespaces/live-1.cloud-platform.service.justice.gov.uk/"$line"
  } &> /dev/null

  cloud-platform environment migrate
  sleep 2

  source git-commit-to-branch.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$COMMIT"
  source git-create-pr.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$PR"

  echo "---------------------------------------------------------------"
done < "$FILE"
