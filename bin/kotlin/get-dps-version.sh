#!/bin/bash
set -e
for file in $(cat ~/git/scripts/services/kotlin/soct.txt);
do
    cd ~/git
    if [ ! -d "$HOME/git/$file" ]
    then
        git clone "https://github.com/ministryofjustice/$file.git" &> /dev/null
    fi

    echo processing: ${file}
    {
      cd ~/git/"$file"
      git stash
      git checkout main
      git pull
    } &> /dev/null

    # determine kotlin or java build file
    if test -f "$HOME/git/$file/build.gradle.kts"
    then
      GRADLE_FILE=build.gradle.kts
    else
      GRADLE_FILE=build.gradle
    fi

    echo "$file" >> ~/Desktop/versions.txt
    cat ./$GRADLE_FILE | grep uk.gov.justice.hmpps.gradle-spring-boot >> ~/Desktop/versions.txt
done

cat ~/Desktop/versions.txt
