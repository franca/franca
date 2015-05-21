package org.franca.core.dsl.tests.util;

/**
 * A configurable tool for comparing generated and reference source files.
 * It is less detailed than EMF Compare and more convenient than a plain string compare.
 * 
 * @author KLaus Birken (initial contribution)
 */
public class FileComparer {

	private static final boolean verbose = false;
			
	private static final String LINE_SEPARATOR = System.getProperty("line.separator");

	public class Conflict {
		public int lineExpected;
		public int lineActual;
		public String expected;
		public String actual;
		
		Conflict(int le, int la, String se, String sa) {
			lineExpected = le+1;
			lineActual = la+1;
			expected = se;
			actual = sa;
		}
	}

	public Conflict checkEqual (String expected, String actual) {
		String[] expectedLines = expected.split(LINE_SEPARATOR);
		String[] actualLines = actual.split(LINE_SEPARATOR);
		
		int ie=0, ia=0;
		while (ie<expectedLines.length && ia<actualLines.length) {
			ie = proceed(expectedLines, ie, "E");
			ia = proceed(actualLines, ia, "A");
			
			if (ie<expectedLines.length && ia<actualLines.length) {
				String le = prepare(expectedLines[ie]);
				String la = prepare(actualLines[ia]);
				if (! le.equals(la))
					return new Conflict(ie, ia, le, la);
				ie++;
				ia++;
			}
		}
		
		// eat trailing empty lines
		if (ie<expectedLines.length) {
			ie = proceed(expectedLines, ie, "E");
		}
		if (ia<actualLines.length) {
			ia = proceed(actualLines, ia, "A");
		}

		// check remaining lines in one of the files
		if (ie<expectedLines.length) {
			return new Conflict(ie, -1, expectedLines[ie], null);
		}
		if (ia<actualLines.length) {
			return new Conflict(-1, ia, null, actualLines[ia]);
		}
		return null;
	}

	private int proceed (final String[] text, final int idx, String which) {
		int i = idx;
		int j = i;
		do {
			j = i;
			
			// skip over empty lines
			while (i<text.length && skipLine(text[i])) {
				i++;
			}
			if (verbose && i>j)
				System.out.println(which + ": skipped empty: " + (j+1) + " -> " + (i+1));
	
			// skip over comments etc.
			int i0 = i;
			if (i<text.length && skipRegionStart(text[i])) {
				do {
					i++;
				} while (i<text.length && !skipRegionEnd(text[i]));
				if (i<text.length)
					i++;
			}
			if (verbose && i>i0)
				System.out.println(which + ": skipped other: " + (i0+1) + " -> " + (i+1));

		} while (i<text.length && j<i);
		
		return i;
	}

	protected String prepare (String line) {
		return line.replaceAll("\\t", "    ");
	}

	protected boolean skipLine (String line) {
		if (line.matches("^\\s*$"))
			return true;
		return false;
	}

	protected boolean skipRegionStart (String line) {
		return false;
	}

	protected boolean skipRegionEnd (String line) {
		return false;
	}
}
