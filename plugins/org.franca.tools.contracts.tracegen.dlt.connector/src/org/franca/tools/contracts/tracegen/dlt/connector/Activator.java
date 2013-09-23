package org.franca.tools.contracts.tracegen.dlt.connector;

import org.franca.tools.contracts.tracegen.dlt.connector.server.TraceValidatorServer;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

public class Activator implements BundleActivator {

	private static BundleContext context;
	
	static BundleContext getContext() {
		return context;
	}

	public void start(BundleContext bundleContext) throws Exception {
		Activator.context = bundleContext;
		TraceElementProcessor.INSTANCE.start();
		TraceValidatorServer.INSTANCE.start();
	}

	public void stop(BundleContext bundleContext) throws Exception {		
		Activator.context = null;
		TraceValidatorServer.INSTANCE.interruptThread();
		TraceElementProcessor.INSTANCE.interruptThread();
	}
}

