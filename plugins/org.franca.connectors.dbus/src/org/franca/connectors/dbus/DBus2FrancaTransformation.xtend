package org.franca.connectors.dbus

import com.google.inject.Inject
import java.util.List
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
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FrancaFactory

class DBus2FrancaTransformation {

	@Inject extension TransformationLogger

	List<FType> newTypes
	
	def create FrancaFactory::eINSTANCE.createFModel transform (NodeType src) {
		name = src.name
		interfaces.addAll(src.interface.map [transformInterface])
	}

	def getTransformationIssues() {
		return getIssues
	}

	def create FrancaFactory::eINSTANCE.createFInterface transformInterface (InterfaceType src) {
		name = src.name
		if (src.version != null)
			version = src.version.transformVersion
		if(src.doc != null) {
			comment = src.doc.transformAnnotationBlock()
		}			
		newTypes = types
		attributes.addAll(src.property.map [transformAttribute])
		methods.addAll(src.method.map [transformMethod])
		broadcasts.addAll(src.signal.map [transformBroadcast])
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
		val te = src.type.transformTypeSig(nameNormal) 
		type = te.type
		array = if (te.isArray) "[]" else null
	}
	
//	def private transformAttributeType (String typeSig, String namespace) {
//		// as DBus doesn't have a detailed typesystem, we have to use an artificial typesystem here
//		val srcTypeList = new DBusTypeParser().parseTypeList(typeSig)
//		if (srcTypeList.size==1)
//			// this is a single-type attribute, just convert it
//			return srcTypeList.get(0).transformType(namespace)
//		else {
//			// this is a multi-type attribute, create synthetic struct type
//			// NB: didn't find spec or examples for multi-type attributes, just support it here
//			val it = FrancaFactory::eINSTANCE.createFStructType
//			buildStructType(srcTypeList, namespace, "property")
//			return new TypedElem(it.encapsulateTypeRef)
//		}
//	}

	def create FrancaFactory::eINSTANCE.createFMethod transformMethod (MethodType src) {
		val nameNormal = src.name.normalizeId 
		name = nameNormal
		if(src.doc != null) {
			comment = src.doc.transformAnnotationBlock()
		}
		inArgs.addAll(src.arg.filter(a | a.direction==DirectionType::IN).map [transformArg(nameNormal)])
		outArgs.addAll(src.arg.filter(a | a.direction==DirectionType::OUT).map [transformArg(nameNormal)])
	}

	def create FrancaFactory::eINSTANCE.createFBroadcast transformBroadcast (SignalType src) {
		name = src.name.normalizeId
		if(src.doc != null) {
			comment = src.doc.transformAnnotationBlock()
		}					
		outArgs.addAll(src.arg.map [transformArg(src.name)])
	}

	def create FrancaFactory::eINSTANCE.createFArgument transformArg (ArgType src, String namespace) {
		name = src.name.normalizeId
		val te = src.type.transformTypeSig(namespace + "_" + name) 
		type = te.type
		array = if (te.isArray) "[]" else null
		if(src.doc != null && src.primitiveType) {
			comment = src.doc.transformAnnotationBlock()
		}					
	}

	// ANNOTATIONS 
	def create FrancaFactory::eINSTANCE.createFAnnotationBlock transformAnnotationBlock(DocType doc) {				
		elements.add(transformAnnotation(doc))				
	}

	def boolean isPrimitiveType(ArgType argument) {
		argument.type.length == 1
	}

	def create FrancaFactory::eINSTANCE.createFAnnotation transformAnnotation(DocType doc) {
		type = FAnnotationType::DESCRIPTION
		comment = doc.line.get(0)
	}
	// ANNOTATION

	def TypedElem transformTypeSig (String typeSig, String namespace) {
		//println("DBus2FrancaTransformation: parsing type-sig " + typeSig + " in namespace " + namespace)

		// as DBus doesn't have a detailed typesystem, we have to use an artificial typesystem here
		val srcType = new DBusTypeParser().parseSingleType(typeSig)
		// TODO: check for null
		
		srcType.transformType(namespace)
	}

	/**
	 * Transform an arbitrary type and create a Franca inline
	 * array "[]" if outermost DBusType is an array.
	 */
	def TypedElem transformType (DBusType src, String namespace) {
		//println("  transformType(" + src + ", " + namespace + ")")
		switch (src) {
			DBusBasicType: new TypedElem(src.transformBasicType)
			DBusDictType: new TypedElem(src.transformDictType(namespace).encapsulateTypeRef)
			DBusArrayType: src.createInlineArrayType(namespace)
			DBusStructType: new TypedElem(src.transformStructType(namespace).encapsulateTypeRef)
			default: new TypedElem()
		}
	}	
	
