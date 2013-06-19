/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import java.util.Set
import org.eclipse.etrice.core.room.LiteralType
import org.eclipse.etrice.core.room.PrimitiveType
import org.eclipse.etrice.core.room.RoomFactory
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FTypeRef
import org.eclipse.etrice.core.room.DataType
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FTypeDef
import org.eclipse.etrice.core.room.DataClass

import static extension org.franca.connectors.etrice.internal.CommentGenerator.*
import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*
import org.franca.core.franca.FType
import org.franca.core.franca.FMapType

class TypeGenerator {
	
	Set<PrimitiveType> newPrimitiveTypes = newHashSet
	Set<DataClass> newDataClasses = newHashSet
	
	def getNewPrimitiveTypes() {
		newPrimitiveTypes
	}

	def getNewDataClasses() {
		newDataClasses
	}

	def DataType transformType (FTypeRef src) {
		if (src.derived==null) {
			src.transformBasicType
		} else {
			var type = src.derived
			switch (type) {
				FArrayType:       type.transformArrayType 
				FStructType:      type.transformStructType
				FEnumerationType: type.transformEnumType
				FTypeDef:         type.transformTypeDef
				//TODO: FUnionType:       type.transformUnionType
				//TODO: FMapType:         type.transformMapType
			}
		}
	}
	
	def boolean isMultiType(FTypeRef type) {
		type.derived != null && type.derived.multiType
	}
	
	def isMultiType(FType type) {
		(type instanceof FArrayType) ||
		(type instanceof FMapType) ||
		(type instanceof FTypeDef && (type as FTypeDef).actualType.multiType)
	}

	
	def private PrimitiveType transformBasicType (FTypeRef src) {
		src.predefined.createPrimitiveType
	}
	

	def private transformArrayType (FArrayType src) {
		createArrayDC(src)
	}

	def private transformStructType (FStructType src) {
		createStructDC(src)
	}

	def private transformEnumType (FEnumerationType src) {
		createEnumDC(src)
	}

	def private transformTypeDef (FTypeDef src) {
		createTypeDefDC(src)
	}


//	def private create RoomFactory::eINSTANCE.createDataClass createByteArrayDC (String dcName, int n) {
//		name = dcName;
//		attributes.add(createUInt8Attribute(n))
//
//		newDataClasses.add(it)
//	}


	def private create RoomFactory::eINSTANCE.createDataClass createArrayDC (FArrayType src) {
		name = getDataClassName(src.name, "Array")

		var att = RoomFactory::eINSTANCE.createAttribute
		att.name = "value"
		att.size = 99;  // TODO: not_supported: dynamic arrays
		att.refType = src.elementType.transformType.toRefableType
		attributes.add(att)

		newDataClasses.add(it)
	}


	def private create RoomFactory::eINSTANCE.createDataClass createStructDC (FStructType src) {
		name = getDataClassName(src.name, "Struct")
		if (src.comment != null)		
			docu = src.comment.transformComment

		for(e : src.elements) {
			var att = RoomFactory::eINSTANCE.createAttribute
			att.name = e.name
			if (e.comment != null)
				att.docu = e.comment.transformComment
			att.refType = e.type.transformType.toRefableType
			attributes.add(att)
		}

		newDataClasses.add(it)
	}

	
	def private create RoomFactory::eINSTANCE.createDataClass createEnumDC (FEnumerationType src) {
		name = getDataClassName(src.name, "Enum")
		docu = src.comment.transformComment
		
		for(e : src.enumerators) {
			var doc = e.name
			if (e.value!=null)
				doc = doc + " = " + e.value
			if (e.comment!=null)
				doc = doc + " // " + e.comment.transformCommentFlat
			docu.text.add(doc)
		}
		
		attributes.add(createUInt32Attribute)

		newDataClasses.add(it)
	}
	
	def private create RoomFactory::eINSTANCE.createDataClass createTypeDefDC (FTypeDef src) {
		name = getDataClassName(src.name, "Def")
		if (src.comment != null)		
			docu = src.comment.transformComment

		var att = RoomFactory::eINSTANCE.createAttribute
		att.name = "value"
		att.refType = src.actualType.transformType.toRefableType
		attributes.add(att)

		newDataClasses.add(it)
	}

	def private createUInt8Attribute (int n) {
		var it = RoomFactory::eINSTANCE.createAttribute
		name = "value"
		if (n>1)
			size = n
		refType = FBasicTypeId::UINT8.createPrimitiveType.toRefableType
		return it
	}

	def private createUInt32Attribute () {
		var it = RoomFactory::eINSTANCE.createAttribute
		name = "value"
		refType = FBasicTypeId::UINT32.createPrimitiveType.toRefableType
		return it
	}

	def create RoomFactory::eINSTANCE.createDataClass transformComplexType (String src, String comment) {
		name = src.toFirstUpper;
		docu = comment.transformComment
		attributes.add(createDummyAttribute)

		newDataClasses.add(it)
	}

	def private create RoomFactory::eINSTANCE.createAttribute createDummyAttribute() {
		name = "dummy"
		refType = FBasicTypeId::UINT8.createPrimitiveType.toRefableType
	}

	def private create RoomFactory::eINSTANCE.createPrimitiveType createPrimitiveType (FBasicTypeId src) {
		name = src.literal
		switch (src) {
			case FBasicTypeId::INT8:    initPrimiType(LiteralType::INT)
			case FBasicTypeId::UINT8:   initPrimiType(LiteralType::INT)
			case FBasicTypeId::INT16:   initPrimiType(LiteralType::INT)
			case FBasicTypeId::UINT16:  initPrimiType(LiteralType::INT)
			case FBasicTypeId::INT32:   initPrimiType(LiteralType::INT)
			case FBasicTypeId::UINT32:  initPrimiType(LiteralType::INT)
			case FBasicTypeId::INT64:   initPrimiType(LiteralType::INT) // TODO: not_supported in eTrice, emulate
			case FBasicTypeId::UINT64:  initPrimiType(LiteralType::INT) // TODO: not_supported in eTrice, emulate
			case FBasicTypeId::BOOLEAN: initPrimiType(LiteralType::BOOL)
			case FBasicTypeId::STRING:  initPrimiType(LiteralType::CHAR)
			case FBasicTypeId::FLOAT:   initPrimiType(LiteralType::REAL)
			case FBasicTypeId::DOUBLE:  initPrimiType(LiteralType::REAL)
			default:  initPrimiType(LiteralType::INT)  // TODO: correct? should be mapped to "undefined"
		}
		
		newPrimitiveTypes.add(it)
	}
	
	def private initPrimiType (PrimitiveType it, LiteralType lit) {
		type = lit
		targetName = switch (lit) {
			case LiteralType::BOOL: "java.lang.Boolean"
			case LiteralType::INT:  "java.lang.Integer"
			case LiteralType::REAL: "java.lang.Double"
			case LiteralType::CHAR: "java.lang.String"
			default: "UNKNOWN"
		}
		//TODO What is the use case for the separation of targetName and castName?
		//     Once the answer is found, here is the place to implement the different types:
		castName = targetName
		
		defaultValueLiteral = switch (lit) {
			case LiteralType::BOOL: "false"
			case LiteralType::INT:  "0"
			case LiteralType::REAL: "0.0"
			case LiteralType::CHAR: '""'
			default: "UNKNOWN"
		}
	}

	def getDataClassName (String id, String prefix) {
		prefix + id.toFirstUpper
	}


}