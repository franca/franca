package org.franca.core.ui.addons.contractviewer;

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

	private IPartListener partListener;
	private IResourceChangeListener resourceChangeListener;
	
	public Activator() {
		partListener = new FrancaEditorPartListener();
		resourceChangeListener = new ResourceChangeListener();
	}
	
	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);

		IWorkbenchPage activePage = getActivePage();
		if (activePage != null) {
			activePage.addPartListener(partListener);
		}
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceChangeListener, IResourceChangeEvent.POST_BUILD);
	}

	@Override
	public void stop(BundleContext context) throws Exception {
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
}
