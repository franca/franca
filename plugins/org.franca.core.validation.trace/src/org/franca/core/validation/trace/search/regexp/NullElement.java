package org.franca.core.validation.trace.search.regexp;

public class NullElement extends RegexpElement {

	public static NullElement INSTANCE = new NullElement();
	
	private NullElement() {
		
	}
	
	@Override
	public String toString() {
		return "0";
	}
	
}
