package org.franca.deploymodel.dsl.validation;

import org.franca.deploymodel.dsl.validation.internal.ValidatorRegistry;

public class ExternalValidatorRegistry {

	public static final String EXPENSIVE = ValidatorRegistry.MODE_EXPENSIVE;
	public static final String NORMAL = ValidatorRegistry.MODE_NORMAL;
	public static final String FAST = ValidatorRegistry.MODE_FAST;

	/**
	 * Add validator to registry.
	 * 
	 * This should only be used in standalone mode. For the IDE, the following
	 * extension point should be used for registration:
	 *    org.franca.deploymodel.dsl.deploymentValidator
	 * 
	 * @param validator the external Franca deployment model validator
	 */
	public static void addValidator(IFDeployExternalValidator validator) {
		ValidatorRegistry.addValidator(validator, FAST);
	}
	
	/**
	 * Add validator to registry with a given check mode.
	 * 
	 * This should only be used in standalone mode. For the IDE, the following
	 * extension point should be used for registration:
	 *    org.franca.deploymodel.dsl.deploymentValidator
	 * 
	 * @param validator the external Franca deployment model validator
	 * @param mode the proper check mode
	 */
	public static void addValidator(IFDeployExternalValidator validator, String mode) {
		ValidatorRegistry.addValidator(validator, mode);
 	}
}
