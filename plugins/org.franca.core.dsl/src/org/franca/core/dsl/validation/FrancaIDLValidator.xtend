/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FExpression
import org.franca.core.franca.FField
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FrancaPackage

import static org.eclipse.xtext.nodemodel.util.NodeModelUtils.*
import static org.franca.core.dsl.validation.internal.ValidationHelpers.*
import static org.franca.core.franca.FrancaPackage.Literals.*

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.core.dsl.validation.internal.FrancaNameProvider.*

/**
 * The validator class for Franca IDL.
 * 
 * Implement new validation routines here.
 */
class FrancaIDLValidator extends FrancaIDLJavaValidator {

	/**
	 * Check that there is no name collision among type collections and interfaces.
	 * All pairwise combinations will be checked. This method also checks the imported
	 * type collisions and interfaces.
	 */
	@Check
	def checkPackageMemberNamesUnique(FModel model) {
		val members = model.namedPackageMembers
		if (members.empty) {
			return
		}

		// check local type collections
		checkDuplicates(this, members,
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
				"model element");

		// check against imported type collections
		val imported = model.getAllImportedModels
		for(m : imported.importedModels) {
			for(other : m.namedPackageMembers) {
				val qn = qnProvider.getFullyQualifiedName(other)
				for(local : members) {
					val qn0 = qnProvider.getFullyQualifiedName(local)
					if (qn.equals(qn0)) {
						error(
							"Model element name collides with imported model element " +
							"(imported via " + imported.getViaString(m.eResource) + ")",
							local, FMODEL_ELEMENT__NAME)
					}
				}
			}
		}
	}

	/**
	 * Check if there is more than one anonymous type collection in a package.
	 * 
	 * This also takes into account imported anonymous type collections.
	 */
	@Check
	def checkAnonymousTypeCollections(FModel model) {
		var count = 0
		var FTypeCollection anon = null
		for (coll : model.typeCollections) {
			if (coll.isAnonymous) {
				anon = coll
				count = count + 1
			}
		}
		
		if (count > 1) {
			val pkg =
				if (model.name!=null)
					"package '" + model.name + "'"
				else
					"root package"
			error("duplicate anonymous type collection in " + pkg, model, FMODEL__NAME)
		}
		
		if (anon!=null) {
			// check against imported type collections
			val imported = model.getAllImportedModels
			for(m : imported.getImportedModels) {
				if (m.name == model.name) {
					for(tc : m.typeCollections) {
						if (tc.isAnonymous) {
							error(
								"Another anonymous type collection in same package is imported via " +
								imported.getViaString(m.eResource),
								model, FMODEL__NAME)
							return
						}
					}
				}
			}
		}
	}
	
	def private isAnonymous(FTypeCollection tc) {
		tc.name==null || tc.name.empty
	}
	
	@Check
	def checkCompoundElementsUnique(FCompoundType type) {
		val elements = type.elements
		checkDuplicates(this, elements, FMODEL_ELEMENT__NAME, "element name")

		val baseNames = getBaseElementNames(type, [it])
		for (f : elements) {
			val n = f.name
			if (baseNames.containsKey(n)) {
				error("Element name collision with base element '" + baseNames.get(n) + "'", f,
					FMODEL_ELEMENT__NAME)
			}
		}
	}

	@Check
	def checkUnionElementTypesUnique(FUnionType type) {
		val names = createNameList
		for (f : type.elements) {
			names.add(f, getResolvedName(f.type))
		}
		checkDuplicates(this, names, FTYPED_ELEMENT__TYPE, "element type")

		val baseNames = getBaseElementNames(type, [it.type])
		for (f : type.elements) {
			val n = f.type.name
			if (baseNames.containsKey(n)) {
				error("Element type collision with base element '" + baseNames.get(n) + "'", f,
					FTYPED_ELEMENT__TYPE);
			}
		}
	}

	def String getResolvedName(FTypeRef ref) {

		if(ref.predefined != null) ref.name

		if (ref.derived instanceof FTypeDef) {
			var defs = ref.derived as FTypeDef;
			defs.actualType.resolvedName
		} else {
			ref.name
		}
	}

	@Check
	def checkEnumeratorsUnique(FEnumerationType type) {
		val elements = type.enumerators
		checkDuplicates(this, elements, FMODEL_ELEMENT__NAME, "enumerator name");

		val baseNames = getBaseElementNames(type)
		for (f : elements) {
			val n = f.name
			if (baseNames.containsKey(n)) {
				error("Enumerator name collision with base element '" + baseNames.get(n) + "'", f,
					FMODEL_ELEMENT__NAME)
			}
		}
	}

	@Check
	def checkCompoundInitializersUnique(FCompoundInitializer initializer) {
		val names = createNameList
		for (e : initializer.elements) {
			names.add(e, e.element.name)
		}
		checkDuplicates(this, names, FFIELD_INITIALIZER__ELEMENT, "initializer field");
	}

	def private Map<String, String> getBaseElementNames(FCompoundType type, (FField)=>EObject nameProvider) {
		val Map<String, String> baseNames = newHashMap
		val base = type.getBase
		if (base != null) {
			for (me : base.getAllElements) {
				val f = me as FField
				val owner = f.eContainer.name + "." + f.name
				val n = nameProvider.apply(f).name
				baseNames.put(n, owner)
			}
		}
		baseNames
	}

	def private Map<String, String> getBaseElementNames(FEnumerationType type) {
		val Map<String, String> baseNames = newHashMap
		val base = type.base
		if (base != null) {
			for (me : base.getAllElements) {
				val e = me as FEnumerator

				// if there is a cycle in the inheritance chain, type's elements will
				// be part of base.getAllElements: we block this here.
				if (! type.enumerators.contains(e)) {
					val owner = e.eContainer.name + "." + e.name
					baseNames.put(e.name, owner)
				}
			}
		}
		baseNames
	}

	/**
	 * Check if an enumerator definition is actually an invalid remainder of
	 * parsing on the lexer level, e.g. "ENUM1 = 0ENUM2". In this case, "0"
	 * will be parsed as integer (zero), and "ENUM2" will be parsed as next
	 * enumerator value. This can happen when no separator (optional comma)
	 * is used. 
	 * 
	 * We do not want to allow this kind of "hidden" enumerator definition.
	 * Therefore, we have to issue a validation error.
	 * 
	 * We have to do the implementation of the check on the parser's node model.   
	 */
	@Check
	def checkEnumeratorContext(FEnumerator enumerator) {
		val node = getNode(enumerator)
		val prev = node.getPreviousSibling
		
		// sanity check first
		if (node!=null && prev!=null) {
			// if there is no hidden element (i.e., whitespace) right before
			// the current node (corresponding to the enumerator under validation),
			// it is an indicator of the case we want to detect.
			if (! node.leafNodes.head.hidden) {
				// however, this might produce false positives
				// (e.g., "enumeration E {X }" should be legal, although there is
				// a curly bracket right before "X" and no whitespace).  
				val prevObj = prev.leafNodes.last.semanticElement
				if (prevObj!=null) {
					// now we check the previous node in the AST: if it is no expression
					// then we have a special case as with "{X" above.
					if (prevObj instanceof FExpression) {
						error(
							"invalid enumerator definition '" + enumerator.name + "', " +
							"use whitespace or comma to separate enumerators",
							enumerator, FMODEL_ELEMENT__NAME)
					}
				}
			}
		}
	}
}
