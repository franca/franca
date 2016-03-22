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
import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.Extensions
import com.google.eclipse.protobuf.protobuf.Group
import com.google.eclipse.protobuf.protobuf.Import
import com.google.eclipse.protobuf.protobuf.Literal
import com.google.eclipse.protobuf.protobuf.Message
import com.google.eclipse.protobuf.protobuf.MessageElement
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.MessageLink
import com.google.eclipse.protobuf.protobuf.Modifier
import com.google.eclipse.protobuf.protobuf.OneOf
import com.google.eclipse.protobuf.protobuf.Option
import com.google.eclipse.protobuf.protobuf.Package
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.ProtobufPackage
import com.google.eclipse.protobuf.protobuf.Rpc
import com.google.eclipse.protobuf.protobuf.ScalarTypeLink
import com.google.eclipse.protobuf.protobuf.Service
import com.google.eclipse.protobuf.protobuf.Stream
import com.google.eclipse.protobuf.protobuf.TypeExtension
import com.google.inject.Inject
import java.util.LinkedList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Data
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FField
import org.franca.core.franca.FType
import org.franca.core.franca.FrancaFactory

import static org.franca.core.framework.TransformationIssue.*

@Data
class TransformContext {
	String namespace
}

/**
 * Model-to-model transformation from Google Protobuf to Franca IDL.
 * 
 * Current scope: Support for Protobuf version proto2.  
 */
class Protobuf2FrancaTransformation {

	//	val static DEFAULT_NODE_NAME = "default"
	@Inject extension TransformationLogger

	val LinkedList<FType> types = newLinkedList
	val LinkedList<org.franca.core.franca.Import> imports = newLinkedList

	var TransformContext currentContext
	var int index

	def getTransformationIssues() {
		return getIssues
	}

