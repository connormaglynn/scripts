 #!/bin/bash

# This script depends on the following
# - git installed and configured
# - gh installed and configured
# - cloud-platform-environments repo existing in '~/git/cloud-platform-environments'
# - BRANCH_NAME & COMMIT_MESSAGE will probably need to have a new ticket number for another migration
# 
# You will need to pass in a file that is a list of namespaces that exist, as a parameter one namespace per line i.e:
#     manage-soc-cases-dev
#     licences-dev


set -e
NAMESPACEFILE_FILE=${1-namespaces}

for namespace in $(cat "$NAMESPACEFILE_FILE"); do
  BRANCH_NAME="DCS-1333_migrate_${namespace}_to_live"
  COMMIT_MESSAGE="DCS-1333: migrate $namespace to live"

  echo "Stashing any changes"
  git stash

  echo "Starting migration for $namespace"
  cd ~/git/cloud-platform-environments/namespaces/live-1.cloud-platform.service.justice.gov.uk/$namespace

  echo "Checking out main"
  git checkout main

  echo "Pulling main"
  git pull

  echo "Checking out a branch for $namespace"
  git checkout -b $BRANCH_NAME

  echo "Migrating $namespace"
  cloud-platform environment migrate >> ~/Desktop/migration-output.txt

  echo "Comitting changes for  $namespace"
  git add -A
  git commit -m "$COMMIT_MESSAGE"

  echo "Creating PR for changes for  $namespace"
  git push --set-upstream origin $BRANCH_NAME
  gh pr create --title "$COMMIT_MESSAGE" --body "$COMMIT_MESSAGE"

  echo "---------------------------------------------------------------"
done
