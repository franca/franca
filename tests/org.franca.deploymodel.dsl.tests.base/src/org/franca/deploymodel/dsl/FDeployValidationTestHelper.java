/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl;

import java.util.List;

import org.eclipse.xtext.testing.validation.ValidationTestHelper;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.utils.ValidationIssueConverter;
import org.franca.deploymodel.dsl.fDeploy.FDModel;

import com.google.inject.Inject;

public class FDeployValidationTestHelper {
	
	@Inject ValidationTestHelper validationHelper;

	public String getValidationIssues (FDModel model) {
		List<Issue> issues = validationHelper.validate(model);
		return ValidationIssueConverter.getIssuesAsString(issues);
	}

}
