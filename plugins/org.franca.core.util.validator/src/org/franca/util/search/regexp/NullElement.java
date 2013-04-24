package org.franca.util.search.regexp;

public class NullElement extends RegexpElement {

	public static NullElement INSTANCE = new NullElement();
	
	private NullElement() {
		
	}
	
	@Override
	public String toString() {
		return "0";
	}
	
}
