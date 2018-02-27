package org.franca.core.dsl;

import org.franca.core.dsl.tests.FrancaIDLInjectorProvider;

import com.google.inject.Injector;

/**
 * InjectorProvider for Franca IDL tests.
 * @author Klaus Birken
 */
public class FrancaIDLTestsInjectorProvider extends FrancaIDLInjectorProvider {

	protected Injector internalCreateInjector() {
	    return new FrancaIDLTestsStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
