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

class ProviderExtension implements IFDeployExtension {
	
	val host1 = new Host("host1")
	val host2 = new Host("host2")
	val host3 = new Host("host3")
	val host23 = new Host("host23")
	
	override getShortDescription() {
		"providers and instances"
	}

	override Collection<Root> getRoots() {
		val root1 = new Root(this, "providerX", #[ host1 ]) => [
			addChild(new Element("instanceX", #[ host2, host23 ]) => [
				addChild(new Element("level2", #[ host23 ]))
			])
			addChild(new Element("instanceY", #[ host3, host23 ]))
		]
		#[ root1 ]
	}

}
