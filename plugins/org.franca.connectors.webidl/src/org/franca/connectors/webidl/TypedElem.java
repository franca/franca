package org.franca.connectors.webidl;

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
