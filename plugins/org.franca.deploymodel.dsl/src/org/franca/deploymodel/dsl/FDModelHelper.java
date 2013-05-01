/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl;

import com.google.inject.Injector;

/**
 * Manager for loading and saving Franca deployment models from file system. 
 * It supports models which are distributed over several files.
 * 
 * This class is not dependency-injection aware and shouldn't be used
 * anymore. It could lead to spurious errors in a non-standalone environment
 * (e.g., when used in the context of an IDE-action-handler class).
 * 
 * @author kbirken
 * @deprecated use FDeployPersistenceManager with dependency injection
 */
public class FDModelHelper extends FDeployPersistenceManager {

	// singleton
	private static FDModelHelper instance = null;

	public static FDModelHelper instance() {
		if (instance == null) {
			Injector injector = new FDeployStandaloneSetup().createInjectorAndDoEMFRegistration();
			instance = injector.getInstance(FDModelHelper.class);
		}
		return instance;
	}

}
