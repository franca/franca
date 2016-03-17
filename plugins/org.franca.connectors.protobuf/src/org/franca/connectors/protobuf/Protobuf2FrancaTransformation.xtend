/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.protobuf.ComplexType
import com.google.eclipse.protobuf.protobuf.ComplexTypeLink
import com.google.eclipse.protobuf.protobuf.CustomOption
import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.ExtensibleType
import com.google.eclipse.protobuf.protobuf.Group
import com.google.eclipse.protobuf.protobuf.Literal
import com.google.eclipse.protobuf.protobuf.Message
import com.google.eclipse.protobuf.protobuf.MessageElement
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.Modifier
import com.google.eclipse.protobuf.protobuf.NativeOption
import com.google.eclipse.protobuf.protobuf.OneOf
import com.google.eclipse.protobuf.protobuf.Package
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.ProtobufPackage
import com.google.eclipse.protobuf.protobuf.ScalarTypeLink
import com.google.eclipse.protobuf.protobuf.Service
import com.google.inject.Inject
import org.eclipse.xtend.lib.annotations.Data
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FField
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FrancaFactory

import static org.franca.core.framework.TransformationIssue.*

@Data
class TransformContext {
	String namespace
	FTypeCollection typeCollection
}

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
					Message:{
						val context = new TransformContext(elem.name,factory.createFTypeCollection)
						typeCollection.types += elem.transformMessage(context)
						typeCollection.types += context.typeCollection.types
					}
						
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

	def private create factory.createFStructType transformMessage(Message message, TransformContext context) {

		//TODO add comments if necessary
		name = message.name
		if (message.elements.empty)
			polymorphic = true
		else {
			//TODO transform message elements 
			for (elem : message.elements) {
				elements += elem.transformMessageElement(context)
			}
		}
	}

	def private getContextNameSpacePrefix(TransformContext context){
		if (context.namespace.nullOrEmpty)
			return ""
		else 
			context.namespace.toFirstUpper+"_"
	}
	
	def encapsulateTypeRef (FType type) { 
 		val it = FrancaFactory::eINSTANCE.createFTypeRef 
 		derived = type; 
 		return it 
 	}
 	
 	def createField(FType type, String name, boolean isArray){
 		val field = factory.createFField
		field.type = encapsulateTypeRef(type)
		field.name = name
		field.array = isArray
		field
 	} 
	
	def FField transformMessageElement(MessageElement elem, TransformContext context) {
		switch elem {
			MessageField:
				elem.transformMessageField(context)
			OneOf:{
				val union = factory.createFUnionType
				union.name = context.contextNameSpacePrefix+elem.name.toFirstUpper
				val newContext = new TransformContext(union.name,factory.createFTypeCollection)
				union.elements += elem.elements.map[transformMessageElement(newContext)]
				context.typeCollection.types += union
				context.typeCollection.types += newContext.typeCollection.types
				union.createField(elem.name, elem.isIsRepeated)
			}
			Group: {
				val group = elem.transformGroup(context)
				context.typeCollection.types += group
				group.createField(elem.name, elem.modifier == Modifier.REPEATED)
			}
				
			//					ComplexType:
			//						elements += elem.transformComplexType
			default: {
				addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage::MESSAGE__ELEMENTS,
					"Unsupported message element '" + elem.class.name + "', will be ignored")
				return null
			}
		}
	}

	def private create factory.createFField transformMessageField(MessageField field, TransformContext context) {

		//TODO think about the array
		type = field.type.transformTypeLink(context)
		name = field.name
		array = field.modifier == Modifier.REPEATED
	}

	def dispatch create factory.createFTypeRef transformTypeLink(ScalarTypeLink scalarType, TransformContext context) {
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

	def dispatch transformTypeLink(ComplexTypeLink complexTypeLink, TransformContext context) {
		complexTypeLink.target.transformComplexType(context)
	}

	def private create factory.createFTypeRef transformComplexType(ComplexType complexType, TransformContext context) {
		switch complexType {
			Enum:
				derived = complexType.transformEnum
			ExtensibleType:
				derived = complexType.transformExtensibleType(context)
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

	def private transformExtensibleType(ExtensibleType extensibleType, TransformContext context) {
		switch extensibleType {
			Message: extensibleType.transformMessage(context)
		//			Group : extensibleType.transformGroup
		}
	}

	def private create factory.createFStructType transformGroup(Group group, TransformContext context) {
		name = context.contextNameSpacePrefix+group.name
		elements += group.elements.map[(it as MessageElement).transformMessageElement(context)]
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
