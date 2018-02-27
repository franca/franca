/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.dsl.ui.internal;

import com.google.inject.Module;

/*
 * Plug-in activator which can adapt to JDT vs. non-JDT environments. 
 */
public class FrancaIDLAdaptiveActivator extends DslActivator {

	protected Module getUiModule(String grammar) {
		if (ORG_FRANCA_CORE_DSL_FRANCAIDL.equals(grammar)) {
			boolean jdtAvailable = isJDTAvailable();
			if (jdtAvailable) {
				System.out.println("Franca IDL: JDT is available.");
				return new org.franca.core.dsl.ui.FrancaIDLUiModule(this);
			} else {
				System.out.println("Franca IDL: JDT is not available.");
				return new org.franca.core.dsl.ui.FrancaIDLUiModuleWithoutJDT(this);
			}
		}
		
		throw new IllegalArgumentException(grammar);
	}
	
	private boolean isJDTAvailable() {
		ClassLoader classLoader = FrancaIDLAdaptiveActivator.class.getClassLoader();
		//System.out.println("ClassLoader of FrancaIDLActivator is " + classLoader);

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
