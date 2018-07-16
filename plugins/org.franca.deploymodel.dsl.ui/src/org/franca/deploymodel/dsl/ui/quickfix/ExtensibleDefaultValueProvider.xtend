/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl.ui.quickfix

import java.util.List
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IConfigurationElement
import org.eclipse.core.runtime.IExtensionPoint
import org.eclipse.core.runtime.IExtensionRegistry
import org.eclipse.core.runtime.Platform
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef

/**
 * A provider for deployment property default values which can be extended
 * by an extension point.</p>
 */
class ExtensibleDefaultValueProvider {

	val static final String EXTENSION_POINT_ID = "org.franca.deploymodel.dsl.ui.defaultValueProvider"

	private static List<IDefaultValueProvider> extensions = null

	/**
	 * Provide a default value for any of the property types in a deployment model.<p/>
	 * 
	 * The actual default value might be different for the various properties of a
	 * deployment model. Thus, the context is submitted as arguments to the method.</p>
	 */
	def static FDComplexValue generateDefaultValue(
		FDRootElement root,
		FDElement element,
		FDProperty property,
		FDTypeRef typeRef
	) {
		if (extensions===null) {
			initializeExtensions
		}
		
		// try to get a value from all extensions (first come, first serve)
		for(ext : extensions) {
			val v = ext.generateDefaultValue(root, element, property, typeRef)
			if (v!==null)
				return v
		}
		
		// no default value provided by extensions, use fallback provider
		val fallbackProvider = new DefaultValueProvider
		fallbackProvider.generateDefaultValue(root, element, property, typeRef)
	}


	def private static void initializeExtensions() {
		extensions = newArrayList

		val IExtensionRegistry reg = Platform.getExtensionRegistry
		if (reg===null) {
			// standalone mode, we cannot get extensions from extension point registry
			return
		}
		
		val IExtensionPoint ep = reg.getExtensionPoint(EXTENSION_POINT_ID)
		for (ext : ep.extensions) {
			for (IConfigurationElement ce : ext.configurationElements) {
				if (ce.name.equals("defaultValueProvider")) {
					try {
						val Object ee = ce.createExecutableExtension("class")
						if (ee instanceof IDefaultValueProvider) {
							putToList(ee)
						}
					} catch (CoreException e) {
						e.printStackTrace();
					}
				}
			}
		}
	}
	
	def private static void putToList(IDefaultValueProvider ^extension) {
		extensions.add(extension)
	}
}
