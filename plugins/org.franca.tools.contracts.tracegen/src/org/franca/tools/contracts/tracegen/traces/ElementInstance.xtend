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
//	boolean isPrimitive
	
	new(FTypedElement element, Object actualValue) {
		this.element = element
//		this.isPrimitive = element.type.derived == null		
		this.value = actualValue//getSimulatedValue(element.type)
	}
//	new(FArgument arg, EventData triggeringEvent) {
//		this.element = arg
//		this.isPrimitive = arg.type.derived == null		
//		this.value = triggeringEvent.getActualValue(arg)
//	}
	
	private new() {}
	
	def private copy(Object value) {
		ValueCopier::copy(value)
	}
	
	def ElementInstance copy() {
		val result = new ElementInstance
		result.element = this.element
		result.value = copy(this.value)
//		result.isPrimitive = this.isPrimitive
		return result
	}
	
	
	def setValue(Object object) {
//		if (isPrimitive) {
			value = object
//		} else {
//			(value as SimulatedValue).setValue(object)
//			throw new UnsupportedOperationException
//		}
	}
	
	def getValue() {
//		if (isPrimitive) {
			return value
//		} else {
//			return (value as SimulatedValue).getValue
//			throw new UnsupportedOperationException
//		}
	}
}