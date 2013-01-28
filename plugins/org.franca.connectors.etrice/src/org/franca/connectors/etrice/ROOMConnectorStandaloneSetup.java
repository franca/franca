/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice;

import org.eclipse.xtext.util.Modules2;
import org.franca.core.dsl.FrancaIDLRuntimeModule;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;

import com.google.inject.Guice;
import com.google.inject.Injector;

/**
 * Standalone setup class with provides a mixin of Franca IDL and ROOMConnector.
 * 
 * @author birken
 */
public class ROOMConnectorStandaloneSetup extends FrancaIDLStandaloneSetup {

    @Override
    public Injector createInjector() {
        return Guice.createInjector(
        		Modules2.mixin(
        				new FrancaIDLRuntimeModule(),
        				new ROOMConnectorModule()
        		));
    }
}
