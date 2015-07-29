package org.franca.core.dsl.scoping

import java.util.List
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractScope
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FTypeCollection

import static org.franca.core.FrancaModelExtensions.*

class InheritedEnumeratorScope extends AbstractScope {
	
	val List<IEObjectDescription> inheritedEnumerators = newArrayList

	new (IScope parent, FTypeCollection currentContext, IQualifiedNameProvider qualifiedNameProvider) {
		super(parent, false)
		init(parent, currentContext, qualifiedNameProvider)
	}
	
	def private init(IScope original, FTypeCollection currentContext, IQualifiedNameProvider qualifiedNameProvider) {
		val enumerators = original.allElements.map[EObjectOrProxy].filter(FEnumerator)
		val enumerations = enumerators.map[eContainer as FEnumerationType].toSet
		val tcName = qualifiedNameProvider.getFullyQualifiedName(currentContext)
		val packageName = qualifiedNameProvider.getFullyQualifiedName(currentContext.eContainer)
		for(enumeration : enumerations.filter[base!=null]) {
			val parent = enumeration.base
			val baseEnumerators = getAllElements(parent)
			val name = qualifiedNameProvider.getFullyQualifiedName(enumeration)
			for(e : baseEnumerators) {
				val eName = name.append(e.name)
				val n = 
					if (eName.startsWith(tcName)) {
						eName.skipFirst(tcName.segmentCount)
					} else if (eName.startsWith(packageName)) {
						eName.skipFirst(packageName.segmentCount)
					} else {
						eName
					}
					val desc = EObjectDescription.create(n, e)
					inheritedEnumerators.add(desc)
			}
		}
	}
	
	override protected getAllLocalElements() {
		inheritedEnumerators
	}
	
}