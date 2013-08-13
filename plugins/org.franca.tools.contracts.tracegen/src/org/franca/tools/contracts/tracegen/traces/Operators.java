/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.traces;

public class Operators {
	public Number operator_plus(Number left, Number right) {
		if (left instanceof Byte) {
			return ((Byte) left) + ((Byte) right);
		}
		if (left instanceof Short) {
			return ((Short) left) + ((Short) right);
		}
		if (left instanceof Integer) {
			return ((Integer) left) + ((Integer) right);
		}
		if (left instanceof Long) {
			return ((Long) left) + ((Long) right);
		}
		if (left instanceof Float) {
			return ((Float) left) + ((Float) right);
		}
		if (left instanceof Double) {
			return ((Double) left) + ((Double) right);
		}
		throw new UnsupportedOperationException();
	}
	public Number operator_minus(Number left, Number right) {
		if (left instanceof Byte) {
			return ((Byte) left) - ((Byte) right);
		}
		if (left instanceof Short) {
			return ((Short) left) - ((Short) right);
		}
		if (left instanceof Integer) {
			return ((Integer) left) - ((Integer) right);
		}
		if (left instanceof Long) {
			return ((Long) left) - ((Long) right);
		}
		if (left instanceof Float) {
			return ((Float) left) - ((Float) right);
		}
		if (left instanceof Double) {
			return ((Double) left) - ((Double) right);
		}
		throw new UnsupportedOperationException();
	}
	public Number operator_multiply(Number left, Number right) {
		if (left instanceof Byte) {
			return ((Byte) left) * ((Byte) right);
		}
		if (left instanceof Short) {
			return ((Short) left) * ((Short) right);
		}
		if (left instanceof Integer) {
			return ((Integer) left) * ((Integer) right);
		}
		if (left instanceof Long) {
			return ((Long) left) * ((Long) right);
		}
		if (left instanceof Float) {
			return ((Float) left) * ((Float) right);
		}
		if (left instanceof Double) {
			return ((Double) left) * ((Double) right);
		}
		throw new UnsupportedOperationException();
	}
	public Number operator_divide(Number left, Number right) {
		if (left instanceof Byte) {
			return ((Byte) left) / ((Byte) right);
		}
		if (left instanceof Short) {
			return ((Short) left) / ((Short) right);
		}
		if (left instanceof Integer) {
			return ((Integer) left) / ((Integer) right);
		}
		if (left instanceof Long) {
			return ((Long) left) / ((Long) right);
		}
		if (left instanceof Float) {
			return ((Float) left) / ((Float) right);
		}
		if (left instanceof Double) {
			return ((Double) left) / ((Double) right);
		}
		throw new UnsupportedOperationException();
	}
}
