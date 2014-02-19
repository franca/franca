/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils;

import org.franca.core.franca.FExpression

class ExpressionEvaluator {
	
	def static Object evaluate (FExpression expr) {
		eval(expr)
	}
	
	// catch-all (shouldn't occur)
	def static private dispatch Object eval (FExpression expr) {
		throw new RuntimeException("Unknown expression " + expr.class.toString)
	}
}
