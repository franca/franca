/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard.packageselection;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.dialogs.Dialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.dialogs.ElementListSelectionDialog;
import org.franca.core.ui.addons.Activator;
import org.franca.core.ui.addons.wizard.FrancaWizardUtil;

public class BasicPackageSelector extends PackageSelector {

	private Text packageNameText;
	private Label packageNameStatus;
	private Button packageNameBrowseButton;

	public BasicPackageSelector(Composite parent, boolean allowPackageEditing) {
		super(parent);

		GridLayout layout = new GridLayout();
		layout.numColumns = 5;
		this.setLayout(layout);

		Label packageNameLabel = new Label(this, SWT.NULL);
		packageNameLabel.setText("&Package:");
		GridData gridData = new GridData();
		gridData.horizontalSpan = 1;
		packageNameLabel.setLayoutData(gridData);

		packageNameText = new Text(this, SWT.BORDER | SWT.SINGLE);
		packageNameText.setEditable(allowPackageEditing);
		packageNameText.setText("");
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = (2);
		packageNameText.setLayoutData(gridData);

		packageNameText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				for (IPackageSelectorChangeListener listener : listeners) {
					listener.packageChanged(getPackageName());
				}
				if (getPackageName().length() == 0) {
					packageNameStatus.setText("(default)");
				}
				else {
					packageNameStatus.setText("");
				}
			}
		});

		packageNameStatus = new Label(this, SWT.NULL);
		packageNameStatus.setText("(default)");
		gridData = new GridData(GridData.HORIZONTAL_ALIGN_END);
		gridData.widthHint = 60;
		gridData.horizontalSpan = 1;
		packageNameStatus.setLayoutData(gridData);

		packageNameBrowseButton = new Button(this, SWT.NONE);
		packageNameBrowseButton.setText("Browse");
		gridData = new GridData(GridData.HORIZONTAL_ALIGN_END);
		gridData.horizontalSpan = 1;
		packageNameBrowseButton.setLayoutData(gridData);
		packageNameBrowseButton.addSelectionListener(new BrowseButtonSelectionListener());

	}

	private class BrowseButtonSelectionListener implements SelectionListener {

		@Override
		public void widgetSelected(SelectionEvent e) {
			ElementListSelectionDialog packageSelection = new ElementListSelectionDialog(getShell(),
					new BasicPackageSelectorLabelProvider());
			packageSelection.setTitle("Select a package for the Franca file");
			packageSelection.setMessage("Available packages:");
			packageSelection.setElements(getPackages());
			if (packageSelection.open() == Dialog.OK) {
				IContainer selection = (IContainer) packageSelection.getFirstResult();
				if (selection.getParent() instanceof IProject) {
					packageNameStatus.setText("(default)");
					packageNameText.setText("");
				}
				else {
					packageNameStatus.setText("");
					packageNameText.setText(FrancaWizardUtil.getPackageName((IContainer) selection));
				}

				for (IPackageSelectorChangeListener listener : listeners) {
					listener.packageChanged(getPackageName());
				}
			}
		}

		@Override
		public void widgetDefaultSelected(SelectionEvent e) {
		}

	}

	private Object[] getPackages() {
		if (container == null) {
			// display only "default package"
			return new Object[] { null };
		}
		else {
			List<IContainer> containers = new ArrayList<IContainer>();
			List<IContainer> queue = new LinkedList<IContainer>();
			queue.addAll(getAccessibleMemberContainers(container));
			containers.add(container); // for default package

			while (!queue.isEmpty()) {
				IContainer head = queue.remove(0);
				containers.add(head);
				queue.addAll(getAccessibleMemberContainers(head));
			}

			return containers.toArray();
		}
	}

	private List<IContainer> getAccessibleMemberContainers(IContainer container) {
		List<IContainer> result = new ArrayList<IContainer>();
		try {
			for (IResource res : container.members()) {
				if (res.isAccessible() && res instanceof IContainer) {
					result.add((IContainer) res);
				}
			}
		}
		catch (CoreException e) {
			//
		}
		return result;
	}

	private static final IStatus OK_STATUS = new Status(IStatus.OK, Activator.PLUGIN_ID, "");
	private static final String PACKAGE_NAME_INVALID = "The package name is not valid!";

	@Override
	public IStatus validate() {
		if (getPackageName().length() > 0) {
			if (getPackageName().charAt(0) == '.' || getPackageName().charAt(getPackageName().length() - 1) == '.') {
				return new Status(IStatus.ERROR, Activator.PLUGIN_ID, PACKAGE_NAME_INVALID);
			}
			if (!getPackageName().toLowerCase().matches(getPackageName())) {
				return new Status(IStatus.ERROR, Activator.PLUGIN_ID, PACKAGE_NAME_INVALID);
			}
			for (char c : getPackageName().toCharArray()) {
				if (!(Character.isLetter(c) || c == '.')) {
					return new Status(IStatus.ERROR, Activator.PLUGIN_ID, PACKAGE_NAME_INVALID);
				}
			}
		}

		return OK_STATUS;
	}

	@Override
	public String getPackageName() {
		return packageNameText.getText();
	}

	@Override
	public void setContainer(IContainer container) {
		if (!(container instanceof IProject)) {
			super.setContainer(container);
			packageNameBrowseButton.setEnabled(true);
		}
		else {
			packageNameBrowseButton.setEnabled(false);
		}
	}

}
