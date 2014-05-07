/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.search;

import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

/**
 * Represents a trace element in the Franca contract. 
 * A trace element has a start and an end {@link FState} and an associated {@link FTransition} between these states. 
 * 
 * @author Tamas Szabo
 *
 */
public interface TraceElement {

	public String getName();
}
