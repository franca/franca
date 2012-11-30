/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.core;

import org.eclipse.emf.ecore.EObject;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;

/**
 * Helper functions for navigation in deployment models.
 * 
 * @author kbirken
 *
 */
public class FDModelUtils {

	public static FDModel getModel(EObject obj) {
		EObject x = obj;
		do {
			if (x instanceof FDModel)
				return (FDModel) x;
			x = x.eContainer();
		} while (x != null);
		return null;
	}

	public static FDRootElement getRootElement(FDElement obj) {
		EObject x = obj;
		do {
			if (x instanceof FDRootElement)
				return (FDRootElement) x;
			x = x.eContainer();
		} while (x != null);
		return null;
	}

}
