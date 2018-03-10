/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.dbus

import com.google.inject.Inject
import java.util.List
import java.util.Map
import model.emf.dbusxml.AccessType
import model.emf.dbusxml.DbusxmlFactory
import model.emf.dbusxml.DirectionType
import model.emf.dbusxml.DocType
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FrancaPackage

import static org.franca.core.framework.FrancaModelMapper.*
import static org.franca.core.framework.TransformationIssue.*

import static extension org.franca.core.utils.ExpressionEvaluator.*
import static extension org.franca.connectors.dbus.util.DBusLogic.*

class Franca2DBusTransformation {

	@Inject extension TransformationLogger

	String mInterfaceName

	def create DbusxmlFactory::eINSTANCE.createNodeType transform(FModel src) {
		clearIssues

		name = src.name
		interface.addAll(src.interfaces.map[transformInterface])
		addBacklink(it, src)
	}

	def getTransformationIssues() {
		return getIssues
	}

	def create DbusxmlFactory::eINSTANCE.createInterfaceType transformInterface(FInterface src) {

		//println("transformInterface: " + src.name
		val parentInterfaces = newHashSet
		parentInterfaces.add(src)
		var source = src
		while (source.base!==null && !parentInterfaces.contains(source.base)) {
			var base = source.base
			if (!parentInterfaces.contains(base)) {
				parentInterfaces.add(base)
			}
			source = base;
		}

		name = mInterfaceName = src.model.name + "." + src.name
		if (src.version !== null)
			version = "" + src.version.major + "." + src.version.minor

		//doc = src.comment
		// map attributes
		val propertyReference = property
		parentInterfaces.forEach[propertyReference.addAll(it.attributes.copyAttributes.map[transformAttribute])]

		// map methods (request/reponse and broadcast)
		val methodReference = method

		//method.addAll(src.methods.map [transformMethod])	
		parentInterfaces.forEach[methodReference.addAll(it.methods.copyMethods.map[transformMethod])]

		//signal.addAll(src.broadcasts.map [transformBroadcast])
		val signalReference = signal

		parentInterfaces.forEach[signalReference.addAll(it.broadcasts.copyBroadcasts.map[transformBroadcast])]
		addBacklink(it, src)
	}

	/**
	 * This method is to copy all attributes and add them to child attribute list
	 */
	def copyAttributes(EList<FAttribute> original) {
		val copy = newArrayList
		original.forEach[copy.add(EcoreUtil.copy(it))]
		copy
	}

	/**
	 * This method is to copy all methods and add them to child method list
	 */
	def copyMethods(EList<FMethod> original) {
		val copy = newArrayList
		original.forEach[copy.add(EcoreUtil.copy(it))]
		copy
	}

	/**
	 * This method is to copy all broadCasts and add them to child broadcast list
	 */
	def copyBroadcasts(EList<FBroadcast> original) {
		val copy = newArrayList
		original.forEach[copy.add(EcoreUtil.copy(it))]
		copy
	}

	def create DbusxmlFactory::eINSTANCE.createPropertyType transformAttribute(FAttribute src) {
		name = src.name
		type = transformType2TypeString(src.type, src.array)
		if (src.isReadonly)
			access = AccessType::READ
		else
			access = AccessType::READWRITE
		addBacklink(it, src)
	}

	def create DbusxmlFactory::eINSTANCE.createMethodType transformMethod(FMethod src) {
		name = src.name
		doc = src.createDoc
		arg.addAll(src.inArgs.map[transformArgument(DirectionType::IN)])
		arg.addAll(src.outArgs.map[transformArgument(DirectionType::OUT)])
		if(src.errors !== null) error.addAll(src.errors.createErrors)
		addBacklink(it, src)
	}

	def create DbusxmlFactory::eINSTANCE.createSignalType transformBroadcast(FBroadcast src) {
		name = src.name
		doc = src.createDoc
		arg.addAll(src.outArgs.map[transformArgument(DirectionType::OUT)])
		addBacklink(it, src)
	}

	def create DbusxmlFactory::eINSTANCE.createArgType transformArgument(FArgument src, DirectionType dir) {
		direction = dir
		name = src.name
		type = transformType2TypeString(src.type, src.array)
		doc = src.createDoc
		addBacklink(it, src)
	}

	def create DbusxmlFactory::eINSTANCE.createDocType createDoc(FArgument src) {

		if (src.type.derived !== null && src.type.derived.comment !== null) {
			line.addLines(src.name + " (of type " + src.type.derived.name + ")", src.description)
			line.addAll(src.type.derived.lineComment)
		} else {
			line.addLines(src.name, src.description)
		}
	}

