/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.core

import org.franca.deploymodel.dsl.fDeploy.FDBoolean
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDEnumerator
import org.franca.deploymodel.dsl.fDeploy.FDInteger
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDString
import org.franca.deploymodel.dsl.fDeploy.FDValue
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory

import static extension org.franca.deploymodel.core.FDModelUtils.*

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
		setSingleProperty(elem, spec, property,
			[dflt | (dflt as FDInteger).value != value],
			[ | createFDValue(value) ]
		)						
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
		setSingleProperty(elem, spec, property,
			[dflt | eval(dflt as FDBoolean) != value],
			[ | createFDValue(value) ]
		)						
	}

	def private static eval (FDBoolean it) {
		value=="true"
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
			setPropertyGeneric(decl, elem,
				[dflt | (dflt as FDString).value != value],
				[ | createFDValue(value) ]
			)						
		} else {
			// we assume this is an enumeration property
			val enumtype = decl.type.complex as FDEnumType
			val evalue = enumtype.enumerators.findFirst(e | e.name == value)
			if (evalue!=null) {
				setPropertyGeneric(decl, elem,
					[dflt | dflt.getEnumerator != evalue],
					[ | createFDValue(evalue) ]
				)						
			}
			
		}
		
	}
	
	
	// -------------------------------------------------------------------------
	// utilities

	/** Generic helper function. */
	def private static setSingleProperty (FDElement elem, FDSpecification spec, String property, 
		(FDValue) => boolean isNonDefault,
		() => FDValue getNewValue
	) {
		// get property decl
		var decl = getPropertyDecl(elem, spec, property)
		setPropertyGeneric(decl, elem, isNonDefault, getNewValue)
	}


	/** Find property declaration for element by property name. */	
	def static getPropertyDecl (FDElement elem, FDSpecification spec, String property) {
		var propertyDecls = PropertyMappings::getAllPropertyDecls(spec, elem)
		
		// find property declaration
		val pdecl = propertyDecls.findFirst(d | d.name == property)
		if (pdecl==null)
			throw new Exception("DeployModelBuilder: No property '" + property +
				"' in specification '"  + spec.name + "' for element " + elem.toString)

		return pdecl
	}


	def private static setPropertyGeneric (FDPropertyDecl decl, FDElement elem,
		(FDValue) => boolean isNonDefault,
		() => FDValue getNewValue
	) {
		//println("set property generic : " + decl.name)
		// check if property type is array
		if (decl.type.array!=null) {
			// array: just add another value
			// TODO: proper default handling (issue: comparison of arrays...)
			var prop = getProperty(elem, decl)
			if (prop.value.array==null) {
				// create on the fly
				prop.value.array = FDeployFactory::eINSTANCE.createFDValueArray
			}
			prop.value.array.values.add(getNewValue.apply())
		} else {
			// single value: check if value is equal to default value
			var dflt = GenericPropertyAccessor::getDefault(decl)
			if (dflt==null || isNonDefault.apply(dflt.single)) {
				var prop = getProperty(elem, decl)
				prop.value.single = getNewValue.apply()
			}
		}
	}
	

	/** Create property object for element. */
	def static getProperty (FDElement element, FDPropertyDecl decl) {
		var prop = element.properties.items.findFirst[p|p.decl==decl]
		if (prop==null) {
			// create on the fly
			prop = FDeployFactory::eINSTANCE.createFDProperty
			prop.decl = decl
			element.properties.items.add(prop)
		}
		
		if (prop.value==null) {
			// create on the fly
			prop.value = FDeployFactory::eINSTANCE.createFDComplexValue
		}
		
		return prop
	}


	// -------------------------------------------------------------------------
	// creation helpers
	
	def private static createFDValue (int value) {
		val v = FDeployFactory::eINSTANCE.createFDInteger
		v.value = value
		v
	}

	def private static createFDValue (boolean value) {
		val v = FDeployFactory::eINSTANCE.createFDBoolean
		v.value = Boolean::toString(value)
		v
	}

	def private static createFDValue (String value) {
		val v = FDeployFactory::eINSTANCE.createFDString
		v.value = value
		v
	}

	def private static createFDValue (FDEnumerator value) {
		val v = FDeployFactory::eINSTANCE.createFDGeneric
		v.value = value
		v
	}
}

