/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal;

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.franca.core.contracts.IssueCollector
import org.franca.core.contracts.TypeIssue
import org.franca.core.contracts.TypeSystem
import org.franca.core.framework.FrancaHelpers
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FExpression
import org.franca.core.franca.FInitializer
import org.franca.core.franca.FTypeRef

import static org.franca.core.franca.FrancaPackage$Literals.*
import org.franca.core.franca.FStructInitializer
import org.franca.core.franca.FStructType
import org.franca.core.franca.FArrayInitializer
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FInitializerExpression

import static extension org.franca.core.FrancaModelExtensions.*
import org.franca.core.franca.FField
import org.franca.core.franca.FUnionInitializer
import org.franca.core.franca.FUnionType

class TypesValidator {

	def static checkConstantType (ValidationMessageReporter reporter, FConstantDef constantDef) {
		checkConstantRHS(constantDef.rhs, constantDef.type,
			reporter, constantDef, FCONSTANT_DEF__RHS, -1
		)
	}
	
	def private static void checkConstantRHS (
		FInitializerExpression rhs,
		FTypeRef typeLHS,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		switch (rhs) {
			FExpression: {
				val typeRHS = checkExpression(reporter, rhs, ctxt, feature, index)
				if (typeRHS!=null) {
					if (! TypeSystem::isCompatibleType(typeRHS, typeLHS)) {
						reporter.reportError(
							"invalid expression type in constant definition (is " +
								FrancaHelpers::getTypeString(typeRHS) + ", expected " +
								FrancaHelpers::getTypeString(typeLHS) + ")",
							ctxt, feature, index);
					}
				}
				
			}
			FInitializer: {
				checkInitializer(rhs, typeLHS, reporter, ctxt, feature, index)
			}
		}
	}
	
	def private static dispatch checkInitializer (
		FArrayInitializer rhs,
		FTypeRef type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		if (type.derived==null || !(type.derived instanceof FArrayType)) {
			reporter.reportError(
					"invalid array initializer in constant definition (expected " +
						FrancaHelpers::getTypeString(type) + ")",
					ctxt, feature);
			return;
		}
		
		val t = type.derived as FArrayType
		for(e : rhs.elements) {
			checkConstantRHS(e,
				t.elementType,
				reporter, rhs, FARRAY_INITIALIZER__ELEMENTS, rhs.elements.indexOf(e)
			)
			
		}
	}
	
	def private static dispatch checkInitializer (
		FStructInitializer rhs,
		FTypeRef type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		if (type.derived==null || !(type.derived instanceof FStructType)) {
			reporter.reportError(
					"invalid struct initializer in constant definition (expected " +
						FrancaHelpers::getTypeString(type) + ")",
					ctxt, feature, index);
			return;
		}
		
		val t = type.derived as FStructType
		val elems = t.getAllElements
		if (elems.size != rhs.elements.size) {
			reporter.reportError(
					"invalid number of elements in struct initializer (is " +
						rhs.elements.size + ", expected " +
						elems.size + ")",
					ctxt, feature, index);
		} else {
			for(i : 0..elems.size-1) {
				checkConstantRHS(rhs.elements.get(i),
					(elems.get(i) as FField).type,
					reporter, rhs, FSTRUCT_INITIALIZER__ELEMENTS, i
				)
			}
		}
	}
	
	def private static dispatch checkInitializer (
		FUnionInitializer rhs,
		FTypeRef type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		if (type.derived==null || !(type.derived instanceof FUnionType)) {
			reporter.reportError(
					"invalid union initializer in constant definition (expected " +
						FrancaHelpers::getTypeString(type) + ")",
					ctxt, feature, index);
			return;
		}
		
		val t = type.derived as FUnionType
		val elems = t.getAllElements
		val e = elems.findFirst[it==rhs.element]
		if (e==null) {
			reporter.reportError(
					"union initializer references invalid field '" +
						rhs.element.name + "' in constant definition",
					rhs, FUNION_INITIALIZER__ELEMENT, -1);
		} else {
			rhs.element.type
			checkConstantRHS(rhs.value,
				(e as FField).type,
				reporter, rhs, FUNION_INITIALIZER__VALUE, -1
			)
		}
	}

	def private static dispatch checkInitializer (
		FInitializer rhs,
		FTypeRef type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature,
		int index
	) {
		throw new RuntimeException("Unknown FInitializer type '" + rhs.class.toString + "'")
	}
	

	def static FTypeRef checkExpression (
			ValidationMessageReporter reporter,
			FExpression expr,
			EObject loc, EStructuralFeature feat)
	{
		checkExpression(reporter, expr, loc, feat, -1)
	}

	def private static FTypeRef checkExpression (
			ValidationMessageReporter reporter,
			FExpression expr,
			EObject loc, EStructuralFeature feat, int index)
	{
		val ts = new TypeSystem
		val issues = new IssueCollector
		val type = ts.evaluateType(expr, issues, loc, feat)
		if (! issues.issues.empty) {
			for(TypeIssue ti : issues.issues) {
				reporter.reportError(ti.message, ti.location, ti.feature)
			}
			return null
		}
		
		return type
	}
}

