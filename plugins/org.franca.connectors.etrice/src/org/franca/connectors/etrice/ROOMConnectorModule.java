/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice;

import org.franca.connectors.etrice.internal.ModelLib;
import org.franca.connectors.etrice.internal.TypeGenerator;

import com.google.inject.AbstractModule;
import com.google.inject.Singleton;

/**
 * Guice module for configuring Guice injectors.
 * This module is needed for initializing ROOMConnector objects.
 * 
 * @author birken
 *
 */
public class ROOMConnectorModule extends AbstractModule {

	@Override
	protected void configure() {
		bind(TypeGenerator.class).in(Singleton.class);
		bind(ModelLib.class).in(Singleton.class);
	}

}