	def private DocType createDoc(FModelElement src) {
		if (src.comment !== null) {
			val it = DbusxmlFactory::eINSTANCE.createDocType
			line.addLines(src.name, src.description)
			it
		} else {
			null
		}
	}

	def private addLines(List<String> target, String prefix, String multiline) {
		val lines = multiline.split("(\r)?\n")
		var i = 0
		for (s : lines) {
			if (i == 0 && prefix != "")
				target.add(prefix + " = " + s.trim)
			else
				target.add(s.trim)
			i = i + 1
		}
	}

	def dispatch List<String> lineComment(FType src) {
		newArrayList("lineComment to be defined")
	}

	def dispatch List<String> lineComment(FArrayType src) {
		val s = newArrayList(src.name + " = array[" + src.elementType.label + "]")
		if (src.elementType.derived !== null)
			s.addAll(src.elementType.derived.lineComment)
		s
	}

	def dispatch List<String> lineComment(FMapType src) {
		val s = newArrayList(src.name + " = dictionary(key=" + src.keyType.label + ",value=" + src.valueType.label + ")")
		if (src.keyType.derived !== null && src.valueType.derived !== null)
			s.addAll(lineCommentForDictionary(src.keyType.derived, src.valueType.derived))
		s
	}

	def dispatch lineCommentForDictionary(FType key, FType value) {
		val s = newArrayList("key = " + key.lineComment.head)
		s.addAll("value = " + value.lineComment.head)
		s
	}

	def dispatch lineCommentForDictionary(FEnumerationType key, FUnionType value) {
		val s = newArrayList("key = " + key.allEnumerators.map([name]).toString)
		for (enumerator : key.allEnumerators) {
			for (field : value.elements) {
				if (field.details.contains(enumerator.name)) {
					s.add(
						"key = " + enumerator.name + " (" + enumerator.value + "), value = of type '" +
							field.type.transformBasicType + "', " + enumerator.description)
				}
			}
		}
		s
	}

	def dispatch List<String> lineComment(FCompoundType src) {
		val fieldComment = [ FField e, int index |
			index + ": " + src.name + "." + e.name + " ('" + e.type.transformBasicType + "') = " + e.description
		]

		val typename = switch (src) {
			FStructType: "struct"
			FUnionType: "variant"
		}

		val s = newArrayList(src.name + " " + typename + src.elements.map([name]) + " = " + src.description)
		for (e : src.elements) {
			s.add(fieldComment.apply(e, src.elements.indexOf(e)))
		}
		s
	}

	def dispatch List<String> lineComment(FEnumerationType src) {
		newArrayList("enum" + src.allEnumerators.map[name + " (" + value + ")"])
	}

	def annotationComments(FModelElement src, FAnnotationType annotationType) {
		if (src.comment !== null) {
			src.comment.elements.filter([FAnnotation a|a.type == annotationType])
		}
	}

	def description(FModelElement src) {
		val c = src.annotationComments(FAnnotationType::DESCRIPTION)
		if(c !== null && c.size > 0) c.head.comment else "Description missing"
	}

	def details(FModelElement src) {
		val c = src.annotationComments(FAnnotationType::DETAILS)
		if(c !== null && c.size > 0) c.head.comment else "NO DETAILS AVAILABLE"
	}

	def List<FEnumerator> allEnumerators(FEnumerationType e) {

		val List<FEnumerator> ret = newArrayList()

		if (e.base !== null) {
			ret.addAll(e.base.allEnumerators)
		}

		ret.addAll(e.enumerators.immutableCopy)
		ret

	}

	def private createErrors(FEnumerationType src) {
		val valueMap = src.computeValues
		src.allEnumerators.map([toError(valueMap.get(it))])
	}

	// TODO: this method should be moved to org.franca.core 
	def private computeValues(FEnumerationType src) {
		val Map<FEnumerator, Integer> values = newHashMap
		var i = 0
		for (e : src.enumerators) {
			val v = e.computeEnumValue
			if (v !== null) {
				if (v <= i) {
					addIssue(IMPORT_WARNING, e, FrancaPackage::FENUMERATOR__VALUE,
						"Enumerator values must be increasing, ignoring value of '" + e.name + "'.")
				} else {
					i = v
				}
			}
			values.put(e, i)
			i = i + 1
		}
		values
	}

