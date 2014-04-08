/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.xtext.ui.preferences.StatusInfo;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FrancaPackage;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage;

import com.google.inject.Inject;
import com.google.inject.Injector;

/**
 * Wizard page for the Franca fdepl specific properties.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
@SuppressWarnings("restriction")
public class FrancaFDEPLFileWizardConfigurationPage extends StatusWizardPage implements IModelElementSelectorListener {

	private static final String SPEC_MUST_BE_SET = "Either you must set a deployment specification name or select an already existing one!";
	private static final String ROOT_ELEMENT_MUST_BE_SET = "You must set exactly one of Interface / TypeCollection / Provider if you have selected an FDSpecification!";
	private Text specificationName;
	private ModelElementSelector typeCollectionSelector;
	private ModelElementSelector interfaceSelector;
	private ModelElementSelector specificationSelector;
	private Text providerName;

	@Inject
	private Injector injector;

	public FrancaFDEPLFileWizardConfigurationPage() {
		super(FrancaFileWizard.FDEPL_TITLE);
		setTitle(FrancaFileWizard.FDEPL_TITLE);
	}

	@Override
	public void createControl(final Composite parent) {
		IProject project = ((FrancaFileWizardContainerConfigurationPage) getPreviousPage()).getProject();
		int nColumns = 5;

		initializeDialogUnits(parent);
		Composite composite = new Composite(parent, SWT.NONE);
		composite.setFont(parent.getFont());

		GridLayout layout = new GridLayout();
		layout.numColumns = nColumns;
		layout.marginBottom = 0;
		layout.marginHeight = 0;
		layout.marginLeft = 0;
		layout.marginRight = 0;
		layout.marginTop = 0;
		layout.marginWidth = 0;

		composite.setLayout(layout);

		Label label = new Label(composite, SWT.NULL);
		label.setText("&Deployment specification name:");
		specificationName = new Text(composite, SWT.BORDER | SWT.SINGLE);
		specificationName.setText("");
		GridData gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = nColumns - 1;
		specificationName.setLayoutData(gridData);
		specificationName.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				validatePage();
			}
		});

		label = new Label(composite, SWT.SEPARATOR | SWT.HORIZONTAL);
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = nColumns;
		label.setLayoutData(gridData);

		label = new Label(composite, SWT.NULL);
		label.setText("&Deployment definition");
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = nColumns;
		label.setLayoutData(gridData);

		label = new Label(composite, SWT.NULL);
		label.setText("&TypeCollection:");
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = nColumns - 1;
		typeCollectionSelector = new ModelElementSelector(composite, project,
				FrancaPackage.eINSTANCE.getFTypeCollection(), injector);
		typeCollectionSelector.setLayoutData(gridData);
		typeCollectionSelector.addModelElementSelectorListener(this);

		label = new Label(composite, SWT.NULL);
		label.setText("&Interface:");
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = nColumns - 1;
		interfaceSelector = new ModelElementSelector(composite, project, FrancaPackage.eINSTANCE.getFInterface(),
				injector);
		interfaceSelector.setLayoutData(gridData);
		interfaceSelector.addModelElementSelectorListener(this);

		label = new Label(composite, SWT.NULL);
		label.setText("&Provider:");
		providerName = new Text(composite, SWT.BORDER | SWT.SINGLE);
		providerName.setText("");
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = nColumns - 1;
		providerName.setLayoutData(gridData);
		providerName.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				validatePage();
			}
		});

		label = new Label(composite, SWT.NULL);
		label.setText("&for Specification:");
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		gridData.horizontalSpan = nColumns - 1;
		specificationSelector = new ModelElementSelector(composite, project,
				FDeployPackage.eINSTANCE.getFDSpecification(), injector);
		specificationSelector.setLayoutData(gridData);
		specificationSelector.addModelElementSelectorListener(this);

		setControl(composite);
		validatePage();
	}

	public void validatePage() {
		StatusInfo si = new StatusInfo(StatusInfo.OK, "");
		if (specificationName.getText().isEmpty() &&
				specificationSelector.getValue() == null) {
			si.setError(SPEC_MUST_BE_SET);
		}

		if (specificationSelector.getValue() != null) {
			int set = 0;
			set += (typeCollectionSelector.getValue() == null ? 0 : 1);
			set += (interfaceSelector.getValue() == null ? 0 : 1);
			set += (providerName.getText().isEmpty() ? 0 : 1);

			if (set != 1) {
				si.setError(ROOT_ELEMENT_MUST_BE_SET);
			}
		}

		if (si.getSeverity() == IStatus.OK) {
			si.setInfo("");
		}

		updateStatus(si);

		if (si.isError()) {
			setErrorMessage(si.getMessage());
		}
	}

	protected void updateStatus(IStatus status) {
		setPageComplete(!status.matches(IStatus.ERROR));
		applyStatus(status);
	}

	public String getSpecificationName() {
		return specificationName.getText();
	}

	public FDSpecification getSpecification() {
		return (FDSpecification) specificationSelector.getValue();
	}

	public FTypeCollection getTypeCollection() {
		return (FTypeCollection) typeCollectionSelector.getValue();
	}

	public FInterface getInterface() {
		return (FInterface) interfaceSelector.getValue();
	}

	public String getProviderName() {
		return providerName.getText();
	}

	@Override
	public void selectionChanged(EObject value) {
		validatePage();
	}

}
