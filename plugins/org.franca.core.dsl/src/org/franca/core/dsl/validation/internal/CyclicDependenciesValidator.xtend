/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal

import com.google.inject.Inject
import java.util.ArrayList
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.franca.core.dsl.validation.util.DiGraphAnalyzationUtil
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FBracketInitializer
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FConstant
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FElementInitializer
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FEvaluableElement
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FModel
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FUnionType
import org.franca.core.utils.digraph.Digraph

class CyclicDependenciesValidator {
	@Inject IQualifiedNameProvider qnProvider;
	@Inject extension DiGraphAnalyzationUtil

	/** Traverses the graph of dependencies beginning with <code>m</code> and reports an error if the graph is not a tree. */
	def check(ValidationMessageReporter reporter, FModel m) {
		val Digraph<EObject> d = new Digraph<EObject>()

		// Track analyzed elements in order to avoid infinite loops     
		val Set<EObject> analyzedElements = <EObject>newHashSet()
		d.addEdgesForSubtree(m, m.dependencies, analyzedElements)
		try {
			d.topoSort
		} catch (Digraph.HasCyclesException xe) {
			val eResourceOfModel = m.eResource;
			val fqNameOfModel = qnProvider.getFullyQualifiedName(m).toString
			val edgesMap = d.edgesIterator.toMultiMap
			val cycles = edgesMap.separateCycles
			for (cycle : cycles) {
				val msgPerNode = newLinkedList
				val nodes = newLinkedList
				// First loop collects messages per node
				for (node : cycle) {
					var fqn = qnProvider.getFullyQualifiedName(node)
					var msgForNode = ""
					if (fqn==null) {
						// skip intermediate nodes (e.g., FExpressions, FQualifiedElementRefs, ...)
					} else {
						msgForNode = fqn.toString
						if (node.eResource == eResourceOfModel) {
							msgForNode = msgForNode.replaceAll(fqNameOfModel + "\\.?", "")
						}
						msgPerNode += msgForNode
						nodes += node
					}
				}
				for (node : nodes) {
					// Second loop tinkers messages ...
					if (node.eResource == m.eResource) {
						val StringBuilder msg = new StringBuilder("Cyclic dependency detected: this")
						msgPerNode.tail.forEach[msg.append("->").append(it)]
						msg.append("->this")
						var eAttribute = node.eClass.EAllAttributes.findFirst[it.name == "name"]
						if(eAttribute==null){
							eAttribute = node.eClass.EAllAttributes.head
						}
						if(eAttribute!=null){
							reporter.reportError(msg.toString, node, eAttribute);
						} 
					}
					// ... and shifts msgPerNode in order to make the errormessage appear specific per node 
					msgPerNode.add(msgPerNode.head)
					msgPerNode.remove
				}
			}
		}
	}

	def dispatch dependencies(FModel m) {
		val List<EObject> result = new ArrayList<EObject>()
		result.addAll(m.interfaces)
		result.addAll(m.typeCollections)
		result
	}

	def dispatch dependencies(FInterface i) {
		val result = new ArrayList<EObject>();
		result.add(i.base)
		result.addAll(i.types)
		result
	}

	def dispatch dependencies(FTypeCollection c) {
		val result = new ArrayList<EObject>();
		result.addAll(c.types)
		result.addAll(c.constants)
		result
	}

	def dispatch dependencies(FArrayType a) {
		newArrayList(a.elementType.derived)
	}

	def dispatch List<? extends EObject> dependencies(FAttribute a) {
		newArrayList()
	}

	def dispatch dependencies(FStructType s) {

		// s.elements.fold(<EObject>newArrayList(s.base),[result,element| result+= element.type.derived; result])
		val result = newArrayList(s.base)
		result.addAll(s.elements.map[type.derived])
		result
	}

	def dispatch dependencies(FEnumerationType e) {
		newArrayList(e.base)
	}

	def dispatch dependencies(FEnumerator e) {
		if (e.value==null)
			<EObject>newArrayList()
		else
			newArrayList(e.value)
	}

	def dispatch dependencies(FTypeDef td) {
		newArrayList(td.actualType.derived)
	}

	def dispatch dependencies(FUnionType u) {
		val result = newArrayList(u.base)
		result.addAll(u.elements.map[type.derived])
		result
	}

	def dispatch dependencies(FMapType m) {
		newArrayList(m.keyType, m.valueType).map[derived]
	}

	def dispatch dependencies(FConstantDef c) {
		newArrayList(c.rhs)
	}
	
	def dispatch dependencies(FBinaryOperation op) {
		newArrayList(op.left, op.right)
	}
	
	def dispatch dependencies(FUnaryOperation op) {
		newArrayList(op.operand)
	}
	
	def dispatch dependencies(FConstant c) {
		<EObject>newArrayList()
	}
	
	def dispatch dependencies(FBracketInitializer ai) {
		val result = newArrayList
		result.addAll(ai.elements)
		result
	}
		
	def dispatch dependencies(FElementInitializer ai) {
		val result = newArrayList
		result.add(ai.first)
		if (ai.second!=null)
			result.add(ai.second)
		result
	}
		
	def dispatch dependencies(FCompoundInitializer si) {
		val result = newArrayList
		result.addAll(si.elements.map[value])
		result
	}
		
	def dispatch dependencies(FEvaluableElement e) {
		<EObject>newArrayList()
	}
	
	def dispatch dependencies(FQualifiedElementRef e) {
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
	
	def protected dispatch List<EObject> dependencies(Object e) {
		throw new IllegalStateException("Unhandled parameter type: dependencies not yet implemented for " + e)
	}

	def protected dispatch List<EObject> dependencies(Void e) {
		<EObject>newArrayList()
	}

	def protected Digraph<EObject> addEdgesForSubtree(Digraph<EObject> d, EObject from, List<? extends EObject> to,
		Set<EObject> analyzedElements) {
		if (analyzedElements.add(from)) {
			val Procedure1<? super EObject> con = [d.doAddEdgesForSubtree(from, it, analyzedElements)]
			to.forEach(con)
		}
		d
	}

	/** Adds Edge e1->e2 to the Digraph and continues the traversal with addEdgesFor(e2). */
	def protected Digraph<EObject> doAddEdgesForSubtree(Digraph<EObject> d, EObject e1, EObject e2,
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
