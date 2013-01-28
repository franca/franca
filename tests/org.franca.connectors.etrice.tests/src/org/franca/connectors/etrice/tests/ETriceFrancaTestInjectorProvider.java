/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.tests;

import org.franca.connectors.etrice.ROOMConnectorStandaloneSetup;
import org.franca.core.dsl.FrancaIDLInjectorProvider;

import com.google.inject.Injector;

public class ETriceFrancaTestInjectorProvider extends FrancaIDLInjectorProvider {

	protected Injector internalCreateInjector() {
	    return new ROOMConnectorStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
