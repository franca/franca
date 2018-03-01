package org.franca.deploymodel.dsl.tests;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

import org.franca.core.dsl.tests.util.FileComparer;
import org.franca.core.dsl.tests.util.JavaFileComparer;

import com.itemis.xtext.testing.XtextTest;

public class GeneratorTestBase extends XtextTest {

	private static final String LINE_SEPARATOR = System.getProperty("line.separator");

	protected String readFile(String filename) {
		StringBuilder contents = new StringBuilder();

		try {
			// FileReader reads using default encoding
			BufferedReader input = new BufferedReader(new FileReader(filename));
			try {
				String line = null;
				while ((line = input.readLine()) != null) {
					contents.append(line);
					contents.append(System.getProperty("line.separator"));
				}
			} finally {
				input.close();
			}
		} catch (IOException ex) {
			ex.printStackTrace();
		}

		return contents.toString();
	}

	protected boolean isEqualJava(String expected, String actual) {
		FileComparer fc = new JavaFileComparer();
		return isEqualAux(expected, actual, fc);
	}

	private boolean isEqualAux(String expected, String actual, FileComparer fc) {
		FileComparer.Conflict conflict = fc.checkEqual(expected, actual);
		if (conflict!=null) {
			System.out.println("Files differ:");
			if (conflict.lineExpected != 0)
				System.out.println("  expected (line " + conflict.lineExpected +
						"): /" + conflict.expected + "/");
			else
				System.out.println("  expected: EOF");

			if (conflict.lineActual!=0)
				System.out.println("  actual (line " + conflict.lineActual +
						"):   /" + conflict.actual + "/");
			else
				System.out.println("  actual: EOF");

			return false;
		}
		return true;
	}
	
	protected static void printMultiLine(String input, String title) {
		String[] lines = input.split(LINE_SEPARATOR);
		System.out.println(title);
		for(int i=0; i<lines.length; i++) {
			System.out.println(String.format("%04d ", i+1) + lines[i]);
//			System.out.println(lines[i]);
		}
	}
}
