/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl

import com.google.inject.Inject
import org.csu.idl.idlmm.Contained
import org.csu.idl.idlmm.IdlmmPackage
import org.csu.idl.idlmm.InterfaceDef
import org.csu.idl.idlmm.ModuleDef
import org.csu.idl.idlmm.TranslationUnit
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FModel
import org.franca.core.franca.FrancaFactory

import static org.franca.core.framework.TransformationIssue.*

/**
 * Model-to-model transformation from OMG IDL (aka CORBA) to Franca IDL.  
 */
class OMGIDL2FrancaTransformation {

//	val static DEFAULT_NODE_NAME = "default"
	 
	@Inject extension TransformationLogger

//	List<FType> newTypes
	
	def getTransformationIssues() {
		return getIssues
	}

	def FModel transform(TranslationUnit src) {
		clearIssues

		val it = factory.createFModel

		// TODO: handle src.includes
		
		if (src.contains.empty) {
			addIssue(IMPORT_WARNING,
				src, IdlmmPackage::TRANSLATION_UNIT__IDENTIFIER,
				"Empty OMG IDL translation unit, created empty Franca model")
		} else {
			if (src.contains.size > 1) {
				addIssue(FEATURE_IS_IGNORED,
					src, IdlmmPackage::TRANSLATION_UNIT__IDENTIFIER,
					"OMG IDL translation unit with more than one definition, ignoring all but the first one")
			}
			
			// TODO: what should we do with TUs that have more than one definition?
			val first = src.contains.get(0)
			if (first instanceof ModuleDef) {
				// we expect that first definition is a ModuleDef, ignore all other ones
				// TODO: correct? or should we create several Franca files per OMG IDL TU?
				
				// OMG IDL's module name will be the package identifier in Franca  
				it.name = first.identifier

				// map all definitions of this module to the Franca model
				for(d : first.contains) {
					d.transformDefinition(it)
				}
			} else {
				// TODO: check if this restriction is what we want
				addIssue(IMPORT_ERROR,
					first, IdlmmPackage::CONTAINED__IDENTIFIER,
					"First and only member of OMG IDL translation unit should be a 'module' definition")
			}
		}
		it
	}


	def private dispatch transformDefinition(InterfaceDef src, FModel target) {
		factory.createFInterface => [
			// transform all properties of this InterfaceDef
			name = src.identifier
			// TODO: add other properties
			
			// add resulting object to target model
			target.interfaces.add(it)
		]
	}

	// TODO: handle all kinds of OMG IDL definitions here
	
	// catch-all for this dispatch method
	def private dispatch transformDefinition(Contained src, FModel target) {
				addIssue(FEATURE_NOT_HANDLED_YET,
					src, IdlmmPackage::CONTAINED__IDENTIFIER,
					"OMG IDL definition '" + src.class.name + "' not handled yet (object '" + src.identifier + "')")
			
	}

	def private factory() {
		FrancaFactory::eINSTANCE
	}
}
