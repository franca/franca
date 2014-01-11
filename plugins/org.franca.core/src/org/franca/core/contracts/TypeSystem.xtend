/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.contracts

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.franca.core.framework.FrancaHelpers
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
import org.franca.core.utils.FrancaModelCreator

import static org.franca.core.FrancaModelExtensions.*
import static org.franca.core.franca.FrancaPackage$Literals.*

import static extension org.franca.core.framework.FrancaHelpers.*

class TypeSystem {
	
	val FrancaModelCreator francaModelCreator = new FrancaModelCreator
	
	public static val BOOLEAN_TYPE = getBooleanType
	static val INTEGER_TYPE = getIntegerType
	static val STRING_TYPE = getStringType
	
	var IssueCollector collector
	
	/**
	 * Checks type of 'expr' against expected. 
	 */
	def FTypeRef checkType (FExpression expr, FTypeRef expected, IssueCollector collector, EObject loc, EStructuralFeature feat) {
		this.collector = collector
		expr.checkType(expected, loc, feat)
	}
	
	def private dispatch FTypeRef checkType (FConstant expr, FTypeRef expected, EObject loc, EStructuralFeature feat) {
		switch (expr) {
			FBooleanConstant: if (expected.checkIsBoolean(loc, feat)) BOOLEAN_TYPE else null
			FIntegerConstant: if (expected.checkIsInteger(loc, feat)) INTEGER_TYPE else null
			FStringConstant:  if (expected.checkIsString(loc, feat)) STRING_TYPE else null
			default: {
				addIssue("invalid type of constant value (expected " +
					FrancaHelpers::getTypeString(expected) + ")",
					loc, feat
				)
				null				
			}
		}
	}

	def private dispatch FTypeRef checkType (FUnaryOperation it, FTypeRef expected, EObject loc, EStructuralFeature feat) {
		if (FOperator::NEGATION.equals(op)) {
			val ok = expected.checkIsBoolean(loc, feat)
			val type = operand.checkType(BOOLEAN_TYPE, it, FUNARY_OPERATION__OPERAND)
			if (ok) type else null
		} else {
			addIssue("unknown unary operator", loc, feat)
			null
		}
	}

	def private dispatch FTypeRef checkType (FBinaryOperation it, FTypeRef expected, EObject loc, EStructuralFeature feat) {
		if (FOperator::AND.equals(op) || FOperator::OR.equals(op)) {
			val t1 = left.checkType(BOOLEAN_TYPE, it, FBINARY_OPERATION__LEFT)
			val t2 = right.checkType(BOOLEAN_TYPE, it, FBINARY_OPERATION__RIGHT)
			val ok = expected.checkIsBoolean(loc, feat)
			if (t1!=null && t2!=null && ok) BOOLEAN_TYPE else null	
		} else if (FOperator::EQUAL.equals(op) || FOperator::UNEQUAL.equals(op)) {
			// check that both operands have compatible type
			val t1 = left.checkType(null, it, FBINARY_OPERATION__LEFT)
			val t2 = right.checkType(null, it, FBINARY_OPERATION__RIGHT)
			if (checkOperandsType(t1, t2, loc, feat)) {
				val ok = expected.checkIsBoolean(loc, feat)
				if (ok) BOOLEAN_TYPE else null	
			} else {
				null
			}
		} else if (FOperator::SMALLER.equals(op) || FOperator::SMALLER_OR_EQUAL.equals(op) ||
			FOperator::GREATER_OR_EQUAL.equals(op) || FOperator::GREATER.equals(op)
		) {
			val t1 = left.checkType(null, it, FBINARY_OPERATION__LEFT)
			val t2 = right.checkType(null, it, FBINARY_OPERATION__RIGHT)
			if (checkOperandsType(t1, t2, loc, feat)) {
				val ok = expected.checkIsBoolean(loc, feat)
				if (ok) BOOLEAN_TYPE else null	
			} else {
				null
			}
		} else if (FOperator::ADDITION.equals(op) || FOperator::SUBTRACTION.equals(op) ||
			FOperator::MULTIPLICATION.equals(op) || FOperator::DIVISION.equals(op)
		) {
			// TODO: this doesn't work for floats and doubles
			// TODO: this also doesn't check for various integer sizes and unsigned/signed
			val t1 = left.checkType(INTEGER_TYPE, it, FBINARY_OPERATION__LEFT)
			val t2 = right.checkType(INTEGER_TYPE, it, FBINARY_OPERATION__RIGHT)
			if (checkOperandsType(t1, t2, loc, feat)) {
				val ok = expected.checkIsInteger(loc, feat)
				if (ok) t1 else null	
			} else {
				null
			}
		} else {
			addIssue("unknown binary operator '" + op + "'", loc, feat)
			null
		}
	}

