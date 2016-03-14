/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.ProtobufPackage
import com.google.eclipse.protobuf.protobuf.Service
import com.google.inject.Inject
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FModel
import org.franca.core.franca.FrancaFactory

import static org.franca.core.framework.TransformationIssue.*

/**
 * Model-to-model transformation from Google Protobuf to Franca IDL.
 * 
 * Current scope: Support for Protobuf version proto2.  
 */
class Protobuf2FrancaTransformation {

//	val static DEFAULT_NODE_NAME = "default"
	 
	@Inject extension TransformationLogger

//	List<FType> newTypes
	
	def getTransformationIssues() {
		return getIssues
	}

	def FModel transform(Protobuf src) {
		clearIssues

		val it = factory.createFModel

		// TODO: set via protobuf package declaration 
		it.name = "dummy_package"
		
		if (src.elements.empty) {
			addIssue(IMPORT_WARNING,
				src, ProtobufPackage::PROTOBUF__ELEMENTS,
				"Empty proto file, created empty Franca model")
		} else {
			for(elem : src.elements) {
				switch(elem) {
					Service: it.interfaces.add(elem.transformService)
					// TODO: map top-level protobuf Message to struct in Franca anonymous typecollection
					default: {
						addIssue(FEATURE_NOT_HANDLED_YET,
							elem, ProtobufPackage::PROTOBUF__ELEMENTS,
							"Unsupported protobuf element '" + elem.class.name + "', will be ignored")
					} 
				}
			}
		}
		
		it
	}		

	def private transformService(Service src) {
		val it = factory.createFInterface
		it.name = src.name
		
		// transform elements of this service
		for(elem : src.elements) {
			// TODO
		}
		it
	}

	def private factory() {
		FrancaFactory::eINSTANCE
	}
}


