package org.franca.core.utils

import org.franca.core.franca.FrancaFactory
import org.franca.core.franca.FCurrentError
import org.eclipse.xtext.EcoreUtil2
import org.franca.core.franca.FTransition
import org.franca.core.franca.FBasicTypeId

class FrancaModelCreator {
	
	def create FrancaFactory::eINSTANCE.createFTypeRef createTypeRef(FCurrentError currentError) {
		val containingTransition = EcoreUtil2::getContainerOfType(currentError, typeof(FTransition))
		val trigger = containingTransition.trigger
		val event = trigger.event
		val method = event.error
		if (method != null) {
			val errors = method.errors
			if (errors != null) it.derived = errors else it.derived = method.errorEnum
		} else {
			it.predefined = FBasicTypeId::UNDEFINED
		}
	}
}