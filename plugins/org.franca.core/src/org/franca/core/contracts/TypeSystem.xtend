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
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FConstant
import org.franca.core.franca.FCurrentError
import org.franca.core.franca.FDoubleConstant
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FExpression
import org.franca.core.franca.FFloatConstant
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FOperator
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FStringConstant
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FrancaFactory
import org.franca.core.typesystem.ActualType
import org.franca.core.utils.FrancaModelCreator

import static org.franca.core.FrancaModelExtensions.*
import static org.franca.core.franca.FrancaPackage.Literals.*

/**
 * The type system for Franca IDL expressions.
 * 
 * This is used for computing scopes and validation of expressions, constant definitions
 * and state variable declarations.
 */
class TypeSystem {
	
	val FrancaModelCreator francaModelCreator = new FrancaModelCreator
	
	// some predefined types
	public static val BOOLEAN_TYPE = getBooleanType
	public static val INTEGER_TYPE = getIntegerType
	public static val STRING_TYPE = getStringType
	static val FLOAT_TYPE = getFloatType
	static val DOUBLE_TYPE = getDoubleType
	
	var IssueCollector collector

	
	/**
	 * Checks type of input expression against expected. 
	 * 
	 * If expected==null, the type of the input expression will be computed.
	 * 
	 * @return type of input expression, or null on error
	 */
	def ActualType checkType (
		FExpression expr,
		ActualType expected,
		IssueCollector collector,
		EObject loc,
		EStructuralFeature feat
	) {
		this.collector = collector
		expr.checkType(expected, loc, feat)
	}
	
	def private dispatch ActualType checkType (FConstant expr, ActualType expected, EObject loc, EStructuralFeature feat) {
		switch (expr) {
			FBooleanConstant: if (expected.checkIsBoolean(loc, feat)) BOOLEAN_TYPE else null
			FIntegerConstant: if (expected.checkIsInteger(loc, feat)) INTEGER_TYPE else null
			FFloatConstant:   if (expected.checkIsFloat(loc, feat)) FLOAT_TYPE else null
			FDoubleConstant:  if (expected.checkIsDouble(loc, feat)) DOUBLE_TYPE else null
			FStringConstant:  if (expected.checkIsString(loc, feat)) STRING_TYPE else null
			default: {
				addIssue("invalid type of constant value (expected " +
					expected.getTypeString + ")",
					loc, feat
				)
				null				
			}
		}
	}

	def private dispatch ActualType checkType (FUnaryOperation it, ActualType expected, EObject loc, EStructuralFeature feat) {
		if (FOperator::NEGATION.equals(op)) {
			val ok = expected.checkIsBoolean(loc, feat)
			val type = operand.checkType(BOOLEAN_TYPE, it, FUNARY_OPERATION__OPERAND)
			if (ok) type else null
		} else {
			addIssue("unknown unary operator", loc, feat)
			null
		}
	}

