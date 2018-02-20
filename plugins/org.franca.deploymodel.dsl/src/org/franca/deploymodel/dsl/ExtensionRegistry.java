/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl;

import java.util.Collection;
import java.util.List;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;

import com.google.common.collect.Lists;

/**
 * This is the registry for deployment extensions.</p>
 * 
 * It can be used in the IDE (with Eclipse's regular extension point mechanism) or
 * in standalone mode. 
 * 
 * @author Klaus Birken (itemis AG)
 */
public class ExtensionRegistry {

	private static final String EXTENSION_POINT_ID = "org.franca.deploymodel.dsl.deploymentExtension";

	private static List<IFDeployExtension> extensions = null;
	
	/**
	 * Add extension to registry.
	 * 
	 * This should only be used in standalone mode. For the IDE,
	 * use the extension point (see above) for registration.
	 * 
	 * @param extension the Franca deployment extension to be registered
	 */
	public static void addExtension(IFDeployExtension extension) {
		if (extensions==null) {
			extensions = Lists.newArrayList();
		}
		register(extension);
 	}

	/**
	 * Get all registered extensions.</p>
	 * 
	 * This will initialize the registry on demand.
	 * 
	 * @return list of all registered extensions
	 */
	public static Collection<IFDeployExtension> getExtensions() {
		if (extensions==null)
			initializeValidators();
		return extensions;
	}

	private static void initializeValidators() {
		if (extensions==null) {
			extensions = Lists.newArrayList();
		}

		IExtensionRegistry reg = Platform.getExtensionRegistry();
		if (reg==null) {
			// standalone mode, we cannot get deployment extensions from extension point registry
			return;
		}
		IExtensionPoint ep = reg.getExtensionPoint(EXTENSION_POINT_ID);

		for (IExtension extension : ep.getExtensions()) {
			for (IConfigurationElement ce : extension.getConfigurationElements()) {
				if (ce.getName().equals("validator")) {
					try {
						Object o = ce.createExecutableExtension("class");
						if (o instanceof IFDeployExtension) {
							IFDeployExtension ext = (IFDeployExtension) o;
							register(ext);
						}
					} catch (CoreException e) {
						e.printStackTrace();
					}
				}
			}
		}
	}
	
	private static void register(IFDeployExtension extension) {
		extensions.add(extension);
	}
	
	private static void initOnDemand() {
	}
}
