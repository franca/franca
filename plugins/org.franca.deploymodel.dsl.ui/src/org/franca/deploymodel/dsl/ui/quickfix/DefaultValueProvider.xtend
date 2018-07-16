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
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDValue
import org.franca.deploymodel.extensions.ExtensionRegistry

import static org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId.*

class DefaultValueProvider extends AbstractDefaultValueProvider {
	
	/**
	 * Provide a default value for each of the property types in a deployment model.<p/>
	 * 
	 * Note that some types will not have a generic default value, we try to compute
	 * a proper default value depending on the context. If this is not possible, null is returned.
	 */
	override FDComplexValue generateDefaultValue(
		FDRootElement root,
		FDElement element,
		FDProperty property,
		FDTypeRef typeRef
	) {
		var FDValue simple = null
		if (typeRef.complex === null) {
			switch (typeRef.predefined.value) {
				case BOOLEAN_VALUE:
					simple = createBooleanValue(false)
				case INTEGER_VALUE:
					simple = createIntegerValue(0)
				case STRING_VALUE:
					simple = createStringValue("")
				case INTERFACE_VALUE: {
					// for properties of type "Interface" there is no proper default
					// instead, we use some heuristics
					switch (root) {
						FDTypes: {
							// a definition for a TypeCollection doesn't have an interface, no default
						}
						FDInterface: {
							// use the interface for this deployment definition as default 
							simple = createInterfaceRefValue(root.target)
						}
					}
				}
				default: {
					System.err.println("ERROR in DefaultValueProvider: Invalid property type (is " + typeRef.predefined.value + ")!")
				}
			}
		} else {
			val complex = typeRef.complex
			if (complex instanceof FDEnumType) {
				simple = createEObjectValue(complex.enumerators.get(0))
			} else if (complex instanceof FDExtensionType) {
				val typeDef = ExtensionRegistry.findType(complex.name)
				simple = typeDef.createDefaultValue(element)
			}
		}

		// prepare return value
		if (simple === null) {
			// no value could be computed, just return null
			null
		} else {
			if (typeRef.array === null) {
				createSingle(simple)
			} else {
				// this is an array-property (aka group), at least one element required
				createGroup(simple)
			}
		}
	}
}
