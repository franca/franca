/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.franca.core.contracts.IssueCollector;
import org.franca.core.contracts.TypeIssue;
import org.franca.core.contracts.TypeSystem;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FConstantDef;
import org.franca.core.franca.FExpression;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FrancaPackage;

public class TypesValidator {

	public static void checkConstantType (ValidationMessageReporter reporter, FConstantDef constantDef) {
		FTypeRef typeRHS = checkExpression(reporter, constantDef.getRhs(), constantDef, FrancaPackage.Literals.FCONSTANT_DEF__RHS);
		if (typeRHS!=null) {
			FTypeRef typeLHS = constantDef.getType();
			if (! TypeSystem.isCompatibleType(typeRHS, typeLHS)) {
				reporter.reportError(
						"invalid expression type in contant definition (is " +
								FrancaHelpers.getTypeString(typeRHS) + ", expected " +
								FrancaHelpers.getTypeString(typeLHS) + ")",
						constantDef, FrancaPackage.Literals.FCONSTANT_DEF__RHS);
			}
		}
	}
	

	public static FTypeRef checkExpression (
			ValidationMessageReporter reporter,
			FExpression expr,
			EObject loc, EStructuralFeature feat)
	{
		TypeSystem ts = new TypeSystem();
		IssueCollector issues = new IssueCollector();
		FTypeRef type = ts.evaluateType(expr, issues, loc, feat);
		if (! issues.getIssues().isEmpty()) {
			for(TypeIssue ti : issues.getIssues()) {
				reporter.reportError(ti.getMessage(), ti.getLocation(), ti.getFeature());
			}
			return null;
		}
		
		return type;
	}
}

