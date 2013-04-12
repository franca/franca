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
	
	def private String genLabel (FTransition it) {
		val ev = trigger.event
		if (ev.call!=null) {
			"call " + ev.call.name
		} else if (ev.respond!=null) {
			"respond " + ev.respond.name
		} else if (ev.signal!=null) {
			"signal " + ev.signal.name
		} else if (ev.signal!=null) {
			"set " + ev.set.name
		} else if (ev.signal!=null) {
			"update " + ev.update.name
		} else {
			"unknown_event"
		}
	}
}