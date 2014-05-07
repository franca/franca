/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.search.regexp;

import org.franca.tools.contracts.tracevalidator.search.TraceElement;

public class SingleElement extends RegexpElement {

	private TraceElement element;
	
	public SingleElement() {
		this.element = null;
	}
	
	public SingleElement(TraceElement element) {
		this.element = element;
	}
	
	public TraceElement getElement() {
		return element;
	}
	
	@Override
	public String toString() {
		return element.toString();
	}
}
