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

class TypesValidator {

	def static checkConstantType (ValidationMessageReporter reporter, FConstantDef constantDef) {
		val rhs = constantDef.getRhs();
		switch (rhs) {
			FExpression: {
				val typeRHS = checkExpression(reporter, rhs, constantDef, FCONSTANT_DEF__RHS)
				if (typeRHS!=null) {
					val typeLHS = constantDef.getType();
					if (! TypeSystem::isCompatibleType(typeRHS, typeLHS)) {
						reporter.reportError(
							"invalid expression type in constant definition (is " +
								FrancaHelpers::getTypeString(typeRHS) + ", expected " +
								FrancaHelpers::getTypeString(typeLHS) + ")",
							constantDef, FCONSTANT_DEF__RHS);
					}
				}
				
			}
			FInitializer: {
				checkInitializer(rhs, constantDef.type, reporter, constantDef, FCONSTANT_DEF__RHS)
			}
		}
	}
	
	def private static dispatch checkInitializer (
		FArrayInitializer rhs,
		FTypeRef type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature
	) {
		if (type.derived==null || !(type.derived instanceof FArrayType)) {
			reporter.reportError(
					"invalid array initializer type in constant definition (expected " +
						FrancaHelpers::getTypeString(type) + ")",
					ctxt, feature);
		}
	}
	
	def private static dispatch checkInitializer (
		FStructInitializer rhs,
		FTypeRef type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature
	) {
		if (type.derived==null || !(type.derived instanceof FStructType)) {
			reporter.reportError(
					"invalid struct initializer type in constant definition (expected " +
						FrancaHelpers::getTypeString(type) + ")",
					ctxt, feature);
		}
		
		val t = type.derived as FStructType
		// TODO: support struct inheritance
		if (t.elements.size != rhs.elements.size) {
			reporter.reportError(
					"invalid number of elements in struct initializer (is " +
						rhs.elements.size + ", expected " +
						t.elements.size + ")",
					ctxt, feature);
		}
		for(i : 0..t.elements.size-1) {
			// TODO
		}
	}
	
	def private static dispatch checkInitializer (
		FInitializer rhs,
		FTypeRef type,
		ValidationMessageReporter reporter,
		EObject ctxt,
		EStructuralFeature feature
	) {
		throw new RuntimeException("Unknown FInitializer type '" + rhs.class.toString + "'")
	}
	

	def static FTypeRef checkExpression (
			ValidationMessageReporter reporter,
			FExpression expr,
			EObject loc, EStructuralFeature feat)
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

