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
import java.util.ArrayList

import model.emf.dbusxml.ArgType
import model.emf.dbusxml.DirectionType
import model.emf.dbusxml.DocType
import model.emf.dbusxml.InterfaceType
import model.emf.dbusxml.MethodType
import model.emf.dbusxml.NodeType
import model.emf.dbusxml.PropertyType
import model.emf.dbusxml.SignalType
import model.emf.dbusxml.typesystem.DBusArrayType
import model.emf.dbusxml.typesystem.DBusBasicType
import model.emf.dbusxml.typesystem.DBusDictType
import model.emf.dbusxml.typesystem.DBusStructType
import model.emf.dbusxml.typesystem.DBusType
import model.emf.dbusxml.typesystem.DBusTypeList
import model.emf.dbusxml.typesystem.DBusTypeParser
import model.emf.dbusxml.DbusxmlPackage

import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FrancaFactory
import org.franca.core.franca.FUnionType

import static org.franca.core.framework.TransformationIssue.*
import org.eclipse.emf.ecore.EObject

@Data
class TransformContext {
	EObject location
	int feature	
}

class DBus2FrancaTransformation {

	val static DEFAULT_NODE_NAME = "default"
	 
	@Inject extension TransformationLogger

	List<FType> newTypes
	
	def create FrancaFactory::eINSTANCE.createFModel transform (NodeType src) {
		clearIssues

		// transform node name to Franca package
		if (src.name===null) {
			addIssue(IMPORT_WARNING,
				src, DbusxmlPackage::NODE_TYPE__NAME,
				"D-Bus node without name, using default name '" + DEFAULT_NODE_NAME + "'")
			name = DEFAULT_NODE_NAME
		} else {
			name = src.name.replace('/', '_')
		}

		// transform all interfaces of this node
		interfaces.addAll(src.interface.map [transformInterface])
	}

	def getTransformationIssues() {
		return getIssues
	}

	def create FrancaFactory::eINSTANCE.createFInterface transformInterface (InterfaceType src) {
		name = src.name.split ("\\.").last
		if (src.version !== null)
			version = src.version.transformVersion
		if(src.doc.hasLines) {
			comment = src.doc.transformAnnotationBlock
		}
		
		newTypes = new ArrayList<FType>
		attributes.addAll(src.property.map [transformAttribute])
		methods.addAll(src.method.map [transformMethod])
		broadcasts.addAll(src.signal.map [transformBroadcast])
		types.addAll(newTypes)
	}

	def create FrancaFactory::eINSTANCE.createFVersion transformVersion (String ver) {
		var mm = ver.split('.')
		if (mm.size == 2) {
			major = new Integer(mm.get(0))
			minor = new Integer(mm.get(1))
		} else {
			major = 0
			minor = 0
		}
	}

	def create FrancaFactory::eINSTANCE.createFAttribute transformAttribute (PropertyType src) {
		val nameNormal = src.name.normalizeId 
		name = nameNormal
//		val te = src.type.transformAttributeType(nameNormal) 
		val te = src.type.transformTypeSig(nameNormal,
			new TransformContext(src, DbusxmlPackage::PROPERTY_TYPE__TYPE)) 
		type = te.type
		array = te.isArray
	}
	
	def create FrancaFactory::eINSTANCE.createFMethod transformMethod (MethodType src) {
		val nameNormal = src.name.normalizeId 
		name = nameNormal
		if(src.doc.hasLines) {
			comment = src.doc.transformAnnotationBlock
		}
		val srcInArgs = src.arg.filter(a | a.direction==DirectionType::IN).toList
		inArgs.addAll(srcInArgs.map[
			transformArg(nameNormal, "_inArg" + srcInArgs.indexOf(it))
		])
		val srcOutArgs = src.arg.filter(a | a.direction==DirectionType::OUT).toList
		outArgs.addAll(srcOutArgs.map[
			transformArg(nameNormal, "_outArg" + srcOutArgs.indexOf(it))
		])
	}

	def create FrancaFactory::eINSTANCE.createFBroadcast transformBroadcast (SignalType src) {
		name = src.name.normalizeId
		if(src.doc.hasLines) {
			comment = src.doc.transformAnnotationBlock
		}					
		outArgs.addAll(src.arg.map [transformArg(src.name, "_arg" + src.arg.indexOf(it))])
	}

	def create FrancaFactory::eINSTANCE.createFArgument transformArg (ArgType src, String namespace, String dfltName) {
		if (src.name!==null)
			name = src.name.normalizeId
		else
			name = dfltName
		val te = src.type.transformTypeSig(namespace + "_" + name,
			new TransformContext(src, DbusxmlPackage::ARG_TYPE__TYPE)) 
		type = te.type
		array = te.isArray
		if(src.doc.hasLines && src.primitiveType) {
			comment = src.doc.transformAnnotationBlock
		}					
	}

