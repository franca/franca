package org.franca.deploymodel.dsl;

import org.eclipse.xtext.junit4.GlobalRegistries;

import com.google.inject.Injector;

/**
 * InjectorProvider for Franca deployment tests.
 * @author Klaus Birken
 */
public class FDeployTestsInjectorProvider extends FDeployInjectorProvider {
	private Injector injector;

	public Injector getInjector() {
		if (injector == null) {
			stateBeforeInjectorCreation = GlobalRegistries.makeCopyOfGlobalState();
			this.injector = new FDeployTestsStandaloneSetup().createInjectorAndDoEMFRegistration();
			stateAfterInjectorCreation = GlobalRegistries.makeCopyOfGlobalState();
		}
		return injector;
	}
}
