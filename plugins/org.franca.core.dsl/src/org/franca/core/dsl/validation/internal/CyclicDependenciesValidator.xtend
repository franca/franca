package org.franca.core.dsl.validation.internal

import com.google.inject.Inject
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FrancaPackage
import org.franca.core.utils.digraph.Digraph

class CyclicDependenciesValidator {
	@Inject IQualifiedNameProvider qnProvider;

	val Set<EObject> analyzed = <EObject>newHashSet()

	def check(ValidationMessageReporter reporter, FTypeCollection c) {
		val Digraph<String> d = new Digraph<String>()
		c.types.forEach[d.addEdgesAndTraverse(it, it.dependencies)]
		try {
			d.topoSort
		} catch (Digraph$HasCyclesException xe) {
			val msg = d.edgesToString.replaceAll(qnProvider.getFullyQualifiedName(c).toString + ".", "")
			reporter.reportError("Cyclic dependency detected: " + msg, c, FrancaPackage::eINSTANCE.FModelElement_Name);
		}
	}


	def dispatch dependencies(FArrayType a){
		newArrayList(a.elementType.derived)
	}

	def dispatch dependencies(FStructType s){
		// s.elements.fold(<EObject>newArrayList(s.base),[result,element| result+= element.type.derived; result])
		val result = newArrayList(s.base)
		result.addAll(s.elements.map[type.derived])
		result
	}
	
	def dispatch dependencies(FEnumerationType e){
		newArrayList(e.base)
	}

	def dispatch dependencies(FUnionType u){
		val result = newArrayList(u.base)
		result.addAll(u.elements.map[type.derived])
		result
	}

	
	def dispatch List<EObject> dependencies( Object e) {
		throw new IllegalStateException("Unhandled parameter types: dependencies not yet implemented for" + e)
	}

	def dispatch List<EObject> dependencies(Void e) {
		<EObject>newArrayList()
	}

	
	def dispatch Digraph<String> addEdgesAndTraverse(Digraph<String> d, EObject from, List<EObject> to){
		if(analyzed.add(from)){
			to.forEach[d.addEdgeAndTraverse(from,it)]
		}
		d
	}

	def dispatch Digraph<String> addEdgesAndTraverse(Digraph<String> d, Void from, EObject... to){
		d
	}


    /** Adds Edge e1->e2 to the Digraph and continues the traversal with addEdgesFor(e2). */
	def addEdgeAndTraverse(Digraph<String> d, EObject e1, EObject e2) {
		if (e1 != null && e2 != null) {
			val qn1 = qnProvider.getFullyQualifiedName(e1)
			val qn2 = qnProvider.getFullyQualifiedName(e2)
			if (qn1 != null && qn2 != null) {
				d.addEdge(qn1.toString, qn2.toString)
			}
		}
		if(e2!=null){
			d.addEdgesAndTraverse(e2,e2.dependencies);
		}
		d
	}
}
