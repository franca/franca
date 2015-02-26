/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal

import com.google.inject.Inject
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.franca.core.dsl.validation.util.DiGraphAnalyzationUtil
import org.franca.core.franca.FModel
import org.franca.core.utils.digraph.Digraph

import static extension org.franca.core.dsl.validation.internal.CyclicDependenciesDetector.*

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

}
