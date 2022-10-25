#!/bin/bash
set -eu

TICKET=${1:?"missing arg 1 for TICKET"}
VERSION=${2:?"missing arg 2 for VERSION"}
SERVICES=${3:?"missing arg 3 for SERVICES"}
COMMIT=${4:-false}
PR=${5:-false}

BRANCH_NAME="$TICKET-bump-gradle-spring-boot-version"
MESSAGE="Bump gradle-spring-boot version to $VERSION"

while read -r line;
do
  source git-checkout-clean-main.sh "$line"

  echo "updating $line to version $VERSION"
  sed -i "" "s/.*uk.gov.justice.hmpps.gradle-spring-boot.*/  id(\"uk.gov.justice.hmpps.gradle-spring-boot\") version \"$VERSION\"/" ./build.gradle.kts

  ./gradlew clean build

  source git-commit-to-branch.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$COMMIT"
  source git-create-pr.sh "$TICKET" "$MESSAGE" "$BRANCH_NAME" "$PR"

  echo "---------------------------------------------------------------"
done < ~/git/scripts/services/kotlin/"$SERVICES".txt
