/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
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

/**
 * Common wizard page for configuring the container of a new Franca fdepl/fidl file.
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
@SuppressWarnings("restriction")
public class FrancaFileWizardContainerConfigurationPage extends StatusWizardPage implements Listener {

	private Text packageNameText;
	private Text fileNameText;

	private static final String THE_GIVEN_FILE_ALREADY_EXISTS = "The given file already exists!";
	private static final String DEFAULT_FILE_NAME = "";
	private static final String FILE_NAME_ERROR = "File name must be specified!";
	private static final String FILE_NAME_NOT_VALID = "File name must be valid!";
	private String FILE_EXTENSION_ERROR;

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
		sourceFolderSelector = new ContainerSelectionGroup(composite, this, false,
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
		Label packageNameLabel = new Label(composite, SWT.NULL);
		packageNameLabel.setText("&Package:");
		gridData = new GridData();
		gridData.horizontalSpan = 1;
		packageNameLabel.setLayoutData(gridData);

		packageNameText = new Text(composite, SWT.BORDER | SWT.SINGLE);
		packageNameText.setEditable(false);
		packageNameText.setText(inferPackageName());
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = 3;
		packageNameText.setLayoutData(gridData);

		Label packageNameStatus = new Label(composite, SWT.NULL);
		packageNameStatus.setText("(inferred)");
		gridData = new GridData(GridData.HORIZONTAL_ALIGN_END);
		gridData.horizontalSpan = 1;
		packageNameStatus.setLayoutData(gridData);

		packageNameText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				validatePage();
			}
		});

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
	
	private static final IStatus OK_STATUS = new Status(IStatus.OK, Activator.PLUGIN_ID, "");

	private void validatePage() {
		IStatus status = validateContainerName();
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
		return OK_STATUS;
	}

	private IStatus validateFileName() {
		if (getFileName() == null || getFileName().length() == 0) {
			return new Status(IStatus.ERROR, Activator.PLUGIN_ID,
					FILE_NAME_ERROR);
		}

		if (ResourcesPlugin.getWorkspace().getRoot()
				.findMember(sourceFolderSelector.getContainerFullPath().append(getFileName())) != null) {
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

	private String inferPackageName() {
		IPath path = sourceFolderSelector.getContainerFullPath();
		IResource act = ResourcesPlugin.getWorkspace().getRoot().findMember(path);

		if (act != null && !(act instanceof IProject)) {
			StringBuilder sb = new StringBuilder();

			// here we can only apply a simple method which just traverses up in
			// the hierarchy until the current IResource's parent is an IProject
			List<IResource> segments = new ArrayList<IResource>();
			while (!(act.getParent() == null || act.getParent() instanceof IProject)) {
				segments.add(act);
				act = act.getParent();
			}

			if (segments.size() >= 1) {
				sb.append(segments.get(segments.size() - 1).getName());
				for (int i = segments.size() - 2; i >= 0; i--) {
					sb.append("." + segments.get(i).getName());
				}
			}

			return sb.toString();
		}
		else {
			return "";
		}
	}

	public String getFileName() {
		return fileNameText.getText();
	}

	public String getContainerName() {
		return sourceFolderSelector.getContainerFullPath().toString();
	}

	public String getPackageName() {
		return packageNameText.getText();
	}

	public IProject getProject() {
		return this.getProject();
	}

	@Override
	public void handleEvent(Event event) {
		if (this.packageNameText != null) {
			this.packageNameText.setText(inferPackageName());
		}
	}
}
