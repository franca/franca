/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.traces

import org.franca.core.franca.FTypedElement
import org.franca.tools.contracts.tracegen.values.ValueCopier

class ElementInstance {
	
	FTypedElement element
	Object value
	
	new(FTypedElement element, Object actualValue) {
		this.element = element
		this.value = actualValue//getSimulatedValue(element.type)
	}
	
	private new() {}
	
	def private copy(Object value) {
		ValueCopier::copy(value)
	}
	
	def ElementInstance copy() {
		val result = new ElementInstance
		result.element = this.element
		result.value = copy(this.value)
		return result
	}
	
	
	def setValue(Object object) {
		value = object
	}
	
	def getValue() {
		return value
	}
}