package org.franca.core.dsl.tests.util;

/**
 * A tool for comparing Java files (e.g., generated vs. reference).
 * 
 * @author Klaus Birken (initial contribution)
 */
public class JavaFileComparer extends FileComparer {

	protected boolean skipLine (String line) {
		if (super.skipLine(line))
			return true;
		if (line.matches("^\\s*//.*$"))
			return true;
		return false;
	}

	protected boolean skipRegionStart (String line) {
		boolean m = line.matches("^\\s*/\\*(\\*)?");
		return m;
	}

	protected boolean skipRegionEnd (String line) {
		boolean m = line.matches("^\\s*\\*/");
		return m;
	}


}
