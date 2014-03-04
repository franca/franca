/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.core;

import org.franca.core.franca.FTypeCollection;
import org.franca.deploymodel.dsl.FDMapper;
import org.franca.deploymodel.dsl.fDeploy.FDTypes;

/**
 * This class provides type-safe access to deployment properties which are attached to a Franca IDL interface. The get-functions in this class take an EObject
 * as first argument, which should be an entity from the Franca IDL model (e.g., a FMethod or a FAttribute). The value of the property will be returned in a
 * type-safe way. It will be the actual property value attached to the Franca interface or the default value defined in the specification.
 * 
 * @author KBirken
 * @see FDeployedProvider
 */
public class FDeployedTypeCollection extends MappingGenericPropertyAccessor {
	protected FDTypes ftypes;

	public FDeployedTypeCollection(FDTypes ftypes) {
		super(ftypes.getSpec(),new FDMapper(ftypes));
		this.ftypes = ftypes;
	}

	public FTypeCollection getTypeCollection() {
		return ftypes.getTarget();
	}

}
