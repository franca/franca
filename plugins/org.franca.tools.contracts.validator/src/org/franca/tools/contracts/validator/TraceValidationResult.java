/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.validator;

import java.util.List;
import java.util.Set;

import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FTransition;

/**
 * The class represents the result of a trace validation. 
 * It contains the actual result as a boolean 'valid' flag.  
 * In case of an invalid trace:
 * <br/>
 * - the processed {@link List} contains the processed events, and the last element is where the trace resulted in a mismatch against the contract
 * <br/>
 * - the expected {@link Set} contains those {@link FTransition}s which should have occurred at the last event of the processed {@link List}
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public class TraceValidationResult {

	public static TraceValidationResult TRUE = new TraceValidationResult(true);
	public static TraceValidationResult FALSE = new TraceValidationResult(true);
	
	public boolean valid;
	public Set<FTransition> expected;
	public List<FEventOnIf> processed;
	
	public TraceValidationResult(boolean isValid) {
		super();
		this.valid = isValid;
	}

	public TraceValidationResult(boolean isValid, Set<FTransition> expected, List<FEventOnIf> processed) {
		super();
		this.valid = isValid;
		this.expected = expected;
		this.processed = processed;
	}
	
}