	def private Integer computeEnumValue(FEnumerator e) {
		if (e.value === null) {
			null
		} else {
			val v = e.value.evaluateIntegerOrParseString
			if (v === null) {
				addIssue(IMPORT_WARNING, e, FrancaPackage::FENUMERATOR__VALUE,
					"Invalid value for enumerator '" + e.name + "', must be integer.")
				null
			} else {
				if (v.intValue < 0) {
					addIssue(IMPORT_WARNING, e, FrancaPackage::FENUMERATOR__VALUE,
						"Invalid negative value for enumerator '" + e.name + "'.")
					null
				} else
					new Integer(v.intValue)
			}
		}
	}

	def private create DbusxmlFactory::eINSTANCE.createErrorType toError(FEnumerator e, Integer value) {
		name = mInterfaceName + ".Error." + e.name
		id = "" + value
		doc = e.createDoc
	}

	def String transformType2TypeString(FTypeRef src, boolean isArray) {
		val simple = src.transformSingleType2TypeString
		if (isArray) {
			'a' + simple
		} else {
			simple
		}
	}

	def String transformSingleType2TypeString(FTypeRef src) {
		if (src.derived === null) {
			src.transformBasicType
		} else {
			var type = src.derived
			switch (type) {
				FArrayType: type.transformArrayType
				FStructType: type.transformStructType
				FUnionType: type.transformVariantType
				FEnumerationType: type.transformEnumType
				FMapType: type.transformMapType
				FTypeDef: type.actualType.transformSingleType2TypeString
			}
		}
	}

	def String transformBasicType(FTypeRef src) {
		switch (src.predefined) {
			case FBasicTypeId::INT8:
				'n' // not_supported in DBus, use INT16 instead
			case FBasicTypeId::UINT8:
				'y'
			case FBasicTypeId::INT16:
				'n'
			case FBasicTypeId::UINT16:
				'q'
			case FBasicTypeId::INT32:
				'i'
			case FBasicTypeId::UINT32:
				'u'
			case FBasicTypeId::INT64:
				'x'
			case FBasicTypeId::UINT64:
				't'
			case FBasicTypeId::BOOLEAN:
				'b'
			case FBasicTypeId::STRING:
				's'
			case FBasicTypeId::FLOAT:
				'd' // not_supported in DBus, use DOUBLE instead
			case FBasicTypeId::DOUBLE:
				'd'
			case FBasicTypeId::BYTE_BUFFER:
				'ay'
			default: {
				addIssue(FEATURE_NOT_SUPPORTED, src, FrancaPackage::FTYPE_REF__PREDEFINED,
					"Basic Franca type " + src.predefined + " not supported by this transformation")
				'?'
			}
		}
	}

	def String transformArrayType(FArrayType src) {
		'a' + src.elementType.transformSingleType2TypeString
	}

	def String transformStructType(FStructType src) {
		if (src.isPolymorphicTree) {

			// polymorphic structs will be transported across DBus as variants.
			// the integer at the beginning is a tag which indicates the actual type.
			return "(iv)"
		} else {
			return "(" + src.getStructTypeString + ")"
		}
	}

	private def boolean isPolymorphicTree(FStructType src) {
		if (src.base !== null)
			src.base.isPolymorphicTree
		else
			src.isPolymorphic
	}

	private def String getStructTypeString(FStructType src) {
		var ts = ""

		// get type string of base struct (recursive call)
		if (src.base !== null) {
			ts = ts + src.base.getStructTypeString
		}

		// compile own type string
		for (e : src.elements) {
			ts = ts + e.type.transformType2TypeString(e.array)
		}

		ts
	}

	def String transformEnumType(FEnumerationType src) {
		if (src.base !== null) {

			// TODO: handle src.base
			addIssue(FEATURE_NOT_HANDLED_YET, src, FrancaPackage::FENUMERATION_TYPE__BASE,
				"Inheritance for enumeration " + src.name + " not yet supported")
		}

		'u'
	}

	def String transformVariantType(FUnionType src) {
		if (src.base !== null) {

			// TODO: handle src.base
			addIssue(FEATURE_NOT_HANDLED_YET, src, FrancaPackage::FUNION_TYPE__BASE,
				"Inheritance for union " + src.name + " not yet supported")
		}

		'(uv)'
	}

	def String transformMapType(FMapType src) {
		if (! src.keyType.isProperDictKey) {
			addIssue(FEATURE_NOT_SUPPORTED, src, FrancaPackage::FMAP_TYPE__KEY_TYPE,
				"DBus supports only basic types as dict-key (for map " + src.name + ")")
			return '?'
		}
		'a{' + src.keyType.transformSingleType2TypeString + src.valueType.transformSingleType2TypeString + '}'
	}

	def private getLabel(FTypeRef src) {
		if (src.derived !== null)
			src.derived.name
		else
			src.predefined.getName()
	}

	private def model(FTypeCollection it) {
		eContainer as FModel
	}
}
