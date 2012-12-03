package org.franca.deploymodel.dsl;

import com.google.inject.Injector;

/**
 * InjectorProvider for Franca deployment tests.
 * @author Klaus Birken
 */
public class FDeployTestsInjectorProvider extends FDeployInjectorProvider {

	protected Injector internalCreateInjector() {
	    return new FDeployTestsStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
