#!/bin/bash
set -e
for file in $(cat ~/git/scripts/services/kotlin/dps-shared.txt);
do
    BRANCH_NAME="DCS-1361-add-trivyIgnore-log4j"
    COMMIT_MESSAGE="🔐 DCS-1361: Bump gradle-spring-boot to 3.3.14 - Add trivyignore for log4j false positive"

    echo "Starting update for $file"
    cd ~/git/$file

    echo "Stashing any changes"
    git stash

    echo "Checking out main"
    git checkout main

    echo "Pulling main"
    git pull

    echo "Checking out a branch for $file"
    git checkout -b $BRANCH_NAME

    echo "updating plugin"
    sed -i "" 's/.*uk.gov.justice.hmpps.gradle-spring-boot.*/  id("uk.gov.justice.hmpps.gradle-spring-boot") version "3.3.14"/' ./build.gradle.kts >> ~/Desktop/output.txt

    echo "Comitting changes for  $file"
    ./gradlew
    cd ~/git/$file
    git add .
    git commit -m "$COMMIT_MESSAGE"

    echo "Creating PR for changes for  $file"
    git push --set-upstream origin $BRANCH_NAME
    gh pr create --title "$COMMIT_MESSAGE" --body "$COMMIT_MESSAGE" >> ~/Desktop/prs-created.txt

    echo "---------------------------------------------------------------"
done
