package org.franca.util.search.regexp;

public class AndElement extends CompoundElement {

	public AndElement(RegexpElement... elements) {
		super(elements);
	}
	
	@Override
	public String toString() {
		return "("+elements[0].toString()+"."+elements[1].toString()+")";
	}
	
}
