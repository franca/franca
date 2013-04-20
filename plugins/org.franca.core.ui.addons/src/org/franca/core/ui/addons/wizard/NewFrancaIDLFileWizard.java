package org.franca.core.ui.addons.wizard;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.Collections;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.INewWizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.wizards.newresource.BasicNewResourceWizard;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FrancaFactory;

import com.google.inject.Inject;

/**
 * A wizard implementation used to create new Franca IDL files.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public class NewFrancaIDLFileWizard extends Wizard implements INewWizard {

    private static final String NEW_EMF_INC_QUERY_QUERY_DEFINITION_FILE = "Create a new EMF-IncQuery Query Definition file.";
    private NewFrancaIDLFileWizardContainerConfigurationPage page1;
    private NewFrancaIDLFileWizardConfigurationPage page2;
    private ISelection selection;
    private IWorkbench workbench;
    private final IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
    private IPath filePath;

    @Inject
    private IResourceSetProvider resourceSetProvider;

    public NewFrancaIDLFileWizard() {
        super();
        setNeedsProgressMonitor(true);
    }

    @Override
    public void addPages() {
        page1 = new NewFrancaIDLFileWizardContainerConfigurationPage();
        page1.init((IStructuredSelection) selection);
        page1.setDescription(NEW_EMF_INC_QUERY_QUERY_DEFINITION_FILE);
        page2 = new NewFrancaIDLFileWizardConfigurationPage();
        addPage(page1);
        addPage(page2);
        setForcePreviousAndNextButtons(false);
    }

    @Override
    public boolean performFinish() {
        final String containerName = page1.getContainerName();
        final String fileName = page1.getFileName();

        // replace dots with slash in the path
        final String packageName = page1.getPackageName().replaceAll("\\.", "/");
        final String interfaceName = page2.getInterfaceName();
        final String typeCollectionName = page2.getTypeCollectionName();
        final String modelName = page2.getModelName();
        
        IRunnableWithProgress op = new IRunnableWithProgress() {
            @Override
            public void run(IProgressMonitor monitor) throws InvocationTargetException {
                try {
                    doFinish(containerName, fileName, packageName, modelName, interfaceName, typeCollectionName, monitor);
                } catch (Exception e) {
                    throw new InvocationTargetException(e);
                } finally {
                    monitor.done();
                }
            }
        };
        try {
            getContainer().run(true, false, op);
            IFile file = (IFile) root.findMember(filePath);
            BasicNewResourceWizard.selectAndReveal(file, workbench.getActiveWorkbenchWindow());
            IDE.openEditor(workbench.getActiveWorkbenchWindow().getActivePage(), file, true);
        } catch (InterruptedException e) {
            // This is never thrown as of false cancellable parameter of getContainer().run
            return false;
        } catch (InvocationTargetException e) {
            Throwable realException = e.getTargetException();
            e.printStackTrace();
            MessageDialog.openError(getShell(), "Error", realException.getMessage());
            return false;
        } catch (PartInitException e) {
            e.printStackTrace();
            MessageDialog.openError(getShell(), "Error", e.getMessage());
        }
        return true;
    }

    private void doFinish(String containerName, String fileName, String packageName, String modelName, String interfaceName, String typeCollectionName, IProgressMonitor monitor) {
        monitor.beginTask("Creating " + fileName, 1);
        createEiqFile(containerName, fileName, packageName, modelName, interfaceName, typeCollectionName);
        monitor.worked(1);
    }

    @Override
    public void init(IWorkbench workbench, IStructuredSelection selection) {
        this.selection = selection;
        this.workbench = workbench;
    }

    private void createEiqFile(String containerName, String fileName, String packageName, String modelName, String interfaceName, String typeCollectionName) {
        IResource containerResource = root.findMember(new Path(containerName));
        ResourceSet resourceSet = resourceSetProvider.get(containerResource.getProject());

        filePath = containerResource.getFullPath().append(packageName + "/" + fileName);
        String fullPath = filePath.toString();

        URI fileURI = URI.createPlatformResourceURI(fullPath, false);
        Resource resource = resourceSet.createResource(fileURI);

        FModel model = FrancaFactory.eINSTANCE.createFModel();
        model.setName(modelName);
        
        if (interfaceName != null && interfaceName.length() > 0) {
        	FInterface _interface = FrancaFactory.eINSTANCE.createFInterface();
        	_interface.setName(interfaceName);
        	model.getInterfaces().add(_interface);
        }
        
        if (typeCollectionName != null && typeCollectionName.length() > 0) {
        	FTypeCollection typeCollection = FrancaFactory.eINSTANCE.createFTypeCollection();
        	typeCollection.setName(typeCollectionName);
        	model.getTypeCollections().add(typeCollection);
        }
        
        resource.getContents().add(model);

        try {
            resource.save(Collections.EMPTY_MAP);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}