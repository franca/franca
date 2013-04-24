package org.franca.util.search.regexp;

public abstract class CompoundElement extends RegexpElement {
	
	public RegexpElement[] elements;
	
	public CompoundElement(RegexpElement... elements) {
		this.elements = elements;
	}
	
	public RegexpElement[] getElements() {
		return elements;
	}
}
