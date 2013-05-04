/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons;

import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.ui.IPartListener;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.franca.core.ui.addons.contractviewer.util.FrancaEditorPartListener;
import org.franca.core.ui.addons.contractviewer.util.ResourceChangeListener;
import org.osgi.framework.BundleContext;

public class Activator extends AbstractUIPlugin {

	public static final String PLUGIN_ID = "org.franca.core.ui.addons";
	private IPartListener partListener;
	private IResourceChangeListener resourceChangeListener;
	private static Activator plugin;
	
	public Activator() {
		partListener = new FrancaEditorPartListener();
		resourceChangeListener = new ResourceChangeListener();
	}
	
	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;

		IWorkbenchPage activePage = getActivePage();
		if (activePage != null) {
			activePage.addPartListener(partListener);
		}
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceChangeListener, IResourceChangeEvent.POST_BUILD);
	}

	@Override
	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);

		IWorkbenchPage activePage = getActivePage();
		if (activePage != null) {
			activePage.removePartListener(partListener);
		}
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(resourceChangeListener);
	}

	private IWorkbenchPage getActivePage() {
		if (PlatformUI.getWorkbench().getActiveWorkbenchWindow() != null) {
			IWorkbenchPage activePage = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
			if (activePage != null) {
				return activePage;
			}
		}
		return null;
	}
	
	public static Activator getDefault() {
		return plugin;
	}
}
