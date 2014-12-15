/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal

import java.util.Map

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FField
import org.franca.core.franca.FEnumerator
import static org.franca.core.franca.FrancaPackage$Literals.*
import static org.franca.core.dsl.validation.internal.ValidationHelpers.*

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.core.dsl.validation.internal.FrancaNameProvider.*
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef

class FrancaIDLValidator {

	ValidationMessageReporter reporter

	new(ValidationMessageReporter reporter) {
		this.reporter = reporter
	}

	// *****************************************************************************
	def checkCompoundElementsUnique(FCompoundType type) {
		val elements = type.elements
		checkDuplicates(reporter, elements, FMODEL_ELEMENT__NAME, "element name")

		val baseNames = getBaseElementNames(type, [it])
		for (f : elements) {
			val n = f.name
			if (baseNames.containsKey(n)) {
				reporter.reportError("Element name collision with base element '" + baseNames.get(n) + "'", f,
					FMODEL_ELEMENT__NAME)
			}
		}
	}

	def checkUnionElementTypesUnique(FUnionType type) {
		val names = createNameList
		for (f : type.elements) {
			names.add(f, getResolvedName(f.type))
		}
		checkDuplicates(reporter, names, FTYPED_ELEMENT__TYPE, "element type")

		val baseNames = getBaseElementNames(type, [it.type])
		for (f : type.elements) {
			val n = f.type.name
			if (baseNames.containsKey(n)) {
				reporter.reportError("Element type collision with base element '" + baseNames.get(n) + "'", f,
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

	def checkEnumeratorsUnique(FEnumerationType type) {
		val elements = type.enumerators
		checkDuplicates(reporter, elements, FMODEL_ELEMENT__NAME, "enumerator name");

		val baseNames = getBaseElementNames(type)
		for (f : elements) {
			val n = f.name
			if (baseNames.containsKey(n)) {
				reporter.reportError("Enumerator name collision with base element '" + baseNames.get(n) + "'", f,
					FMODEL_ELEMENT__NAME)
			}
		}
	}

	def checkCompoundInitializersUnique(FCompoundInitializer initializer) {
		val names = createNameList
		for (e : initializer.elements) {
			names.add(e, e.element.name)
		}
		checkDuplicates(reporter, names, FFIELD_INITIALIZER__ELEMENT, "initializer field");
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

}
