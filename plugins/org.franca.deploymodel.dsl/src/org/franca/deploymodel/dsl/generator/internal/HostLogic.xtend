/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost

class HostLogic {
	
	def static String getFrancaType(FDPropertyHost host, boolean forInterfaces) {
		switch (host) {
			case PROVIDERS:        null  // ignore
			case INSTANCES:        null  // ignore
			case TYPE_COLLECTIONS: "FTypeCollection"
			case INTERFACES:       forInterfaces.use("FInterface")
			case ATTRIBUTES:       forInterfaces.use("FAttribute")
			case METHODS:          forInterfaces.use("FMethod")
			case BROADCASTS:       forInterfaces.use("FBroadcast")
			case ARGUMENTS:        forInterfaces.use("FArgument")
			case STRUCTS:    		"FStructType"
			case UNIONS:     		"FUnionType"
			case STRUCT_FIELDS:    "FField"
			case UNION_FIELDS:     "FField"
			case ENUMERATIONS:     "FEnumerationType"
			case ENUMERATORS:      "FEnumerator"
			case TYPEDEFS:         "FTypeDef"
			//case NUMBERS:        // generic handling
			//case FLOATS:         // generic handling
			//case INTEGERS:       // generic handling
			//case STRINGS:        // generic handling
			//case ARRAYS:         // generic handling
			default:               "EObject"  // reasonable default
		}
	}
	
	def static isInterfaceOnly(FDPropertyHost host) {
		host.getFrancaType(false)==null
	}

	def static private use(boolean forInterfaces, String type) {
		if (forInterfaces)
			type
		else
			null
	}


	def static String getFrancaTypeProvider(FDPropertyHost host) {
		switch (host) {
			case PROVIDERS:  "FDProvider"
			case INSTANCES:  "FDInterfaceInstance"
			default:         null // ignore all other hosts
		}
	}

	def static isProviderHost(FDPropertyHost host) {
		host.getFrancaTypeProvider!=null
	}

}