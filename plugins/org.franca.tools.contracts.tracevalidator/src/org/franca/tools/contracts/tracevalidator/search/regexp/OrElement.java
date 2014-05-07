/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.search.regexp;

public class OrElement extends CompoundElement {

	public OrElement(RegexpElement... elements) {
		super(elements);
	}
	
	@Override
	public String toString() {
		if (elements.length == 0) {
			return "(|)";
		}
		else if (elements.length == 1) {
			return "("+elements[0]+")";
		}
		else {
			return "("+elements[0].toString()+"|"+elements[1].toString()+")";
		}
	}
	
}
