/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.generators.ui.handlers;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import org.franca.core.franca.FModel;
import org.franca.generators.FrancaGenerators;

import com.google.inject.Inject;

public class GenerateJSHandler extends AbstractHandler {

	private final static String SERVER_GEN_DIR = "server";
	private final static String CLIENT_GEN_DIR = "client";
	
    @Inject
    private IResourceSetProvider resSetProvider;
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		ISelection selection = HandlerUtil.getCurrentSelection(event);
		if (selection instanceof IStructuredSelection) {
			Object obj = ((IStructuredSelection) selection).getFirstElement();
			if (obj != null && obj instanceof IFile) {
				IFile file = (IFile) obj;
				ResourceSet resourceSet = resSetProvider.get(file.getProject());
				Resource resource = (Resource) resourceSet.getResource(URI.createPlatformResourceURI(file.getFullPath().toString(), false), true);
				if (resource.getContents().size() > 0) {
					FModel model = (FModel) resource.getContents().get(0);
					FrancaGenerators.instance().genWebsocket(file.getProject(), model, SERVER_GEN_DIR, CLIENT_GEN_DIR);
				}
			}
		}
		return null;
	}


}
