package org.franca.tools.contracts.tracegen.traces

import org.franca.core.franca.FDeclaration
import org.franca.core.franca.FTypeRef
import java.util.logging.Logger
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FMapType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FArrayType
import org.franca.tools.contracts.tracegen.types.SimulatedArrayValue
import java.util.logging.Level
import org.franca.tools.contracts.tracegen.types.SimulatedCompound
import org.franca.tools.contracts.tracegen.types.SimulatedMapValue

class ValuedDeclaration {
	
	FDeclaration declaration
	Object value
	boolean isPrimitive
	
	new(FDeclaration declaration) {
		this.declaration = declaration
		value = getSimulatedValue(declaration.type)
	}
	
	def private Object getSimulatedValue(FTypeRef typeRef) {
		val derived = typeRef.derived
		if (derived == null) {
			isPrimitive = true
			return ( getDefaultlyInitializedJavaObject(typeRef.predefined))
		} else {
			isPrimitive = false
			return getSimulatedValueClass(derived).newInstance
		}
	}
	
	def private dispatch Class<?> getSimulatedValueClass(FArrayType type) {
		typeof(SimulatedArrayValue)
	}
	def private dispatch Class<?> getSimulatedValueClass(FCompoundType type) {
		typeof(SimulatedCompound)
	}
	def private dispatch Class<?> getSimulatedValueClass(FEnumerationType type) {
		throw new UnsupportedOperationException
	}
	def private dispatch Class<?> getSimulatedValueClass(FMapType type) {
		typeof(SimulatedMapValue)
	}
	def private dispatch Class<?> getSimulatedValueClass(FTypeDef type) {
		throw new UnsupportedOperationException
	}
	
	def Object getDefaultlyInitializedJavaObject(FBasicTypeId id) {
		val name = id.literal
		switch (id) {
			case FBasicTypeId::INT8:    (0 /*as Byte*/)
			case FBasicTypeId::UINT8:   (0 /*as Short*/)
			case FBasicTypeId::INT16:   (0 as Integer)
			case FBasicTypeId::UINT16:  (0 as Integer)
			case FBasicTypeId::INT32:   (0 as Integer)
			case FBasicTypeId::UINT32:  (0 as Integer)
			case FBasicTypeId::INT64:   (0l)
			case FBasicTypeId::UINT64:  (0l)
			case FBasicTypeId::BOOLEAN: (false)
			case FBasicTypeId::STRING:  ("")
			case FBasicTypeId::FLOAT:   (0.0f)
			case FBasicTypeId::DOUBLE:  (0.0d)
			default: {
				Logger::anonymousLogger.log(Level::SEVERE, "Unknown primitive type: '" + name + "'")
				throw new IllegalArgumentException("Unknown primitive type: '" + name + "'\nMaybe the type even was not a primitive one, but a user defined type!")
//				return (0 as Integer)
			}  
		}
	}
	
	def setValue(Object object) {
		if (isPrimitive) {
			value = object
		} else {
//			(value as SimulatedValue).setValue(object)
			throw new UnsupportedOperationException
		}
	}
	
	def getValue() {
		if (isPrimitive) {
			return value
		} else {
//			return (value as SimulatedValue).getValue
			throw new UnsupportedOperationException
		}
	}
}