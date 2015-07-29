package org.franca.core.typesystem

import org.franca.core.franca.FCurrentError
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FEvaluableElement
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.utils.FrancaModelCreator

import static org.franca.core.FrancaModelExtensions.*

import static extension org.franca.core.framework.FrancaHelpers.*

/**
 * This is a wrapper for the Franca FTypeRef class used by Franca's type system.
 * 
 * It takes into account if the referenced type is an implicit array type.
 */
class ActualType {

	val static francaModelCreator = new FrancaModelCreator

	val FTypeRef typeRef
	val boolean implicitArray
	
	private new (FTypeRef typeRef) {
		this.typeRef = typeRef
		this.implicitArray = false
	}

	private new (FTypedElement element) {
		this.typeRef = element.type
		this.implicitArray = element.array
	}
	
	private new (FEnumerator enumerator) {
		this.typeRef = francaModelCreator.createTypeRef(enumerator)
		this.implicitArray = false
	}
	
	private new (FCurrentError current) {
		this.typeRef = francaModelCreator.createTypeRef(current)
		this.implicitArray = false
	}
	
	def static typeFor(FTypeRef typeRef) {
		new ActualType(typeRef)
	}
	
	def static typeFor(FEvaluableElement element) {
		switch (element) {
			FTypedElement: new ActualType(element)
			FEnumerator: new ActualType(element)
			default: null
		}
	}

	def static typeFor(FCurrentError typeRef) {
		new ActualType(typeRef)
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
	
	def isNumber() {
		(! implicitArray) && typeRef.isNumber
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

		// both types must be implicit arrays or none of them
		if ((reference.implicitArray && !this.implicitArray) || (!reference.implicitArray && this.implicitArray))
			return false
		
		// special handling for enumeration types
		if (this.isEnumeration || reference.isEnumeration) {
			if (this.isEnumeration && reference.isEnumeration) {
				val bases = getInheritationSet(reference.derived)
				bases.contains(this.derived)
			} else
				false
			
		} else {
			// all other derived types
			val bases = getInheritationSet(this.derived)
			bases.contains(reference.derived)
		}
	}


	def getTypeString() {
		val ts = typeRef.getTypeString
		if (implicitArray)
			"array of " + ts
		else
			ts 
	}
}
