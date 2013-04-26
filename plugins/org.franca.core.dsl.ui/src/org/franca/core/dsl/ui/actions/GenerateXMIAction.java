/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.ui.actions;

import java.io.IOException;
import java.util.Collection;
import java.util.Collections;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IObjectActionDelegate;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FrancaRecursiveValidator;

import com.google.inject.Inject;

/**
 * Action delegate to generate XMI representation of Franca fidl files. 
 * 
 * @author Tamas Szabo
 *
 */
public class GenerateXMIAction implements IObjectActionDelegate {

	private IStructuredSelection selection;

	@Inject
	private FrancaPersistenceManager loader;

	@Inject
	private FrancaRecursiveValidator validator;

	@SuppressWarnings("deprecation")
	@Override
	public void run(IAction action) {
		if (selection != null && selection.size() == 1) {
			IFile file = (IFile) selection.getFirstElement();
			String fidlFile = file.getLocationURI().toString();

			FModel model = loader.loadModel(fidlFile);
			if (model != null) {
				Collection<Issue> issues = validator
						.validate(model.eResource());
				boolean isValid = true;

				for (Issue issue : issues) {
					if (issue.getSeverity() == Severity.ERROR) {
						isValid = false;
					}
				}

				if (isValid) {
					ResourceSet resourceSet = new ResourceSetImpl();
					resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put(
					    Resource.Factory.Registry.DEFAULT_EXTENSION, new XMIResourceFactoryImpl());
					int extensionIndex = file.getFullPath().toString().lastIndexOf("." + file.getFileExtension());
		    		String outputFilePath = file.getFullPath().toString().substring(0, extensionIndex) + ".xmi";
					URI fileURI = URI.createPlatformResourceURI(outputFilePath, true);
					Resource resource = resourceSet.createResource(fileURI);
				    resource.getContents().add(model);

					try {
						resource.save(Collections.EMPTY_MAP);
						file.getProject().refreshLocal(IResource.DEPTH_INFINITE, null);
					} catch (IOException e) {
						e.printStackTrace();
					} catch (CoreException e) {
						e.printStackTrace();
					}
				}
			}
		}
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.selection = (IStructuredSelection) selection;
	}

	@Override
	public void setActivePart(IAction action, IWorkbenchPart targetPart) {

	}

}