	// ANNOTATIONS 
	def private hasLines (DocType doc) {
		doc!==null && doc.line!==null && (!doc.line.empty)
	}
	
	def private create FrancaFactory::eINSTANCE.createFAnnotationBlock transformAnnotationBlock(DocType doc) {
		if (doc.line!==null && !doc.line.empty)				
			elements.add(transformAnnotation(doc))				
	}

	def boolean isPrimitiveType(ArgType argument) {
		argument.type.length == 1
	}

	def private create FrancaFactory::eINSTANCE.createFAnnotation transformAnnotation(DocType doc) {
		type = FAnnotationType::DESCRIPTION
		comment = doc.line.get(0)
	}
	// ANNOTATIONS

	def TypedElem transformTypeSig (String typeSig, String namespace, TransformContext tc) {
		//println("DBus2FrancaTransformation: parsing type-sig " + typeSig + " in namespace " + namespace)

		// as DBus doesn't have a detailed typesystem, we have to use an artificial typesystem here
		val srcType = new DBusTypeParser().parseSingleType(typeSig)
		if (srcType===null) {
			throw new RuntimeException("Couldn't parse type signature '" + typeSig + "'")
		}
		
		srcType.transformType(namespace, tc)
	}

	/**
	 * Transform an arbitrary type and create a Franca inline
	 * array "[]" if outermost DBusType is an array.
	 */
	def TypedElem transformType (DBusType src, String namespace, TransformContext tc) {
//		println("  transformType(" + src + ", " + namespace + ")")
		switch (src) {
			DBusBasicType: new TypedElem(src.transformBasicType(tc))
			DBusDictType: new TypedElem(src.transformDictType(namespace, tc).encapsulateTypeRef)
			DBusArrayType: src.createInlineArrayType(namespace, tc)
			DBusStructType: new TypedElem(src.transformStructOrUnion(namespace, tc))
			default: new TypedElem()
		}
	}	
	
	/**
	 * Transform an arbitrary type, but create an explicit Franca array type
	 * if outermost DBusType is an array.
	 */
	def FTypeRef transformTypeNoInlineArray (DBusType src, String namespace, TransformContext tc) {
		//println("  transformTypeNoInlineArray(" + src + ", " + namespace + ")")
		switch (src) {
			DBusBasicType: src.transformBasicType(tc)
			DBusDictType: src.transformDictType(namespace, tc).encapsulateTypeRef
			DBusArrayType: src.transformArrayType(namespace, tc).encapsulateTypeRef
			DBusStructType: src.transformStructOrUnion(namespace, tc)
			default: FrancaFactory::eINSTANCE.createFTypeRef
		}
	}	

	def private FTypeRef transformStructOrUnion (DBusStructType src, String namespace, TransformContext tc) {
		val elems = src.elementTypes
		if (elems.size==2 &&
			elems.get(0).isBasicType(DBusBasicType::DBUS_TYPE_UINT32) &&
			elems.get(1).isBasicType(DBusBasicType::DBUS_TYPE_VARIANT)
		) {
			// This is a "(uv)" type signature. This would be created when transforming
			// a Franca union type to DBus. Create the union type here.
			transformUnionType(namespace).encapsulateTypeRef
		} else {
			src.transformStructType(namespace, tc).encapsulateTypeRef
		}
	}	

	def private boolean isBasicType (DBusType t, DBusBasicType expected) {
		(t instanceof DBusBasicType) && (t as DBusBasicType)==expected
	}

	def FTypeRef transformBasicType (DBusBasicType src, TransformContext tc) {
		var it = FrancaFactory::eINSTANCE.createFTypeRef
		// @ignore src.name
		switch (src) {
			case DBusBasicType::DBUS_TYPE_BYTE: predefined = FBasicTypeId::UINT8
			case DBusBasicType::DBUS_TYPE_INT16: predefined = FBasicTypeId::INT16
			case DBusBasicType::DBUS_TYPE_UINT16: predefined = FBasicTypeId::UINT16
			case DBusBasicType::DBUS_TYPE_INT32: predefined = FBasicTypeId::INT32
			case DBusBasicType::DBUS_TYPE_UINT32: predefined = FBasicTypeId::UINT32
			case DBusBasicType::DBUS_TYPE_INT64: predefined = FBasicTypeId::INT64
			case DBusBasicType::DBUS_TYPE_UINT64: predefined = FBasicTypeId::UINT64
			case DBusBasicType::DBUS_TYPE_BOOLEAN: predefined = FBasicTypeId::BOOLEAN
			case DBusBasicType::DBUS_TYPE_DOUBLE: predefined = FBasicTypeId::DOUBLE
			case DBusBasicType::DBUS_TYPE_STRING: predefined = FBasicTypeId::STRING
			case DBusBasicType::DBUS_TYPE_OBJECT_PATH: predefined = FBasicTypeId::STRING
			case DBusBasicType::DBUS_TYPE_SIGNATURE: predefined = FBasicTypeId::STRING
			case DBusBasicType::DBUS_TYPE_UNIX_FD: predefined = FBasicTypeId::UINT32
			case DBusBasicType::DBUS_TYPE_VARIANT: {
				addIssue(IMPORT_WARNING,
					tc.location, tc.feature,
					"Variant type not supported by this transformation")
				predefined = FBasicTypeId::UNDEFINED // not_supported yet
			}
			default: predefined = FBasicTypeId::UNDEFINED
		}
		it
	}

