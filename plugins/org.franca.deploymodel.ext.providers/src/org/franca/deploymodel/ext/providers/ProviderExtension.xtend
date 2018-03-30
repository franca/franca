/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.ext.providers

import java.util.Collection
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.franca.deploymodel.dsl.fDeploy.FDExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDValue
import org.franca.deploymodel.extensions.AbstractFDeployExtension

import static org.franca.deploymodel.extensions.IFDeployExtension.AbstractElementDef.Nameable.*

import static extension org.franca.deploymodel.ext.providers.ProviderUtils.*

/**
 * Implementation of provider/instance deployment extension.</p>
 * 
 * This class registers new deployment hosts and generic deployment definition elements.
 * It also implies some logic for glueing the hosts and the new elements.</p>
 * 
 * It will be registered at the IDE via a normal Eclipse extension point.</p>
 * 
 * @author Klaus Birken (itemis AG) 
 */
class ProviderExtension extends AbstractFDeployExtension {
	
	override getShortDescription() {
		"providers and instances"
	}

	val public static PROVIDER_TAG = "provider"
	val public static INSTANCE_TAG = "instance"
	
	val providers = new Host("providers")
	val instances = new Host("instances")
	
	override Collection<RootDef> getRoots() {
		val root1 =
			new RootDef(this, PROVIDER_TAG, MANDATORY_NAME, #[ providers ]) => [
				addChild(new ElementDef(INSTANCE_TAG, fidl.FInterface, OPTIONAL_NAME, #[ instances ]))
			]

		#[ root1 ]
	}

	override Collection<TypeDef> getTypes() {
		#[
			// the new deployment property type "Instance" can be used to refer to "instance"
			// elements in deployment definitions 
			new TypeDef("Instance",
				[ all | new FilteringScope(all, [isInstanceReference]) ],
				[ element | element.getDefaultInstanceValue ],
				FDExtensionElement
			)
		]
	}
	
	def private boolean isInstanceReference(IEObjectDescription obj) {
		EcoreUtil2.isAssignableFrom(fdeploy.FDExtensionElement, obj.EClass)
	}
}
