package org.franca.core.util.search.regexp;

public class ClosureElement extends CompoundElement {
	
	public ClosureElement(RegexpElement... elements) {
		super(elements);
	}
	
	@Override
	public String toString() {
		return "("+elements[0]+"*)";
	}

}
