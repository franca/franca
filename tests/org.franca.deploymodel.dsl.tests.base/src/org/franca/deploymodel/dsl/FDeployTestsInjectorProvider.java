package org.franca.deploymodel.dsl;

import org.franca.core.dsl.FrancaIDLStandaloneSetup;

import com.google.inject.Injector;

/**
 * InjectorProvider for Franca deployment tests.
 * @author Klaus Birken
 */
public class FDeployTestsInjectorProvider extends FDeployInjectorProvider {

	private Injector francaInjector = null;
	
	@Override
	public Injector getInjector() {
		if (francaInjector == null) {
			francaInjector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
		}
		return super.getInjector();
	}
	
	protected Injector internalCreateInjector() {
	    return new FDeployTestsStandaloneSetup().createInjectorAndDoEMFRegistration();
	}

	@Override
	public void setupRegistry() {
		if (francaInjector != null) {
			new FrancaIDLStandaloneSetup().register(francaInjector);
		}
		super.setupRegistry();
	}
}