	def private dispatch ActualType checkType (FBinaryOperation it, ActualType expected, EObject loc, EStructuralFeature feat) {
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

	def private checkOperandsType (ActualType t1, ActualType t2, EObject loc, EStructuralFeature feat) {
		if (t1==null || t2==null) {
			false
		} else {
			if (! t2.isCompatibleType(t1) && ! t1.isCompatibleType(t2)) {
				addIssue("operands must have compatible types", loc, feat)
				false
			} else {
				true
			}
		}
	}	

	def private dispatch ActualType checkType (FQualifiedElementRef expr, ActualType expected, EObject loc, EStructuralFeature feat) {
		val result = expr.typeOf
		if (result==null) {
			addIssue("expected typed expression", loc, feat)
			null
		} else {
			if (expected==null) {
				result
			} else {
				if (expected.isEnumeration && result.isEnumeration) {
					// expr is an enumerator value, check if its type is as expected
					val iset = getInheritationSet(expected.derived)
					if (iset.contains(result.derived))
						result
					else
						null
				} else {
					// default: check type compatibility
					if (result.isCompatibleType(expected)) {
						result
					} else {
						addIssue("invalid type (is " +
							result.getTypeString + ", expected " +
							expected.getTypeString + ")",
							loc, feat
						)
						null
					}
				}
			}
		}
	}

	/**
	 * Get the type of some qualified element reference.
	 * 
	 * E.g., the type of a struct element is computed from the type
	 * of the struct itself and its element definition.
	 */
	def ActualType getTypeOf (FQualifiedElementRef expr) {
		if (expr?.qualifier==null) {
			val te = expr?.element
			te.typeRef
		} else {
			expr?.field.typeRef;
		}
	}
	
	def private ActualType getTypeRef (FModelElement elem) {
		switch (elem) {
			FTypedElement: new ActualType(elem)
			FEnumerator: new ActualType(francaModelCreator.createTypeRef(elem))	
			default: null // FModelElement without a type (maybe itself is a type)
		}
	}
	
	def private dispatch ActualType checkType (FCurrentError expr, ActualType expected, EObject loc, EStructuralFeature feat) {
		if (expected==null) {
			new ActualType(francaModelCreator.createTypeRef(expr))
		} else {
			if (expected.isEnumeration) {
				val type = new ActualType(francaModelCreator.createTypeRef(expr))
				if (type.isCompatibleType(expected)) {
					type
				} else {
					addIssue("invalid type (is error enumerator, expected " +
						expected.getTypeString + ")",
						loc, feat
					)
					null
				}
			} else {
				addIssue("invalid error enumerator (expected " +
					expected.getTypeString + ")",
					loc, feat
				)
				null
			}
		}
	}
	
	def private dispatch ActualType checkType (FExpression expr, ActualType expected, EObject loc, EStructuralFeature feat) {
		addIssue("unknown expression type '" + expr.eClass.name + "'", loc, feat)
		null
	}
	

	def private checkIsBoolean (ActualType expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			return true

		val ok = expected.isBoolean
		if (!ok) {
			addIssue("invalid type (is Boolean, expected " +
				expected.getTypeString + ")",
				loc, feat
			)
		}
		ok
	}	

	def private checkIsInteger (ActualType expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			return true

		val ok = expected.isInteger
		if (!ok) {
			addIssue("invalid type (is Integer, expected " +
				expected.getTypeString + ")",
				loc, feat
			)
		}
		ok
	}	

	def private checkIsFloat (ActualType expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			return true

		val ok = expected.isFloat
		if (!ok) {
			addIssue("invalid type (is Float, expected " +
				expected.getTypeString + ")",
				loc, feat
			)
		}
		ok
	}

	def private checkIsDouble (ActualType expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			return true

		val ok = expected.isDouble
		if (!ok) {
			addIssue("invalid type (is Double, expected " +
				expected.getTypeString + ")",
				loc, feat
			)
		}
		ok
	}
	
	def private checkIsString (ActualType expected, EObject loc, EStructuralFeature feat) {
		if (expected==null)
			return true

		val ok = expected.isString
		if (!ok) {
			addIssue("invalid type (is String, expected " +
				expected.getTypeString + ")",
				loc, feat
			)
		}
		ok
	}	


	def static isSameType (ActualType t1, ActualType t2) {
		return t2.isOfCompatiblePrimitiveType(t1) ||
			(t1.derived!=null /*&& t2.derived!=null*/ && t1.derived==t2.derived)
	}

	def private static getIntegerType (/*FIntegerConstant value*/) {
		val tref = FrancaFactory::eINSTANCE.createFTypeRef
		
		// TODO: we should be more specific here depending on the actual value
		tref.predefined = FBasicTypeId::INT32
		new ActualType(tref)
	}
	
	def private static getFloatType (/*FIntegerConstant value*/) {
		val tref = FrancaFactory::eINSTANCE.createFTypeRef
		
		// TODO: we should be more specific here depending on the actual value
		tref.predefined = FBasicTypeId::FLOAT
		new ActualType(tref)
	}
	
	def private static getDoubleType (/*FIntegerConstant value*/) {
		val tref = FrancaFactory::eINSTANCE.createFTypeRef
		
		// TODO: we should be more specific here depending on the actual value
		tref.predefined = FBasicTypeId::DOUBLE
		new ActualType(tref)
	}

	def private static getBooleanType() {
		val tref = FrancaFactory::eINSTANCE.createFTypeRef
		tref.predefined = FBasicTypeId::BOOLEAN
		new ActualType(tref)
	}

	def private static getStringType() {
		val tref = FrancaFactory::eINSTANCE.createFTypeRef
		tref.predefined = FBasicTypeId::STRING
		new ActualType(tref)
	}

	def private addIssue (String mesg, EObject loc, EStructuralFeature feat) {
		if (collector!=null)
			collector.addIssue(mesg, loc, feat)
	}
	
}