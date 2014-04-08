/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons;

import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.resource.ImageRegistry;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;

public class Activator extends AbstractUIPlugin {

	public static final String PLUGIN_ID = "org.franca.core.ui.addons";
	private static Activator plugin;
	
	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
	}

	@Override
	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
	}
	
	public static Activator getDefault() {
		return plugin;
	}
	
	@Override
	protected void initializeImageRegistry(ImageRegistry reg) {
		super.initializeImageRegistry(reg);
        @SuppressWarnings("unused")
        Bundle bundle = Platform.getBundle(PLUGIN_ID);
        reg.put("package", imageDescriptorFromPlugin(PLUGIN_ID, "icons/package.gif"));
        reg.put("package_empty", imageDescriptorFromPlugin(PLUGIN_ID, "icons/package_empty.gif"));
	}
}
