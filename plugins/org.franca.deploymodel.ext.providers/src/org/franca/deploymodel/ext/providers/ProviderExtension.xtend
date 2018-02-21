package org.franca.deploymodel.ext.providers

import org.franca.deploymodel.extensions.IFDeployExtension
import java.util.Collection

class ProviderExtension implements IFDeployExtension {
	
	val host1 = new Host("host1")
	val host2 = new Host("host2")
	
	override getShortDescription() {
		"providers and instances"
	}

	override getHosts() {
		#[ host1, host2 ]
	}

	override Collection<Root> getRoots() {
		#[
			new Root("providerX", #[ host1 ])
		]
	}

}
