/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.validation

import java.util.List
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FField
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.core.FDPropertyHost
import org.franca.deploymodel.dsl.FDSpecificationExtender

import static org.franca.deploymodel.dsl.fDeploy.FDBuiltInPropertyHost.*

import static extension org.franca.core.framework.FrancaHelpers.*

/**
 * Compute if a given Franca IDL element has to be defined in
 * a deployment definition because of mandatory deployment properties.
 * 
 * This is a helper class for Franca deployment validation. It uses a
 * specification extender in order to get information about which 
 * property hosts are mandatory according to a deployment specification.
 */
class PropertyDefChecker {
	
	FDSpecificationExtender specHelper
		
	new (FDSpecificationExtender specHelper) {
		this.specHelper = specHelper
	}
	
	// *****************************************************************************

	def mustBeDefined (FMethod it) {
		if (specHelper.isMandatory(METHODS)) return true
		if (inArgs.empty && outArgs.empty) return false
		if (specHelper.isMandatory(ARGUMENTS)) return true
		if (inArgs.findFirst[mustBeDefined()]!==null) return true
		if (outArgs.findFirst[mustBeDefined()]!==null) return true
		false
	}
	
	def mustBeDefined (FBroadcast it) {
		if (specHelper.isMandatory(BROADCASTS)) return true
		if (outArgs.empty) return false
		if (specHelper.isMandatory(ARGUMENTS)) return true
		if (outArgs.findFirst[mustBeDefined()]!==null) return true
		false
	}
	
	def mustBeDefined (FArrayType it) {
		specHelper.isMandatory(ARRAYS)
	}
	
	def mustBeDefined (FStructType it) {
		if (specHelper.isMandatory(STRUCTS)) return true
		elements.mustBeDefined(FDPropertyHost.builtIn(STRUCT_FIELDS))
	}
	
	def mustBeDefined (FUnionType it) {
		if (specHelper.isMandatory(UNIONS)) return true
		elements.mustBeDefined(FDPropertyHost.builtIn(UNION_FIELDS))
	}

	def mustBeDefined (List<FField> it, FDPropertyHost host) {
		if (empty) return false
		if (specHelper.isMandatory(host)) return true
		if (findFirst[mustBeDefined]!==null) return true
		false
	}
	
	def mustBeDefined (FEnumerationType it) {
		if (specHelper.isMandatory(ENUMERATIONS)) return true 
		if (enumerators.empty) return false
		if (specHelper.isMandatory(ENUMERATORS)) return true
		false
	}
	
	def mustBeDefined (FTypeDef it) {
		specHelper.isMandatory(TYPEDEFS)
	}
	

	def mustBeDefined (FAttribute it) {
		specHelper.isMandatory(ATTRIBUTES) || type.mustBeDefined(array)
	}

	def mustBeDefined (FArgument it) {
		specHelper.isMandatory(ARGUMENTS) || type.mustBeDefined(array)
	}

	def mustBeDefined (FField it) {
		val isStruct = eContainer instanceof FStructType
		val host = if (isStruct) STRUCT_FIELDS else UNION_FIELDS
		specHelper.isMandatory(host) || specHelper.isMandatory(FIELDS) || type.mustBeDefined(array)
	}

	def mustBeDefined (FMapType it) {
		specHelper.isMandatory(MAPS) || keyType.mustBeDefined() || valueType.mustBeDefined
	}
	
	// *****************************************************************************

	def private mustBeDefined (FTypeRef it, boolean isInlineArray) {
		// check if the type reference is an implicit array
		if (isInlineArray) {
			if (specHelper.isMandatory(ARRAYS))
				return true
		}
		mustBeDefined
	}

	def public mustBeDefined (FTypeRef it) {
		if (isString) {
			if (specHelper.isMandatory(STRINGS))
				return true
		} else if (isInteger) {
			if (specHelper.isMandatory(INTEGERS) || specHelper.isMandatory(NUMBERS))
				return true
		} else if (isFloatingPoint) {
			if (specHelper.isMandatory(FLOATS) || specHelper.isMandatory(NUMBERS))
				return true
		} else if (isBoolean) {
			if (specHelper.isMandatory(BOOLEANS))
				return true
		} else if (isByteBuffer) {
			if (specHelper.isMandatory(BYTE_BUFFERS))
				return true
		}

		false
	}
}

