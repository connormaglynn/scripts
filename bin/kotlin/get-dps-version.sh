#!/bin/bash
set -e
for file in $(cat ~/git/scripts/services/kotlin/dps-shared.txt);
do 
    echo processing: ${file}
    cd ~/git/$file
    cat ./build.gradle.kts | grep uk.gov.justice.hmpps.gradle-spring-boot
    cd ~/
done
