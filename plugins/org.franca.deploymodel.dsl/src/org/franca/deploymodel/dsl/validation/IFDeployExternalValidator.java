/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.validation;

import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.deploymodel.dsl.fDeploy.FDModel;

/**
 * The external validator is used to extend the set of validators used by Franca. 
 * It is possible to define custom validation rules for deployment models
 * (i.e., deployment specifications and definitions) and those will be called 
 * either after the *.fdepl file is saved (FAST and NORMAL mode) or when it is 
 * manually triggered from the context menu of Franca (EXPENSIVE mode).
 * 
 * @author Klaus Birken (itemis AG)
 *
 */
public interface IFDeployExternalValidator {

	/**
	 * This method is used to perform external validation logic on a given
	 * Franca deployment file. 
	 * 
	 * @param model the Franca deployment model created from the *.fdepl file
	 * @param messageAcceptor the message acceptor to log the validation messages
	 */
	public void validateModel(FDModel model, ValidationMessageAcceptor messageAcceptor);
	
}
