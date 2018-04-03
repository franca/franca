/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.ext.providers

import java.util.List
import org.eclipse.xtext.EcoreUtil2
import org.franca.core.franca.FInterface
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDValue
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory

class ProviderUtils {
	/**
	 * Get a list of all Franca IDL interfaces referenced by a Franca deployment model.</p>
	 * 
	 * @return the list of FDInterfaces
	 */
	def static List<FDExtensionRoot> getProviders(FDModel model) {
		model.deployments.filter(FDExtensionRoot).filter[tag==ProviderExtension.PROVIDER_TAG].toList
	}

	/**
	 * Get all instance elements for a given "provider" root element.</p>
	 */
	def static List<FDExtensionElement> getInstances(FDExtensionRoot provider) {
		provider.elements.filter[tag==ProviderExtension.INSTANCE_TAG].toList
	}
	
	/**
	 * Get target Franca interface for a given instance element.</p>
	 */
	def static FInterface getTargetInterface(FDExtensionElement instance) {
		val target = instance.target
		if (target instanceof FInterface)
			target
		else
			null
	}
	
	/**
	 * Try to provide a proper default value for interface instance properties.</p>
	 */
	def static FDValue getDefaultInstanceValue(FDElement element) {
		// for properties of type "Instance" there is no proper default
		// instead, we use some heuristics
		val root = EcoreUtil2.getContainerOfType(element, FDExtensionRoot)
		if (root!==null) {
			// this is a provider definition, use first instance definition (if any)
			val first = root.instances.head
			if (first!==null) {
				FDeployFactory.eINSTANCE.createFDGeneric => [ value = first ]
			} else {
				// there is no first instance
				null
			}
		} else {
			// for all other deployment definitions, we cannot determine an instance
			null
		}
	}
}
