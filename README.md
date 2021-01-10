# MimirTestRunner
A script and support files for running JUnit 4 tests in programming quesions in MimirHQ

Mimir is an excellent tool for teaching computer science. However, their test case  
syntax leaves something to be desired if you've worked with JUnit. You don't have  
access to the assertions that JUnit has, nor the ability to define functions for setUp()  
or tearDown() or any other custome function. It's a fairly severe limitation.  

This little repo solves that problem and lets you run any number of JUnit 4 tests.

## How to use
1. Create a new "Code Question" in Mimir.
1. Create your solution code and starter code as usual.
1. For grading, click "Add Test Case"
1. On the grading screen, name your test case and assign the *full* points
for the problem
1. Select a "Custom Test Case" for the test case type.
1. Turn on "Allow partial credit"
1. Drag and drop any test cases or supplemental JAR files into the Files area
1. Paste the following test script into the Bash script area:  
```bash
# To use this script:
#   Add "Optional" files containing your test cases
#   (file names must macth ".*Test.java$" regex) and
#   any other jar files or java files you want to compile
#   or include in the classpath. You could also wget
#   those file from a github source.

wget -q https://raw.githubusercontent.com/toddawhittaker/MimirTestRunner/master/MimirTestRunner.sh
source ./MimirTestRunner.sh
```  
  
  Alternately, you could directly paste in the contents of `MimirTestRunner.sh` from the repo.


That's it. The `MimirTestRunner.sh` will grab the test runner and required JUnit  
libraries from this repo. It will compile all the Java files and run those that  
are test cases. The exit code from the runner will tell Mimir what percent of the  
test cases pass.

If you want to provide debugging help to students, it's best to give them a message as  
the first parameter to all your calls to `assertXXXX`.

Happy unit testing!