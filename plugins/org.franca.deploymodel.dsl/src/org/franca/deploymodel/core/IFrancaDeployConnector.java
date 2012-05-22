/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.core;

import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.IModelPersistenceManager;
import org.franca.deploymodel.dsl.fDeploy.FDModel;

public interface IFrancaDeployConnector extends IModelPersistenceManager {

	// conversion to/from Franca deployment models
	public FDModel toFranca (IModelContainer model);
	public IModelContainer fromFranca (FDModel fmodel);
}