	/**
	 * Transform an arbitrary type, but create an explicit Franca array type
	 * if outermost DBusType is an array.
	 */
	def FTypeRef transformTypeNoInlineArray (DBusType src, String namespace) {
		//println("  transformTypeNoInlineArray(" + src + ", " + namespace + ")")
		switch (src) {
			DBusBasicType: src.transformBasicType
			DBusDictType: src.transformDictType(namespace).encapsulateTypeRef
			DBusArrayType: src.transformArrayType(namespace).encapsulateTypeRef
			DBusStructType: src.transformStructType(namespace).encapsulateTypeRef
			default: FrancaFactory::eINSTANCE.createFTypeRef
		}
	}	
	
	def FTypeRef transformBasicType (DBusBasicType src) {
		var it = FrancaFactory::eINSTANCE.createFTypeRef
		// @ignore src.name
		switch (src) {
			case DBusBasicType::DBUS_TYPE_INT8: predefined = FBasicTypeId::INT8
			case DBusBasicType::DBUS_TYPE_INT16: predefined = FBasicTypeId::INT16
			case DBusBasicType::DBUS_TYPE_UINT16: predefined = FBasicTypeId::UINT16
			case DBusBasicType::DBUS_TYPE_INT32: predefined = FBasicTypeId::INT32
			case DBusBasicType::DBUS_TYPE_UINT32: predefined = FBasicTypeId::UINT32
			case DBusBasicType::DBUS_TYPE_INT64: predefined = FBasicTypeId::INT64
			case DBusBasicType::DBUS_TYPE_UINT64: predefined = FBasicTypeId::UINT64
			case DBusBasicType::DBUS_TYPE_BOOLEAN: predefined = FBasicTypeId::BOOLEAN
			case DBusBasicType::DBUS_TYPE_DOUBLE: predefined = FBasicTypeId::DOUBLE
			case DBusBasicType::DBUS_TYPE_STRING: predefined = FBasicTypeId::STRING
			case DBusBasicType::DBUS_TYPE_VARIANT: predefined = FBasicTypeId::UNDEFINED // not_supported yet
			default: predefined = FBasicTypeId::UNDEFINED
		}
		it
	}

	def encapsulateTypeRef (FType type) {
		val it = FrancaFactory::eINSTANCE.createFTypeRef
		derived = type;
		return it
	}

	def createInlineArrayType (DBusArrayType src, String namespace) {
		val elementType = src.elementType.transformTypeNoInlineArray(namespace)
		new TypedElem(elementType, true);
	}	
	
	def create FrancaFactory::eINSTANCE.createFArrayType transformArrayType (DBusArrayType src, String namespace) {
		name = "t" + namespace + "Array"
		comment = createAnnotationBlock("array generated for DBus argument " + namespace)
		
		val ns = namespace + "Elem"
		elementType = src.elementType.transformTypeNoInlineArray(ns)
		newTypes.add(it)
	}

	def create FrancaFactory::eINSTANCE.createFStructType transformStructType (DBusStructType src, String namespace) {
		buildStructType(src.elementTypes, namespace, "argument")
	}

	def private buildStructType (FStructType it, DBusTypeList srcTypeList, String namespace, String tag) {
		name = "t" + namespace.toFirstUpper + "Struct"
		comment = createAnnotationBlock("struct generated for DBus " + tag + " " + namespace)
		var i = 1
		for(e : srcTypeList) {
			elements.add(e.transformField(namespace, "elem" + i))
			i = i + 1
		}
		newTypes.add(it)
	}

	def create FrancaFactory::eINSTANCE.createFMapType transformDictType (DBusDictType src, String namespace) {
		name = "t" + namespace + "Dict"
		//comment = createAnnotationBlock("...")
		keyType = src.keyType.transformTypeNoInlineArray(namespace+"Key")
		valueType = src.valueType.transformTypeNoInlineArray(namespace+"Value")
		newTypes.add(it)
	}

	def create FrancaFactory::eINSTANCE.createFField transformField (DBusType src, String namespace, String elementName) {
		// struct members do not have a name in DBus
		name = elementName
		val te = src.transformType(namespace)
		type = te.type
		array = if (te.isArray) "[]" else null
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


