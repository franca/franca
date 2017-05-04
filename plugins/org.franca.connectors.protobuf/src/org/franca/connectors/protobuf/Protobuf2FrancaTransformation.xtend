/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.protobuf.BOOL
import com.google.eclipse.protobuf.protobuf.BooleanLink
import com.google.eclipse.protobuf.protobuf.ComplexType
import com.google.eclipse.protobuf.protobuf.ComplexTypeLink
import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.ExtensibleType
import com.google.eclipse.protobuf.protobuf.Extensions
import com.google.eclipse.protobuf.protobuf.Group
import com.google.eclipse.protobuf.protobuf.Import
import com.google.eclipse.protobuf.protobuf.Literal
import com.google.eclipse.protobuf.protobuf.Message
import com.google.eclipse.protobuf.protobuf.MessageElement
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.MessageLink
import com.google.eclipse.protobuf.protobuf.Modifier
import com.google.eclipse.protobuf.protobuf.NativeFieldOption
import com.google.eclipse.protobuf.protobuf.NativeOption
import com.google.eclipse.protobuf.protobuf.OneOf
import com.google.eclipse.protobuf.protobuf.Option
import com.google.eclipse.protobuf.protobuf.Package
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.ProtobufPackage
import com.google.eclipse.protobuf.protobuf.Rpc
import com.google.eclipse.protobuf.protobuf.ScalarTypeLink
import com.google.eclipse.protobuf.protobuf.Service
import com.google.eclipse.protobuf.protobuf.Stream
import com.google.eclipse.protobuf.protobuf.StringLink
import com.google.eclipse.protobuf.protobuf.TypeExtension
import com.google.inject.Inject
import java.math.BigInteger
import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.typesystem.emf.EcoreUtil2
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FField
import org.franca.core.franca.FOperator
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
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
	static final Logger logger = Logger.getLogger(typeof(Protobuf2FrancaTransformation))

	val static OPTION_DEPRECATED = "deprecated"
	val static DESCRIPTOR_BASENAME = "descriptor"
	
	//	val static DEFAULT_NODE_NAME = "default"
	@Inject extension TransformationLogger

	val Map<EObject, FType> types = newLinkedHashMap

	var Map<EObject, FType> externalTypes

	var TransformContext currentContext
	var int index
	var needsDescriptorImport = false
	
	var normalizeIds = false

	/**
	 * Configure if first letter of ids should be enforced to be uppercase.
	 * 
	 * The default is false, i.e., uppercase is not enforced.
	 */	
	def setNormalizeIds(boolean enforce) {
		normalizeIds = enforce
	}
	
	def getTransformationIssues() {
		return getIssues
	}

	def getExternalTypes() {
		externalTypes ?: newLinkedHashMap()
	}
	
	/**
	 * Check if the resulting Franca IDL model needs to import "descriptor.fidl".
	 * 
	 * The file "descriptor.fidl" is corresponding to the Protobuf file "descriptor.proto". 
	 */
	def boolean needsDescriptorInclude(Protobuf src) {
		for(te : EcoreUtil2.allContents(src).filter(TypeExtension)) {
			val target = te.type.target
			if (target.isFromDescriptorProto) {
				return true;
			}
		}
		return false;
	}
	
	def create factory.createFModel transform(Protobuf src, Map<EObject, FType> externalTypes) {
		clearIssues

		this.externalTypes = externalTypes
		
		index = 0
		types.clear
		needsDescriptorImport = false
		
		val res = src.eResource
		if (res!=null) {
			logger.info("Transforming " + res.URI.toString)
		}
		
		val typeCollection = typeCollections.head ?: factory.createFTypeCollection

		val packages = src.elements.filter(Package)
		name = packages.head?.name ?: "dummy_package"

		val options = src.elements.filter(Option)
//		if (options.findFirst[needsInterface]!=null) {
//			interfaces += factory.createFInterface => [name = "FileOption"]
//		}

		if (src.elements.empty) {
			addIssue(IMPORT_WARNING, src, ProtobufPackage.PROTOBUF__ELEMENTS,
				"Empty proto file, created empty Franca model")
		} else {
			for (elem : src.elements) {
				switch (elem) {
					Service:
						interfaces += elem.transformService
					Message: {
						currentContext = new TransformContext(elem.name.normalizeId)
						typeCollection.add(elem, elem.transformMessage)
					}
					Enum: {
						typeCollection.types += elem.transformEnum
					}
					Group: {
						currentContext = new TransformContext("")
						typeCollection.add(elem, elem.transformGroup)
					}
					TypeExtension: {
						index++;
						typeCollection.add(elem, elem.transformTypeExtension)
					}
					Import: {
						// do not import descriptor.fidl exactly when descriptor.proto is imported
						// instead, we apply a different, Franca-specific logic
						if (! elem.importURI.endsWith(DESCRIPTOR_BASENAME + ".proto")) {
							val importElement = elem.transformImport
							if (!importElement.importURI.nullOrEmpty) {
								it.imports += importElement
							}
						}
					}
					case elem instanceof Package: {
						// currently not mapped
					}
					case elem instanceof Option: {
						// currently not mapped
						if (elem instanceof NativeOption) {
							val v = elem.value
							val t = elem.source.target
							if (v!=null && t!=null) {
								if (v instanceof StringLink) {
									if (t instanceof MessageField) {
										logger.info("Option: " + t.name + " = " + v.target)
									}
								}
							}
						}
					}
					default: {
						addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage.PROTOBUF__ELEMENTS,
							"Unsupported protobuf element '" + elem.class.name + "', will be ignored")
					}
				}
			}
		}
		
		if (needsDescriptorImport) {
			val import = factory.createImport
			import.importURI = DESCRIPTOR_BASENAME + ".fidl"
			it.imports.add(import)
		}

		for(entry : types.entrySet) {
			typeCollection.add(entry.key, entry.value)
		}

		if (! typeCollection.types.empty) {
			typeCollections += typeCollection
		}
	}

	def private add(FTypeCollection tc, EObject src, FType target) {
		tc.types += target
		if (src!=null)
			externalTypes.put(src, target)	
	}
	
	private def create factory.createImport transformImport(Import elem) {
		val uri = URI.createURI(elem.importURI)
		if (uri !== null) {
			if (!uri.toString.endsWith(".proto")) {

				//TODO
				addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage.IMPORT__IMPORT_URI,
					"Unsupported uri element '" + elem.importURI + "', will be ignored")
			} else {
				// deactivated this check because some imported files may be read from classpath
				// (e.g., descriptor.proto is read from the jar file of the protobuf-plugin) 
//				if (!uri.isFile) {
//					addIssue(IMPORT_ERROR, elem, ProtobufPackage.IMPORT__IMPORT_URI,
//						"Couldn't find the import source file: '" + elem.importURI + "', will be ignored")
//					return;
//				}

				//TODO import google/protobuf/descriptor.proto
				importURI = uri.lastSegment.split("\\.").get(0).concat(".fidl")
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
		val target = typeExtension.type.target
		if (target.eIsProxy) {
			val resourceSet = typeExtension.eResource.resourceSet
			EcoreUtil.resolveAll(resourceSet)
			val resolved = EcoreUtil.resolve(target, resourceSet)
			if (resolved.eIsProxy) {
				//TODO
				name = "unsolved_" + NodeModelUtils.getNode(typeExtension.type).text.replace('.', '_').trim
				val fakeBase = createFakeBaseStruct
				base = fakeBase
			}
		} else {
			if (target.isFromDescriptorProto) {
				needsDescriptorImport = true
			}
			name = target.name.normalizeId + "_" + index
			base = transformExtensibleType(target)
		}
		
		elements += typeExtension.elements.map [ element |
			transformField(name, [element.transformMessageElement])
		].filterNull
	}

	def private boolean isFromDescriptorProto(ExtensibleType type) {
		val res = type.eResource
		res!=null && res.URI.lastSegment == DESCRIPTOR_BASENAME+".proto"
	}
	
	def private create factory.createFStructType createFakeBaseStruct() {
		name = "unknown"
		polymorphic = true
		types.put(null, it)
	}

	def private dispatch FStructType transformExtensibleType(Message message) {
		message.transformMessage
	}

	def private dispatch FStructType transformExtensibleType(Group group) {
		group.transformGroup
	}

	def private create factory.createFEnumerationType transformEnum(Enum enum1) {
		name = enum1.name.normalizeId
		enumerators += enum1.elements.filter[element|!(element instanceof Option)].map[transformEnumElement]
	}

	def private create factory.createFStructType transformMessage(Message message) {

		//TODO add comments if necessary
		name = message.name.normalizeId
		elements += message.elements.map[transformMessageElement].filterNull
		if (elements.empty)
			polymorphic = true
	}

	def private getContextNameSpacePrefix(TransformContext context) {
		if (context?.namespace.nullOrEmpty)
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
				return elem.transformMessageField
			OneOf: {
				val union = factory.createFUnionType
				union.name = currentContext.contextNameSpacePrefix + elem.name.normalizeId
				union.elements += elem.elements.map [ element |
					transformField(union.name, [element.transformMessageElement])
				].filterNull
				types.put(elem, union) // TODO: correct?
				return union.createField(elem.name, false)
			}
			Group: {
				val group = elem.transformGroup
				types.put(elem, group)
				return group.createField(elem.name, elem.modifier == Modifier.REPEATED)
			}
			Enum: {
				val enum1 = elem.transformEnum
				enum1.name = currentContext.contextNameSpacePrefix + elem.name.normalizeId
				types.put(elem, enum1)
			}
			Message: {
				val nameSpace = currentContext.contextNameSpacePrefix + elem.name.normalizeId
				val struct = transform(nameSpace, [elem.transformMessage])
				struct.name = nameSpace
				types.put(elem, struct) // TODO: correct?
			}
			Option: {
			}
			Extensions: {
			}
			TypeExtension: {
				types.put(elem, elem.transformTypeExtension)
			}
			default: {
				addIssue(FEATURE_NOT_HANDLED_YET, elem, ProtobufPackage.MESSAGE__ELEMENTS,
					"Unsupported message element '" + elem.class.name + "', will be ignored")
			}
		}
		return null
	}

	def private create factory.createFField transformMessageField(MessageField field) {
		type = EcoreUtil.copy(field.type.transformTypeLink)
		name = field.name
		array = field.modifier == Modifier.REPEATED
		val nativeOptions = field.fieldOptions.filter(NativeFieldOption)
		val v = nativeOptions.getOptionValue(OPTION_DEPRECATED)
		if (v instanceof BooleanLink) {
			if (v.target == BOOL.TRUE) {
				it.comment = factory.createFAnnotationBlock => [
					elements += factory.createFAnnotation => [
						rawText = "@deprecated : " + field.name
					]
				]
			}
		}
	}
	
	def private getOptionValue(Iterable<NativeFieldOption> options, String option) {
		for(opt : options) {
			val definition = opt.source.target 
			if (definition instanceof MessageField) {
				if (definition.name == option)
					return opt.value
			}
		}
		return null
	}

	def private dispatch create factory.createFTypeRef transformTypeLink(ScalarTypeLink scalarType) {
		predefined = switch scalarType.target {
			case DOUBLE:
				FBasicTypeId.DOUBLE
			case FLOAT:
				FBasicTypeId.FLOAT
			case INT32:
				FBasicTypeId.INT32
			case INT64:
				FBasicTypeId.INT64
			case UINT32:
				FBasicTypeId.UINT32
			case UINT64:
				FBasicTypeId.UINT64
			case BOOL:
				FBasicTypeId.BOOLEAN
			case STRING:
				FBasicTypeId.STRING
			case BYTES:
				FBasicTypeId.BYTE_BUFFER
			case SINT32:
				FBasicTypeId.INT32
			case SINT64:
				FBasicTypeId.INT64
			case FIXED32:
				FBasicTypeId.UINT32
			case FIXED64:
				FBasicTypeId.UINT64
			case SFIXED32:
				FBasicTypeId.INT32
			case SFIXED64:
				FBasicTypeId.INT64
		}
	}

	def private dispatch transformTypeLink(ComplexTypeLink complexTypeLink) {
		complexTypeLink.target.transformComplexType
	}

	def private create factory.createFTypeRef transformComplexType(ComplexType complexType) {
		val key = complexType.eResource.URI.trimFileExtension.toString + "_" + complexType.name.normalizeId
		if (externalTypes.containsKey(key)) {
			derived = externalTypes.get(key)
		} else
			derived = switch complexType {
				Enum:
					complexType.transformEnum
				Message:
					transform(complexType.name, [complexType.transformMessage])
				Group:
					transform(complexType.name, [complexType.transformGroup])
			}
	}

	def private dispatch create factory.createFEnumerator transformEnumElement(Literal literal) {
		name = literal.name
		val integerConstant = factory.createFIntegerConstant => [
			^val = BigInteger.valueOf(Math.abs(literal.index))
		]
		value = switch literal.index {
			case literal.index < 0:
				factory.createFUnaryOperation => [
					op = FOperator.SUBTRACTION
					operand = integerConstant
				]
			default:
				integerConstant
		}
	}

	def private dispatch create factory.createFEnumerator transformEnumElement(Option option) {
		//TODO
	}

	def private create factory.createFStructType transformGroup(Group group) {
		name = currentContext.contextNameSpacePrefix + group.name.normalizeId
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
	
	/**
	 * Helper method which normalizes ids.
	 * 
	 * The behavior can be configured. Currently the following ids will be normalized:
	 * <li>
	 *     <item>name of Franca struct which is transformed from a Protobuf message</item>
	 * </li>
	 * </p>
	 * 
	 * @param id the id which should be normalized
	 */
	def private String normalizeId(String id) {
		if (normalizeIds)
			id.toFirstUpper
		else
			id
	}
}
