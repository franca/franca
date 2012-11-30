
package org.franca.core.dsl;

import org.eclipse.emf.ecore.EPackage;

import com.google.inject.Injector;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class FrancaIDLStandaloneSetup extends FrancaIDLStandaloneSetupGenerated {

	public static void doSetup() {
		new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
	
	public Injector createInjectorAndDoEMFRegistration() {
		// the FrancaPackage might not be registered because the EMF model is not part of the DSL
		if (! EPackage.Registry.INSTANCE.containsKey("http://core.franca.org")) {
			EPackage.Registry.INSTANCE.put("http://core.franca.org", org.franca.core.franca.FrancaPackage.eINSTANCE);
		}
		return super.createInjectorAndDoEMFRegistration();
	}
}

