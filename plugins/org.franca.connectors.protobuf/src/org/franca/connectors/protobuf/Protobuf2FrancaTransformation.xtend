/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.protobuf.ComplexTypeLink
import com.google.eclipse.protobuf.protobuf.CustomOption
import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.Literal
import com.google.eclipse.protobuf.protobuf.Message
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.NativeOption
import com.google.eclipse.protobuf.protobuf.Package
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.ProtobufPackage
import com.google.eclipse.protobuf.protobuf.ScalarTypeLink
import com.google.eclipse.protobuf.protobuf.Service
import com.google.inject.Inject
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FBasicTypeId
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

	def create factory.createFModel transform(Protobuf src) {
		clearIssues

		val typeCollection = typeCollections.head ?: factory.createFTypeCollection

		name = src.elements.filter(Package).head?.name ?: "dummy_package"

		if (src.elements.empty) {
			addIssue(IMPORT_WARNING, src, ProtobufPackage::PROTOBUF__ELEMENTS,
				"Empty proto file, created empty Franca model")
		} else {
			for (elem : src.elements) {
				switch (elem) {
					Service:
						interfaces += elem.transformService
					Message:
						typeCollection.types += elem.transformMessage
					Enum:
						typeCollection.types += elem.transformEnum
					default: {
						addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage::PROTOBUF__ELEMENTS,
							"Unsupported protobuf element '" + elem.class.name + "', will be ignored")
					}
				}
			}
		}
		if (!typeCollection.types.empty)
			typeCollections += typeCollection
	}

	def private create factory.createFEnumerationType transformEnum(Enum enum1) {

		//TODO extend
		name = enum1.name
		enumerators += enum1.elements.map[transformEnumElement]
	}

	def private create factory.createFStructType transformMessage(Message message) {

		//TODO add comments if necessary
		name = message.name
		if (message.elements.empty)
			polymorphic = true
		else {

			//TODO transform message elements 
			for (elem : message.elements) {
				switch elem {
					MessageField:
						elements += elem.transformMessageField
					default: {
						addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage::MESSAGE__ELEMENTS,
							"Unsupported message element '" + elem.class.name + "', will be ignored")
					}
				}
			}
		}
	}

	def private create factory.createFField transformMessageField(MessageField field) {

		//TODO think about the array
		type = field.type.transformTypeLink
		name = field.name
	}

	def dispatch create factory.createFTypeRef transformTypeLink(ScalarTypeLink scalarType) {
		switch scalarType.target {
			//TODO sint32 | sint64 | fixed32 | fixed64 | sfixed32 | sfixed64
			case DOUBLE:
				predefined = FBasicTypeId.DOUBLE
			case FLOAT:
				predefined = FBasicTypeId.FLOAT
			case INT32:
				predefined = FBasicTypeId.INT32
			case INT64:
				predefined = FBasicTypeId.INT64
			case UINT32:
				predefined = FBasicTypeId.UINT32
			case UINT64:
				predefined = FBasicTypeId.UINT64
			case BOOL:
				predefined = FBasicTypeId.BOOLEAN
			case STRING:
				predefined = FBasicTypeId.STRING
			case BYTES:
				predefined = FBasicTypeId.BYTE_BUFFER
			default: {
				addIssue(FEATURE_NOT_HANDLED_YET, scalarType, ProtobufPackage::MESSAGE_FIELD,
					"Unsupported message element '" + scalarType.class.name + "', will be ignored")
			}
		}
	}

	def dispatch create factory.createFTypeRef transformTypeLink(ComplexTypeLink complexType) {
		switch complexType.target {
			Enum: {
				derived = (complexType.target as Enum).transformEnum
			}
		//			ExtensibleType:
		//complexType.transformExtensibleType
		}

	}

	def private dispatch create factory.createFEnumerator transformEnumElement(Literal literal) {
		//TODO do we need to give a value??
		name = literal.name
	}

	def private dispatch create factory.createFEnumerator transformEnumElement(NativeOption option) {
		//TODO
	}
	
	def private dispatch create factory.createFEnumerator transformEnumElement(CustomOption option) {
		//TODO
	}

	def transformExtensibleType(ComplexTypeLink complexType) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def private create factory.createFInterface transformService(Service service) {
		name = service.name

		// transform elements of this service
		for (elem : service.elements) {
			// TODO
		}
	}

	def private factory() {
		FrancaFactory::eINSTANCE
	}
}
