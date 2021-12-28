#!/bin/bash
set -e

KOTLIN_SERVICES=${1-kotlin services}

FILE="/Users/connorglynn/git/scripts/services/kotlin/$KOTLIN_SERVICES.txt"

while read -r line;
do
  source git-checkout-clean-main.sh "$line"

  echo "$line"
  # determine kotlin or java build line
  if test -f "$HOME/git/$line/build.gradle.kts"
  then
    GRADLE_FILE=build.gradle.kts
  else
    GRADLE_FILE=build.gradle
  fi

  grep uk.gov.justice.hmpps.gradle-spring-boot < ./$GRADLE_FILE

  echo "---------------------------------------------------------------"
done < "$FILE"
