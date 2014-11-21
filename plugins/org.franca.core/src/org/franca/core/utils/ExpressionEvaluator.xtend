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
import org.franca.core.franca.FFloatConstant
import org.franca.core.franca.FDoubleConstant
import java.math.BigDecimal
import com.google.common.primitives.UnsignedLong
import com.google.common.primitives.UnsignedInteger
import static extension org.franca.core.utils.JavaTypeSystemHelpers.*
import org.franca.core.franca.FTypeCast

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
						Long::parseLong(s.substring(2), 16)
					} else {
						Long::parseLong(s, 10)
					}
				BigInteger::valueOf(v)
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
	
	def static Object evaluate (FExpression expr) {
		eval(expr)
	}

	def static private dispatch Object eval (FDoubleConstant expr) {
	    expr.^val
	}

	def static private dispatch Object eval (FFloatConstant expr) {
	    expr.^val
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
			default: null
		}
	}

	def static private dispatch Object eval (FBinaryOperation it) {
		val e1 = left.eval
		val e2 = right.eval
		if (e1==null || e2==null)
			return null
		
		switch (op) {
			case FOperator::AND: {
			    if (e1 instanceof Boolean && e2 instanceof Boolean)  {
			        (e1 as Boolean) && (e2 as Boolean)
			    }
			    else {
			        null
			    }
			}
			case FOperator::OR: {
			    if (e1 instanceof Boolean && e2 instanceof Boolean)  {
			        (e1 as Boolean) || (e2 as Boolean)
			    }
			    else {
			        null
			    }
			}
			case FOperator::EQUAL: e1 == e2 
			case FOperator::UNEQUAL: e1 != e2 
			case FOperator::SMALLER: if (e1 instanceof Comparable<?>) (e1 as Comparable<Object>) < e2 else null
			case FOperator::SMALLER_OR_EQUAL: if (e1 instanceof Comparable<?>) (e1 as Comparable<Object>) <= e2 else null
			case FOperator::GREATER_OR_EQUAL: if (e1 instanceof Comparable<?>) (e1 as Comparable<Object>) >= e2 else null
			case FOperator::GREATER: if (e1 instanceof Comparable<?>) (e1 as Comparable<Object>) > e2 else null
			case FOperator::ADDITION: {
			    if (e1 instanceof Number && e2 instanceof Number) {
			         applyOp( e1 as Number, e2 as Number, [BigDecimal a, BigDecimal b | a.add(b)], [BigInteger a, BigInteger b | a.add(b)], [Double a, Double b | a + b])			        
			    } else null
			}
			case FOperator::SUBTRACTION: {
			    if (e1 instanceof Number && e2 instanceof Number) {
			         applyOp( e1 as Number, e2 as Number, [BigDecimal a, BigDecimal b | a.subtract(b)], [BigInteger a, BigInteger b | a.subtract(b)], [Double a, Double b | a - b])
			    } else null
			}
			case FOperator::MULTIPLICATION: {
			    if (e1 instanceof Number && e2 instanceof Number) {
			         applyOp( e1 as Number, e2 as Number, [BigDecimal a, BigDecimal b | a.multiply(b)], [BigInteger a, BigInteger b | a.multiply(b)], [Double a, Double b | a * b])
			    } else null
			}
			case FOperator::DIVISION: {
			    if (e1 instanceof Number && e2 instanceof Number) {
			         applyOp( e1 as Number, e2 as Number, [BigDecimal a, BigDecimal b | a.divide(b)], [BigInteger a, BigInteger b | a.divide(b)], [Double a, Double b | a / b])
			    } else null
			}
			default: null
		}
	}
	
	def private static applyOp(Number e1, Number e2, (BigDecimal, BigDecimal) => BigDecimal bdOp, (BigInteger, BigInteger) => BigInteger biOp, (Double, Double) => Double dOp) {
	    if (e1.isIntegerNumber) {
    	    val BigInteger e1Big =
    	           if (e1 instanceof BigInteger) {
    	               e1 as BigInteger
    	           } else if (e1 instanceof UnsignedInteger) {
    	               (e1 as UnsignedInteger).bigIntegerValue  
    	           } else if (e1 instanceof UnsignedLong) {
    	               (e1 as UnsignedLong).bigIntegerValue
    	           } else {
    	               BigInteger::valueOf(e1.longValue)
    	           }
            if (e2.isIntegerNumber) {
                if (e2 instanceof BigInteger) {
                    biOp.apply(e1Big, (e2 as BigInteger))
                } else {
                    if (e2 instanceof UnsignedInteger) {
                        biOp.apply(e1Big, (e2 as UnsignedInteger).bigIntegerValue)
                    } else if (e2 instanceof UnsignedLong) {
                        biOp.apply(e1Big, (e2 as UnsignedLong).bigIntegerValue)
                    } else {
                        biOp.apply(e1Big, BigInteger::valueOf((e2 as Number).longValue))
                    }
                }
            } else {
                if (e2 instanceof BigDecimal) {
                    bdOp.apply(new BigDecimal(e1 as BigInteger), e2 as BigDecimal)
                } else {
                    // this might result in +/- Infinity, if e1 is too large to be converted to double
                    dOp.apply((e1 as BigDecimal).doubleValue, (e2 as Number).doubleValue)
                }
            }
	    } else {
	        val BigDecimal e1Big =
	               if (e1 instanceof BigDecimal) {
	                   e1 as BigDecimal
	               } else {
	                   BigDecimal::valueOf(e1.doubleValue)
	               }
	    
            if (e2.isIntegerNumber) {
	           if (e2 instanceof BigInteger) {
	               bdOp.apply(e1Big, new BigDecimal(e2 as BigInteger))
	           } else {
	               if (e2 instanceof UnsignedInteger) {
                        bdOp.apply(e1Big, new BigDecimal((e2 as UnsignedInteger).bigIntegerValue))
                    } else if (e2 instanceof UnsignedLong) {
                        bdOp.apply(e1Big, new BigDecimal((e2 as UnsignedLong).bigIntegerValue))
                    } else {
                        bdOp.apply(e1Big, new BigDecimal((e2 as Number).longValue))
                    }
               }
           }
           else {
    	        if (e2 instanceof BigDecimal) {
    	            bdOp.apply(e1Big, e2 as BigDecimal)
                }
                else {
    	            bdOp.apply(e1Big, new BigDecimal(e2.doubleValue))
    	        }
           }
       } 
	}
	
	def static private dispatch Object eval (FTypeCast typeCast) {
		typeCast.expression.eval
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
			println("field = " + qe.field.toString)
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

	def static private evalAux (FExpression expr) {
		if (expr instanceof FInitializerExpression)
			expr
		else 
			expr.eval
	}

	// catch-all (shouldn't occur)
	def static private dispatch Object eval (FExpression expr) {
		throw new RuntimeException("Unknown expression " + expr.class.toString)
	}
}
