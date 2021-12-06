for file in $(cat ~/bin/apps.txt); 
do 
    echo processing: ${file}
    cd ~/git/$file
    sed -i "" 's/.*uk.gov.justice.hmpps.gradle-spring-boot.*/  id("uk.gov.justice.hmpps.gradle-spring-boot") version "3.3.6"/' ./build.gradle.kts
    cd ~/
done