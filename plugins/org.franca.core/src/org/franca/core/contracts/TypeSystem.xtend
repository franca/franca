/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.contracts

import java.math.BigInteger
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FConstant
import org.franca.core.franca.FCurrentError
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FExpression
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FOperator
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FStringConstant
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FrancaFactory
import org.franca.core.franca.FDoubleConstant
import org.franca.core.franca.FFloatConstant
import org.franca.core.utils.FrancaModelCreator

import static org.franca.core.FrancaModelExtensions.*
import static org.franca.core.franca.FrancaPackage$Literals.*

import static extension org.franca.core.framework.FrancaHelpers.*

import static org.franca.core.contracts.ComparisonResult.*
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FTypeCast
import org.franca.core.franca.FType

class TypeSystem {
	
	val FrancaModelCreator francaModelCreator = new FrancaModelCreator
	var IssueCollector collector // is set by checkType
	
	public static val BOOLEAN_TYPE = FrancaFactory::eINSTANCE.createFTypeRef => [predefined = FBasicTypeId::BOOLEAN]
	public static val ANY_INTEGER_TYPE = FrancaFactory::eINSTANCE.createFTypeRef => [interval = FrancaFactory::eINSTANCE.createFIntegerInterval]
	public static val FLOAT_TYPE = FrancaFactory::eINSTANCE.createFTypeRef => [predefined = FBasicTypeId::FLOAT]
	public static val DOUBLE_TYPE = FrancaFactory::eINSTANCE.createFTypeRef => [predefined = FBasicTypeId::DOUBLE]
	public static val STRING_TYPE = FrancaFactory::eINSTANCE.createFTypeRef => [predefined = FBasicTypeId::STRING]
	
