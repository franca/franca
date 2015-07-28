/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils;

import java.math.BigInteger
import org.franca.core.franca.FExpression
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FOperator
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FConstantDef

import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FField
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FInitializerExpression
import org.franca.core.franca.FStringConstant

class ExpressionEvaluator {
	
	def static Boolean evaluateBoolean (FExpression expr) {
		val obj = expr.evaluate
		if (obj instanceof Boolean)
			obj as Boolean
		else
			null
	}
	
	def static BigInteger evaluateInteger (FExpression expr) {
		val obj = expr.evaluate
		if (obj instanceof BigInteger)
			obj as BigInteger
		else
			null
	}
	
	def static BigInteger evaluateIntegerOrParseString (FExpression expr) {
		val obj = expr.evaluate
		switch (obj) {
			BigInteger: obj
			String: {
				var s = obj.toLowerCase
				val v =
					if (s.startsWith("0x")) {
						Long.parseLong(s.substring(2), 16)
					} else {
						Long.parseLong(s, 10)
					}
				BigInteger.valueOf(v)
			}
			default: null
		}
	}
	
	def static String evaluateString (FExpression expr) {
		val obj = expr.evaluate
		if (obj instanceof String)
			obj as String
		else
			null
	}
	
	def static private Object evaluate (FExpression expr) {
		eval(expr)
	}


	def static private dispatch Object eval (FBooleanConstant expr) {
		expr.^val
	}

	def static private dispatch Object eval (FIntegerConstant expr) {
		expr.^val
	}

	def static private dispatch Object eval (FStringConstant expr) {
		expr.^val
	}

	def static private dispatch Object eval (FUnaryOperation it) {
		val e = operand.eval
		if (e==null)
			return null
			
		switch (op) {
			case FOperator::NEGATION: !(e as Boolean)
			// TODO: this doesn't work for floats and doubles
			case FOperator::SUBTRACTION: -(e as BigInteger)
			default: null
		}
	}

	def static private dispatch Object eval (FBinaryOperation it) {
		val e1 = left.eval
		val e2 = right.eval
		if (e1==null || e2==null)
			return null
		
		switch (op) {
			case FOperator::AND: (e1 as Boolean) && (e2 as Boolean)
			case FOperator::OR:  (e1 as Boolean) || (e2 as Boolean)
			case FOperator::EQUAL: e1 == e2 
			case FOperator::UNEQUAL: e1 != e2 

			// TODO: this doesn't work for floats and doubles
			case FOperator::SMALLER: (e1 as BigInteger) < (e2 as BigInteger)
			case FOperator::SMALLER_OR_EQUAL: (e1 as BigInteger) <= (e2 as BigInteger)
			case FOperator::GREATER_OR_EQUAL: (e1 as BigInteger) >= (e2 as BigInteger)
			case FOperator::GREATER: (e1 as BigInteger) > (e2 as BigInteger)
			case FOperator::ADDITION: (e1 as BigInteger).add(e2 as BigInteger)
			case FOperator::SUBTRACTION: (e1 as BigInteger).subtract(e2 as BigInteger)
			case FOperator::MULTIPLICATION: (e1 as BigInteger).multiply(e2 as BigInteger)
			case FOperator::DIVISION: (e1 as BigInteger).divide(e2 as BigInteger)
			default: null
		}
	}

	def static private dispatch Object eval (FQualifiedElementRef qe) {
		if (qe.qualifier==null) {
			val te = qe.element
			// TODO: support array types
			switch(te) {
				FConstantDef: te.rhs.evalAux
				default: null
			}
		} else {
//			println("field = " + qe.field.toString)
			val q = qe.qualifier.eval
			if (q instanceof FCompoundInitializer) {
				val ci = q as FCompoundInitializer
				val f = qe.field as FField
				val fi = ci.elements.findFirst[element==f]
				fi.value.evalAux
			} else
				null
		}
	}

	def static private evalAux (FInitializerExpression expr) {
		if (expr instanceof FExpression)
			(expr as FExpression).eval
		else 
			expr
	}

	// catch-all (shouldn't occur)
	def static private dispatch Object eval (FExpression expr) {
		throw new RuntimeException("Unknown expression " + expr.class.toString)
	}
}
