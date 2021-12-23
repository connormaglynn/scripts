#!/bin/bash

# this script depends on the following being installed:
# - yq
# - jq
# - git

SERVICES=${1:?"missing arg 1 for SERVICES"}
VERSION=16
DOCKERVERSION=16.13-bullseye
CIRCLEVERSION=16.13-browsers

FILE=~/git/scripts/services/node/$SERVICES.txt

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

#  echo "$line"
#  DOCKERFILE=$(grep "FROM node:" < ./Dockerfile)
#  echo "Dockerfile: $DOCKERFILE"

  echo "updating $line to version $VERSION"
  sed -i "" "s/.*\"node\": \".*/    \"node\": \"^$VERSION\",/" ./package.json


#  CIRCLEPARAMTER=$(yq e '.parameters.node-version.default' ./.circleci/config.yml)
#  if [ "$CIRCLEPARAMTER" != "null" ]; then
#    echo "Circle Parameter: $CIRCLEPARAMTER"
#  else
#    # These need to be standardised across services to use the parameterized method above
#    CIRCLEBUILDER=$(yq e '.executors.builder.docker[0]' ./.circleci/config.yml)
#    echo "Circle Builder: $CIRCLEBUILDER"
#
#    CIRCLEVALIDATOR=$(yq e '.executors.validator.docker[0]' ./.circleci/config.yml)
#    echo "Circle Validator: $CIRCLEVALIDATOR"
#
#    CIRCLEINTTEST=$(yq e '.executors.integration-tests.docker[0]' ./.circleci/config.yml)
#    echo "Circle Executors Int-Tests: $CIRCLEINTTEST"
#
#    CIRCLEINTTEST2=$(yq e '.jobs.integration_tests.docker[0]' ./.circleci/config.yml)
#    echo "Circle Jobs Int_Tests: $CIRCLEINTTEST2"
#  fi
  echo "---------------------------------------------------------------"
done < "$FILE"
