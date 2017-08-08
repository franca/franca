/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.validation.internal;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.eclipse.xtext.validation.CheckMode;
import org.franca.deploymodel.dsl.validation.IFDeployExternalValidator;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

public class ValidatorRegistry {

	private static final String EXTENSION_POINT_ID = "org.franca.deploymodel.dsl.deploymentValidator";
	private static Multimap<CheckMode, IFDeployExternalValidator> validatorMap;
	
	public static final String MODE_EXPENSIVE = "EXPENSIVE";
	public static final String MODE_NORMAL = "NORMAL";
	public static final String MODE_FAST = "FAST";
			
	public static Multimap<CheckMode, IFDeployExternalValidator> getValidatorMap() {
		if (validatorMap == null) {
			initializeValidators();
		}
		return validatorMap;
	}
	
	/**
	 * Add validator to registry with a given check mode.
	 * 
	 * This should only be used in standalone mode. For the IDE,
	 * use the extension point (see above) for registration.
	 * 
	 * @param validator the external Franca deployment model validator
	 * @param mode the proper check mode
	 */
	public static void addValidator(IFDeployExternalValidator validator, String mode) {
		if (validatorMap == null) {
			validatorMap = ArrayListMultimap.create();
		}

		putToMap(validator, mode);
 	}

	private static void initializeValidators() {
		validatorMap = ArrayListMultimap.create();

		IExtensionRegistry reg = Platform.getExtensionRegistry();
		if (reg==null) {
			// standalone mode, we cannot get validators from extension point registry
			return;
		}
		IExtensionPoint ep = reg.getExtensionPoint(EXTENSION_POINT_ID);

		for (IExtension extension : ep.getExtensions()) {
			for (IConfigurationElement ce : extension
					.getConfigurationElements()) {
				if (ce.getName().equals("validator")) {
					try {
						Object o = ce.createExecutableExtension("class");
						if (o instanceof IFDeployExternalValidator) {
							IFDeployExternalValidator validator = (IFDeployExternalValidator) o;
							String mode = ce.getAttribute("mode");
							putToMap(validator, mode);
						}
					} catch (CoreException e) {
						e.printStackTrace();
					}
				}
			}
		}
	}
	
	private static void putToMap (IFDeployExternalValidator validator, String mode) {
		validatorMap.put(CheckMode.ALL, validator);
		
		if (mode.matches(MODE_EXPENSIVE)) {
			validatorMap.put(CheckMode.EXPENSIVE_ONLY, validator);
		} else if (mode.matches(MODE_NORMAL)) {
			validatorMap.put(CheckMode.NORMAL_ONLY, validator);
			validatorMap.put(CheckMode.NORMAL_AND_FAST, validator);
		} else {
			validatorMap.put(CheckMode.FAST_ONLY, validator);
			validatorMap.put(CheckMode.NORMAL_AND_FAST, validator);
		}
	}
}
