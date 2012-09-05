/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.core

import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.FDModelHelper
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.core.GenericPropertyAccessor
import org.franca.deploymodel.dsl.fDeploy.FDInteger
import org.franca.deploymodel.dsl.fDeploy.FDBoolean
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDEnum
import org.franca.deploymodel.dsl.fDeploy.FDString

/**
 * Helper functions to build deploy models.
 * 
 * This will be moved to org.franca.deploymodel in future.
 */
class DeployModelBuilder {
	
	/**
	 * Set an integer deployment property for a given FDElement.
	 * If the property is declared with a default value and the value
	 * which is to be set is exactly the default value, the property will not
	 * be set.
	 * 
	 * @param elem      the FDElement where the property should be set
	 * @param spec      the deployment specification where the property is declared
	 * @param property  the name of the property which should be set
	 * @param value     the actual value to be set
	 */
	def static setProperty (FDElement elem, FDSpecification spec, String property, int value) {
		var decl = getPropertyDecl(elem, spec, property)
		
		// check if value is equal to default value
		var dflt = GenericPropertyAccessor::getDefault(decl)
		if (dflt==null || (dflt.single as FDInteger) != value) {
			var prop = createProperty(elem, decl)
	
			var fdInteger = FDeployFactory::eINSTANCE.createFDInteger
			fdInteger.value = value
			 
			prop.value = FDeployFactory::eINSTANCE.createFDComplexValue 
			prop.value.single = fdInteger
		}
	}

	/**
	 * Set a long integer deployment property for a given FDElement.
	 * If the property is declared with a default value and the value
	 * which is to be set is exactly the default value, the property will not
	 * be set.
	 * 
	 * @param elem      the FDElement where the property should be set
	 * @param spec      the deployment specification where the property is declared
	 * @param property  the name of the property which should be set
	 * @param value     the actual value to be set
	 */
	def static setProperty (FDElement elem, FDSpecification spec, String property, long value) {
		setProperty(elem, spec, property, value as int)
	}
	
	/**
	 * Set a boolean deployment property for a given FDElement.
	 * If the property is declared with a default value and the value
	 * which is to be set is exactly the default value, the property will not
	 * be set.
	 * 
	 * @param elem      the FDElement where the property should be set
	 * @param spec      the deployment specification where the property is declared
	 * @param property  the name of the property which should be set
	 * @param value     the actual value to be set
	 */
	def static setProperty (FDElement elem, FDSpecification spec, String property, boolean value) {
		var decl = getPropertyDecl(elem, spec, property)
		
		// check if value is equal to default value
		var dflt = GenericPropertyAccessor::getDefault(decl)
		if (dflt==null || (dflt.single as FDBoolean) != value) {
			var prop = createProperty(elem, decl)
	
			var fdBoolean = FDeployFactory::eINSTANCE.createFDBoolean
			fdBoolean.value = Boolean::toString(value)
			 
			prop.value = FDeployFactory::eINSTANCE.createFDComplexValue 
			prop.value.single = fdBoolean
		}
	}
	
	/**
	 * Set an enum or string deployment property for a given FDElement.
	 * If the property is declared with a String type, the value will
	 * be set as a raw string. If the property is declared with an 
	 * Enumeration type, the value will be interpreted as an enumerator.
	 * In the latter case, the value should be defined as enumerator in
	 * the property's declaration.
	 * In both cases, if the property is declared with a default value
	 * and the value which is to be set is exactly the default value,
	 * the property will not be set.
	 * 
	 * @param elem      the FDElement where the property should be set
	 * @param spec      the deployment specification where the property is declared
	 * @param property  the name of the property which should be set
	 * @param value     the actual value to be set
	 */
	def static setProperty (FDElement elem, FDSpecification spec, String property, String value) {
		var decl = getPropertyDecl(elem, spec, property)
		
		// detect if type is an enum or string
		if (decl.type.complex==null) {
			// we assume this is a string property
			// check if value is equal to default value
			var dflt = GenericPropertyAccessor::getDefault(decl)
			if (dflt==null || (dflt.single as FDString) != value) {
				var prop = createProperty(elem, decl)
		
				var fdString = FDeployFactory::eINSTANCE.createFDString
				fdString.value = value
				 
				prop.value = FDeployFactory::eINSTANCE.createFDComplexValue 
				prop.value.single = fdString
			}
		} else {
			// we assume this is an enumeration property
			val enumtype = decl.type.complex as FDEnumType
			val evalue = enumtype.enumerators.findFirst(e | e.name == value)
			
			if (evalue!=null) {
				// check if value is equal to default value
				var dflt = GenericPropertyAccessor::getDefault(decl)
				if (dflt==null || ((dflt.single as FDEnum).value != evalue)) {
					var prop = createProperty(elem, decl)
			
					var fdEnum = FDeployFactory::eINSTANCE.createFDEnum
					fdEnum.value = evalue
					 
					prop.value = FDeployFactory::eINSTANCE.createFDComplexValue 
					prop.value.single = fdEnum
				}
			}
			
		}
		
	}
	
	// -------------------------------------------------------------------------
	// utilities

	/** Find property declaration for element by property name. */	
	def static getPropertyDecl (FDElement elem, FDSpecification spec, String property) {
		var propertyDecls = FDModelHelper::getAllPropertyDecls(spec, elem)
		
		// find property declaration
		val pdecl = propertyDecls.findFirst(d | d.name == property)
		if (pdecl==null)
			throw new Exception("DeployModelBuilder: No property '" + property +
				"' in specification '"  + spec.name + "' for element " + elem.toString)

		return pdecl
	}
	
	/** Create property object for element. */
	def static createProperty (FDElement element, FDPropertyDecl decl) {
		var prop = FDeployFactory::eINSTANCE.createFDProperty
		prop.decl = decl
		element.properties.add(prop)
		return prop
	}
}

