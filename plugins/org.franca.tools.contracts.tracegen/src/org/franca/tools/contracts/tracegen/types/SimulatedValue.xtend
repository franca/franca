package org.franca.tools.contracts.tracegen.types

abstract class SimulatedValue {

	protected static final NULL nil = NULL::getInstance();

	def protected Object getDefault(Class<?> type) {
		if (typeof(String).equals(type)) {
			return "";
		}
		if (typeof(Boolean).equals(type)) {
			return false;
		}
		if (typeof(Number).isAssignableFrom(type)) {
			return 0;
		}
		return nil;
	}
	
}
