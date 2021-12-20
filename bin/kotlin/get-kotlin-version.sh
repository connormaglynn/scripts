#!/bin/bash
FILE=${1-kotlin services}

LOG_FILE=~/Desktop/versions.txt

set -e

while read -r line;
do
    cd ~/git
    if [ ! -d "$HOME/git/$line" ]
    then
        git clone "https://github.com/ministryofjustice/$line.git" &> /dev/null
    fi

    echo processing: "$line"
    {
      cd ~/git/"$line"
      git stash
      git checkout main
      git pull
    } &> /dev/null

    # determine kotlin or java build line
    if test -f "$HOME/git/$line/build.gradle.kts"
    then
      GRADLE_FILE=build.gradle.kts
    else
      GRADLE_FILE=build.gradle
    fi

    echo "$line" >> ~/Desktop/versions.txt
    grep "kotlin(\"plugin.spring\")" >> $LOG_FILE < ./$GRADLE_FILE
done < "$FILE"

cat $LOG_FILE
rm $LOG_FILE
