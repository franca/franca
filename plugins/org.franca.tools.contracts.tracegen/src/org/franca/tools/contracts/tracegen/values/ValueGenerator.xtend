/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.values

import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FEnumerationType
import org.franca.tools.contracts.tracegen.values.simple.SimpleValueGenerator
import org.franca.core.franca.FCompoundType
import org.franca.tools.contracts.tracegen.values.complex.ComplexValue
import org.franca.tools.contracts.tracegen.values.complex.CompoundValue
import org.franca.tools.contracts.tracegen.values.complex.EnumValue

class ValueGenerator {
	
	private SimpleValueGenerator vgen
	
	new (SimpleValueGenerator valueGenerator) {
		this.vgen = valueGenerator
	}
	
	def Object createActualValue(FTypedElement it) {
		createActualValue(it.type)
	}
	
	def Object createActualValue(FTypeRef it) {
		if (it.predefined != null && it.predefined != FBasicTypeId::UNDEFINED) {
			vgen.createInitializedSimpleValue(it.predefined)
		} else {
			createActualComplexValueInternal(it.derived)
		}
	}
	
	def private dispatch ComplexValue createActualComplexValueInternal(FType type) {
		throw new IllegalArgumentException("Not yet implemented: Creating random java values for " + type.name)
	}
	
	def private dispatch ComplexValue createActualComplexValueInternal(FEnumerationType enumType) {
		return (new EnumValue() => [value = enumType.enumerators.head])
	}
	
	def private dispatch ComplexValue createActualComplexValueInternal(FCompoundType struct) {
		val actualValues = newHashMap
		//TODO take respect of arrays
		//TODO take respect of base!!
		struct.elements.forEach[
			actualValues.put(it, createActualValue(type))
		]
		val result = new CompoundValue(actualValues)
		
		return result
	}
	
	
}