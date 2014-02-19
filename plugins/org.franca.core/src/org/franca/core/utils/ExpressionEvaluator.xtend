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

import static extension org.franca.core.contracts.TypeSystem.*

class ExpressionEvaluator {
	
	def static BigInteger evaluateInteger (FExpression expr) {
		val obj = expr.evaluate
		if (obj instanceof BigInteger)
			obj as BigInteger
		else
			null
	}
	
	def static private Object evaluate (FExpression expr) {
		eval(expr)
	}


	def static private dispatch Object eval (FIntegerConstant expr) {
		BigInteger.valueOf(expr.^val)
	}

	def static private dispatch Object eval (FBinaryOperation it) {
		val e1 = left.eval
		val e2 = right.eval
		if (e1==null || e2==null)
			return null
		
		switch (op) {
			//case FOperator::AND: 
			//case FOperator::OR: 
			//case FOperator::EQUAL: 
			//case FOperator::UNEQUAL: 
			//case FOperator::SMALLER: 
			//case FOperator::SMALLER_OR_EQUAL: 
			//case FOperator::GREATER_OR_EQUAL: 
			//case FOperator::GREATER: 
			// TODO: this doesn't work for floats and doubles
			case FOperator::ADDITION: (e1 as BigInteger).add(e2 as BigInteger)
			case FOperator::SUBTRACTION: (e1 as BigInteger).subtract(e2 as BigInteger)
			case FOperator::MULTIPLICATION: (e1 as BigInteger).multiply(e2 as BigInteger)
			case FOperator::DIVISION: (e1 as BigInteger).divide(e2 as BigInteger)
			default: null
		}
	}

	def static private dispatch Object eval (FQualifiedElementRef it) {
		if (qualifier==null) {
			val te = element
			// TODO: support array types
			switch(te) {
				FConstantDef: {
					if (te.rhs instanceof FExpression)
						(te.rhs as FExpression).evaluate
					else
						null
				}
				default: null
			}
		} else {
			// TODO: evaluate field
			null
		}
	}

	// catch-all (shouldn't occur)
	def static private dispatch Object eval (FExpression expr) {
		throw new RuntimeException("Unknown expression " + expr.class.toString)
	}
}
