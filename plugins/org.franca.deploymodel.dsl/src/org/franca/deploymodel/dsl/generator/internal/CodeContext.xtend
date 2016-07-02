package org.franca.deploymodel.dsl.generator.internal

import org.franca.deploymodel.dsl.generator.internal.ICodeContext

class CodeContext implements ICodeContext {
	
	boolean targetIsNeeded = false
	
	override requireTargetMember() {
		targetIsNeeded = true
	}

	def isTargetNeeded() {
		targetIsNeeded
	}	
}