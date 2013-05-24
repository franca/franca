package org.franca.tools.contracts.tracegen.types;

public class NULL {

	private static final NULL instance = new NULL();

	private NULL() {
	}

	public static NULL getInstance() {
		return instance;
	}

}
