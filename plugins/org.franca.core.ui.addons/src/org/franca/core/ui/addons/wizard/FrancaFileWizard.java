/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import java.lang.reflect.InvocationTargetException;
import java.util.Map;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
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

import com.google.inject.Inject;
import com.google.inject.Injector;

/**
 * An abstract base class for the Franca file creation wizards. 
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public abstract class FrancaFileWizard extends Wizard implements INewWizard {
	
	public static final String FIDL_TITLE = "Franca Interface Definition Wizard";
	public static final String FDEPL_TITLE = "Franca Deployment Specification Wizard";
	public static final String NEW_FRANCA_FDEPL_FILE = "Create a new Franca Deployment Specification";
	public static final String NEW_FRANCA_IDL_FILE = "Create a new Franca Interface Definition";
	
    protected ISelection selection;
    protected IWorkbench workbench;
    private IPath filePath;

    @Inject
    protected IResourceSetProvider resourceSetProvider;
    
    @Inject 
    protected Injector injector;

    public FrancaFileWizard() {
        super();
        setNeedsProgressMonitor(true);
    }

    @Override
    public abstract void addPages();

    @Override
    public boolean performFinish() {
    	//The data from the SWT Widgets must be collected outside of the Runnable, otherwise Invalid Thread Access will occur
    	final Map<String, Object> parameters = collectParameters();
    	
        IRunnableWithProgress op = new IRunnableWithProgress() {
            @Override
            public void run(IProgressMonitor monitor) throws InvocationTargetException {
                try {
                	monitor.beginTask("Creating file", 1);
                    filePath = performFileCreation(monitor, parameters);
                    monitor.worked(1);
                } catch (Exception e) {
                    throw new InvocationTargetException(e);
                } finally {
                    monitor.done();
                }
            }
        };
        try {
            getContainer().run(true, false, op);
            IFile file = (IFile) ResourcesPlugin.getWorkspace().getRoot().findMember(filePath);
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
    
    protected abstract IPath performFileCreation(IProgressMonitor progressMonitor, Map<String, Object> parameters);

    protected abstract Map<String, Object> collectParameters();
    
    @Override
    public void init(IWorkbench workbench, IStructuredSelection selection) {
        this.selection = selection;
        this.workbench = workbench;
    }
}