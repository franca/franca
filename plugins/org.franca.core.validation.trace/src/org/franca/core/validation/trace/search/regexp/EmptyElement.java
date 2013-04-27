package org.franca.core.validation.trace.search.regexp;

public class EmptyElement extends RegexpElement {

	public static EmptyElement INSTANCE = new EmptyElement();
	
	private EmptyElement() {
		
	}
	
	@Override
	public String toString() {
		return "€";
	}
}
