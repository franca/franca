package org.franca.connectors.omgidl

import org.franca.core.franca.FModel
import org.franca.core.franca.FrancaFactory
import org.franca.core.franca.FInterface
import org.eclipse.emf.ecore.EObject
import org.csu.idl.idlmm.InterfaceDef
import org.csu.idl.idlmm.ModuleDef
import org.csu.idl.idlmm.TranslationUnit

class OMGIDL2FrancaTransformationUtil {
	
	def private static createTypeCollection (String name, int major, int minor) {
		factory.createFTypeCollection => [
			it.name = name
			it.version = factory.createFVersion => [
				it.major = major
				it.minor = minor
			]
		]
	}
	
	def static dispatch getTypeCollection (FModel target) {
		if (target.typeCollections.isNullOrEmpty) {
			target.typeCollections.add(createTypeCollection(null, 1, 0))
		}
		target.typeCollections.get(0)
	}
	
	def static dispatch getTypeCollection (FInterface target) {
		target
	}
	
	def private static factory() {
		FrancaFactory::eINSTANCE
	}
}