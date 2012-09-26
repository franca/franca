package org.franca.core.dsl;

import org.eclipse.xtext.junit4.GlobalRegistries;

import com.google.inject.Injector;

/**
 * InjectorProvider for Franca IDL tests.
 * @author Klaus Birken
 */
public class FrancaIDLTestsInjectorProvider extends FrancaIDLInjectorProvider {
	private Injector injector;

	public Injector getInjector() {
		if (injector == null) {
			stateBeforeInjectorCreation = GlobalRegistries.makeCopyOfGlobalState();
			this.injector = new FrancaIDLTestsStandaloneSetup().createInjectorAndDoEMFRegistration();
			stateAfterInjectorCreation = GlobalRegistries.makeCopyOfGlobalState();
		}
		return injector;
	}
}
