import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;
import org.junit.internal.TextListener;
import org.junit.runner.notification.Failure;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Pattern;
import java.io.File;

/**
 * Write a description of class MyTestRunner here.
 *
 * @author (your name)
 * @version (a version number or a date)
 */
public class MimirTestRunner {
    public static void main(String [] args) {
        MimirTestRunner testRunner = new MimirTestRunner();
        if (args.length == 0) {
            File dir = new File(".");
            File [] fileList = dir.listFiles();
            for (File file : fileList) {
                String fileName = file.getName();
                if (file.isFile()
                && Pattern.matches(".*Test\\.java$", fileName)
                && !Pattern.matches(".*Abstract.*", fileName)) {
                    String className = fileName.substring(0, fileName.lastIndexOf(".java"));
                    testRunner.runTestClass(className);
                }
            }
        } else {
            for (String arg : args) {
                testRunner.runTestClass(arg);
            }
        }
        testRunner.printResults();
        System.exit(testRunner.getScore());
    }

    private JUnitCore junitCore;
    private Map<String, Result> results;
    private int runs;
    private int fails;

    public MimirTestRunner() {
        junitCore = new JUnitCore();
        results = new HashMap<String, Result>();
    }

    public void runTestClass(String className) {
        try {
            Class testClass = Class.forName(className);
            Result result = junitCore.run(testClass);
            runs += result.getRunCount();
            fails += result.getFailureCount();
            results.put(className, result);
        } catch (ClassNotFoundException ex) {
            System.out.println("Could not find class " + ex.getMessage());
        }
    }

    private String niceTrace(Throwable t, String stopLine) {
        final String INDENT = "     ";
        boolean foundStop = false;
        StringBuilder builder = new StringBuilder();
        StackTraceElement [] trace = t.getStackTrace();

        if (!t.getClass().equals(java.lang.AssertionError.class)) {
            builder.append(INDENT);
            builder.append(t.getClass().getName());
            builder.append("\n");
        }

        for (StackTraceElement call : trace) {
            String line = call.toString();

            if (line.contains(stopLine)) {
                if (!foundStop) {
                    foundStop = true;
                }
            } else if (foundStop) {
                break;
            }
            if (!line.contains("org.junit.Assert")) {
                builder.append(INDENT).append(INDENT).append("at ");
                builder.append(line);
                builder.append("\n");
            }

        }
        return builder.toString();
    }

    public void printResults() {
        System.out.println("\nTest Results:\n");
        int count = 0;
        for (String className : results.keySet()) {
            Result result = results.get(className);
            List<Failure> failures = result.getFailures();
            for (Failure failure : failures) {
                String reason = failure.getMessage();
                String trace = niceTrace(failure.getException(), className);
                String errorText = "FAILED UNIT TEST";
                if (!failure.getException().getClass().equals(java.lang.AssertionError.class)) {
                    errorText = "ERROR IN YOUR CODE";
                }

                System.out.println(String.format(
                        "%d. %s - %s:",
                        ++count,
                        errorText,
                        failure.getTestHeader()));
                if (reason != null) {
                    System.out.println("     " + reason);
                }
                System.out.println(trace);
            }
        }
		int passed = runs - fails < 0 ? 0 : runs - fails;
        System.out.println(String.format(
                "%d of %d tests passed. Your score is %d%%",
                passed, runs, getScore()));

    }

    public int getScore() {
        int score = (int)Math.round(((double)runs-fails)/runs*100);
		if (score < 0) {
			score = 0;
		}
		return score;
    }
}
