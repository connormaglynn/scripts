#!/bin/bash
LOG_FILE=~/Desktop/prs-created.txt
TICKET="PAT-2115"
VERSION="3.3.16"
BRANCH_NAME="$TICKET-bump-gradle-spring-boot-version"
COMMIT_MESSAGE="⬆️ $TICKET: Bump gradle-spring-boot version to $VERSION"

set -eu
for file in $(cat ~/git/scripts/services/kotlin/soct.txt);
do
  {
    cd ~/git/"$file"
    git stash
    git checkout main
    git pull
    git checkout -b $BRANCH_NAME
  } &> /dev/null

  echo "updating $file to version $VERSION"
  sed -i "" "s/.*uk.gov.justice.hmpps.gradle-spring-boot.*/  id(\"uk.gov.justice.hmpps.gradle-spring-boot\") version \"$VERSION\"/" ./build.gradle.kts

  echo "Comitting changes for  $file"
  {
    ./gradlew
    cd ~/git/"$file"
    git add .
    git commit -m "$COMMIT_MESSAGE"
  } &> /dev/null

    echo "Creating PR for changes for  $file"
    git push --set-upstream origin $BRANCH_NAME &> /dev/null
    gh pr create --title "$COMMIT_MESSAGE" --body "$COMMIT_MESSAGE" >> $LOG_FILE

    echo "---------------------------------------------------------------"
done

cat $LOG_FILE
