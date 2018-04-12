/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.examples.validators.fdepl;

import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage;
import org.franca.deploymodel.dsl.validation.IFDeployExternalValidator;

/**
 * This is an example of an external validator for Franca deployment models.<p/>
 * 
 * It checks the name of a deployment specification and issues an error
 * if the name is shorter than a hard-coded minimum length.
 */
public class SpecNameValidator implements IFDeployExternalValidator {

	static final int SPEC_NAME_MINIMUM_LENGTH = 5;
			
	@Override
	public void validateModel(FDModel model,
			ValidationMessageAcceptor messageAcceptor) {

		for(FDSpecification spec : model.getSpecifications()) {
			String name = spec.getName();
			if (name.length() < SPEC_NAME_MINIMUM_LENGTH) {
				messageAcceptor.acceptError(
						"The name of the specification is too short (minimum is " +
								SPEC_NAME_MINIMUM_LENGTH + " characters)!", spec,
						FDeployPackage.Literals.FD_SPECIFICATION__NAME,
						ValidationMessageAcceptor.INSIGNIFICANT_INDEX, 
						null);
			}
		}
	}
}
