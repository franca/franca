/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.viewers.IContentProvider;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.internal.ide.misc.ContainerSelectionGroup;
import org.franca.core.ui.addons.Activator;
import org.franca.core.ui.addons.wizard.packageselection.BasicPackageSelector;
import org.franca.core.ui.addons.wizard.packageselection.IPackageSelectorChangeListener;
import org.franca.core.ui.addons.wizard.packageselection.PackageSelector;

/**
 * Common wizard page for configuring the container of a new Franca fdepl/fidl
 * file.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
@SuppressWarnings("restriction")
public class FrancaFileWizardContainerConfigurationPage extends StatusWizardPage implements Listener, IPackageSelectorChangeListener {

	private Text fileNameText;
	private PackageSelector packageSelector;

	private static final String THE_GIVEN_FILE_ALREADY_EXISTS = "The given file already exists!";
	private static final String DEFAULT_FILE_NAME = "";
	private static final String FILE_NAME_ERROR = "File name must be specified!";
	private static final String FILE_NAME_NOT_VALID = "File name must be valid!";
	private String FILE_EXTENSION_ERROR;
	private IProject selectedProject;
	
	private static final String SOURCE_FOLDER_ERROR = "You must specify a valid source folder!";

	private String extension;
	private IContainer initialSelection;
	private ContainerContentProvider containerContentProvider;
	private ContainerSelectionGroup sourceFolderSelector;

	public FrancaFileWizardContainerConfigurationPage(String extension) {
		super(extension.matches("fidl") ? FrancaFileWizard.FIDL_TITLE : FrancaFileWizard.FDEPL_TITLE);
		this.extension = extension;
		this.FILE_EXTENSION_ERROR = "File extension must be \"" + extension + "\"!";
		setTitle(extension.matches("fidl") ? FrancaFileWizard.FIDL_TITLE : FrancaFileWizard.FDEPL_TITLE);
	}

	/**
	 * Initialization based on the current selection.
	 * 
	 * @param selection
	 *            the current selection in the workspace
	 */
	public void init(IStructuredSelection selection) {
		if (selection instanceof StructuredSelection) {
			Object obj = ((StructuredSelection) selection).getFirstElement();

			if (obj instanceof IContainer) {
				initialSelection = (IContainer) obj;
			}
			// REFLECTION based checks for JDT containers - try to invoke
			// getResource from IJavaElement
			else {
				initialSelection = (IContainer) FrancaWizardUtil.tryInvoke(obj, "getResource");
			}

			selectedProject = initialSelection.getProject();
			
			if (containerContentProvider != null) {
				containerContentProvider.setInitialSeletion(initialSelection);
			}
		}
	}

	@Override
	public void createControl(Composite parent) {
		initializeDialogUnits(parent);
		Composite composite = new Composite(parent, SWT.NONE);

		GridLayout layout = new GridLayout();
		layout.numColumns = 5;
		composite.setLayout(layout);

		// Source folder selection
		sourceFolderSelector = new ContainerSelectionGroup(composite, this, true,
				"Source folder for the new Franca " + extension + " file:", false);
		Object treeViewer = FrancaWizardUtil.tryGet(sourceFolderSelector, "treeViewer");
		// try to set a custom content provider
		if (treeViewer != null) {
			containerContentProvider = new ContainerContentProvider();
			containerContentProvider.setInitialSeletion(initialSelection);
			FrancaWizardUtil.tryInvoke(treeViewer, "setContentProvider", new Class<?>[] { IContentProvider.class },
					new Object[] { containerContentProvider });
		}
		// set the initial selection anyway (if any)
		if (initialSelection != null) {
			sourceFolderSelector.setSelectedContainer(initialSelection);
		}

		GridData gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = 5;
		sourceFolderSelector.setLayoutData(gridData);

		// Package selection
		packageSelector = new BasicPackageSelector(composite, true);
		packageSelector.registerPackageSelectorChangedListener(this);
		gridData = new GridData(GridData.HORIZONTAL_ALIGN_FILL);
		gridData.horizontalSpan = 5;
		packageSelector.setLayoutData(gridData);

		// File name editing
		Label fileNameLabel = new Label(composite, SWT.NULL);
		fileNameLabel.setText("&File name:");
		gridData = new GridData(GridData.HORIZONTAL_ALIGN_FILL);
		gridData.horizontalSpan = 1;
		fileNameLabel.setLayoutData(gridData);

		fileNameText = new Text(composite, SWT.BORDER | SWT.SINGLE);
		fileNameText.setText(DEFAULT_FILE_NAME);
		gridData = new GridData(GridData.HORIZONTAL_ALIGN_FILL);
		gridData.horizontalSpan = 4;
		fileNameText.setLayoutData(gridData);

		fileNameText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				validatePage();
			}
		});

		setControl(composite);

		validatePage();
	}

	// VALIDATION
	
	private static final IStatus OK_STATUS = new Status(IStatus.OK, Activator.PLUGIN_ID, "");

	private void validatePage() {
		IStatus status = validateContainerName();
		if (status.getSeverity() != IStatus.ERROR) {
			status = packageSelector.validate();
		}
		if (status.getSeverity() != IStatus.ERROR) {
			status = validateFileName();
		}
		setStatus(status);
	}

	private void setStatus(IStatus status) {
		applyStatus(status);
		if (status.getSeverity() == IStatus.ERROR) {
			this.setPageComplete(false);
		}
		else {
			this.setPageComplete(true);
		}
	}

	private IStatus validateContainerName() {
		if (sourceFolderSelector.getContainerFullPath() == null) {
			return new Status(IStatus.ERROR, Activator.PLUGIN_ID, SOURCE_FOLDER_ERROR);
		}
		
		IResource resource = ResourcesPlugin.getWorkspace().getRoot().findMember(sourceFolderSelector.getContainerFullPath());
		if (resource instanceof IProject) {
			return new Status(IStatus.ERROR, Activator.PLUGIN_ID, SOURCE_FOLDER_ERROR);
		}
		
		return OK_STATUS;
	}

	private IStatus validateFileName() {
		if (getFileName() == null || getFileName().length() == 0) {
			return new Status(IStatus.ERROR, Activator.PLUGIN_ID,
					FILE_NAME_ERROR);
		}

		String packageName = getPackageName().replaceAll("\\.", "/");
		if (ResourcesPlugin.getWorkspace().getRoot()
				.findMember(sourceFolderSelector.getContainerFullPath().append(packageName).append(getFileName())) != null) {
			return new Status(IStatus.ERROR, Activator.PLUGIN_ID,
					THE_GIVEN_FILE_ALREADY_EXISTS);
		}

		boolean wrongExtension = false;

		if (!getFileName().contains(".")) {
			wrongExtension = true;
		}
		else {
			int dotLoc = getFileName().lastIndexOf('.');
			String ext = getFileName().substring(dotLoc + 1);
			wrongExtension = !ext.equalsIgnoreCase(extension);
		}

		if (wrongExtension) {
			return new Status(IStatus.ERROR, Activator.PLUGIN_ID,
					FILE_EXTENSION_ERROR);
		}

		if (getFileName().replace('\\', '/').indexOf('/', 1) > 0) {
			return new Status(IStatus.ERROR, Activator.PLUGIN_ID,
					FILE_NAME_NOT_VALID);
		}

		return OK_STATUS;
	}

	// GETTERS
	
	public String getFileName() {
		return fileNameText.getText();
	}

	public String getContainerName() {
		return sourceFolderSelector.getContainerFullPath().toString();
	}

	public String getPackageName() {
		return packageSelector.getPackageName();
	}

	public IProject getProject() {
		return selectedProject;
	}

	@Override
	public void handleEvent(Event event) {
		if (packageSelector != null) {
			IResource resource = ResourcesPlugin.getWorkspace().getRoot()
					.findMember(sourceFolderSelector.getContainerFullPath());
			if (resource != null) {
				validatePage();
				packageSelector.setContainer((IContainer) resource);
			}
		}
	}

	@Override
	public void packageChanged(String packageName) {
		validatePage();
	}
}
