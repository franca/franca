/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.contracts

import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FExpression
import org.franca.core.franca.FConstant
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FrancaFactory
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FStringConstant
import org.franca.core.franca.FBinaryOperation
import static org.franca.core.franca.FrancaPackage$Literals.*
import static extension org.franca.core.framework.FrancaHelpers.*
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FOperator
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FCurrentError
import static extension org.franca.core.FrancaModelExtensions.*
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FTypedElement

class TypeSystem {
	
	static val BOOLEAN_TYPE = getBooleanType
	static val STRING_TYPE = getStringType
	static val UNDEFINED_TYPE = getUndefinedType
	
	var IssueCollector collector
	
	def FTypeRef evaluateType (FExpression expr, IssueCollector collector, EObject loc, EStructuralFeature feat) {
		this.collector = collector
		expr.evalType(loc, feat)
	}
	
	def private dispatch FTypeRef evalType (FConstant expr, EObject loc, EStructuralFeature feat) {
		switch (expr) {
			FIntegerConstant: expr.integerType
			FBooleanConstant: BOOLEAN_TYPE
			FStringConstant: STRING_TYPE
			default: {
				addIssue("unknown constant type", loc, feat)
				UNDEFINED_TYPE
			}
		}
	}

	def private dispatch FTypeRef evalType (FUnaryOperation it, EObject loc, EStructuralFeature feat) {
		val type = operand.evalType(it, FUNARY_OPERATION__OPERAND)
		if (FOperator::NEGATION.equals(op)) {
			if (! type.checkBoolean(it, FUNARY_OPERATION__OPERAND)) {
				return UNDEFINED_TYPE
			}
			return BOOLEAN_TYPE
		}
		return UNDEFINED_TYPE
	}
	
	def private dispatch FTypeRef evalType (FBinaryOperation it, EObject loc, EStructuralFeature feat) {
		val t1 = left.evalType(it, FBINARY_OPERATION__LEFT)
		val t2 = right.evalType(it, FBINARY_OPERATION__RIGHT)
		if (t1.isUndefined || t2.isUndefined)
			return UNDEFINED_TYPE

		if (FOperator::AND.equals(op) || FOperator::OR.equals(op)) {
			if (! t1.checkBoolean(it, FBINARY_OPERATION__LEFT))
				return UNDEFINED_TYPE
			if (! t2.checkBoolean(it, FBINARY_OPERATION__RIGHT))
				return UNDEFINED_TYPE
			return BOOLEAN_TYPE
		} else if (FOperator::EQUAL.equals(op) || FOperator::UNEQUAL.equals(op)) {
			if (! isCompatibleType(t1, t2) && ! isCompatibleType(t2, t1)) {
				addIssue("operands must have compatible type", loc, feat)
				return UNDEFINED_TYPE
			}
			return BOOLEAN_TYPE
		} else if (FOperator::SMALLER.equals(op) || FOperator::SMALLER_OR_EQUAL.equals(op) ||
			FOperator::GREATER_OR_EQUAL.equals(op) || FOperator::GREATER.equals(op)
		) {
			if (! t1.checkInteger(it, FBINARY_OPERATION__LEFT))
				return UNDEFINED_TYPE
			if (! t2.checkInteger(it, FBINARY_OPERATION__RIGHT))
				return UNDEFINED_TYPE
			return BOOLEAN_TYPE
		} else if (FOperator::ADDITION.equals(op) || FOperator::SUBTRACTION.equals(op) ||
			FOperator::MULTIPLICATION.equals(op) || FOperator::DIVISION.equals(op)
		) {
			if (! t1.checkInteger(it, FBINARY_OPERATION__LEFT))
				return UNDEFINED_TYPE
			if (! t2.checkInteger(it, FBINARY_OPERATION__RIGHT))
				return UNDEFINED_TYPE
			return t1 // TODO: or t2, or combination of both types
		}

		addIssue("unknown binary operator '" + op + "'", loc, feat)
		UNDEFINED_TYPE
	}
	
	def private dispatch FTypeRef evalType (FCurrentError it, EObject loc, EStructuralFeature feat) {
		return type
	}

	def private dispatch FTypeRef evalType (FQualifiedElementRef expr, EObject loc, EStructuralFeature feat) {
		if (expr?.qualifier==null) {
			val te = expr?.element
			val boolean TODO = true;
//			if (!(te == null) && te.array) {
//				addIssue("array types not supported yet", loc, feat)
//				return UNDEFINED_TYPE
//			}
			if (te instanceof FTypedElement) {
				return (te as FTypedElement).type
			}
			return null
		} else {
			val field = expr?.field;
			if (field instanceof FTypedElement) {
				return (field as FTypedElement).type
			}
			return null
		} 
//		println("TE: " + expr.toString)
//		if (expr.element!=null)
//			println("  element: " + expr.element.toString)
//		if (expr.target!=null)
//			println("  target : "  + expr.target.toString)
//		if (expr.field!=null)
//			println("  field  : " + expr.field.toString)
//		te.type
	}
	
	def private dispatch FTypeRef evalType (FExpression expr, EObject loc, EStructuralFeature feat) {
		addIssue("unknown expression type '" + expr.eClass.name + "'", loc, feat)
		UNDEFINED_TYPE
	}
	

	def private isUndefined (FTypeRef type) {
		type.derived==null && type.predefined==FBasicTypeId::UNDEFINED
	}

	def private checkBoolean (FTypeRef type, FExpression loc, EStructuralFeature feat) {
		if (! type.isBoolean) {
			addIssue("expected boolean (is " + type.typeString + ")", loc, feat)
			return false
		}
		return true
	}

	def private checkInteger (FTypeRef type, FExpression loc, EStructuralFeature feat) {
		if (! type.isInteger) {
			addIssue("expected integer (is " + type.typeString + ")", loc, feat)
			return false
		}
		return true
	}
	
	def static private isOfCompatiblePrimitiveType(FTypeRef t1, FTypeRef t2) {
		if (t1.isBoolean) return t2.isBoolean
		if (t1.isString) return t2.isString
		if (t1.isInteger) return t2.isInteger
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

	def private getIntegerType (FIntegerConstant value) {
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

	def private static getUndefinedType() {
		val it = FrancaFactory::eINSTANCE.createFTypeRef
		predefined = FBasicTypeId::UNDEFINED
		it
	}
	
	def private addIssue (String mesg, EObject loc, EStructuralFeature feat) {
		if (collector!=null)
			collector.addIssue(mesg, loc, feat)
	}
	
}