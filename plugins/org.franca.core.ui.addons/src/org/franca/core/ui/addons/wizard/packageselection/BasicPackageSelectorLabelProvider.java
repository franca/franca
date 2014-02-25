/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard.packageselection;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.ILabelProviderListener;
import org.eclipse.swt.graphics.Image;
import org.franca.core.ui.addons.Activator;
import org.franca.core.ui.addons.wizard.FrancaWizardUtil;

public class BasicPackageSelectorLabelProvider implements ILabelProvider {

	@Override
	public void addListener(ILabelProviderListener listener) {

	}

	@Override
	public void dispose() {

	}

	@Override
	public boolean isLabelProperty(Object element, String property) {
		return false;
	}

	@Override
	public void removeListener(ILabelProviderListener listener) {

	}

	@Override
	public Image getImage(Object element) {
		if (element instanceof IContainer && (hasFileContent((IContainer) element))) {
			return Activator.getDefault().getImageRegistry().get("package");
		}
		else {
			return Activator.getDefault().getImageRegistry().get("package_empty");
		}
	}

	@Override
	public String getText(Object element) {
		if (element instanceof IContainer) {
			if (((IContainer) element).getParent() instanceof IProject) {
				return "(default package)";
			}
			else {
				return FrancaWizardUtil.getPackageName((IContainer) element);
			}
		}
		return null;
	}

	private boolean hasFileContent(IContainer container) {
		try {
			for (IResource resource : container.members()) {
				if (resource.isAccessible() && resource instanceof IFile) {
					return true;
				}
			}
			return false;
		}
		catch (CoreException e) {
			return false;
		}
	}

}