	def private checkOperandsType (FTypeRef t1, FTypeRef t2, EObject loc, EStructuralFeature feat) {
		if (t1==null || t2==null) {
			false
		} else {
			if (! isCompatibleType(t1, t2) && ! isCompatibleType(t2, t1)) {
				addIssue("operands must have compatible type", loc, feat)
				false
			} else {
				true
			}
		}
	}	

	def private dispatch FTypeRef checkType (FQualifiedElementRef expr, FTypeRef expected, EObject loc, EStructuralFeature feat) {
		val result = expr.typeOf
		if (result==null) {
			addIssue("expected typed expression", loc, feat)
			null
		} else {
			if (expected==null) {
				result
			} else {
				if (isCompatibleType(expected, result)) {
					result
				} else {
					addIssue("invalid type (is " +
						FrancaHelpers::getTypeString(result) + ", expected " +
						FrancaHelpers::getTypeString(expected) + ")",
						loc, feat
					)
					null
				}
			}
		}
	}

	def FTypeRef getTypeOf (FQualifiedElementRef expr) {
		if (expr?.qualifier==null) {
			val te = expr?.element
			// TODO: support array types
			te.typeRef
		} else {
			expr?.field.typeRef;
		}
	}
	
	def private FTypeRef getTypeRef (FModelElement elem) {
		switch (elem) {
			FTypedElement: elem.type
			FEnumerator: francaModelCreator.createTypeRef(elem)	
			default: null // FModelElement without a type (maybe itself is a type)
		}
	}
	
	def private dispatch FTypeRef checkType (FCurrentError expr, FTypeRef expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			francaModelCreator.createTypeRef(expr)
		else {
			if (expected.isEnumeration) {
				val type = francaModelCreator.createTypeRef(expr)
				if (isCompatibleType(expected, type)) {
					type
				} else {
					addIssue("invalid type (is error enumerator, expected " +
						FrancaHelpers::getTypeString(expected) + ")",
						loc, feat
					)
					null
				}
			} else {
				addIssue("invalid error enumerator (expected " +
					FrancaHelpers::getTypeString(expected) + ")",
					loc, feat
				)
				null
			}
		}
	}
	
	def private dispatch FTypeRef checkType (FExpression expr, FTypeRef expected, EObject loc, EStructuralFeature feat) {
		addIssue("unknown expression type '" + expr.eClass.name + "'", loc, feat)
		null
	}
	

	def private checkIsBoolean (FTypeRef expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			return true

		val ok = expected.isBoolean
		if (!ok) {
			addIssue("invalid type (is Boolean, expected " +
				FrancaHelpers::getTypeString(expected) + ")",
				loc, feat
			)
		}
		ok
	}	

	def private checkIsInteger (FTypeRef expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			return true

		val ok = expected.isInteger
		if (!ok) {
			addIssue("invalid type (is Integer, expected " +
				FrancaHelpers::getTypeString(expected) + ")",
				loc, feat
			)
		}
		ok
	}	

	def private checkIsString (FTypeRef expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			return true

		val ok = expected.isString
		if (!ok) {
			addIssue("invalid type (is String, expected " +
				FrancaHelpers::getTypeString(expected) + ")",
				loc, feat
			)
		}
		ok
	}	

	def static private isOfCompatiblePrimitiveType(FTypeRef t1, FTypeRef t2) {
		if (t1.isBoolean) return t2.isBoolean
		if (t1.isInteger) return t2.isInteger
		if (t1.isString) return t2.isString
		if (t1.isFloatingPoint) return t2.isFloatingPoint
		
		return false
	}
	
	def static isCompatibleType(FTypeRef reference, FTypeRef type) {
		return (isOfCompatiblePrimitiveType(reference, type)) ||
			(reference.derived != null && getInheritationSet(type.derived).contains(reference.derived))
	}

	def static isSameType (FTypeRef t1, FTypeRef t2) {
		return isOfCompatiblePrimitiveType(t1, t2) ||
			(t1.derived!=null /*&& t2.derived!=null*/ && t1.derived==t2.derived)
	}

	def private static getIntegerType (/*FIntegerConstant value*/) {
		val it = FrancaFactory::eINSTANCE.createFTypeRef
		
		// TODO: we should be more specific here depending on the actual value
		predefined = FBasicTypeId::INT32
		it
	}

	def private static getBooleanType() {
		val it = FrancaFactory::eINSTANCE.createFTypeRef
		predefined = FBasicTypeId::BOOLEAN
		it
	}

	def private static getStringType() {
		val it = FrancaFactory::eINSTANCE.createFTypeRef
		predefined = FBasicTypeId::STRING
		it
	}

	def private addIssue (String mesg, EObject loc, EStructuralFeature feat) {
		if (collector!=null)
			collector.addIssue(mesg, loc, feat)
	}
	
}