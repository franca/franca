/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.core.FDPropertyHost

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
	 * Get the argument type name for the property accessor method for a given deployment host.
	 */
	def static String getFrancaTypeName(FDPropertyHost host, boolean forInterfaces) {
		host.getFrancaType(forInterfaces)?.simpleName
	}
	
	/**
	 * Get the argument type for the property accessor method for a given deployment host.
	 */
	def static Class<? extends EObject> getFrancaType(FDPropertyHost host, boolean forInterfaces) {
		val builtIn = host.builtIn
		if (builtIn!==null) {
			// this is a built-in host, decide using a hard-coded mapping table 
			switch (builtIn) {
				case PROVIDERS:        null  // ignore
				case INSTANCES:        null  // ignore
				case TYPE_COLLECTIONS: typeof(FTypeCollection)
				case INTERFACES:       forInterfaces.use(typeof(FInterface))
				case ATTRIBUTES:       forInterfaces.use(typeof(FAttribute))
				case METHODS:          forInterfaces.use(typeof(FMethod))
				case BROADCASTS:       forInterfaces.use(typeof(FBroadcast))
				case ARGUMENTS:        forInterfaces.use(typeof(FArgument))
				case STRUCTS:          typeof(FStructType)
				case UNIONS:     	   typeof(FUnionType)
				case STRUCT_FIELDS:    typeof(FField)
				case UNION_FIELDS:     typeof(FField)
				case FIELDS:           typeof(FField)
				case ENUMERATIONS:     typeof(FEnumerationType)
				case ENUMERATORS:      typeof(FEnumerator)
				case TYPEDEFS:         typeof(FTypeDef)
				//case NUMBERS:        // generic handling
				//case FLOATS:         // generic handling
				//case INTEGERS:       // generic handling
				//case STRINGS:        // generic handling
				//case ARRAYS:         // generic handling
				default:               typeof(EObject)  // reasonable default
			}
		} else {
			// this is an extension host, it's argument type will be it cannot refer to a Franca metamodel object
			// but it has to be some EObject nevertheless
			val hostDef = host.name.findHost
			if (hostDef!==null) {
				// get classes (aka grammar rules) which host properties of this hostDef 
				val classes = getHostingClasses(hostDef)
			
				// get the property-accessor argument types for each of these classes
				val targetClasses = classes.map[getAccessorArgumentType]

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
	}

	def static isInterfaceOnly(FDPropertyHost host) {
		host.getFrancaType(false)===null
	}

	/**
	 * Helper function which simplifies the implementation of getFrancaType.
	 */
	def static private use(boolean forInterfaces, Class<? extends EObject> type) {
		if (forInterfaces)
			type
		else
			null
	}


	// TODO: adapt this when extracting PROVIDERS/INSTANCES into a deployment extension
	def static String getFrancaTypeProvider(FDPropertyHost host) {
		val builtIn = host.builtIn
		if (builtIn===null) {
			// this is an extension host, it cannot refer to a Franca metamodel object
			return null
		}
			
		switch (builtIn) {
			case PROVIDERS:  "FDProvider"
			case INSTANCES:  "FDInterfaceInstance"
			default:         null // ignore all other hosts
		}
	}

	def static isProviderHost(FDPropertyHost host) {
		host.getFrancaTypeProvider!==null
	}

}