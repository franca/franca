
package org.franca.core.dsl;

import org.franca.core.franca.FrancaPackage;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class FrancaIDLStandaloneSetup extends FrancaIDLStandaloneSetupGenerated {

	public static void doSetup() {
		// initialize FrancaPackage from Franca ecore model first
	    @SuppressWarnings("unused")
		FrancaPackage fpackage = FrancaPackage.eINSTANCE;

		new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

