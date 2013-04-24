package org.franca.core.ui.addons.wizard;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.viewers.IStructuredSelection;

/**
 * Implementation of the Franca IDL file wizard.
 * 
 * @author Tamas Szabo
 *
 */
public class FrancaIDLFileWizard extends FrancaFileWizard {

	private static final String EXTENSION = "fidl";
	private FrancaFileWizardContainerConfigurationPage page1;
	private FrancaIDLFileWizardConfigurationPage page2;
	
	@Override
	protected IPath performFileCreation(IProgressMonitor monitor, Map<String, String> parameters) {
        return FrancaWizardUtil.createFrancaIDLFile(resourceSetProvider, parameters);
	}
	
	@Override
	protected Map<String, String> collectParameters() {
		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("containerName", page1.getContainerName());
		parameters.put("fileName", page1.getFileName());
        // replace dots with slash in the path
		parameters.put("packageName", page1.getPackageName().replaceAll("\\.", "/"));
		parameters.put("interfaceName", page2.getInterfaceName());
		parameters.put("typeCollectionName", page2.getTypeCollectionName());
		parameters.put("modelName", page2.getModelName());
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
