package org.franca.deploymodel.dsl.scoping;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.common.util.URI;

/** Util class providing convenience regarding the <code>deploySpecProvider</code> Extension Point. */
public class DeploySpecProvider {

	public static final String DEPLOY_SPEC_PROVIDER_EXTENSION = "org.franca.deploymodel.dsl.deploySpecProvider";
	public static final String DEPLOY_SPEC_PROVIDER_RESOURCE_ATTRIB = "resource";

	public List<URI> getURIs() {
		List<URI> result = new ArrayList<URI>();
		IConfigurationElement[] extensions = Platform.getExtensionRegistry().getConfigurationElementsFor(DEPLOY_SPEC_PROVIDER_EXTENSION);
		for (IConfigurationElement e : extensions) {
			String res = e.getAttribute(DEPLOY_SPEC_PROVIDER_RESOURCE_ATTRIB);
			String pluginName = e.getContributor().getName();
			result.add(URI.createPlatformPluginURI(pluginName + "/" + res, true));
		}
		return result;
	}
}
