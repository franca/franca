package org.franca.deploymodel.dsl.validation

import java.util.Collection
import java.util.List
import java.util.Queue
import java.util.Set
import org.eclipse.xtend.typesystem.emf.EcoreUtil2
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import static org.franca.deploymodel.dsl.fDeploy.FDeployPackage$Literals.*

import static extension org.franca.core.utils.CycleChecker.*
import static extension org.franca.core.FrancaModelExtensions.*

class FDeployValidator {
	
	ValidationMessageReporter reporter
	
	new (ValidationMessageReporter reporter) {
		this.reporter = reporter	
	}


	// *****************************************************************************
	
	def checkRootElement (FDRootElement it) {
		// ensure that use-relation is non-cyclic 
		val path = isReferenced[e | e.use] 
		if (path!=null) {
			val idx = use.indexOf(path.get(0))
			reporter.reportError("Cyclic use-relation in element '" + name + "'",
				it, FD_ROOT_ELEMENT__USE, idx)
		}
		
		// ensure that all use-relations are covered by same deployment spec
		for(other : use) {
			if (spec != other.spec) {
				reporter.reportError("Use-relation '" + other.name + "' " +
					"refers to deployment with different specification " +
					"'" + other.spec.name + "'",
					it, FD_ROOT_ELEMENT__USE, use.indexOf(other))
			}
		}
	}


	// *****************************************************************************

	def checkUsedTypes (FDTypes rootElem,
		List<FType> localTypes,
		PropertyDefChecker checker
	) {
		val Set<FTypeRef> typerefs = newHashSet
		for(t : rootElem.target.types) {
			typerefs.addAll(EcoreUtil2::allContents(t).filter(typeof(FTypeRef)).toSet)
		} 
		checkUsedTypesRoot(rootElem, typerefs, localTypes, checker)
	}

	def checkUsedTypes (FDInterface rootElem,
		List<FType> localTypes,
		PropertyDefChecker checker
	) {
		val typerefs = EcoreUtil2::allContents(rootElem.target).filter(typeof(FTypeRef)).toSet
		checkUsedTypesRoot(rootElem, typerefs, localTypes, checker)
	}

	def private checkUsedTypesRoot (FDRootElement rootElem,
		Collection<FTypeRef> typerefs,
		List<FType> localTypes,
		PropertyDefChecker checker
	) {
		val referencedTypes =
			typerefs.map[derived].filterNull
			.filter[it.isDeploymentRelevantType()]
			.toSet
		
		// compute all types which are used locally, but not defined locally
		val nonLocal = referencedTypes.filter[!localTypes.contains(it)].toSet
				
		// check if non-local types are covered by 'use' reference (recursively)
		val fromOthers = rootElem.typeDefinitionsByTransitiveUse

		// find non-local types which are not yet deployed in some 'use'd deploy model
		val remaining = nonLocal.filter[!fromOthers.contains(it)].toSet
		
		// identify those types which need deployment properties
		for(missing : remaining) {
			if (checker.mustBeDefined(missing)) {
				val model = missing.getModel
				reporter.reportError(
					"Deployment for type '" + missing.name + "' is missing, " +
					"add 'use' reference for deployment of package '" + model.name + "'",
					rootElem, FD_INTERFACE__TARGET)
			}
		}
	}
	
	// TODO replace by dispatch-function in checker
	def private mustBeDefined (PropertyDefChecker checker, FType t) {
		switch (t) {
			FArrayType:       checker.mustBeDefined(t)
			FStructType:      checker.mustBeDefined(t)
			FUnionType:       checker.mustBeDefined(t)
			FEnumerationType: checker.mustBeDefined(t)
			default: true
		}
	}
	
	def private isDeploymentRelevantType (FType it) {
		(it instanceof FArrayType) ||
		(it instanceof FStructType) ||
		(it instanceof FUnionType) ||
		(it instanceof FEnumerationType)
	}
	
	def private getTypeDefinitionsByTransitiveUse (FDRootElement rootElem) {
		var Set<FDRootElement> visited = newHashSet(rootElem)
		var Queue<FDRootElement> work = newLinkedList
		var Set<FType> found = newHashSet
		
		work.addAll(rootElem.use)
		while (! work.empty) {
			val e = work.poll
			if (!visited.contains(e)) {
				visited.add(e)
				
				found.addAll(e.getLocalTypes)
				work.addAll(e.use)
			}	
		}				
		found
	}
	
	
	/** Get types defined locally in a root element. */
	def private Collection<FType> getLocalTypes (FDRootElement rootElem) {
		switch (rootElem) {
			FDInterface: rootElem.target.types
			FDTypes: rootElem.target.types
			default: newArrayList
		}
	}

//	def private print (Collection<FType> types, String tag) {
//		print(tag + ":")
//		for(t : types)
//			print(" " + t.name)
//		println(" (" + types.size + ")")
//	}
}

