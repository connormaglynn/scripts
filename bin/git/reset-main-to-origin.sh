#!/bin/bash
set -e
for file in $(cat ~/git/scripts/services/kotlin/soct.txt);
do
    echo "Starting reset for $file"
    cd ~/git/$file

    echo "Stashing any changes"
    git stash

    echo "Checking out main"
    git checkout main

    echo "Pulling main"
    git pull

    echo "resetting main"
    git fetch origin
    git reset --hard origin/main
    git diff main origin/main

    echo "---------------------------------------------------------------"
done