	def create factory.createFModel transform(Protobuf src) {
		clearIssues
		val typeCollection = typeCollections.head ?: factory.createFTypeCollection
		index = 0
		if (!types.empty || !imports.empty) {
			types.clear
			imports.clear
			addIssue(IMPORT_WARNING, src, ProtobufPackage.PROTOBUF,
				"One instance may be executing two transformations")
		}

		name = src.elements.filter(Package).head?.name ?: "dummy_package"

		if (src.elements.empty) {
			addIssue(IMPORT_WARNING, src, ProtobufPackage.PROTOBUF__ELEMENTS,
				"Empty proto file, created empty Franca model")
		} else {
			for (elem : src.elements) {
				switch (elem) {
					Service:
						interfaces += elem.transformService
					Message: {
						currentContext = new TransformContext(elem.name.toFirstUpper)
						typeCollection.types += elem.transformMessage
					}
					Enum:
						typeCollection.types += elem.transformEnum
					Group: {
						currentContext = new TransformContext("")
						typeCollection.types += elem.transformGroup
					}
					TypeExtension: {
						index ++;
						typeCollection.types += elem.transformTypeExtension
					}
					Import: {
						val importElement = elem.transformImport
						if (!importElement.importURI.nullOrEmpty){
								it.imports += importElement
							}
					}
					case elem instanceof Package || elem instanceof Option: {
					}
					default: {
						addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage.PROTOBUF__ELEMENTS,
							"Unsupported protobuf element '" + elem.class.name + "', will be ignored")
					}
				}
			}
		}
		typeCollection.types += types
		if (!typeCollection.types.empty)
			typeCollections += typeCollection
	}
	
	private def create factory.createImport transformImport(Import elem) {
		val uri = URI.createFileURI(elem.importURI)
		if (uri !== null) {
			if (!uri.lastSegment.endsWith(".proto")) {
				//TODO
				addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage.IMPORT__IMPORT_URI,
					"Unsupported uri element '" + elem.importURI + "', will be ignored")
			}
			else {
				if (!uri.isFile){
					addIssue(IMPORT_ERROR, elem, ProtobufPackage.IMPORT__IMPORT_URI,
					"Couldn't find the import source file: '" + elem.importURI + "', will be ignored")
					return ;
				}
				val conn = new ProtobufConnector
				val normalizedUri = elem.eResource.resourceSet.URIConverter.normalize(uri)
				val protobufidl = conn.loadModel(normalizedUri.toFileString) as ProtobufModelContainer
				val fmodelGen = conn.toFranca(protobufidl)
				
				elem.eResource.resourceSet.createResource(normalizedUri)
				
				importURI = uri.lastSegment.split("\\.").get(0).concat(".fidl")
				importedNamespace = fmodelGen.name+".*"
			}
		} else
			addIssue(
				IMPORT_ERROR,
				elem,
				ProtobufPackage.IMPORT__IMPORT_URI,
				"Invalid import URI '" + elem.importURI + "', will be ignored"
			)
	}

	def private create factory.createFStructType transformTypeExtension(TypeExtension typeExtension) {
		name = typeExtension.type.target.name.toFirstUpper + "_" + index
		base = transformExtensibleType(typeExtension.type.target)
		elements += typeExtension.elements.map [ element |
			transformField(name, [element.transformMessageElement])
		].filterNull
	}

	def private dispatch transformExtensibleType(Message message) {
		message.transformMessage
	}

	def private dispatch transformExtensibleType(Group group) {
		group.transformGroup
	}

	def private create factory.createFEnumerationType transformEnum(Enum enum1) {
		name = enum1.name
		enumerators += enum1.elements.filter[element|!(element instanceof Option)].map[transformEnumElement]
	}

	def private create factory.createFStructType transformMessage(Message message) {

		//TODO add comments if necessary
		name = message.name.toFirstUpper
		elements += message.elements.map[transformMessageElement].filterNull
		if (elements.empty)
			polymorphic = true
	}

	def private getContextNameSpacePrefix(TransformContext context) {
		if (context.namespace.nullOrEmpty)
			return ""
		else
			context.namespace.toFirstUpper + "_"
	}

	def private encapsulateTypeRef(FType type) {
		val it = FrancaFactory.eINSTANCE.createFTypeRef
		derived = type;
		return it
	}

	def private create factory.createFField createField(FType type, String name, boolean isArray) {
		type = encapsulateTypeRef(type)
		it.name = name.toFirstLower
		array = isArray
	}

	def private transform(String nameSpace, ()=>FType acceptor) {
		val oldContext = currentContext
		currentContext = new TransformContext(nameSpace)
		val ftype = acceptor.apply()
		currentContext = oldContext
		return ftype
	}

	def private transformField(String nameSpace, ()=>FField acceptor) {
		val oldContext = currentContext
		currentContext = new TransformContext(nameSpace)
		val ftype = acceptor.apply()
		currentContext = oldContext
		return ftype
	}

	def private FField transformMessageElement(MessageElement elem) {
		switch elem {
			MessageField:
				elem.transformMessageField
			OneOf: {
				val union = factory.createFUnionType
				union.name = currentContext.contextNameSpacePrefix + elem.name.toFirstUpper
				union.elements += elem.elements.map [ element |
					transformField(union.name, [element.transformMessageElement])
				].filterNull
				types += union
				union.createField(elem.name, elem.isIsRepeated)
			}
			Group: {
				val group = elem.transformGroup
				types += group
				group.createField(elem.name, elem.modifier == Modifier.REPEATED)
			}
			Enum: {
				val enum1 = elem.transformEnum
				enum1.name = currentContext.contextNameSpacePrefix + elem.name.toFirstUpper
				types += enum1
				return null
			}
			Message: {
				val nameSpace = currentContext.contextNameSpacePrefix + elem.name.toFirstUpper
				val struct = transform(nameSpace, [elem.transformMessage])
				struct.name = nameSpace
				types += struct
				struct.createField(elem.name, false)
			}
			Option: {
				return null
			}
			Extensions: {

				//TODO maybe search in the global scope and add fields in the current Message.
				return null
			}
			default: {
				addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage.MESSAGE__ELEMENTS,
					"Unsupported message element '" + elem.class.name + "', will be ignored")
				return null
			}
		}
	}

	def private create factory.createFField transformMessageField(MessageField field) {
		type = EcoreUtil.copy(field.type.transformTypeLink)
		name = field.name
		array = field.modifier == Modifier.REPEATED
	}

	def private dispatch create factory.createFTypeRef transformTypeLink(ScalarTypeLink scalarType) {
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
				addIssue(FEATURE_NOT_HANDLED_YET, scalarType, ProtobufPackage.MESSAGE_FIELD,
					"Unsupported message element '" + scalarType.class.name + "', will be ignored")
			}
		}
	}

	def private dispatch transformTypeLink(ComplexTypeLink complexTypeLink) {
		if (complexTypeLink.target.eIsProxy) {
			val resourceSet = complexTypeLink.eResource.resourceSet
			EcoreUtil.resolve(complexTypeLink.target, resourceSet)
		}
		complexTypeLink.target.transformComplexType
	}

	def private create factory.createFTypeRef transformComplexType(ComplexType complexType) {
		derived = switch complexType {
			Enum:
				complexType.transformEnum
			Message:
				complexType.transformMessage
			Group:
				complexType.transformGroup
		}
	}

	def private dispatch create factory.createFEnumerator transformEnumElement(Literal literal) {

		//TODO do we need to give a value??
		name = literal.name
	}

	def private dispatch create factory.createFEnumerator transformEnumElement(Option option) {
		//TODO
	}

	def private create factory.createFStructType transformGroup(Group group) {
		name = currentContext.contextNameSpacePrefix + group.name.toFirstUpper
		elements += group.elements.map [ element |
			transformField(name, [(element as MessageElement).transformMessageElement])
		].filterNull
		if (elements.empty)
			polymorphic = true
	}

	def private create factory.createFInterface transformService(Service service) {
		name = service.name

		// transform elements of this service
		for (elem : service.elements) {
			switch elem {
				Rpc: {
					methods += elem.transformRpc
				}
				Stream: {
					//TODO
				}
				Option: {
					//TODO confirm whether skip it.
				}
			}
		}
	}

	def private create factory.createFArgument transformMessageLink(MessageLink messageLink) {
		type = encapsulateTypeRef(messageLink.target.transformMessage)
		name = messageLink.target.name.toFirstLower
	}

	def private create factory.createFMethod transformRpc(Rpc rpc) {
		name = rpc.name
		inArgs += rpc.argType.transformMessageLink
		outArgs += rpc.returnType.transformMessageLink
	}

	def private factory() {
		FrancaFactory.eINSTANCE
	}
}
