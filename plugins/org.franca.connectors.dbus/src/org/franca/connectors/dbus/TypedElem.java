/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.dbus;

import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FrancaFactory;

/**
 * Helper class used for DBus=>Franca transformation.
 */ 
public class TypedElem {
	private final FTypeRef type;
	private final boolean isArray;
	
	public TypedElem() {
		this.type = FrancaFactory.eINSTANCE.createFTypeRef();
		this.isArray = false;
	}

	public TypedElem (FTypeRef type) {
		this.type = type;
		this.isArray = false;
	}
	
	public TypedElem (FTypeRef type, boolean isArray) {
		this.type = type;
		this.isArray = true;
	}
	
	public FTypeRef getType() {
		return type;
	}
	
	public boolean isArray() {
		return isArray;
	}
}
