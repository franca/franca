package org.franca.connectors.etrice.ui;

import org.apache.log4j.Logger;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.util.Modules2;
import org.franca.connectors.etrice.ROOMConnectorModule;
import org.franca.core.dsl.FrancaIDLRuntimeModule;
import org.osgi.framework.BundleContext;

import com.google.inject.Guice;
import com.google.inject.Injector;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = "org.franca.connectors.etrice.ui"; //$NON-NLS-1$

	// The shared instance
	private static Activator plugin;

	// The injector (used by the ExecutableExtensionFactory)
	private Injector injector;
	
	/**
	 * The constructor
	 */
	public Activator() {
	}

	/*
	 * (non-Javadoc)
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext)
	 */
	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
		
		// create injector
        try {
            injector = Guice.createInjector(Modules2.mixin(new FrancaIDLRuntimeModule(), new ROOMConnectorModule()));
        } catch (Exception e) {
                Logger.getLogger(getClass()).error(e.getMessage(), e);
                throw e;
        }
	}

	/*
	 * (non-Javadoc)
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext)
	 */
	public void stop(BundleContext context) throws Exception {
		plugin = null;
        injector = null;
		super.stop(context);
	}

    public Injector getInjector() {
        return injector;
    }

	/**
	 * Returns the shared instance
	 *
	 * @return the shared instance
	 */
	public static Activator getDefault() {
		return plugin;
	}

}
