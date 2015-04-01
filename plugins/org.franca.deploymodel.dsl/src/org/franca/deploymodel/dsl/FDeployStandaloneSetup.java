
package org.franca.deploymodel.dsl;

import org.eclipse.emf.ecore.EPackage;

import com.google.inject.Injector;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class FDeployStandaloneSetup extends FDeployStandaloneSetupGenerated{

	public static void doSetup() {
		new FDeployStandaloneSetup().createInjectorAndDoEMFRegistration();
	}

	public Injector createInjectorAndDoEMFRegistration() {
		// In certain use cases (during tests using the FrancaIDLInjectorProvider)
		// the registration of FrancaPackage in the EPackage.Registry might get lost.
		// We do this again here, just in case.
		if (! EPackage.Registry.INSTANCE.containsKey("http://core.franca.org")) {
			EPackage.Registry.INSTANCE.put("http://core.franca.org", org.franca.core.franca.FrancaPackage.eINSTANCE);
		}
		
		return super.createInjectorAndDoEMFRegistration();
	}

    @Override
    public void register(Injector injector) {
        if (!EPackage.Registry.INSTANCE.containsKey("http://www.franca.org/deploymodel/dsl/FDeploy")) {
            EPackage.Registry.INSTANCE.put("http://www.franca.org/deploymodel/dsl/FDeploy", org.franca.deploymodel.dsl.fDeploy.FDeployPackage.eINSTANCE);
        }
        super.register(injector);
    }
}