	def encapsulateTypeRef (FType type) {
		val it = FrancaFactory::eINSTANCE.createFTypeRef
		derived = type;
		return it
	}

	def createInlineArrayType (DBusArrayType src, String namespace, TransformContext tc) {
		val elementType = src.elementType.transformTypeNoInlineArray(namespace, tc)
		new TypedElem(elementType, true);
	}	
	
	def create FrancaFactory::eINSTANCE.createFArrayType transformArrayType (DBusArrayType src, String namespace, TransformContext tc) {
		name = "t" + namespace + "Array"
		comment = createAnnotationBlock("array generated for DBus argument " + namespace)
		
		val ns = namespace + "Elem"
		elementType = src.elementType.transformTypeNoInlineArray(ns, tc)
		newTypes.add(it)
	}

	def create FrancaFactory::eINSTANCE.createFStructType transformStructType (DBusStructType src, String namespace, TransformContext tc) {
		buildStructType(src.elementTypes, namespace, "argument", tc)
	}

	def private buildStructType (FStructType it, DBusTypeList srcTypeList, String namespace, String tag, TransformContext tc) {
		name = "t" + namespace.toFirstUpper + "Struct"
		comment = createAnnotationBlock("struct generated for DBus " + tag + " " + namespace)
		var i = 1
		for(e : srcTypeList) {
			elements.add(e.transformField(namespace, "elem" + i, tc))
			i = i + 1
		}
		newTypes.add(it)
	}

	def create FrancaFactory::eINSTANCE.createFUnionType transformUnionType (String namespace) {
		buildUnionType(namespace, "argument")
	}

	def private buildUnionType (FUnionType it, String namespace, String tag) {
		name = "t" + namespace.toFirstUpper + "Union"
		comment = createAnnotationBlock("union generated for DBus " + tag + " " + namespace)

		// create dummy element for the union
		// TODO: we could retrieve the union's elements from some doc/line tags or
		// some D-Bus introspection xml annotations. 
		val dummy = FrancaFactory::eINSTANCE.createFField
		dummy.name = "dummy"
		var dt = FrancaFactory::eINSTANCE.createFTypeRef
		dt.predefined = FBasicTypeId::UINT8
		dummy.type = dt
		elements.add(dummy)

		newTypes.add(it)
	}

	def create FrancaFactory::eINSTANCE.createFMapType transformDictType (DBusDictType src, String namespace, TransformContext tc) {
		name = "t" + namespace + "Dict"
		//comment = createAnnotationBlock("...")
		keyType = src.keyType.transformTypeNoInlineArray(namespace+"Key", tc)
		valueType = src.valueType.transformTypeNoInlineArray(namespace+"Value", tc)
		newTypes.add(it)
	}

	def create FrancaFactory::eINSTANCE.createFField transformField (DBusType src, String namespace, String elementName, TransformContext tc) {
		// struct members do not have a name in DBus
		name = elementName
		val te = src.transformType(namespace + elementName.toFirstUpper, tc)
		type = te.type
		array = te.isArray
	}


	def createAnnotationBlock (String comment) {
		val it = FrancaFactory::eINSTANCE.createFAnnotationBlock
		elements.add(comment.transformDescription)
		return it		
	}
	
	def transformDescription (String description) {
		val it = FrancaFactory::eINSTANCE.createFAnnotation
		type = FAnnotationType::DESCRIPTION
		comment = description
		return it 
	}


	def normalizeId (String id) {
		var t = id
		while (t.startsWith(' ')) {
			t = t.substring(1, id.length)
		}
		while (t.endsWith(' ')) {
			t = t.substring(0, id.length-1)
		}
		//if (id != t) println("normalize '" + id + "' to '" + t + "'")
		return t
	} 
}


