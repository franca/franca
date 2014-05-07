/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.ui.internal.ide.misc.ContainerSelectionGroup;

/**
 * A {@link ITreeContentProvider} implementation for the
 * {@link ContainerSelectionGroup} in the
 * {@link FrancaFileWizardContainerConfigurationPage}. JDT aware setting will
 * enable to control the depth of displayed folder levels inside the given
 * {@link IProject}.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
@SuppressWarnings("restriction")
public class ContainerContentProvider implements ITreeContentProvider {

	private IProject initialSelection;

	public void setInitialSeletion(IContainer initialSelection) {
		if (initialSelection instanceof IFolder) {
			this.initialSelection = initialSelection.getProject();
		}
		else if (initialSelection instanceof IProject) {
			this.initialSelection = (IProject) initialSelection;
		}
	}

	@Override
	public Object[] getChildren(Object element) {
		if (element instanceof IWorkspace) {
			IProject[] allProjects = ((IWorkspace) element).getRoot().getProjects();

			if (initialSelection != null) {
				return new Object[] { initialSelection };
			}
			else {
				List<IProject> projects = new ArrayList<IProject>();
				for (int i = 0; i < allProjects.length; i++) {
					if (allProjects[i].isOpen()) {
						projects.add(allProjects[i]);
					}
				}
				return projects.toArray();
			}
		}
		// if the context is JDT aware, then only display the first folder level
		// under the project
		// this may cause problems if source folders are nested inside one
		// another - eg. there are multiple levels
		else if (element instanceof IProject) {
			IContainer container = (IContainer) element;
			if (container.isAccessible()) {
				try {
					List<IResource> children = new ArrayList<IResource>();
					IResource[] members = container.members();
					for (int i = 0; i < members.length; i++) {
						if (members[i].getType() != IResource.FILE) {
							children.add(members[i]);
						}
					}
					return children.toArray();
				}
				catch (CoreException e) {
					// this should never happen because we call #isAccessible
					// before invoking #members
				}
			}
		}
		return new Object[0];
	}

	@Override
	public Object[] getElements(Object element) {
		return getChildren(element);
	}

	@Override
	public Object getParent(Object element) {
		if (element instanceof IResource) {
			return ((IResource) element).getParent();
		}
		return null;
	}

	@Override
	public boolean hasChildren(Object element) {
		return getChildren(element).length > 0;
	}

	@Override
	public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {

	}

	@Override
	public void dispose() {

	}

}
