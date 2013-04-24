package org.franca.util.search.regexp;

public class OrElement extends CompoundElement {

	public OrElement(RegexpElement... elements) {
		super(elements);
	}
	
	@Override
	public String toString() {
		if (elements.length == 0) {
			return "(|)";
		}
		else if (elements.length == 1) {
			return "("+elements[0]+")";
		}
		else {
			return "("+elements[0].toString()+"|"+elements[1].toString()+")";
		}
	}
	
}
