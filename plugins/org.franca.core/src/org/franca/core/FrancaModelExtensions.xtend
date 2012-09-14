package org.franca.core

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FModel
import org.franca.core.franca.FInterface
import org.franca.core.franca.FStateGraph
import org.franca.core.franca.FContract

class FrancaModelExtensions {
	
	def static getModel (EObject obj) {
		getParentObject(obj, typeof(FModel))
	}
	
	def static getInterface (EObject obj) {
		getParentObject(obj, typeof(FInterface))
	}
	
	def static getStateGraph (EObject obj) {
		getParentObject(obj, typeof(FStateGraph))
	}
	
	def static getContract (EObject obj) {
		getParentObject(obj, typeof(FContract))
	}
	
	
	def private static <T extends EObject> getParentObject (EObject it, Class<T> clazz) {
		var x = it
		
		do {
			x = x.eContainer
			if (clazz.isInstance(x))
				return x as T
		} while (x!=null)
		
		return null
	}

}
