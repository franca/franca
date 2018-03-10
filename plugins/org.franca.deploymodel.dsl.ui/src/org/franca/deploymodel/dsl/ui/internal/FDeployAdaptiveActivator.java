/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.ui.internal;

import com.google.inject.Module;

/*
 * Plug-in activator which can adapt to JDT vs. non-JDT environments. 
 */
public class FDeployAdaptiveActivator extends DslActivator {

	protected Module getUiModule(String grammar) {
		if (ORG_FRANCA_DEPLOYMODEL_DSL_FDEPLOY.equals(grammar)) {
			boolean jdtAvailable = isJDTAvailable();
			if (jdtAvailable) {
				System.out.println("Franca Deployment: JDT is available.");
				return new org.franca.deploymodel.dsl.ui.FDeployUiModule(this);
			} else {
				System.out.println("Franca Deployment: JDT is not available.");
				return new org.franca.deploymodel.dsl.ui.FDeployUiModuleWithoutJDT(this);
			}
		}
		
		throw new IllegalArgumentException(grammar);
	}
	
	private boolean isJDTAvailable() {
		ClassLoader classLoader = FDeployAdaptiveActivator.class.getClassLoader();
		//System.out.println("ClassLoader of FDeployActivator is " + classLoader);

		boolean jdtAvailable;
		try {
			Class.forName("org.eclipse.jdt.core.JavaCore", false, classLoader);
			jdtAvailable = true;
		} catch (ClassNotFoundException e) {
			jdtAvailable = false;
		}

		return jdtAvailable;
	}

}
