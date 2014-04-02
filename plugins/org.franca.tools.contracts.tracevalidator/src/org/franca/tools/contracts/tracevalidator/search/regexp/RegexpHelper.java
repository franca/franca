/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.search.regexp;

public class RegexpHelper {

	/**
	 * Concatenation rule
	 * 
	 * r * e = e * r = r
	 * r * 0 = 0 * r = 0
	 * 
	 * @param e1 the left hand regexp element
	 * @param e2 the right hand regexp element
	 * @return the concatenation of the two regexp elements
	 */
	public static RegexpElement and(RegexpElement e1, RegexpElement e2) {
		if (e1 instanceof NullElement || e2 instanceof NullElement) {
			return NullElement.INSTANCE;
		}
		if (e1 instanceof EmptyElement) {
			return e2;
		}
		else if (e2 instanceof EmptyElement) {
			return e1;
		}
		else {
			return new AndElement(e1, e2);
		}
	}
	
	/**
	 * Union rule
	 * 
	 * r + 0 = 0 + r = r
	 * r + r = r 
	 * 
	 * @param e1 the left hand regexp element
	 * @param e2 the right hand regexp element
	 * @return the union of the two regexp elements
	 */
	public static RegexpElement union(RegexpElement e1, RegexpElement e2) {
		if (e1 instanceof NullElement) {
			return e2;
		}
		else if (e2 instanceof NullElement) {
			return e1;
		}
		else if (e1.equals(e2)) {
			return e1;
		}
		else {
			return new UnionElement(e1, e2);
		}
	}
	
	
	/**
	 * closure(e) = closure(0) = e
	 * 
	 * @param e1 the regexp element
	 * @return the closure of the regexp element
	 */
	public static RegexpElement closure(RegexpElement e1) {
		if (e1 instanceof NullElement || e1 instanceof EmptyElement) {
			return EmptyElement.INSTANCE;
		}
		else {
			return new ClosureElement(e1);
		}
	}
	
}
