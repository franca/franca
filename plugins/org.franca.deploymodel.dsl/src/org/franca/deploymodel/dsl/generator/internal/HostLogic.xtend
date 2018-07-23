/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import java.util.Set
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.core.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.franca.deploymodel.extensions.IFDeployExtension

import static extension org.franca.deploymodel.extensions.ExtensionRegistry.*

/**
 * This class defines how deployment properties are mapped to Franca IDL objects
 * by the PropertyAccessor generator.<p/>
 * 
 * E.g., each property host implies a defined argument type for the property 
 * getter in the accessor. E.g., for the host 'arguments' the Franca type FArgument
 * is used.
 */
class HostLogic {
	
	/**
	 * The context for which an argument type for a given host should be computed.</p>
	 * 
	 * NB: FRANCA_INTERFACE logically includes FRANCA_TYPE, but not vice versa.
	 */
	public enum Context {
		/** hosts which can be applied to Franca IDL types, excluding interface-only hosts */
		FRANCA_TYPE,
		
		/** hosts which can be applied to Franca IDL interfaces, this includes types! */
		FRANCA_INTERFACE,
		
		/** everything outside of Franca IDL, i.e., deployment elements contributed by extensions */
		NON_FRANCA
	}
	
	val static Set<Class<? extends EObject>> interfaceSpecificClasses = #{ FInterface, FAttribute, FMethod, FBroadcast, FArgument }
	
	/**
	 * Get the argument type for the property accessor method for a given deployment host.
	 */
	def static Class<? extends EObject> getArgumentType(FDPropertyHost host, Context context) {
		val builtIn = host.builtIn
		val Class<? extends EObject> result =
			if (builtIn!==null) {
				// this is a built-in host, decide using a hard-coded mapping table 
				switch (builtIn) {
					case TYPE_COLLECTIONS: FTypeCollection
					case INTERFACES:       FInterface
					case ATTRIBUTES:       FAttribute
					case METHODS:          FMethod
					case BROADCASTS:       FBroadcast
					case ARGUMENTS:        FArgument
					case STRUCTS:          FStructType
					case UNIONS:     	   FUnionType
					case STRUCT_FIELDS:    FField
					case UNION_FIELDS:     FField
					case FIELDS:           FField
					case ENUMERATIONS:     FEnumerationType
					case ENUMERATORS:      FEnumerator
					case MAPS:             FMapType
					case MAP_KEYS:         FMapType
					case MAP_VALUES:       FMapType
					case TYPEDEFS:         FTypeDef
					//case NUMBERS:        // generic handling
					//case FLOATS:         // generic handling
					//case INTEGERS:       // generic handling
					//case STRINGS:        // generic handling
					//case ARRAYS:         // generic handling
					default:               EObject  // reasonable default
				}
			} else {
				// this is an extension host
				host.getArgumentTypeForExtensionHost(context)
			}
		
		if (result===null)
			null
		else {
			// filter non-interface results
			if ((context!==Context.FRANCA_INTERFACE) && interfaceSpecificClasses.contains(result)) {
				null
			} else {
				result
			}
		}
	}
	
	def static private Class<? extends EObject> getArgumentTypeForExtensionHost(FDPropertyHost host, Context context) {
		val hostDef = host.name.findHost
		if (hostDef!==null) {
			// get classes (aka grammar rules) which host properties of this hostDef 
			val classes = getHostingClasses(hostDef)
			
			// filter according to required context
			val filtered =
				if (context===Context.NON_FRANCA)
					classes.filter[isNonFrancaMixinHost || FDeployPackage.eINSTANCE.FDAbstractExtensionElement.isSuperTypeOf(it)]
				else
					classes.filter[!isNonFrancaMixinHost]
		
			if (filtered.empty) {
				// no classes hosting the properties in the given context, abort with null
				return null
			}
			
			// get the property-accessor argument types for each of these classes
			val targetClasses = filtered.map[getAccessorArgumentType]

			// if there are multiple argument types, we select a common super-class
			// see SuperclassFinder for details on this algorithm	
			if (! targetClasses.empty) {
				val sd = new SuperclassFinder
				val superclass = sd.findCommonSuperclass(targetClasses)
				if (superclass!==null) {
					val instClass = superclass.instanceClass
					if (EObject.isAssignableFrom(instClass))
						return instClass as Class<? extends EObject>
				}
			}
		}
		
		// catch-all (everything is an EObject)
		typeof(EObject)
	} 

	def static isInterfaceOnly(FDPropertyHost host) {
		host.getArgumentType(Context.FRANCA_TYPE)===null &&
		host.getArgumentType(Context.FRANCA_INTERFACE)!==null  
	}

	def static boolean isHostFor(FDPropertyHost host, IFDeployExtension.AbstractElementDef elementDef) {
		if (host.builtIn!==null) {
			// there are no RootDefs for built-in hosts
			false
		} else {
			// check if host is relevant for elementDef or one of its sub-elements 
			val hostDef = host.name.findHost
			elementDef.hasHostSubtree(hostDef)
		}
	}

	def static boolean isHostFor(FDPropertyHost host, EClass mixinRoot) {
		if (host.builtIn!==null) {
			// there are no RootDefs for built-in hosts
			false
		} else {
			// check if host is relevant for mixinRoot or one of its children
			val hostDef = host.name.findHost
			val classes = mixinRoot.mixinClasses
			val supportedHosts = classes.map[getAdditionalHosts].flatten.toSet
			supportedHosts.contains(hostDef)
		}
	}
}
