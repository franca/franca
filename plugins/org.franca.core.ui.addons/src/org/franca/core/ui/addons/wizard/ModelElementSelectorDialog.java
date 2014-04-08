/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.dialogs.ElementListSelectionDialog;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;

import com.google.inject.Inject;

/**
 * An {@link ElementListSelectionDialog} implementation to display the
 * {@link EObject} instances of a given {@link EClass} type from the Xtext
 * index.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public class ModelElementSelectorDialog extends ElementListSelectionDialog {

	@Inject
	private IResourceDescriptions resourceDescriptions;

	@Inject
	private IResourceSetProvider resourceSetProvider;

	public ModelElementSelectorDialog(final IQualifiedNameProvider nameProvider) {
		super(Display.getCurrent().getActiveShell(), new LabelProvider() {
			@Override
			public String getText(Object element) {
				return nameProvider.getFullyQualifiedName((EObject) element).toString();
			}
		});
		this.setMessage("Select an element from the list below:");
	}

	public void initializeElements(IProject project, EClass clazz) {
		ResourceSet resourceSet = resourceSetProvider.get(project);

		List<Object> elements = new ArrayList<Object>();
		for (IEObjectDescription resourceDescription : resourceDescriptions.getExportedObjectsByType(clazz)) {
			EObject obj = EcoreUtil.resolve(resourceDescription.getEObjectOrProxy(), resourceSet);
			// this additional check is needed, because we only want to allow
			// the exact types to be present (not subtypes)
			if (obj.eClass().equals(clazz)) {
				elements.add(obj);
			}
		}
		this.setElements(elements.toArray());
	}
}
