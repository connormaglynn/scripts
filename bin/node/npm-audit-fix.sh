#!/bin/bash

# This script depends on the folliwing
# - git installed and configured
# - gh installed and configured
# - cloud-platform-environments repo existing in '~/git/cloud-platform-environments'
# - BRANCH_NAME & COMMIT_MESSAGE will probably need to have a new ticket number for another migration
# 
# You will need to pass in a file that is a list of namespaces that exist, as a parameter one namespace per line i.e:
#     manage-soc-cases-dev
#     licences-dev


NAMESPACEFILE_FILE=${1-namespaces}

for namespace in $(cat "$NAMESPACEFILE_FILE"); do
  BRANCH_NAME="fix_security_vulnerability"
  COMMIT_MESSAGE="🔐 Fix Json Schema Security Vulnerability"

  echo "Starting migration for $namespace"
  cd ~/git/$namespace

  echo "Stashing any changes"
  git stash

  echo "Checking out main"
  git checkout main

  echo "Pulling main"
  git pull

  echo "Checking out a branch for $namespace"
  git checkout -b $BRANCH_NAME

  echo "Running npm audit"
  echo $namespace >> ~/Desktop/npm-audit-before.txt
  $(npm audit >> ~/Desktop/npm-audit-before.txt)

  echo "Running npm audit fix"
  npm audit fix

  echo "Running npm audit and output to file"
  echo $namespace >> ~/Desktop/npm-audit-after.txt
  npm audit >> ~/Desktop/npm-audit-after.txt

  echo "Comitting changes for  $namespace"
  git add -A
  git commit -m "$COMMIT_MESSAGE"

  echo "Creating PR for changes for  $namespace"
  git push --set-upstream origin $BRANCH_NAME
  gh pr create --title "$COMMIT_MESSAGE" --body "$COMMIT_MESSAGE" >> ~/Desktop/prs-created.txt

  echo "---------------------------------------------------------------"
done
