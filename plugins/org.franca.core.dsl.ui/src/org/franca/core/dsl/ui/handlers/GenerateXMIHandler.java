/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.ui.handlers;

import java.io.IOException;
import java.util.Collections;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.ui.util.SpecificConsole;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FrancaRecursiveValidator;

import com.google.inject.Inject;

/**
 * Handler to generate XMI representation of Franca fidl files. 
 * 
 * @author Tamas Szabo
 *
 */
public class GenerateXMIHandler extends AbstractHandler {

	@Inject
	private FrancaPersistenceManager loader;

	@Inject
	private FrancaRecursiveValidator validator;

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		ISelection selection = HandlerUtil.getCurrentSelection(event);
		
		if (selection != null && selection instanceof IStructuredSelection && !selection.isEmpty()) {
			IFile file = (IFile) ((IStructuredSelection) selection).getFirstElement();
            URI uri = URI.createPlatformResourceURI(file.getFullPath().toString(), true);

        	URI rootURI = URI.createURI("classpath:/");
    		FModel model = loader.loadModel(uri, rootURI);
			if (model != null) {
				if (!validator.hasErrors(model.eResource())) {
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
				else {
					SpecificConsole console = new SpecificConsole("Franca");
			        console.getErr().println("Aborting XMI generation due to validation errors!");
				}
			}
		}
		return null;
	}

}
