/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.values.complex;

import java.util.HashMap;
import java.util.Map;

import org.franca.core.franca.FField;

import org.franca.tools.contracts.tracegen.values.ValueCopier

public class CompoundValue extends ComplexValue {
	
	private HashMap<FField, Object> actualFieldValues = newHashMap();
	
	new(Map<FField, Object> actualValues) {
		this.actualFieldValues.putAll(actualValues);
	}
	
	new() {
		//intentionally left empty
	}
	
	def public void setValue(FField field, Object value) {
		actualFieldValues.put(field, value);
	}
	
	def public Object getValue(FField field) {
		return actualFieldValues.get(field);
	}

	override copy() {
		val copiedActuals = newHashMap(this.actualFieldValues.entrySet.map[key -> ValueCopier::copy(value)])
		
		val result = new CompoundValue(copiedActuals)
		
		return result
	}

}
