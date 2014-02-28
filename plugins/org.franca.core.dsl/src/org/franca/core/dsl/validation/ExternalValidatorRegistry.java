package org.franca.core.dsl.validation;

import org.franca.core.dsl.validation.internal.ValidatorRegistry;

public class ExternalValidatorRegistry {

	public static final String EXPENSIVE = ValidatorRegistry.MODE_EXPENSIVE;
	public static final String NORMAL = ValidatorRegistry.MODE_NORMAL;
	public static final String FAST = ValidatorRegistry.MODE_FAST;

	/**
	 * Add validator to registry.
	 * 
	 * This should only be used in standalone mode. For the IDE,
	 * use the extension point (see above) for registration.
	 * 
	 * @param validator the external Franca IDL validator
	 */
	public static void addValidator(IFrancaExternalValidator validator) {
		ValidatorRegistry.addValidator(validator, FAST);
	}
	
	/**
	 * Add validator to registry with a given check mode.
	 * 
	 * This should only be used in standalone mode. For the IDE,
	 * use the extension point (see above) for registration.
	 * 
	 * @param validator the external Franca IDL validator
	 * @param mode the proper check mode
	 */
	public static void addValidator(IFrancaExternalValidator validator, String mode) {
		ValidatorRegistry.addValidator(validator, mode);
 	}
}
