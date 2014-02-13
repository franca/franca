package org.franca.core.contracts;

public enum ComparisonResult {
	SMALLER, EQUAL, GREATER, INCOMPATIBLE;
		
	public static ComparisonResult fromInt(int i) {
		if (i < 0) return SMALLER;
		if (i == 0) return EQUAL;
		/*if (i > 0)*/ return GREATER;
		//return INCOMPATIBLE;
	}
}
