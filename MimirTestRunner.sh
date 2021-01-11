#!/bin/bash
wget -q https://raw.githubusercontent.com/toddawhittaker/MimirTestCoverage/master/hamcrest-core-1.3.jar
wget -q https://raw.githubusercontent.com/toddawhittaker/MimirTestCoverage/master/junit-4.13.jar
wget -q https://raw.githubusercontent.com/toddawhittaker/MimirTestCoverage/master/jacocoagent.jar
wget -q https://raw.githubusercontent.com/toddawhittaker/MimirTestCoverage/master/jacococli.jar
wget -q https://raw.githubusercontent.com/toddawhittaker/MimirTestCoverage/master/MimirTestRunner.java

# get rid of old grading files if exist
rm -f DEBUG
rm -f OUTPUT

# move all jar files into lib
mkdir -p lib
mv *.jar lib 2>/dev/null

# build up a nice classpath with all libraries
DIR=$(pwd)
export CLASSPATH=${DIR}/bin
count=$(find lib -type f -name "*.jar" 2>/dev/null | wc -l)
if [ "$count" != 0 ]
then 
  for filename in lib/*.jar; do
    export CLASSPATH=${CLASSPATH}:${DIR}/${filename}
  done
fi

# compile into separate bin directory (part of classpath)
javac -d bin *.java;

# compile error triggers zero grade
if [ $? -ne 0 ]; then
  echo 0 > ${DIR}/OUTPUT
  exit 1
fi

# produce any student output for their own testing
if [ -f "RunMe.java" ]; then
    java RunMe >> ${DIR}/DEBUG
fi

# run test cases instrumented with JaCoCo
java -javaagent:lib/jacocoagent.jar=destfile=results.exec MimirTestRunner >> ${DIR}/DEBUG
status=$?
if [ $status -ne 100 ]; then
  echo 0 > ${DIR}/OUTPUT
  echo "All test cases must pass for coverage score" >> ${DIR}/DEBUG
  exit 1
fi

# produce JaCoCo report as CSV
java -jar lib/jacococli.jar report results.exec --classfiles bin --csv results.csv --sourcefiles . >> ${DIR}/DEBUG
if [ ! -f results.csv ]; then
  echo 0 > ${DIR}/OUTPUT
  echo "No coverage results generated" >> ${DIR}/DEBUG
  exit 1
fi

# ugly Bash processing of CSV file
total=0;
covered=0;
echo "" >> ${DIR}/DEBUG
echo "Coverage results:" >> ${DIR}/DEBUG

IFS=','
while read GROUP PACKAGE CLASS INSTRUCTION_MISSED \
  INSTRUCTION_COVERED BRANCH_MISSED BRANCH_COVERED \
  LINE_MISSED LINE_COVERED COMPLEXITY_MISSED \
  COMPLEXITY_COVERED METHOD_MISSED METHOD_COVERED
do
  # ignore coverage of test classes and the test runner
  if [[ ! ${CLASS} =~ .+Test(Runner)?$ ]]; then
    class_lines=$(($LINE_MISSED+$LINE_COVERED))
    class_branch=$(($BRANCH_MISSED+$BRANCH_COVERED))
    covered=$(($covered+$LINE_COVERED+BRANCH_COVERED))
    total=$(($total+$class_lines+$class_branch))
    echo "  Class $CLASS" >> ${DIR}/DEBUG
    echo "    $LINE_COVERED of $class_lines lines covered" >> ${DIR}/DEBUG
    echo "    $BRANCH_COVERED of $class_branch branches covered" >> ${DIR}/DEBUG
  fi
done < <(tail -n +2 results.csv)

pct=0
if [ $total -ne 0 ]; then
  pct=$(($covered*100/$total))
fi

echo "" >> ${DIR}/DEBUG
echo "$covered of $total elements covered. Your score is $pct%" >> ${DIR}/DEBUG

# produce final grade
echo "$pct" > ${DIR}/OUTPUT