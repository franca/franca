package org.franca.tools.contracts.tracegen.dlt.connector;

import org.franca.tools.contracts.tracegen.dlt.connector.server.TraceValidatorServer;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

public class Activator implements BundleActivator {

	private static BundleContext context;
	private TraceValidatorServer server;
	
	static BundleContext getContext() {
		return context;
	}

	public void start(BundleContext bundleContext) throws Exception {
		Activator.context = bundleContext;
		this.server = new TraceValidatorServer();
	}

	public void stop(BundleContext bundleContext) throws Exception {		
		Activator.context = null;
		this.server.interruptServer();
	}
}

