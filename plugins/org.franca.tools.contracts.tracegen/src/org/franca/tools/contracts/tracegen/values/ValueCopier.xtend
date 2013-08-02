/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.values

import org.franca.tools.contracts.tracegen.values.complex.ComplexValue

class ValueCopier {
	
	def static copy(Object value) {
		if (value == null) return null;
		
		switch (value) {
			Integer: {
				new Integer(value)
			}
			Long: {
				new Long(value)
			}
			Float: {
				new Float(value)
			}
			Double: {
				new Double(value)
			}
			Boolean: {
				new Boolean(value)
			}
			String: {
				new String(value)
			}
			ComplexValue: {
				value.copy
			}
			default: {
				throw new IllegalArgumentException
			}
		}
	}
}