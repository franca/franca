/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.scoping

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FInitializerExpression
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FArrayInitializer
import org.franca.core.franca.FArrayType

class InitializerMapper {

	def static FTypeRef getExpectedType (FCompoundInitializer initializer) {
		initializer.type
	}
	
	def static private FTypeRef getType (FInitializerExpression e) {
		if (e.eContainer instanceof FConstantDef) {
			val cdef = e.eContainer as FConstantDef
			cdef.type
		} else {
			val parent = e.parentInitializer
			val parentType = getType(parent)
			switch (parent) {
				FArrayInitializer: {
					val p = parentType.derived as FArrayType
					p.elementType
				}
				FCompoundInitializer: {
					val fi = parent.elements.findFirst[f | f.value==e]
					fi.element.type
				}
			}
		}
	}
	def static private getParentInitializer (FInitializerExpression e) {
		var EObject i = e
		do {
			i = i.eContainer
		} while (i!=null && !(i instanceof FInitializerExpression))
		i as FInitializerExpression
	}
	
}