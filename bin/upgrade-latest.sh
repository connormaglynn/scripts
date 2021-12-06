sed -i -e 's/spring-boot") version "3.[0-3].[0-9]\(-beta\)*/spring-boot") version "3.3.10/' \
  -e 's/kotlin("\([^"]*\)") version "1.[4-5].[0-9]*/kotlin("\1") version "1.5.31/' build.gradl*
./gradlew wrapper --gradle-version=7.2 --distribution-type=bin
