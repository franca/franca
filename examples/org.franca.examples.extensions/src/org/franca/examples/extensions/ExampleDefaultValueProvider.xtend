/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.examples.extensions

import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDMethod
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDStruct
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.franca.deploymodel.dsl.ui.quickfix.AbstractDefaultValueProvider

import static org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId.*

/**
 * This is an example default value provider (extension point).</p>
 * 
 * In order to test its functionality, open example project org.franca.examples.deploy, 
 * look for deployment definition file models/org/example/deploy/QuickfixDeploy.fdepl
 * and check out the inline documentation there.</p> 
 */
class ExampleDefaultValueProvider extends AbstractDefaultValueProvider {
	
	override generateDefaultValue(
		FDRootElement root,
		FDElement element,
		FDProperty property,
		FDTypeRef typeRef
	) {
		// check for property name and type
		if (property.decl.name=="MethodProp" && typeRef.predefined.value==INTEGER_VALUE) {
			// we assume that "MethodProp" is always applied for FMethod deployment inside an FInterface
			if (root instanceof FDInterface) {
				if (element instanceof FDMethod) {
					// retrieve index of method in target Franca interface
					// NB: using root.indexOf() would number the elements according to the order
					//     in the deployment definition. We want to number them according to the order
					//     of the methods in the Franca interface specification.
					val index = root.target.methods.indexOf(element.target)

					// create new default value with new number, depending on index (use offset of 0x101)
					val i = index + 0x101
					
					// use helper function with second argument in order to enforce a special format (here: hexadecimal)
					val v = createIntegerValue(i, "0x" + Integer.toHexString(i))
					
					// wrap as single value
					return createSingle(v)
				}
			}
		} else if (property.decl.name=="StructProp" && typeRef.predefined.value==STRING_VALUE) {
			if (element instanceof FDStruct) {
				// retrieve index of element in list of descendants of deployment definition root 
				val index = root.indexOf(element, FDeployPackage.eINSTANCE.FDStruct)

				// build property default value as string
				val v = createStringValue(element.target.name + "_" + index)

				// wrap as single value
				return createSingle(v)
			}
		} else if (property.decl.name=="AttrProp" && typeRef.predefined.value==INTEGER_VALUE) {
			// build a group value consisting of two single values
			val v1 = createIntegerValue(47)
			val v2 = createIntegerValue(11, "0b1011") // format value as binary
			return createGroup(v1, v2)
		}

		// will not compute default value, return control and use fallback default value
		null
	}
	
}
