package org.franca.core.validation.trace.search.regexp;

import org.franca.core.validation.trace.search.TraceElement;

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
