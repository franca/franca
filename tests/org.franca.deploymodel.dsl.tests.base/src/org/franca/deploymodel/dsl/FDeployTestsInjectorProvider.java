/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl;

import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.deploymodel.dsl.tests.FDeployInjectorProvider;

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
