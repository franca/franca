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
 * Implementation of the Franca FDEPL file wizard.
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public class FrancaFDEPLFileWizard extends FrancaFileWizard {

	private static final String EXTENSION = "fdepl";
	private FrancaFileWizardContainerConfigurationPage page1;
	private FrancaFDEPLFileWizardConfigurationPage page2;
	
	@Override
	protected Map<String, Object> collectParameters() {
		Map<String, Object> parameters = new HashMap<String, Object>();
		parameters.put("containerName", page1.getContainerName());
		parameters.put("fileName", page1.getFileName());
		parameters.put("packageName", page1.getPackageName());
		parameters.put("specification", page2.getSpecification());
		parameters.put("typeCollection", page2.getTypeCollection());
		parameters.put("interface", page2.getInterface());
		parameters.put("providerName", page2.getProviderName());
		parameters.put("specificationName", page2.getSpecificationName());
		return parameters;
	}
	
	@Override
	protected IPath performFileCreation(IProgressMonitor monitor, Map<String, Object> parameters) {        
        return FrancaWizardUtil.createFrancaFDEPLFile(resourceSetProvider, parameters);
	}

	@Override
	public void addPages() {
		page1 = new FrancaFileWizardContainerConfigurationPage(EXTENSION);
        page1.init((IStructuredSelection) selection);
        page1.setDescription(NEW_FRANCA_FDEPL_FILE);
        page2 = new FrancaFDEPLFileWizardConfigurationPage();
        injector.injectMembers(page2);
        page2.setDescription(NEW_FRANCA_FDEPL_FILE);
        addPage(page1);
        addPage(page2);
        setForcePreviousAndNextButtons(false);
	}
}
