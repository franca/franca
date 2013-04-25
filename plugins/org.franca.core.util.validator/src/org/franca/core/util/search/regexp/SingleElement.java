package org.franca.core.util.search.regexp;

import org.franca.core.util.search.TraceElement;

public class SingleElement extends RegexpElement {

	private TraceElement element;
	
	public SingleElement() {
		this.element = null;
	}
	
	public SingleElement(TraceElement element) {
		this.element = element;
	}
	
	public TraceElement getElement() {
		return element;
	}
	
	@Override
	public String toString() {
		return element.toString();
	}
}
