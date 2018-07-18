/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl.ui.quickfix

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.franca.core.franca.FInterface
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDValue
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory

abstract class AbstractDefaultValueProvider implements IDefaultValueProvider {

	/**
	 * Helper to get index of FDElement in descendants of given FDRootElement.</p>
	 */	
	def protected int indexOf(FDRootElement root, FDElement elem) {
		val all = EcoreUtil2.eAllOfType(root, FDElement)
		all.indexOf(elem)
	}
	
	/**
	 * Helper to get index of FDElement in descendants of given FDRootElement,
	 * restricted to FDElements of a specific EClass.</p>
	 */	
	def protected int indexOf(FDRootElement root, FDElement elem, EClass clazz) {
		val all = EcoreUtil2.eAllOfType(root, FDElement).filter[clazz.isInstance(it)].toList
		all.indexOf(elem)
	}
	
	/**
	 * Helper method which creates a value of type boolean.</p>
	 */
	def protected FDValue createBooleanValue(boolean v) {
		FDeployFactory.eINSTANCE.createFDBoolean => [ value = if (v) "true" else "false" ]
	}

	/**
	 * Helper method which creates a value of type integer.</p>
	 */
	def protected FDValue createIntegerValue(int v) {
		FDeployFactory.eINSTANCE.createFDInteger => [ value = v; it.formattedValue = null ]
	}

	/**
	 * Helper method which creates a value of type integer.</p>
	 * 
	 * @param v the actual integer value
	 * @param formatted the value as formatted string (e.g., as hex format)
	 */
	def protected FDValue createIntegerValue(int v, String formatted) {
		FDeployFactory.eINSTANCE.createFDInteger => [ value = v; it.formattedValue = formatted ]
	}

	/**
	 * Helper method which creates a value of type String.</p>
	 */
	def protected FDValue createStringValue(String v) {
		FDeployFactory.eINSTANCE.createFDString => [ value = v ]
	}
	
	/**
	 * Helper method which creates a value of type InterfaceRef.</p>
	 */
	def protected FDValue createInterfaceRefValue(FInterface v) {
		FDeployFactory.eINSTANCE.createFDInterfaceRef => [ value = v ]
	}
	
	/**
	 * Helper method which creates a value of type EObject.</p>
	 */
	def protected FDValue createEObjectValue(EObject v) {
		FDeployFactory.eINSTANCE.createFDGeneric => [ value = v ]
	}

	
	/**
	 * Helper method which wraps a value as complex value</p>
	 * 
	 * @param value which has to be wrapped
	 * @return complex value which just contains the single input value
	 */
	def protected FDComplexValue createSingle(FDValue item) {
		val ret = FDeployFactory.eINSTANCE.createFDComplexValue
		ret.single = item
		ret
	}
	
	/**
	 * Helper method which creates a grouped value from a set of items.</p>
	 * 
	 * @param items one or more values which will be members of the grouip
	 * @return complex value which is actually a group of values
	 */
	def protected FDComplexValue createGroup(FDValue... items) {
		val ret = FDeployFactory.eINSTANCE.createFDComplexValue
		val arrayVal = FDeployFactory.eINSTANCE.createFDValueArray
		for(item : items) {
			arrayVal.values.add(item)
		}
		ret.array = arrayVal	
		ret		
	}
	
}
