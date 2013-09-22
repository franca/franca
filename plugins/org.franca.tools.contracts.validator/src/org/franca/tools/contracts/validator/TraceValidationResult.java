package org.franca.tools.contracts.validator;

import java.util.Set;

import org.franca.core.franca.FTransition;

public class TraceValidationResult {

	public static TraceValidationResult TRUE = new TraceValidationResult(true);
	public static TraceValidationResult FALSE = new TraceValidationResult(true);
	public boolean isValid;
	public Set<FTransition> expected;
	
	public TraceValidationResult(boolean isValid) {
		super();
		this.isValid = isValid;
	}

	public TraceValidationResult(boolean isValid, Set<FTransition> expected) {
		super();
		this.isValid = isValid;
		this.expected = expected;
	}
	
}
