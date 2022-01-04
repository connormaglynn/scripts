#!/bin/bash

# this script depends on the following being installed:
# - yq
# - jq
# - git

SERVICES=${1:?"missing arg 1 for SERVICES"}

FILE=~/git/scripts/services/kotlin/$SERVICES.txt

set -eu

while read -r line; do

  source git-checkout-clean-main.sh "$line"

  # determine kotlin or java build line
  if test -f "$HOME/git/$line/build.gradle.kts"
  then
    GRADLE_FILE=./build.gradle.kts
  else
    GRADLE_FILE=./build.gradle
  fi

  echo "$line"
  DOCKERFILE=$(grep "FROM openjdk:" < ./Dockerfile)
  echo "Dockerfile: $DOCKERFILE"

  GRADLE=$(grep "jvmTarget" < $GRADLE_FILE)
  echo "Gradle: $GRADLE"

  KOTLIN=$(grep "kotlin(\"plugin.spring\")" < $GRADLE_FILE)
  echo "Kotlin: $KOTLIN"

  HMPPS_ORB=$(grep -A1 'hmpps/java' ./.circleci/config.yml || echo "null")
  if [ "$HMPPS_ORB" != "null" ]; then
    echo "Hmpps Orb: $HMPPS_ORB"
  else
    # These need to be standardised across services to use the parameterized method above
    CIRCLEBUILDER=$(yq e '.executors.builder.docker[0]' ./.circleci/config.yml)
    echo "Circle Builder: $CIRCLEBUILDER"

    CIRCLEVALIDATOR=$(yq e '.executors.validator.docker[0]' ./.circleci/config.yml)
    echo "Circle Validator: $CIRCLEVALIDATOR"

    CIRCLEINTTEST=$(yq e '.executors.integration-tests.docker[0]' ./.circleci/config.yml)
    echo "Circle Executors Int-Tests: $CIRCLEINTTEST"

    CIRCLEINTTEST2=$(yq e '.jobs.integration_tests.docker[0]' ./.circleci/config.yml)
    echo "Circle Jobs Int_Tests: $CIRCLEINTTEST2"
  fi

  echo "---------------------------------------------------------------"
done < "$FILE"
