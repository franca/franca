package org.franca.core.dsl.scoping

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope

class FilteringScopeWrapper implements IScope {
	
	val IScope original
	val (Class<?>) => boolean predicate
	
	new (IScope original, (Class<?>) => boolean predicate) {
		this.original = original
		this.predicate = predicate
	}

	override getAllElements() {
		original.getAllElements.filterEvaluable
	}
	
	override getElements(QualifiedName name) {
		original.getElements(name).filterEvaluable
	}
	
	override getElements(EObject object) {
		original.getElements(object).filterEvaluable
	}
	
	override getSingleElement(QualifiedName name) {
		val result = original.getSingleElement(name)
		if (result.isEvaluable)
			result
		else
			null
	}
	
	override getSingleElement(EObject object) {
		val result = original.getSingleElement(object)
		if (result.isEvaluable)
			result
		else
			null
	}


	def private filterEvaluable(Iterable<IEObjectDescription> items) {
		items.filter[isEvaluable]
	}
	
	def private isEvaluable(IEObjectDescription desc) {
		val clazz = desc?.EObjectOrProxy?.eClass?.instanceClass
		if (clazz==null)
			false 
		else
			clazz.isEvaluable
	}
	
	def private isEvaluable(Class<?> o) {
		predicate.apply(o)
	}
	
}