	static val integerMapping = #{
		FBasicTypeId::INT8 -> (FrancaFactory::eINSTANCE.createFIntegerInterval => [
							lowerBound = -BigInteger::valueOf(2).pow(7)
							upperBound = BigInteger::valueOf(2).pow(7).subtract(BigInteger::ONE)
					]),
		FBasicTypeId::UINT8 -> (FrancaFactory::eINSTANCE.createFIntegerInterval => [
							lowerBound = BigInteger::ZERO
							upperBound = BigInteger::valueOf(2).pow(8).subtract(BigInteger::ONE)
					]),
		FBasicTypeId::INT16 -> (FrancaFactory::eINSTANCE.createFIntegerInterval => [
							lowerBound = -BigInteger::valueOf(2).pow(15)
							upperBound = BigInteger::valueOf(2).pow(15).subtract(BigInteger::ONE)
					]),
		FBasicTypeId::UINT16 -> (FrancaFactory::eINSTANCE.createFIntegerInterval => [
							lowerBound = BigInteger::ZERO
							upperBound = BigInteger::valueOf(2).pow(16).subtract(BigInteger::ONE)
					]),
		FBasicTypeId::INT32 -> (FrancaFactory::eINSTANCE.createFIntegerInterval => [
							lowerBound = -BigInteger::valueOf(2).pow(31)
							upperBound = BigInteger::valueOf(2).pow(31).subtract(BigInteger::ONE)
					]),
		FBasicTypeId::UINT32 -> (FrancaFactory::eINSTANCE.createFIntegerInterval => [
							lowerBound = BigInteger::ZERO
							upperBound = BigInteger::valueOf(2).pow(32).subtract(BigInteger::ONE)
					]),
		FBasicTypeId::INT64 -> (FrancaFactory::eINSTANCE.createFIntegerInterval => [
							lowerBound = -BigInteger::valueOf(2).pow(63)
							upperBound = BigInteger::valueOf(2).pow(63).subtract(BigInteger::ONE)
					]),
		FBasicTypeId::UINT64 -> (FrancaFactory::eINSTANCE.createFIntegerInterval => [
							lowerBound = BigInteger::ZERO
							upperBound = BigInteger::valueOf(2).pow(64).subtract(BigInteger::ONE)
					])
	}
	
	def private toInterval(FTypeRef ref) {
		val interval = ref.actualInterval
		if (interval != null) return interval
		val predef = ref.actualPredefined
		if (predef != null) return integerMapping.get(predef)
		
		return null
	}
	
	def private createInterval(BigInteger lower, BigInteger upper) {
		FrancaFactory::eINSTANCE.createFTypeRef => [
			interval = FrancaFactory::eINSTANCE.createFIntegerInterval => [
				lowerBound = lower
				upperBound = upper
			]
		]
	}
	
	new (IssueCollector collector) {
		this.collector = collector
	}
	
	def dispatch FTypeRef checkType (FConstant expr, EObject loc, EStructuralFeature feat) {
		switch (expr) {
			FBooleanConstant: BOOLEAN_TYPE
			FIntegerConstant: {
				val value = (expr as FIntegerConstant).^val;
				createInterval(value, value)
			}
			FFloatConstant: FLOAT_TYPE
			FDoubleConstant: DOUBLE_TYPE
			FStringConstant:  STRING_TYPE
			default: {
				addIssue("unknown meta type " + expr.eClass.name + " for constant ", loc, feat);
				null
			}
		}
//		switch (expr) {
//			FBooleanConstant: if (expected.checkIsBoolean(loc, feat)) BOOLEAN_TYPE else null
//			FIntegerConstant: {
//				if (expected.checkIsInteger(loc, feat)) {
//					val value = (expr as FIntegerConstant).^val
//					val type = createInterval(value, value)
//					if (expected == null) {
//						return type
//					}
//					val comp = compareCardinality(type, expected)
//					if (comp == SMALLER || comp == EQUAL) {
//						return type
//					} else {
//						val tempInterval = expected.toInterval
//						addIssue("constant value out of range (expected to be between " +
//							tempInterval.lowerBound + " and " + tempInterval.upperBound + ")",
//							loc, feat
//						)
//					}
//				}
//				return null
//			}
//			FFloatConstant: if (expected.checkIsFloat(loc, feat)) FLOAT_TYPE else null
//			FDoubleConstant: if (expected.checkIsDouble(loc, feat)) DOUBLE_TYPE else null
//			FStringConstant:  if (expected.checkIsString(loc, feat)) STRING_TYPE else null
//			default: {
//				addIssue("invalid type of constant value (expected " +
//					FrancaHelpers::getTypeString(expected) + ")",
//					loc, feat
//				)
//				null				
//			}
//		}
	}
	
	def dispatch FTypeRef checkType (FTypeCast it, EObject loc, EStructuralFeature feat) {
		val actualType = it.expression.checkType(it, FTYPE_CAST__EXPRESSION);
		
			if (actualType == null) {
				null
			} else if (!it.type.isAssignableTo(actualType)) {
				if (it.type != null) addIssue(actualType.typeString + " can not be cast to " + type.typeString, loc, feat);
				null
			} else {		
				type
			}
	}

	def dispatch FTypeRef checkType (FUnaryOperation it, EObject loc, EStructuralFeature feat) {
		if (FOperator::NEGATION.equals(op)) {
			val type = operand.checkType(it, FUNARY_OPERATION__OPERAND)
			if (! type.isBoolean) {
				if (type != null) {
					addIssue("invalid type (is " + type.typeString + ", expected boolean)", loc, feat)					
				}
				null
			} else {
				type
			}
		} else {
			addIssue("unknown unary operator", loc, feat)
			null
		}
	}

	def dispatch FTypeRef checkType (FBinaryOperation it, EObject loc, EStructuralFeature feat) {
		if (FOperator::AND.equals(op) || FOperator::OR.equals(op)) {
			val t1 = left.checkType(it, FBINARY_OPERATION__LEFT)
			val t2 = right.checkType(it, FBINARY_OPERATION__RIGHT)
			if (! (t1.isBoolean && t2.isBoolean)) {
				if (t1 != null) {
					addIssue("invalid type (is " + t1.typeString + ", expected boolean)", it, FBINARY_OPERATION__LEFT)
				}
				if (t2 != null) {
					addIssue("invalid type (is " + t1.typeString + ", expected boolean)", it, FBINARY_OPERATION__RIGHT)
				}
				null
			} else {
				BOOLEAN_TYPE
			}
		} else if (FOperator::EQUAL.equals(op) || FOperator::UNEQUAL.equals(op)) {
			// check that both operands have compatible type
			val t1 = left.checkType(it, FBINARY_OPERATION__LEFT)
			val t2 = right.checkType(it, FBINARY_OPERATION__RIGHT)
			if (isComparable(t1, t2, loc, feat)) {
				BOOLEAN_TYPE
			} else {
				if (! (t1 == null || t2 == null)) {
					addIssue("the types " + t1.typeString + " and " + t2.typeString + " are not comparable",
						loc, feat
					)
					//TODO vermutlich kann ich auf loc und feat verzichten, beides kommt jetzt wohl aus it
				}
				null
			}
		} else if (FOperator::SMALLER.equals(op) || FOperator::SMALLER_OR_EQUAL.equals(op) ||
			FOperator::GREATER_OR_EQUAL.equals(op) || FOperator::GREATER.equals(op)
		) {
			val t1 = left.checkType(it, FBINARY_OPERATION__LEFT)
			val t2 = right.checkType(it, FBINARY_OPERATION__RIGHT)
			if (isOrderDefined(t1, t2, loc, feat)) {
				BOOLEAN_TYPE
			} else {
				if (t1 != null && t2 != null) {
					addIssue("there is no order defined between elements of type " + t1.typeString +
					         " and those of type " + t2.typeString, loc, feat
					)
				}
				null
			}
		} else if (FOperator::ADDITION.equals(op) || FOperator::SUBTRACTION.equals(op) ||
			FOperator::MULTIPLICATION.equals(op) || FOperator::DIVISION.equals(op)
		) {		
			val FTypeRef lhsType = left.checkType(it, FBINARY_OPERATION__LEFT)
			val FTypeRef rhsType = right.checkType(it, FBINARY_OPERATION__RIGHT)
			
			if (lhsType.isNumber && rhsType.isNumber) {
				val ComparisonResult typesCompared = compareCardinality(lhsType, rhsType)
				switch typesCompared {
					case GREATER : {lhsType}
					case EQUAL : {lhsType}
					case SMALLER : {rhsType}
					default : { // in case of two different constants, for example
						//TODO think about the assignable cases. what if compare cardinality says incompatible but assignable says something else?
						if (lhsType.isInteger && rhsType.isInteger) {
							val lhsInterval = toInterval(lhsType)
							val rhsInterval = toInterval(rhsType)
							createInterval(
								lhsInterval.lowerBound.min(rhsInterval.lowerBound),
								lhsInterval.upperBound.max(rhsInterval.upperBound)
							)
//								} else if (lhsType.isAssignableTo(rhsType)) {
//									rhsType
//								} else if (rhsType.isAssignableTo(lhsType)) {
//									lhsType
						} else {
							if (lhsType != null && rhsType != null) {
								addIssue("incompatible types " + lhsType.typeString + " and " + rhsType.typeString, loc, feat)
							}
							null
						}
					}
				}
			} else {
				null
			}
					
		} else {
			addIssue("unknown binary operator " + op, loc, feat)
			null
		}
	}

	def dispatch FTypeRef checkType (FQualifiedElementRef expr, EObject loc, EStructuralFeature feat) {
		getActualTypeOf(expr, loc, feat)
	}

	def public FTypeRef getActualTypeOf (FQualifiedElementRef expr, EObject loc, EStructuralFeature feat) {
		if (expr == null) {
			null
		} else {
			val element = (if (expr.qualifier == null) {
				expr.element
			} else {
				expr.field
			});
			if (element instanceof FType) {
				addIssue("references to types are not allowed here (referencing type " + element.name + ")", loc, feat);
				null
			} else {
				val result = element.typeRef.actualFTypeRef
				if (result == null) {
					addIssue(element.name + " is not a typed element", loc, feat);
				};
				result
			}
		}
	}
	
	def private FTypeRef getTypeRef (FModelElement elem) {
		switch (elem) {
			FTypedElement: elem.type
			FEnumerator: francaModelCreator.createTypeRef(elem)
			default: null // FModelElement without a type (maybe itself is a type)
		}
	}
	
	def dispatch FTypeRef checkType (FCurrentError expr, EObject loc, EStructuralFeature feat) {
		if (expr != null)
			francaModelCreator.createTypeRef(expr)
//		else {
//			if (expected.isEnumeration) {
//				val type = francaModelCreator.createTypeRef(expr)
//				if (isAssignableTo(type, expected)) {
//					type
//				} else {
//					addIssue("invalid type (is error enumerator, expected " +
//						FrancaHelpers::getTypeString(expected) + ")",
//						loc, feat
//					)
//					null
//				}
//			} else {
//				addIssue("invalid error enumerator (expected " +
//					FrancaHelpers::getTypeString(expected) + ")",
//					loc, feat
//				)
//				null
//			}
//		}
	}
	
	def dispatch FTypeRef checkType (FExpression expr, EObject loc, EStructuralFeature feat) {
		addIssue("unknown expression type " + expr.eClass.name, loc, feat)
		null
	}
	
