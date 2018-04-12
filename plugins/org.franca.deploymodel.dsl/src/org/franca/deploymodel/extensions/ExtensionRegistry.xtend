/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.extensions

import com.google.common.collect.Iterables
import com.google.common.collect.LinkedListMultimap
import com.google.common.collect.Lists
import com.google.common.collect.Multimap
import com.google.common.collect.Sets
import java.util.Collection
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IConfigurationElement
import org.eclipse.core.runtime.IExtension
import org.eclipse.core.runtime.IExtensionPoint
import org.eclipse.core.runtime.IExtensionRegistry
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.franca.deploymodel.dsl.fDeploy.FDAbstractExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.franca.deploymodel.extensions.IFDeployExtension.Host
import org.franca.deploymodel.extensions.IFDeployExtension.HostMixinDef.AccessorArgumentStyle

import static extension org.franca.deploymodel.extensions.ExtensionUtils.*

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

	// auxiliary data structures (used as cache)
	static Map<EClass, Iterable<Host>> allAdditionalHosts = newHashMap
	static Map<Host, Set<EClass>> hostingClasses = newHashMap
	static Map<EClass, IFDeployExtension> mixinExtensions = newHashMap
	static Map<EClass, EClassifier> accessorArgumentType = newHashMap
	static Set<EClass> isNonFrancaMixin = newHashSet
	static Map<EClass, String> nonFrancaMixinRootPrefix = newHashMap
	static Multimap<EClass, EClass> mixinChildren = LinkedListMultimap.create

	/** 
	 * Add extension to registry.</p>
	 * 
	 * This should only be used in standalone mode. For the IDE,
	 * use the extension point (see above) for registration.</p>
	 * 
	 * @param ^extension the Franca deployment extension to be registered
	 */
	def static void addExtension(IFDeployExtension ^extension) {
		if (extensions === null) {
			extensions = Lists.newArrayList()
		}
		//println("DEPLOYEXTENSION STANDALONE ADD '" + extension.shortDescription + "'")
		register(^extension)
	}
	
	/**
	 * Reset the registry and remove all extensions.</p>
	 * 
	 * This should be used by standalone tests which call addExtension() to
	 * register an extension and test it.</p> 
	 * 
	 * Note that this method will remove <em>all</em> registered extensions.
	 * Due to complex cached data structures in the registry it is not possible
	 * to remove a single specific extension in the current implementation.</p> 
	 */
	def static void reset() {
		//println("DEPLOYEXTENSION STANDALONE CLEAR")
		extensions.clear
		allAdditionalHosts.clear
		hostingClasses.clear
		mixinExtensions.clear
		accessorArgumentType.clear
		isNonFrancaMixin.clear
		mixinChildren.clear
	}

	/** 
	 * Get all registered extensions.</p>
	 * 
	 * This will initialize the registry on demand.</p>
	 * 
	 * @return list of all registered extensions
	 */
	def static Collection<IFDeployExtension> getExtensions() {
		if(extensions === null) initializeValidators()
		return extensions
	}

	/**
	 * Internal helper which initializes all deployment extensions
	 * that have been registered as Eclipse extension points.</p> 
	 */
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

	/**
	 * This is the central registration method for new extensions.</p>
	 * 
	 * All extensions will be registered here, either via the IDE's extension point
	 * infrastructure or via method addExtension in the standalone case.</p>
	 */
	def private static void register(IFDeployExtension ^extension) {
		// add extension to the list of all extensions
		val desc = extension.shortDescription
		if (extensions.map[shortDescription].contains(desc)) {
			System.err.println("ERROR: Deployment extension '" + desc + "' has already been registered!")
			return
		}
		extensions.add(^extension)
		
		//println("DEPLOYEXTENSION REGISTERED '" + desc + "'")

		for(root : extension.roots) {
			root.hosts.forEach[addHostingClass(FDeployPackage.eINSTANCE.FDExtensionRoot)]
			root.hostsOnlyInSubtree.forEach[addHostingClass(FDeployPackage.eINSTANCE.FDExtensionElement)]
		}
		for(mixin : extension.mixins) {
			val clazz = mixin.hostingClass
			val hosts = mixin.hosts

			// add to global table of additional hosts
			if (allAdditionalHosts.containsKey(clazz)) {
				val previousHosts = allAdditionalHosts.get(clazz)
				val joined = Iterables.unmodifiableIterable(Iterables.concat(previousHosts, hosts))
				allAdditionalHosts.put(clazz, joined)
			} else {
				allAdditionalHosts.put(clazz, hosts)
			}

			// add to reverse mapping of hosts to hosting classes			
			hosts.forEach[addHostingClass(clazz)]
		}
		
		// add entries to map of argument-types for property accessors
		for(mixin : extension.mixins) {
			val clazz = mixin.hostingClass

			// store extension for mixin
			mixinExtensions.put(clazz, extension)
			
			// determine argument type
			if (mixin.accessorArgument === AccessorArgumentStyle.BY_TARGET_FEATURE) {
				val targetType = clazz.classOfTargetFeature
				if (accessorArgumentType.containsKey(clazz)) {
					val targetType0 = accessorArgumentType.get(clazz)
					if (targetType0!==targetType) {
						System.err.println("ERROR: Duplicate argument type definition for class '" + clazz.name + "'")
					}
				} else {
					accessorArgumentType.put(clazz, targetType)
				}
			}
			
			// remember all mixins which should be handled as Franca IDL extensions
			if (mixin.isNonFrancaMixin) {
				isNonFrancaMixin.add(clazz)

				// store prefixes for root mixins
				if (mixin.accessorRootPrefix!==null) {
					val prefix = mixin.accessorRootPrefix
					nonFrancaMixinRootPrefix.put(clazz, prefix)
				}
			}
		}
		
		// find non-Franca child mixins and attach to root mixins
		val children = extension.mixins.filter[isChildMixin].map[hostingClass].toSet
		val roots = extension.mixins.filter[accessorRootPrefix!==null].map[hostingClass]
		for(rootMixin : roots) {
			val usedClasses = rootMixin.EStructuralFeatures.map[EType].toSet
			val both = Sets.intersection(children, usedClasses)
			mixinChildren.putAll(rootMixin, both)
		}
	}

	def private static addHostingClass(Host host, EClass clazz) {
		if (! hostingClasses.containsKey(host)) {
			hostingClasses.put(host, newHashSet)
		}
		hostingClasses.get(host).add(clazz)
	}

	/**
	 * Helper to get the classifier type from EMF feature "target".</p>
	 */
	def private static EClassifier getClassOfTargetFeature(EClass clazz) {
		val targetFeature = clazz.EAllReferences.findFirst[name=="target"]
		if (targetFeature!==null) {
			if (targetFeature.EType instanceof EClassifier)
				targetFeature.EType
			else
				null
		} else {
			null
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

	def static boolean hasHostSubtree(IFDeployExtension.AbstractElementDef elem, Host host) {
		elem.allHosts.contains(host)
	}

	/**
	 * Get metamodel ElementDef from model FDAbstractExtensionElement (which is an EObject)</p>
	 */	
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
	
	def static Set<EClass> getHostingClasses(Host host) {
		if(extensions === null) initializeValidators()
		
		val result = hostingClasses.get(host)
		if (result!==null)
			result
		else
			newHashSet
	}
	
	def static EClassifier getAccessorArgumentType(EClass clazz) {
		if (accessorArgumentType.containsKey(clazz)) {
			// we have an entry in the argumentType mapping table, use it
			accessorArgumentType.get(clazz)
		} else {
			// there is no mapping for this clazz, use it directly as argument type
			clazz
		}
	}
	
	def static IFDeployExtension getMixinExtension(EClass clazz) {
		mixinExtensions.get(clazz)
	}

	def static getNonFrancaMixinRoots() {
		nonFrancaMixinRootPrefix.keySet
	}
	
	def static String getNonFrancaMixinPrefix(EClass clazz) {
		nonFrancaMixinRootPrefix.get(clazz)
	}
	
	def static Iterable<EClass> getMixinClasses(EClass rootClass) {
		Iterables.concat(mixinChildren.get(rootClass), newArrayList(rootClass)) 
	}

	def static boolean isNonFrancaMixinHost(EClass clazz) {
		isNonFrancaMixin.contains(clazz)
	}

	def static Map<IFDeployExtension.TypeDef, IFDeployExtension> getTypes() {
		val result = newHashMap
		for(ext : getExtensions()) {
			for(type : ext.types) {
				result.put(type, ext)
			} 
		}
		result
	}

	def static IFDeployExtension.TypeDef findType(String typeName) {
		val types = getExtensions().map[types].flatten//.filter[tag!==null]
		types.findFirst[name==typeName]
	}

}
