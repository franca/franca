/*******************************************************************************
 * Copyright (c) 2017 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.ui.quickfix

import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDExtensionType
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDValue
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory
import org.franca.deploymodel.extensions.ExtensionRegistry

import static org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId.*

import static extension org.franca.deploymodel.core.FDModelUtils.*

class DefaultValueProvider {
	
	/**
	 * Provide a default value for each of the property types in a deployment model.<p/>
	 * 
	 * Note that some types will not have a generic default value, we try to compute
	 * a proper default value depending on the context. If this is not possible, null is returned.
	 */
	def static FDComplexValue generateDefaultValue(FDElement element, FDTypeRef typeRef) {
		var FDValue simple = null
		if (typeRef.complex === null) {
			switch (typeRef.predefined.value) {
				case BOOLEAN_VALUE:
					simple = FDeployFactory.eINSTANCE.createFDBoolean => [ value = "false" ]
				case INTEGER_VALUE:
					simple = FDeployFactory.eINSTANCE.createFDInteger => [ value = 0 ]
				case STRING_VALUE:
					simple = FDeployFactory.eINSTANCE.createFDString => [ value = "" ]
				case INTERFACE_VALUE: {
					// for properties of type "Interface" there is no proper default
					// instead, we use some heuristics
					val root = element.rootElement
					switch (root) {
						FDTypes: {
							// a definition for a TypeCollection doesn't have an interface, no default
						}
						FDInterface: {
							// use the interface for this deployment definition as default 
							simple = FDeployFactory.eINSTANCE.createFDInterfaceRef => [ value = root.target ]
						}
						FDProvider: {
							// try to find first instance in the provider definition, use its target interface
							val someInterface = root.firstInstance?.target
							simple = FDeployFactory.eINSTANCE.createFDInterfaceRef => [ value = someInterface ]
						}
					}
				}
				case INSTANCE_VALUE: {
					// for properties of type "Instance" there is no proper default
					// instead, we use some heuristics
					val root = element.rootElement
					if (root instanceof FDProvider) {
						// this is a provider definition, use first instance definition (if any)
						val first = root.firstInstance
						if (first!=null) {
							simple = FDeployFactory.eINSTANCE.createFDGeneric => [ value = first ]
						} else {
							// there is no first instance
						}
					} else {
						// for all other deployment definitions, we cannot determine an instance
					}
				}
				default: {
					System.err.println("ERROR in DefaultValueProvider: Invalid property type (is " + typeRef.predefined.value + ")!")
				}
			}
		} else {
			val complex = typeRef.complex
			if (complex instanceof FDEnumType) {
				simple = FDeployFactory.eINSTANCE.createFDGeneric => [
					value = complex.enumerators.get(0)
				]
			} else if (complex instanceof FDExtensionType) {
				val typeDef = ExtensionRegistry.findType(complex.name)
				simple = typeDef.createDefaultValue(element)
			}
		}

		if (simple!==null) {
			val ret = FDeployFactory.eINSTANCE.createFDComplexValue
			if (typeRef.array === null) {
				ret.single = simple
			} else {
				// this is an array-property (aka group), at least one element required
				val arrayVal = FDeployFactory.eINSTANCE.createFDValueArray
				arrayVal.values.add(simple)
				ret.array = arrayVal	
			}
			ret
		} else {
			null
		}
	}

	def private static FDInterfaceInstance getFirstInstance(FDProvider providerDef) {
		if (providerDef.instances.empty)
			null
		else
			providerDef.instances.get(0)
	}
}
