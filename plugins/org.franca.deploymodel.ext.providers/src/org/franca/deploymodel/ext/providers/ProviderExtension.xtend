/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.ext.providers

import java.util.Collection
import org.franca.deploymodel.extensions.AbstractFDeployExtension

import static org.franca.deploymodel.extensions.IFDeployExtension.AbstractElementDef.Nameable.*

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

	val providers = new Host("providersX")
	val instances = new Host("instancesX")
	
	override Collection<RootDef> getRoots() {
		val root1 =
			new RootDef(this, "providerX", MANDATORY_NAME, #[ providers ]) => [
				addChild(new ElementDef("instanceX", fidl.FInterface, OPTIONAL_NAME, #[ instances ]))
			]

		#[ root1 ]
	}
}
