package org.franca.core.validation.trace.search;

import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

public class FrancaTraceElement implements TraceElement {

	private FState from;
	private FState to;
	private FTransition transition;
	
	public FrancaTraceElement(FState from, FTransition transition) {
		this.transition = transition;
		this.from = from;
		this.to = transition.getTo();
	}
	
	public FState getFrom() {
		return from;
	}
	
	public FState getTo() {
		return to;
	}
	
	@Override
	public boolean equals(Object obj) {
		if (obj == this) {
			return true;
		}
		else if (obj == null || this.getClass() != obj.getClass()) {
			return false;
		}
		else {
			FrancaTraceElement trace = (FrancaTraceElement) obj;
			return (trace.from.equals(this.from) && (trace.transition.equals(this.transition)));
		}
	}
	
	@Override
	public int hashCode() {
		int result = 37;
		result = 37 * result + from.hashCode();
		result = 37 * result + transition.hashCode();
		return result;
	}
	
	@Override
	public String getName() {
		return "("+from.getName()+"->"+transition.getTo().getName()+")";
	}
}
