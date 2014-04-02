/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.search.regexp;

public class NullElement extends RegexpElement {

	public static NullElement INSTANCE = new NullElement();
	
	private NullElement() {
		
	}
	
	@Override
	public String toString() {
		return "0";
	}
	
}
