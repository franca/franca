/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation;

import org.franca.core.dsl.validation.internal.ValidatorRegistry;

public class ExternalValidatorRegistry {

	public static final String EXPENSIVE = ValidatorRegistry.MODE_EXPENSIVE;
	public static final String NORMAL = ValidatorRegistry.MODE_NORMAL;
	public static final String FAST = ValidatorRegistry.MODE_FAST;

	/**
	 * Add validator to registry.
	 * 
	 * This should only be used in standalone mode. For the IDE, the following
	 * extension point should be used for registration:
	 *    org.franca.core.dsl.francaValidator
	 * 
	 * @param validator the external Franca IDL validator
	 */
	public static void addValidator(IFrancaExternalValidator validator) {
		ValidatorRegistry.addValidator(validator, FAST);
	}
	
	/**
	 * Add validator to registry with a given check mode.
	 * 
	 * This should only be used in standalone mode. For the IDE, the following
	 * extension point should be used for registration:
	 *    org.franca.core.dsl.francaValidator
	 * 
	 * @param validator the external Franca IDL validator
	 * @param mode the proper check mode
	 */
	public static void addValidator(IFrancaExternalValidator validator, String mode) {
		ValidatorRegistry.addValidator(validator, mode);
 	}
}
