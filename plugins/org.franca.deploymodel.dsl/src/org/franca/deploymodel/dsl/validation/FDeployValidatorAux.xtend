/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.validation

import com.google.common.collect.Sets
import java.util.Collection
import java.util.List
import java.util.Map
import java.util.Queue
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.generator.internal.HostLogic

import static org.franca.deploymodel.dsl.fDeploy.FDeployPackage.Literals.*

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.core.utils.CycleChecker.*

class FDeployValidatorAux {
	
	ValidationMessageReporter reporter
	
	new (ValidationMessageReporter reporter) {
		this.reporter = reporter	
	}


	// *****************************************************************************
	
	def checkRootElement (FDRootElement it) {
		// ensure that use-relation is non-cyclic 
		val path = isReferenced[e | e.use] 
		if (path!==null) {
			val idx = use.indexOf(path.get(0))
			reporter.reportError("Cyclic use-relation in element '" + name + "'",
				it, FD_ROOT_ELEMENT__USE, idx)
		}
		
		// ensure that all use-relations are covered by a compatible deployment spec
		for(other : use) {
			if (spec!==null && other.spec!==null) {
				if (! spec.isCompatible(other.spec)) {
					reporter.reportError("Use-relation '" + other.name + "' " +
						"refers to deployment with incompatible specification " +
						"'" + other.spec.name + "'",
						it, FD_ROOT_ELEMENT__USE, use.indexOf(other))
				}
			}
		}
	}

	// compatible means either same spec or a derived (i.e. more detailed) spec
	def private isCompatible (FDSpecification spec1, FDSpecification spec2) {
		// we cannot do this check if there are cycles in the extend-relation
		if (spec2.cyclicBaseSpec !== null) {
			// return true to avoid an additional error message, the cyclic-check
			// will issue an error.
			return true
		}
			
		var check = spec2
		do {
			if (spec1 == check)
				return true
			check = check.base
		} while (check!==null)
		
		return false
	}

	/**
	 * Check if extends-relation on FDSpecifications has cycles.
	 * 
	 * @returns FDSpecification which has an extends-cycle, null if the
	 *          extends-relation is cycle-free.
	 * */
	def getCyclicBaseSpec(FDSpecification spec) {
		var Set<FDSpecification> visited = newHashSet
		var s = spec
		var FDSpecification last = null
		do {
			visited.add(s)
			last = s
			s = s.base
			if (s!==null && visited.contains(s)) {
				return last
			}
		} while (s !== null)
		return null
	}

	/**
	 * Check if a FDSpecification contains properties which lead 
	 * to clashes in the generated property accessor Java code.
	 */
	def checkClashingProperties(FDSpecification spec) {
		// compute groups of properties with same name
		val allPropertyDecls = spec.declarations.map[properties].flatten
		val groups = allPropertyDecls.groupBy[name]
		
		// check each group in turn
		for(propName : groups.keySet) {
			val props = groups.get(propName)
			
			// find duplicates in the group if they have the same host
			val perHost = props.groupBy[getHost]
			val directDuplicates = perHost.values.filter[size>1].flatten.toSet 
			for(pd : directDuplicates) {
				reporter.reportError(
					"Duplicate property name '" + pd.name + "'",
					pd, FD_PROPERTY_DECL__NAME)
			}

			// continue with all remaining property declarations
			// (if there is a clash already for the same host, we skip all other checks)
			val localUnique = Sets.difference(props.toSet, directDuplicates)

			// check properties according to clashes due to their argument type
			// of the resulting property accessor methods
			localUnique.checkGroupArgumentType

			// enumeration-typed properties must not have the same name
			val enumProps = localUnique.filter[isEnumType]
			if (enumProps.size > 1) {
				for(ep : enumProps) {
					reporter.reportError(
						"Deployment property '" + ep.name + "' with an enumeration type has to be unique",
						ep, FD_PROPERTY_DECL__NAME)
				}
			}
		} 
	}
	
	/**
	 * Check a group of properties according to the argument type of the
	 * resulting property accessor get() method.<p/>
	 * 
	 * All properties in the input group should have the same name.
	 * If the name is different, the actual getter argument type is
	 * not relevant.
	 * 
	 * @param items the to-be-checked group of properties with the same name
	 */
	def private checkGroupArgumentType(Iterable<FDPropertyDecl> items) {
		// group items according to the type of the accessor argument
		val argtypeGroups = items.groupBy[HostLogic.getArgumentType(host, HostLogic.Context.FRANCA_INTERFACE)]
		
		// report errors for properties with same of conflicting argument type 
		val Map<Class<? extends EObject>, Iterable<Class<? extends EObject>>> colliding = newHashMap
		val argtypes = argtypeGroups.keySet
		for(at : argtypes) {
			val List<Class<? extends EObject>> colliders = newArrayList
			 
			// check for conflicts with same argument type
			if (argtypeGroups.get(at).size>1) {
				colliders.add(at)
			}
			
			// check for conflicts with other argument types
			colliders += argtypes.filter[it!=at && willCollide(it, at)]

			if (! colliders.empty)
				colliding.put(at, colliders)
		}
		
		for(h : colliding.keySet) {
			val collidingProps = colliding.get(h).map[argtypeGroups.get(it)].flatten.toSet
			for(p : argtypeGroups.get(h)) {
				val coll = collidingProps.filter[it!=p].map[host].map[getName].toSet.sort.join(', ')
				reporter.reportError(
					"Name conflict for property '" + p.name + "' due to conflicting property hosts" +
					" (conflicting: " + coll + ")",
					p, FD_PROPERTY_DECL__NAME)
			}
		}
	}
	
	/**
	 * Check if two types will collide if used as single arguments of 
	 * methods which use Java's static overloading.<p/>
	 * 
	 * Example with colliding types:
	 * <code><pre>
	 * public void get(FArgument a)
	 * public void get(EObject b)
	 * </pre></code><p/>
	 * 
	 * Example with independent types:
	 * <code><pre>
	 * public void get(FArgument a)
	 * public void get(FMethod b)
	 * </pre></code><p/>
	 */
	def private willCollide(Class<? extends EObject> a, Class<? extends EObject> b) {
		a.isAssignableFrom(b) || b.isAssignableFrom(a)
	}
	
	def private isEnumType(FDPropertyDecl decl) {
		val t = decl.type.complex
		t!==null && (t instanceof FDEnumType)
	}
	
	def private getHost(FDPropertyDecl decl) {
		val declaration = decl.eContainer as FDDeclaration
		declaration.host
	}
	

	// *****************************************************************************

	def checkUsedTypes (FDTypes rootElem,
		List<FType> localTypes,
		PropertyDefChecker checker
	) {
		val Set<FTypeRef> typerefs = newHashSet
		for(t : rootElem.target.types) {
			typerefs.addAll(EcoreUtil2::eAllContents(t).filter(typeof(FTypeRef)).toSet)
		} 
		checkUsedTypesRoot(rootElem, typerefs, localTypes, checker)
	}

	def checkUsedTypes (FDInterface rootElem,
		List<FType> localTypes,
		PropertyDefChecker checker
	) {
		val typerefs = EcoreUtil2::eAllContents(rootElem.target).filter(typeof(FTypeRef)).toSet
		return checkUsedTypesRoot(rootElem, typerefs, localTypes, checker)
	}

	def private checkUsedTypesRoot (FDRootElement rootElem,
		Collection<FTypeRef> typerefs,
		List<FType> localTypes,
		PropertyDefChecker checker
	) {
		var boolean hasError = false
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
				hasError = true
			}
		}
		
		return hasError
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

