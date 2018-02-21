package org.franca.deploymodel.ext.providers

import org.franca.deploymodel.extensions.IFDeployExtension
import java.util.Collection

class ProviderExtension implements IFDeployExtension {
	
	override getShortDescription() {
		"providers and instances"
	}

	override getHosts() {
		#[ 'host1', 'host2' ]
	}

	override Collection<Root> getRoots() {
		#[
			new Root("providerX", #[ "host1" ])
		]
	}

}
