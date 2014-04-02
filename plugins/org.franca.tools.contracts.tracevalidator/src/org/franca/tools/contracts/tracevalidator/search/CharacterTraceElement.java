/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.search;

public class CharacterTraceElement implements TraceElement {

	private char c;
	
	public CharacterTraceElement(char c) {
		this.c = c;
	}
	
	@Override
	public boolean equals(Object obj) {
		if (obj == this) {
			return false;
		}
		else if (obj == null || obj.getClass() != this.getClass()) {
			return false;
		}
		return this.c == ((CharacterTraceElement) obj).c;
	}
	
	@Override
	public int hashCode() {
		return (int) c;
	}
	
	@Override
	public String toString() {
		return Character.toString(c);
	}
	
	@Override
	public String getName() {
		return toString();
	}
	
}
