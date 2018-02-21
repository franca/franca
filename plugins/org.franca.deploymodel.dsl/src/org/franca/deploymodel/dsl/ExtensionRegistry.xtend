/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl

import com.google.common.collect.Lists
import java.util.Collection
import java.util.List
import java.util.Map
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IConfigurationElement
import org.eclipse.core.runtime.IExtension
import org.eclipse.core.runtime.IExtensionPoint
import org.eclipse.core.runtime.IExtensionRegistry
import org.eclipse.core.runtime.Platform

/** 
 * This is the registry for deployment extensions.</p>
 * 
 * It can be used in the IDE (with Eclipse's regular extension point mechanism) or
 * in standalone mode.</p>
 *  
 * @author Klaus Birken (itemis AG)
 */
class ExtensionRegistry {
	static final String EXTENSION_POINT_ID = "org.franca.deploymodel.dsl.deploymentExtension"
	
	static List<IFDeployExtension> extensions = null

	/** 
	 * Add extension to registry.
	 * This should only be used in standalone mode. For the IDE,
	 * use the extension point (see above) for registration.
	 * @param ^extension the Franca deployment extension to be registered
	 */
	def static void addExtension(IFDeployExtension ^extension) {
		if (extensions === null) {
			extensions = Lists.newArrayList()
		}
		register(^extension)
	}

	/** 
	 * Get all registered extensions.</p>
	 * This will initialize the registry on demand.
	 * @return list of all registered extensions
	 */
	def static Collection<IFDeployExtension> getExtensions() {
		if(extensions === null) initializeValidators()
		return extensions
	}

	def private static void initializeValidators() {
		if (extensions === null) {
			extensions = Lists.newArrayList()
		}
		
		var IExtensionRegistry reg = Platform.getExtensionRegistry()
		if (reg === null) {
			// standalone mode, we cannot get deployment extensions from extension point registry
			return
		}
		
		var IExtensionPoint ep = reg.getExtensionPoint(EXTENSION_POINT_ID)
		for (IExtension ext : ep.getExtensions()) {
			for (IConfigurationElement ce : ext.getConfigurationElements()) {
				if (ce.name.equals("validator")) {
					try {
						var Object o = ce.createExecutableExtension("class")
						if (o instanceof IFDeployExtension) {
							var IFDeployExtension dExt = (o as IFDeployExtension)
							register(dExt)
						}
					} catch (CoreException e) {
						e.printStackTrace()
					}

				}
			}
		}
	}

	def private static void register(IFDeployExtension ^extension) {
		extensions.add(^extension)
	}


	def static Map<String, IFDeployExtension> getHosts() {
		val result = newHashMap
		for(ext : getExtensions()) {
			for(host : ext.hosts) {
				result.put(host, ext)
			} 
		}
		result
	}

	def static Map<IFDeployExtension.Root, IFDeployExtension> getRoots() {
		val result = newHashMap
		for(ext : getExtensions()) {
			for(root : ext.roots) {
				result.put(root, ext)
			} 
		}
		result
	}

	def static IFDeployExtension.Root findRoot(String type) {
		val roots = getExtensions().map[roots].flatten
		roots.findFirst[name==type]
	}
}
