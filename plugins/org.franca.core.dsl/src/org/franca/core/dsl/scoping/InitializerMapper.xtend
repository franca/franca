/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.scoping

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FBracketInitializer
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FDeclaration
import org.franca.core.franca.FElementInitializer
import org.franca.core.franca.FInitializerExpression
import org.franca.core.franca.FMapType
import org.franca.core.typesystem.ActualType

import static org.franca.core.typesystem.ActualType.*

/**
 * This class computes the expected type for nested initializer expressions. 
 */
class InitializerMapper {

	/**
	 * Compute the expected type for any nested initializer expression. 
	 */
	def static ActualType getExpectedType (FCompoundInitializer initializer) {
		initializer.type
	}
	
	def static private ActualType getType (FInitializerExpression e) {
		if (e.eContainer instanceof FConstantDef) {
			// we reached a FConstantDef, which is the root for the initializer expression
			val cdef = e.eContainer as FConstantDef
			typeFor(cdef)
		} else if (e.eContainer instanceof FDeclaration) {
			// we reached a FDeclaration, which is the root for the initializer expression
			val decl = e.eContainer as FDeclaration
			typeFor(decl)
		} else {
			// we are somewhere below root, try to resolve expected parent type 
			val parentInitializer = e.parentInitializer
			
			// recursive call for parent initializer
			val parentType = getType(parentInitializer)
			switch (parentInitializer) {
				FBracketInitializer: {
					// parent is a FBracketInitializer, get FElementInitializer for e
					val ei = e.eContainer as FElementInitializer
					if (parentType.isImplicitArray) {
						// parent is an implicit array type, e must be its plain type
						typeFor(parentType.typeRef)
					} else if (parentType.isExplicitArray) {
						// parent is an array type, e must be of its element type
						val p = parentType.actualDerived as FArrayType
						typeFor(p.elementType)
					} else if (parentType.isMap) {
						// parent is a map type, e must be of either its key or value type
						val p = parentType.actualDerived as FMapType
						if (e == ei.first) {
							typeFor(p.keyType)
						} else {
							typeFor(p.valueType)
						}
					} else {
						null
					}
				}
				FCompoundInitializer: {
					// find FFieldInitializer for e in parentInitializer's children
					val fi = parentInitializer.elements.findFirst[f | f.value==e]
					typeFor(fi.element)
				}
			}
		}
	}

	/** Get parent FInitializerExpression along the EObject containment hierarchy. */
	def static private getParentInitializer (FInitializerExpression e) {
		var EObject i = e
		do {
			i = i.eContainer
		} while (i!=null && !(i instanceof FInitializerExpression))
		i as FInitializerExpression
	}
	
}