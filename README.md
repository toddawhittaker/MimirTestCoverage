# MimirTestCoverage
A script for evaluating code coverage for student written JUnit tests in MimirHQ

Mimir is an excellent tool for teaching computer science. However, I prefer teaching
using test-driven development and awarding marks for student code coverage. There is
currently no capability for this. However by combining my [MimirTestRunner](https://github.com/toddawhittaker/MimirTestRunner) with a little JaCoCo magic, we can get
coverage statistics.

This little repo solves that problem and lets you calculate scores based on student test coverage
of their own (or your) program code. 

## How to use
1. Create a new "Code Question" in Mimir.
1. Create your solution code and starter code as usual.
1. For grading, click "Add Test Case"
1. On the grading screen, name your test case and assign the *full* points
for the problem
1. Select a "Custom Test Case" for the test case type.
1. Turn on "Allow partial credit"
1. Drag and drop any supplemental Java or JAR files into the Files area
(these will be added to the classpath)
1. Paste the following test script into the Bash script area:  
```bash
# To use this script:
#   Add files containing the code you want students to test
#   (file names must not match ".*Test.java$" regex) and
#   any other jar files or java files you want to compile
#   or include in the classpath. You could also wget
#   those file from a github source.

wget -q https://raw.githubusercontent.com/toddawhittaker/MimirTestCoverage/master/MimirTestRunner.sh
source ./MimirTestRunner.sh
```  
  
  Alternately, you could directly paste in the contents of `MimirTestRunner.sh` from the repo.

Make sure students are submitting files that match the regex ```.*Test.java$``` in order for them
to be run. Coverage on test files is ignored.

That's it. The `MimirTestRunner.sh` will grab the test runner and required JUnit
and JaCoCo libraries from this repo. It will compile all the Java files and run those that
are test cases to collect coverage data (right now it's lines + branches). It will output
the percentage of coverage to form the grade.

Happy unit testing!