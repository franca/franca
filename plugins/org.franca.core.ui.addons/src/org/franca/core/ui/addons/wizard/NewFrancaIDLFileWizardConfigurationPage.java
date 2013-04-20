package org.franca.core.ui.addons.wizard;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.jdt.internal.ui.dialogs.StatusInfo;
import org.eclipse.jdt.internal.ui.dialogs.StatusUtil;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

@SuppressWarnings("restriction")
public class NewFrancaIDLFileWizardConfigurationPage extends WizardPage {

    private static final String TITLE = "Franca IDL file Wizard";
    private static final String ONE_MUST_BE_SET = "At least either the type collection name or the interface name must be set!";
    private static final String MODEL_NAME_MUST_BE_SET = "The package name of the Franca model must be set!";
    private Text interfaceNameText;
    private Text typeCollectionNameText;
    private Text modelNameText;

    public NewFrancaIDLFileWizardConfigurationPage() {
        super(TITLE);
        setTitle(TITLE);
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
        label.setText("&Franca model package name:");
        modelNameText = new Text(composite, SWT.BORDER | SWT.SINGLE);
        modelNameText.setText("");
        GridData gd_0 = new GridData(GridData.FILL_HORIZONTAL);
        gd_0.horizontalSpan = nColumns-1;
        modelNameText.setLayoutData(gd_0);
        modelNameText.addModifyListener(new ModifyListener() {
            public void modifyText(ModifyEvent e) {
                validatePage();
            }
        });
        
        label = new Label(composite, SWT.SEPARATOR | SWT.HORIZONTAL);
        GridData gd_1 = new GridData(GridData.FILL_HORIZONTAL);
        gd_1.horizontalSpan = nColumns;
        label.setLayoutData(gd_1);
        
        label = new Label(composite, SWT.NULL);
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
        StatusUtil.applyToStatusLine(this, status);
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
