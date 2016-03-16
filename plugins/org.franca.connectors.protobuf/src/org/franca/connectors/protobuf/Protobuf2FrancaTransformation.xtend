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
import com.google.eclipse.protobuf.protobuf.Message
import org.franca.core.franca.FTypeCollection
import com.google.eclipse.protobuf.protobuf.MessageField
import org.franca.core.franca.FField

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

		val fmodel = factory.createFModel

		fmodel.name = src.elements.filter(com.google.eclipse.protobuf.protobuf.Package).head?.name ?: "dummy_package"

		if (src.elements.empty) {
			addIssue(IMPORT_WARNING, src, ProtobufPackage::PROTOBUF__ELEMENTS,
				"Empty proto file, created empty Franca model")
		} else {
			for (elem : src.elements) {
				switch (elem) {
					Service:
						fmodel.interfaces.add(elem.transformService)
					Message:
						fmodel.typeCollections.add(elem.transformMessage(fmodel))
					default: {
						addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage::PROTOBUF__ELEMENTS,
							"Unsupported protobuf element '" + elem.class.name + "', will be ignored")
					}
				}
			}
		}

		fmodel
	}
	
	def FTypeCollection transformMessage(Message message, FModel model){
		val typeCollection = model.typeCollections.head ?: factory.createFTypeCollection

		//TODO add comments if necessary
		val struct = factory.createFStructType
		struct.name = message.name
		if (message.elements.empty)
			struct.polymorphic = true
		else {
			//TODO transform message elements 
			for (elem : message.elements) {
				switch elem{
					MessageField : struct.elements += elem.transformMessageField
					default: {
						addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage::MESSAGE__ELEMENTS,
							"Unsupported message element '" + elem.class.name + "', will be ignored")
					}
				}
			}
		}

		typeCollection.types += struct
		model.typeCollections += typeCollection
		typeCollection
	}
	
	def Iterable<? extends FField> transformMessageField(MessageField field){
		//TODO
		return null
	}

	def private transformService(Service service) {
		val interface = factory.createFInterface
		interface.name = service.name

		// transform elements of this service
		for (elem : service.elements) {
			// TODO
		}
		interface
	}

	def private factory() {
		FrancaFactory::eINSTANCE
	}
}
