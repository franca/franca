/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.validator;

import java.util.Set;

import org.franca.core.franca.FTransition;

/**
 * The class represents the result of a trace validation. It contains the actual
 * result as a boolean 'valid' flag. In case of an invalid trace: <br/>
 * - the traceElementIndex indicates the position where the mismatch against the
 * contract occurred <br/>
 * - the expected {@link Set} contains those {@link FTransition}s which may have
 * occurred at traceElementIndex if the trace would have been a valid one
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public class TraceValidationResult {

	public static TraceValidationResult TRUE = new TraceValidationResult(true);
	public static TraceValidationResult FALSE = new TraceValidationResult(true);

	public boolean valid;
	public Set<FTransition> expected;
	public int traceElementIndex;

	public TraceValidationResult(boolean isValid) {
		this(isValid, null, -1);
	}
	
	public TraceValidationResult(boolean isValid, int traceElementIndex) {
		this(isValid, null, traceElementIndex);
	}

	public TraceValidationResult(boolean isValid, Set<FTransition> expected, int traceElementIndex) {
		super();
		this.valid = isValid;
		this.expected = expected;
		this.traceElementIndex = traceElementIndex;
	}

}
