package org.franca.core.framework

import org.franca.core.franca.FModel

class FrancaModelContainer implements IModelContainer {
	
	val FModel mainModel
	
	new(FModel fmodel) {
		this.mainModel = fmodel
	}
	
	def model() {
		this.mainModel
	}
}