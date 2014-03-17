/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.viewers.IStructuredSelection;

/**
 * Implementation of the Franca IDL file wizard.
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public class FrancaIDLFileWizard extends FrancaFileWizard {

	private static final String EXTENSION = "fidl";
	private FrancaFileWizardContainerConfigurationPage page1;
	private FrancaIDLFileWizardConfigurationPage page2;
	
	@Override
	protected IPath performFileCreation(IProgressMonitor monitor, Map<String, Object> parameters) {
        return FrancaWizardUtil.createFrancaIDLFile(resourceSetProvider, parameters);
	}
	
	@Override
	protected Map<String, Object> collectParameters() {
		Map<String, Object> parameters = new HashMap<String, Object>();
		parameters.put("containerName", page1.getContainerName());
		parameters.put("fileName", page1.getFileName());
        // replace dots with slash in the path
		parameters.put("packageName", page1.getPackageName());
		parameters.put("interfaceName", page2.getInterfaceName());
		parameters.put("typeCollectionName", page2.getTypeCollectionName());
		return parameters;
	}

	@Override
	public void addPages() {
		page1 = new FrancaFileWizardContainerConfigurationPage(EXTENSION);
        page1.init((IStructuredSelection) selection);
        page1.setDescription(NEW_FRANCA_IDL_FILE);
        page2 = new FrancaIDLFileWizardConfigurationPage();
        page2.setDescription(NEW_FRANCA_IDL_FILE);
        addPage(page1);
        addPage(page2);
        setForcePreviousAndNextButtons(false);
	}
}
