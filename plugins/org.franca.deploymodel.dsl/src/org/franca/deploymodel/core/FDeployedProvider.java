/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.core;

import org.franca.deploymodel.dsl.fDeploy.FDProvider;

/**
 * This class provides type-safe access to deployment properties which are
 * related to interface providers and interface instances.
 * The actual get-functions for reading property values are provided
 * by the base class GenericPropertyAccessor in a generic, but 
 * nevertheless type-safe way. The returned value will be the actual
 * property value or the default value as defined in the specification.
 *    
 * @author KBirken
 * @see FDeployedInterface, GenericPropertyAccessor
 */
public class FDeployedProvider extends GenericPropertyAccessor {

	private FDProvider provider;
	
	public FDeployedProvider (FDProvider provider) {
		super(provider.getSpec());
		this.provider = provider;
	}
	
	public FDProvider getProvider() {
		return provider;
	}
}

