/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.xtext.ui.preferences.StatusInfo;

/**
 * Wizard page for the Franca fidl specific properties.
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
@SuppressWarnings("restriction")
public class FrancaIDLFileWizardConfigurationPage extends StatusWizardPage {

    private static final String ONE_MUST_BE_SET = "At least either the type collection name or the interface name must be set!";
    private static final String MODEL_NAME_MUST_BE_SET = "The package name of the Franca model must be set!";
    private Text interfaceNameText;
    private Text typeCollectionNameText;
    private Text modelNameText;

    public FrancaIDLFileWizardConfigurationPage() {
        super(FrancaFileWizard.FIDL_TITLE);
        setTitle(FrancaFileWizard.FIDL_TITLE);
    }
    
    @Override
    public void createControl(Composite parent) {
        int nColumns = 5;

        initializeDialogUnits(parent);
        Composite composite = new Composite(parent, SWT.NONE);
        composite.setFont(parent.getFont());

        GridLayout layout = new GridLayout();
        layout.numColumns = nColumns;
        composite.setLayout(layout);
        
        Label label = new Label(composite, SWT.NULL);
        label.setText("&Interface name:");
        interfaceNameText = new Text(composite, SWT.BORDER | SWT.SINGLE);
        interfaceNameText.setText("");
        GridData gd_2 = new GridData(GridData.FILL_HORIZONTAL);
        gd_2.horizontalSpan = nColumns-1;
        interfaceNameText.setLayoutData(gd_2);
        interfaceNameText.addModifyListener(new ModifyListener() {
            public void modifyText(ModifyEvent e) {
                validatePage();
            }
        });
        
        label = new Label(composite, SWT.NULL);
        label.setText("&Type collection name:");
        typeCollectionNameText = new Text(composite, SWT.BORDER | SWT.SINGLE);
        typeCollectionNameText.setText("");
        GridData gd_3 = new GridData(GridData.FILL_HORIZONTAL);
        gd_3.horizontalSpan = nColumns-1;
        typeCollectionNameText.setLayoutData(gd_3);
        typeCollectionNameText.addModifyListener(new ModifyListener() {
            public void modifyText(ModifyEvent e) {
                validatePage();
            }
        });

        setControl(composite);
        validatePage();
    }

    public void validatePage() {
        StatusInfo si = new StatusInfo(StatusInfo.OK, "");

        boolean atLeastOneIsSet = false;
        
        if (interfaceNameText != null) {
            String interfaceName = interfaceNameText.getText();
            if (interfaceName != null && interfaceName.length() > 0) {
            	atLeastOneIsSet = true;
            }
        }
        if (typeCollectionNameText != null) {
            String typeCollectionName = typeCollectionNameText.getText();
            if (typeCollectionName != null && typeCollectionName.length() > 0) {
            	atLeastOneIsSet = true;
            }
        }
        if (!atLeastOneIsSet) {
        	si.setError(ONE_MUST_BE_SET);
        }
        
        if (modelNameText != null) {
            String modelName = modelNameText.getText();
            if (modelName == null || modelName.length() == 0) {
            	si.setError(MODEL_NAME_MUST_BE_SET);
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

    public String getInterfaceName() {
        return interfaceNameText.getText();
    }
    
    public String getTypeCollectionName() {
		return typeCollectionNameText.getText();
	}
    
    public String getModelName() {
		return modelNameText.getText();
	}
}
