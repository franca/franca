/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal

import java.util.ArrayList
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FConstant
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FBracketInitializer
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FType
import org.franca.core.franca.FTypedElement
import org.franca.core.utils.digraph.Digraph
import org.franca.core.franca.FElementInitializer
import org.franca.core.franca.FTypeCast
import org.franca.core.franca.FModelElement

class CyclicDependenciesDetector {
	
	def static boolean hasCycle(FModelElement element) {
		val Digraph<EObject> d = new Digraph<EObject>()
		
		// Track analyzed elements in order to avoid infinite loops     
		val Set<EObject> analyzedElements = <EObject>newHashSet()
		d.addEdgesForSubtree(element, element.dependencies, analyzedElements)
		try {
			d.topoSort;
			false
		} catch (Digraph$HasCyclesException xe) {
			true
		}
	}

	def static dispatch dependencies(FModel m) {
		val List<EObject> result = new ArrayList<EObject>()
		result.addAll(m.interfaces)
		result.addAll(m.typeCollections)
		result
	}

	def static dispatch dependencies(FInterface i) {
		val result = new ArrayList<EObject>();
		result.add(i.base)
		result.addAll(i.types)
		result
	}

	def static dispatch dependencies(FTypeCollection c) {
		val result = new ArrayList<EObject>();
		result.addAll(c.types)
		result.addAll(c.constants)
		result
	}

	def static dispatch dependencies(FArrayType a) {
		newArrayList(a.elementType.derived)
	}

	def static dispatch dependencies(FStructType s) {

		// s.elements.fold(<EObject>newArrayList(s.base),[result,element| result+= element.type.derived; result])
		val result = newArrayList(s.base)
		result.addAll(s.elements.map[type.derived])
		result
	}

	def static dispatch dependencies(FEnumerationType e) {
		newArrayList(e.base)
	}

	def static dispatch dependencies(FTypeDef td) {
		newArrayList(td.actualType.derived)
	}

	def static dispatch dependencies(FUnionType u) {
		val result = newArrayList(u.base)
		result.addAll(u.elements.map[type.derived])
		result
	}

	def static dispatch dependencies(FMapType m) {
		newArrayList(m.keyType, m.valueType).map[derived]
	}

	def static dispatch dependencies(FConstantDef c) {
		newArrayList(c.rhs)
	}
	
	def static dispatch dependencies(FBinaryOperation op) {
		newArrayList(op.left, op.right)
	}
	
	def static dispatch dependencies(FUnaryOperation op) {
		newArrayList(op.operand)
	}
	
	def static dispatch dependencies(FConstant c) {
		<EObject>newArrayList()
	}
	
	def static dispatch dependencies(FBracketInitializer ai) {
		val result = newArrayList
		result.addAll(ai.elements)
		result
	}
		
	def static dispatch dependencies(FElementInitializer ai) {
		val result = newArrayList
		result.add(ai.first)
		if (ai.second!=null)
			result.add(ai.second)
		result
	}
		
	def static dispatch dependencies(FCompoundInitializer si) {
		val result = newArrayList
		result.addAll(si.elements.map[value])
		result
	}
		
	def static dispatch dependencies(FTypeCast tc) {
		val result = newArrayList
		result.add(tc.type.derived)
		result
	}
		
	def static dispatch dependencies(FQualifiedElementRef e) {
		val result = newArrayList
		if (e.qualifier==null) {
			result.add(e.element)
		} else {
			var f = e.field
			switch (f) {
				FType: result.add(f)
				FTypedElement: result.add(f.type.derived)
			}
		}
		result
	}
	
	def static protected dispatch List<EObject> dependencies(Object e) {
		throw new IllegalStateException("Unhandled parameter types: dependencies not yet implemented for" + e)
	}

	def static protected dispatch List<EObject> dependencies(Void e) {
		<EObject>newArrayList()
	}

	def static protected Digraph<EObject> addEdgesForSubtree(Digraph<EObject> d, EObject from, List<? extends EObject> to,
		Set<EObject> analyzedElements) {
		if (analyzedElements.add(from)) {
			to.forEach[d.doAddEdgesForSubtree(from, it, analyzedElements)]
		}
		d
	}

	/** Adds Edge e1->e2 to the Digraph and continues the traversal with addEdgesFor(e2). */
	def static protected Digraph<EObject> doAddEdgesForSubtree(Digraph<EObject> d, EObject e1, EObject e2,
		Set<EObject> analyzedElements) {
		if (e1 != null && e2 != null) {
			d.addEdge(e1, e2)
		}
		if (e2 != null) {
			d.addEdgesForSubtree(e2, e2.dependencies, analyzedElements);
		}
		d
	}
}