//	def private checkIsBoolean (FTypeRef expected, EObject loc, EStructuralFeature feat) {
//		if (expected==null)
//			return true
//
//		val ok = expected.isBoolean
//		if (!ok) {
//			addIssue("invalid type (is Boolean, expected " +
//				FrancaHelpers::getTypeString(expected) + ")",
//				loc, feat
//			)
//		}
//		ok
//	}	
//
//	def private checkIsInteger (FTypeRef expected, EObject loc, EStructuralFeature feat) {
//		if (expected==null)
//			return true
//
//		val ok = expected.isInteger
//		if (!ok) {
//			addIssue("invalid type (is Integer, expected " +
//				FrancaHelpers::getTypeString(expected) + ")",
//				loc, feat
//			)
//		}
//		ok
//	}	
//
//	def private checkIsFloat (FTypeRef expected, EObject loc, EStructuralFeature feat) {
//		if (expected==null)
//			return true
//
//		val ok = expected.isFloat
//		if (!ok) {
//			addIssue("invalid type (is Float, expected " +
//				FrancaHelpers::getTypeString(expected) + ")",
//				loc, feat
//			)
//		}
//		ok
//	}
//
//	def private checkIsDouble (FTypeRef expected, EObject loc, EStructuralFeature feat) {
//		if (expected==null)
//			return true
//
//		val ok = expected.isDouble
//		if (!ok) {
//			addIssue("invalid type (is Double, expected " +
//				FrancaHelpers::getTypeString(expected) + ")",
//				loc, feat
//			)
//		}
//		ok
//	}
//	
//	def private checkIsString (FTypeRef expected, EObject loc, EStructuralFeature feat) {
//		if (expected==null)
//			return true
//
//		val ok = expected.isString
//		if (!ok) {
//			addIssue("invalid type (is String, expected " +
//				FrancaHelpers::getTypeString(expected) + ")",
//				loc, feat
//			)
//		}
//		ok
//	}	

	def private boolean isComparable(FTypeRef t1, FTypeRef t2, EObject loc, EStructuralFeature feat) {
		if (t1==null || t2==null) {
			return false
		} else {
//			if (isAssignableTo(t1, t2) || isAssignableTo(t2, t1)
			if ((t1.isBoolean && t2.isBoolean) || (t1.isString && t2.isString) ||
				(t1.isNumber && t2.isNumber) ||
				{
					val t1Derived = t1.actualDerived;
					val t2Derived = t2.actualDerived;
					t1Derived instanceof FEnumerationType && t1Derived instanceof FEnumerationType && 
			    	getInheritationSet(t1Derived).contains(t2Derived) || getInheritationSet(t2Derived).contains(t1Derived)
			    }
			) {
				return true
			}
//			addIssue(t1.typeString + " and " + t2.typeString + " are not comparable", loc, feat)				
			return false
		} 
	}
	
	/**
	 * @returns <code>True</code> if an order is defined between elements of t1 and elements of t2.
	 */
	def private boolean isOrderDefined(FTypeRef t1, FTypeRef t2, EObject loc, EStructuralFeature feat) {
		if (t1==null || t2==null) {
			return false
		} else {
			if (t1.isNumber && t2.isNumber) {
				return true
			}
//			addIssue("types are not ordered", loc, feat)				
			return false
		}
	}

	def private addIssue (String mesg, EObject loc, EStructuralFeature feat) {
		if (collector!=null)
			collector.addIssue(mesg, loc, feat)
	}
	
	def static boolean isAssignableTo(FTypeRef source, FTypeRef target) {
		val sourceDerived = getActualDerived(source)
		val targetDerived = getActualDerived(target)
		
		if (sourceDerived != null || targetDerived != null) {
			val possibleTypes = getInheritationSet(targetDerived)
			return possibleTypes.contains(sourceDerived)
		}
		
	    if (source.isNumber) {
			val comp = compareCardinality(source, target)
			return comp == EQUAL || comp == SMALLER
	    }
	    
	    return isBasicType(source, target.predefined)
	}
	
	def static ComparisonResult compareCardinality(FTypeRef tr1, FTypeRef tr2) {
		if (tr1.isDouble) {
			if (tr2.isDouble) return EQUAL
			if (tr2.isFloat) return GREATER
			return ComparisonResult::INCOMPATIBLE
		}
		if (tr1.isFloat) {
			if (tr2.isDouble) return SMALLER
			if (tr2.isFloat) return EQUAL
			return ComparisonResult::INCOMPATIBLE
		}
		
		val predef1 = tr1.actualPredefined
		val predef2 = tr2.actualPredefined
		val interval1 = if (predef1.basicIntegerId) integerMapping.get(predef1) else tr1.interval
		val interval2 = if (predef2.basicIntegerId) integerMapping.get(predef2) else tr2.interval
		
		if (interval1 !=null && interval2 != null) {
			val lowerBound1 = interval1.lowerBound
			val lowerBound2 = interval2.lowerBound
			val upperBound1 = interval1.upperBound
			val upperBound2 = interval2.upperBound
			
			if (lowerBound1 == null) { // lower bound interval1 -infinite
				if (lowerBound2 == null) { // lower bound both -infinite
					if (upperBound1 == null) {
						if (upperBound2 == null) {
							return EQUAL
						}
						return GREATER
					} else { // upperBound of interval1 finite
						if (upperBound2 == null) {
							return SMALLER
						}
						return ComparisonResult::fromInt(upperBound1.compareTo(upperBound2))
					}
				
				// left hand side GREATER
				} else if (upperBound1 == null || (upperBound2 != null && upperBound1.compareTo(upperBound2) >= 0)) {
					return GREATER
				}
			} else { // lower bound of interval1 is finite
				if (lowerBound2 == null) { // interval1 seems to be smaller
					if (upperBound2 == null || (upperBound1 != null && upperBound1.compareTo(upperBound2) <= 0)) {
						return SMALLER
					}
				} else {
					switch lowerBound1.compareTo(lowerBound2) {
						case -1 : { // interval1 seems to be GREATER
							if (upperBound1 == null || (upperBound2 != null && upperBound1.compareTo(upperBound2) >= 0)) {
								return GREATER
							}
						}
						case  0 : { // intervals seem to be EQUAL
							if (upperBound1 == null) {
								if (upperBound2 == null) {
									return EQUAL
								}
								return GREATER
							} else {
								if (upperBound2 == null) {
									return SMALLER
								}
								return ComparisonResult::fromInt(upperBound1.compareTo(upperBound2))
							}
						}
						case  1 : { // interval1 seems to be SMALLER
							if (upperBound2 == null || (upperBound1 != null && upperBound1.compareTo(upperBound2) <= 0)) {
								return SMALLER
							}
						}
					}
				}
			}
			// return ComparisonResult::INCOMPATIBLE
		}
		
		return ComparisonResult::INCOMPATIBLE
	}
	
}
