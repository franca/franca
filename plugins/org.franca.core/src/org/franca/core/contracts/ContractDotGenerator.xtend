/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.contracts

import org.franca.core.franca.FModel
import org.franca.core.franca.FInterface
import org.franca.core.franca.FTransition
import org.franca.core.franca.FGuard
import org.franca.core.franca.FExpression
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FBooleanConstant

import static extension org.franca.core.contracts.FEventUtils.*

class ContractDotGenerator {
	
	def generate (FModel fmodel) '''
		digraph FrancaContract {
			
			«FOR api : fmodel.interfaces»
				«api.generate»
			«ENDFOR»
		}
	'''


	def private generate (FInterface api) '''
		«IF api.contract?.stateGraph != null»
		«FOR it : api.contract.stateGraph.states»
			«name»
		«ENDFOR»
		«FOR it : api.contract.stateGraph.states»
			«FOR out : transitions»
			«name» -> «out.to.name» [label="«out.genLabel»"]
			«ENDFOR»
		«ENDFOR»
		«ENDIF»
	'''
	
	def public String genLabel (FTransition it) {
		trigger.event.getEventLabel + 
		if (guard==null)
			''
		else
			"\n" + guard.genGuard
	}
	
	def private String genGuard (FGuard it) {
		'[' + condition.gen + ']'
	}
	

	def dispatch private String gen (FBinaryOperation it) {
		left.gen + op + right.gen
	}

	def dispatch private String gen (FQualifiedElementRef it) {
		if (qualifier==null) {
			element.name
		} else {
			qualifier.gen + "." + field.name
		}
	}
	
	def dispatch private String gen (FBooleanConstant it) {
		^val.toString
	}

	def dispatch private String gen (FIntegerConstant it) {
		^val.toString
	}

	def dispatch private String gen (FExpression it) {
		toString
	}


}