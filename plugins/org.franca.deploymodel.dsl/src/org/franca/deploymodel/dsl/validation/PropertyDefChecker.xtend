package org.franca.deploymodel.dsl.validation

import java.util.List
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FField
import org.franca.core.franca.FMethod
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.dsl.FDSpecificationExtender
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost
import static org.franca.deploymodel.dsl.fDeploy.FDPropertyHost.*

import static extension org.franca.core.framework.FrancaHelpers.*

class PropertyDefChecker {
	
	FDSpecificationExtender specHelper
	
	new (FDSpecificationExtender aSpecHelper) {
		specHelper = aSpecHelper
	}
	
	// *****************************************************************************

	def mustBeDefined (FMethod it) {
		if (specHelper.isMandatory(METHODS)) return true
		if (inArgs.empty && outArgs.empty) return false
		if (specHelper.isMandatory(ARGUMENTS)) return true
		if (inArgs.findFirst[mustBeDefined()]!=null) return true
		if (outArgs.findFirst[mustBeDefined()]!=null) return true
		false
	}
	
	def mustBeDefined (FBroadcast it) {
		if (specHelper.isMandatory(BROADCASTS)) return true
		if (outArgs.empty) return false
		if (specHelper.isMandatory(ARGUMENTS)) return true
		if (outArgs.findFirst[mustBeDefined()]!=null) return true
		false
	}
	
	def mustBeDefined (FArrayType it) {
		specHelper.isMandatory(ARRAYS)
	}
	
	def mustBeDefined (FStructType it) {
		// activate next line if STRUCTS gets a property host (currently not defined in FDeploy.xtext)
//		if (specHelper.isMandatory(STRUCTS)) return true
		elements.mustBeDefined(STRUCT_FIELDS)
	}
	
	def mustBeDefined (FUnionType it) {
		// activate next line if UNIONS gets a property host (currently not defined in FDeploy.xtext)
//		if (specHelper.isMandatory(UNIONS)) return true
		elements.mustBeDefined(UNION_FIELDS)
	}

	def mustBeDefined (List<FField> it, FDPropertyHost host) {
		if (empty) return false
		if (specHelper.isMandatory(host)) return true
		if (findFirst[mustBeDefined()]!=null) return true
		false
	}
	
	def mustBeDefined (FEnumerationType it) {
		if (specHelper.isMandatory(ENUMERATIONS)) return true 
		if (enumerators.empty) return false
		if (specHelper.isMandatory(ENUMERATORS)) return true
		false
	}
	

	def mustBeDefined (FAttribute target) {
		specHelper.isMandatory(ATTRIBUTES) || mustBeDefined(target.type)
	}

	def mustBeDefined (FArgument target) {
		specHelper.isMandatory(ARGUMENTS) || mustBeDefined(target.type)
	}

	def mustBeDefined (FField target) {
		val isStruct = target.eContainer instanceof FStructType
		val host = if (isStruct) STRUCT_FIELDS else UNION_FIELDS
		specHelper.isMandatory(host) || mustBeDefined(target.type)
	}


	// *****************************************************************************

	def private mustBeDefined (FTypeRef it) {
		if (isString) {
			if (specHelper.isMandatory(STRINGS))
				return true
		} else if (isInteger) {
			if (specHelper.isMandatory(INTEGERS) || specHelper.isMandatory(NUMBERS))
				return true
		} else if (isFloatingPoint) {
			if (specHelper.isMandatory(FLOATS) || specHelper.isMandatory(NUMBERS))
				return true
		} else if (derived!=null) {
//			val type = derived 
//			if (type instanceof FStructType) {
//				println("CHECKING mustBeDefined for " + type.name)
//			}
		}
		false
	}
	
}