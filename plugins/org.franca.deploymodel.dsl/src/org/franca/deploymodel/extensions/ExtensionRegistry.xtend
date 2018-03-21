/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.extensions

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
import org.eclipse.emf.ecore.EClass
import org.franca.deploymodel.dsl.fDeploy.FDAbstractExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot
import org.franca.deploymodel.extensions.IFDeployExtension.Host

import static extension org.franca.deploymodel.extensions.ExtensionUtils.*
import static extension com.google.common.collect.Iterables.*

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

	static Map<EClass, Iterable<Host>> allAdditionalHosts = newHashMap
	
	def private static void register(IFDeployExtension ^extension) {
		// add extension to the list of all extensions
		extensions.add(^extension)
		
		// add to global table of additional hosts
		val addHosts = extension.additionalHosts
		for(clazz : addHosts.keySet) {
			if (allAdditionalHosts.containsKey(clazz)) {
				val previousHosts = allAdditionalHosts.get(clazz)
				val joined = previousHosts.concat(addHosts.get(clazz)).unmodifiableIterable
				allAdditionalHosts.put(clazz, joined)
			} else {
				allAdditionalHosts.put(clazz, addHosts.get(clazz))
			}
		}
	}


	def static Map<Host, IFDeployExtension> getHosts() {
		val result = newHashMap
		for(ext : getExtensions()) {
			val extHosts = ext.allHosts.toInvertedMap[ext]
			result.putAll(extHosts)
		}
		result
	}
	
	def static IFDeployExtension.Host findHost(String hostname) {
		val hosts = getHosts().keySet
		hosts.findFirst[it.name==hostname]
	}

	def static Map<IFDeployExtension.RootDef, IFDeployExtension> getRoots() {
		val result = newHashMap
		for(ext : getExtensions()) {
			for(root : ext.roots) {
				result.put(root, ext)
			} 
		}
		result
	}

	def static IFDeployExtension.RootDef findRoot(String rootTag) {
		val roots = getExtensions().map[roots].flatten//.filter[tag!==null]
		roots.findFirst[tag==rootTag]
	}

//	def static IFDeployExtension.RootDef findRoot(EClass clazz) {
//		val roots = getExtensions().map[roots].flatten.filter[it.EClass!==null]
//		roots.findFirst[it.EClass==clazz]
//	}

	// get metamodel ElementDef from model FDAbstractExtensionElement (which is an EObject)	
	def static IFDeployExtension.AbstractElementDef getElement(FDAbstractExtensionElement elem) {
		switch (elem) {
			FDExtensionRoot: {
				findRoot(elem.tag)
			}
			FDExtensionElement: {
				// recursive call to find Element for parent
				val parent = (elem.eContainer as FDAbstractExtensionElement).getElement
				
				// use tag to find child element
				parent.children.findFirst[it.tag==elem.tag]
			}
			default:
				return null
		}
	}
	
	def static Iterable<Host> getAdditionalHosts(EClass clazz) {
		if(extensions === null) initializeValidators()
		val result = allAdditionalHosts.get(clazz)
		if (result!==null)
			result
		else
			newArrayList
	} 
}
