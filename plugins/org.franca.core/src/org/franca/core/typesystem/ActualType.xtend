package org.franca.core.typesystem

import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement

import static org.franca.core.FrancaModelExtensions.*

import static extension org.franca.core.framework.FrancaHelpers.*

class ActualType {
	
	val FTypeRef typeRef
	val boolean implicitArray
	
	new (FTypeRef typeRef) {
		this.typeRef = typeRef
		this.implicitArray = false
	}

	new (FTypedElement typedElement) {
		this.typeRef = typedElement.type
		this.implicitArray = typedElement.array
	}

	def getTypeRef() {
		typeRef
	}
	
	def getDerived() {
		typeRef.derived
	}

	def getActualDerived() {
		typeRef.actualDerived
	}

	def isImplicitArray() {
		implicitArray
	}
	
	def isBoolean() {
		(! implicitArray) && typeRef.isBoolean
	}

	def isInteger() {
		(! implicitArray) && typeRef.isInteger
	}
	
	def isFloat() {
		(! implicitArray) && typeRef.isFloat
	}
	
	def isDouble() {
		(! implicitArray) && typeRef.isDouble
	}
	
	def isFloatingPoint() {
		(! implicitArray) && typeRef.isFloatingPoint
	}
	
	def isString() {
		(! implicitArray) && typeRef.isString
	}
	
	def isByteBuffer() {
		(! implicitArray) && typeRef.isByteBuffer
	}
	

	def isExplicitArray() {
		(! implicitArray) && typeRef.isArray
	}
	
	def isArray() {
		implicitArray || typeRef.isArray
	}
	
	def isEnumeration() {
		(! implicitArray) && typeRef.isEnumeration
	}
	
	def isStruct() {
		(! implicitArray) && typeRef.isStruct
	}
	
	def isUnion() {
		(! implicitArray) && typeRef.isUnion
	}

	def isCompound() {
		(! implicitArray) && typeRef.isCompound
	}

	def isMap() {
		(! implicitArray) && typeRef.isMap
	}
	

	/**
	 * Checks if this type and another type have a compatible primitive type
	 * and are both either implicit arrays or plain types.
	 */
	def isOfCompatiblePrimitiveType(ActualType other) {
		if ((implicitArray && !other.implicitArray) || (!implicitArray && other.implicitArray))
			return false

		isOfCompatiblePrimitiveType(typeRef, other.typeRef)
	}
	
	/**
	 * Checks if two FTypeRefs have a compatible primitive type.
	 */
	def private static isOfCompatiblePrimitiveType(FTypeRef t1, FTypeRef t2) {
		if (t1.isBoolean) return t2.isBoolean
		if (t1.isInteger) return t2.isInteger
		if (t1.isString) return t2.isString
		if (t1.isFloatingPoint) return t2.isFloatingPoint
		return false
	}
	

	/**
	 * Checks if this type can be used as a replacement of type "reference".
	 */
	def isCompatibleType(ActualType reference) {
		if (isOfCompatiblePrimitiveType(reference))
			return true
		
		if (reference.derived==null || this.derived==null)
			return false

		if ((reference.implicitArray && !this.implicitArray) || (!reference.implicitArray && this.implicitArray))
			return false
		
		// all other derived types
		val bases = getInheritationSet(this.derived)
		return bases.contains(reference.derived)
	}


	def getTypeString() {
		val ts = typeRef.getTypeString
		if (implicitArray)
			"array of " + ts
		else
			ts 
	}
}
