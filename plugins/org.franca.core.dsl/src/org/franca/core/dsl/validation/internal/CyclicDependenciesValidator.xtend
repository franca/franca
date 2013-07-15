package org.franca.core.dsl.validation.internal

import com.google.inject.Inject
import java.util.ArrayList
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.franca.core.dsl.validation.util.DiGraphAnalyzationUtil
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
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
		} catch (Digraph$HasCyclesException xe) {
			val eResourceOfModel = m.eResource;
			val fqNameOfModel = qnProvider.getFullyQualifiedName(m).toString
			val edgesMap = d.edgesIterator.toMultiMap
			val cycles = edgesMap.separateCycles
			for (cycle : cycles) {
				val msgPerNode = newLinkedList()
				// First loop collects messages per node
				for (node : cycle) {
					var msgForNode = qnProvider.getFullyQualifiedName(node).toString
					if (node.eResource == eResourceOfModel) {
						msgForNode = msgForNode.replaceAll(fqNameOfModel + "\\.?", "")
					}
					msgPerNode += msgForNode;
				}
				for (node : cycle) {
					// Second loop tinkers messages ...
					if (node.eResource == m.eResource) {
						val StringBuilder msg = new StringBuilder("Cyclic dependency detected: <this>")
						msgPerNode.tail.forEach[msg.append("->").append(it)]
						msg.append("-><this>")
						var eAttribute = node.eClass.EAllAttributes.findFirst[it.name == "name"]
						if(eAttribute==null){
							eAttribute==node.eClass.EAllAttributes.head
						}
						if(eAttribute!=null){
							reporter.reportError("Cyclic dependency detected: " + msg, node, eAttribute);
						} 
					}
					// ... and shifts msdPerNode in order to make the errormessage appear specific per node 
					msgPerNode.add(msgPerNode.head)
					msgPerNode.remove
				}
			}
		}
	}

	def protected dispatch dependencies(FModel m) {
		val List<EObject> result = new ArrayList<EObject>()
		result.addAll(m.interfaces)
		result.addAll(m.typeCollections)
		result
	}

	def protected dispatch dependencies(FInterface i) {
		val result = new ArrayList<EObject>();
		result.add(i.base)
		result.addAll(i.types)
		result
	}

	def protected dispatch dependencies(FTypeCollection c) {
		c.types
	}

	def protected dispatch dependencies(FArrayType a) {
		newArrayList(a.elementType.derived)
	}

	def protected dispatch dependencies(FStructType s) {

		// s.elements.fold(<EObject>newArrayList(s.base),[result,element| result+= element.type.derived; result])
		val result = newArrayList(s.base)
		result.addAll(s.elements.map[type.derived])
		result
	}

	def protected dispatch dependencies(FEnumerationType e) {
		newArrayList(e.base)
	}

	def protected dispatch dependencies(FTypeDef td) {
		newArrayList(td.actualType.derived)
	}

	def protected dispatch dependencies(FUnionType u) {
		val result = newArrayList(u.base)
		result.addAll(u.elements.map[type.derived])
		result
	}

	def protected dispatch dependencies(FMapType m) {
		newArrayList(m.keyType, m.valueType).map[derived]
	}

	def protected dispatch List<EObject> dependencies(Object e) {
		throw new IllegalStateException("Unhandled parameter types: dependencies not yet implemented for" + e)
	}

	def protected dispatch List<EObject> dependencies(Void e) {
		<EObject>newArrayList()
	}

	def protected Digraph<EObject> addEdgesForSubtree(Digraph<EObject> d, EObject from, List<? extends EObject> to,
		Set<EObject> analyzedElements) {
		if (analyzedElements.add(from)) {
			to.forEach[d.doAddEdgesForSubtree(from, it, analyzedElements)]
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
