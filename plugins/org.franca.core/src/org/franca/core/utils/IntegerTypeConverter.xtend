package org.franca.core.utils

import org.franca.core.franca.FModel
import org.franca.core.franca.FTypeRef
import org.eclipse.xtend.typesystem.emf.EcoreUtil2
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FIntegerInterval
import java.math.BigInteger

/**
 * Converter for all integer type references of a model. 
 * 
 * It provides conversions from ranged integer types to predefined basic
 * integer types and vice versa. For the conversion from ranged integers to
 * predefined integers it can be configured if unsigned types are available
 * or not. E.g., for converting a Franca model towards a Java platform the
 * usage of unsigned types can be disallowed.
 * 
 * The input model is transformed in-place, i.e., its FTypeRef objects are
 * converted directly.
 * 
 * This class can be used as a preprocessor for existing code generators or
 * transformations. 
 *   
 * @see https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=18
 * 
 * @author Klaus Birken (itemis AG)
 */
class IntegerTypeConverter {
	
	/**
	 * Convert all ranged integers in the model to predefined integer types
	 * 
	 * @param model the model which should be converted
	 * @param haveUnsigned flag if unsigned types should be used as result
	 */
	def static void removeRangedIntegers (FModel model, boolean haveUnsigned) {
		val all = EcoreUtil2::allContents(model)
		val typerefs = all.filter(typeof(FTypeRef))
		for(tref : typerefs) {
			if (tref.interval!=null) {
				val range = tref.interval
				//println("typeref range: " + range.lowerBound + " .. " + range.upperBound)
				var basicType = range.computeNextBasicType(haveUnsigned)
				if (basicType==null) {
					// the range doesn't fit into a 64-bit type
					// as a fallback, we choose the biggest basic type which is available
					basicType = computeBiggestBasicType(range.lowerBound, haveUnsigned)
				}
				//println("   result: basicType=" + basicType.toString)
				
				// actually manipulate FTypeRef and exchange interval by basic type
				tref.interval = null
				tref.predefined = basicType
			}
		}
	}

	/**
	 * Convert all predefined integer types in the model to ranged integers
	 * 
	 * @param model the model which should be converted
	 */
	def static void removePredefinedIntegers (FModel model) {
		// TODO
	}

	
	/**
	 * Compute the smallest predefined type which can represent the given interval.
	 * 
	 * @param iv the interval which should be represented
	 * @param haveUnsigned true if unsigned types can be used
	 * @result the smallest predefined type which can represent the interval 
	 */
	def private static FBasicTypeId computeNextBasicType (FIntegerInterval iv, boolean haveUnsigned) {
		if (iv.lowerBound==null || iv.upperBound==null) {
			// lower bound is minInt and/or upper bound is maxInt
			return null
		}

		// check types against bounds in increasing order
		for(b : #{ 8, 16, 32, 64}) {
			if (haveUnsigned) {
				// check first if it fits into a b-bit unsigned
				// range is: 0 .. 2^b-1
				val p1 = BigInteger.ONE.shiftLeft(b)
				val max1 = p1.subtract(BigInteger.ONE)
				if (iv.lowerBound.compareTo(BigInteger.ZERO)>=0 &&
					iv.upperBound.compareTo(max1)<=0
				) {
					return getUnsignedBasicType(b)
				}
			}
			
			// now check if it fits into a b-bit signed
				// range is: -2^(b-1) .. 2^(b-1)-1
			val p2 = BigInteger.ONE.shiftLeft(b-1)
			val min2 = -p2
			val max2 = p2.subtract(BigInteger.ONE)
			if (iv.lowerBound.compareTo(min2)>=0 &&
				iv.upperBound.compareTo(max2)<=0
			) {
				return getSignedBasicType(b)
			}
		}

		// doesn't fit into 64-bit
		return null
	}
	
	/**
	 * Compute which basic type should be used as a fallback if the range
	 * doesn't fit into any available predefined type.
	 */
	def private static FBasicTypeId computeBiggestBasicType(BigInteger lowerBound, boolean haveUnsigned) {
		if (haveUnsigned && lowerBound!=null && lowerBound.compareTo(BigInteger.ZERO)>=0) {
			// lower bound is >=0 and we may use unsigned types
			getUnsignedBasicType(64)
		} else {
			getSignedBasicType(64)
		}
	}
	
	def private static FBasicTypeId getSignedBasicType(int bits) {
		switch (bits) {
			case 8: FBasicTypeId::INT8
			case 16: FBasicTypeId::INT16
			case 32: FBasicTypeId::INT32
			case 64: FBasicTypeId::INT64
			default: throw new RuntimeException("No signed integer type with " + bits + " bits")
		}
	}

	def private static FBasicTypeId getUnsignedBasicType(int bits) {
		switch (bits) {
			case 8: FBasicTypeId::UINT8
			case 16: FBasicTypeId::UINT16
			case 32: FBasicTypeId::UINT32
			case 64: FBasicTypeId::UINT64
			default: throw new RuntimeException("No unsigned integer type with " + bits + " bits")
		}
	}
}
