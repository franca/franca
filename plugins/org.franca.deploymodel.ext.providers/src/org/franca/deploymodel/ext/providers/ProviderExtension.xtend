/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.ext.providers

import org.franca.deploymodel.extensions.IFDeployExtension
import java.util.Collection
import org.franca.core.franca.FrancaPackage

import static org.franca.deploymodel.extensions.IFDeployExtension.AbstractElementDef.Nameable.*

class ProviderExtension implements IFDeployExtension {
	
	val host1 = new Host("host1")
	val host2 = new Host("host2")
	val host3 = new Host("host3")
	val host23 = new Host("host23")
	
	override getShortDescription() {
		"providers and instances"
	}

	override Collection<RootDef> getRoots() {
		val root1 = new RootDef(this, "providerX", MANDATORY_NAME, #[ host1 ]) => [
			addChild(new ElementDef("instanceX", FrancaPackage.eINSTANCE.FInterface, NO_NAME, #[ host2, host23 ]) => [
				addChild(new ElementDef("level2", NO_NAME, #[ host23 ]))
			])
			addChild(new ElementDef("instanceY", OPTIONAL_NAME, #[ host3, host23 ]))
		]
		#[ root1 ]
	}

}
