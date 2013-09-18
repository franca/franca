package org.franca.connectors.etrice.ui.properties;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.dialogs.PropertyPage;

public class ETriceConnectorPropertyPage extends PropertyPage {

	private Text pathValueText;

	/**
	 * @see PreferencePage#createContents
	 */
	@Override
	protected Control createContents(Composite parent) {
		Composite composite = new Composite(parent, SWT.NONE);
		GridLayout layout = new GridLayout(2, false);
		composite.setLayout(layout);
		GridData data = new GridData(GridData.FILL);
		data.grabExcessHorizontalSpace = true;
		composite.setLayoutData(data);

		// Label for path field
		Label pathLabel = new Label(composite, SWT.NONE);
		GridDataFactory.fillDefaults().align(SWT.BEGINNING, SWT.CENTER)
				.applyTo(pathLabel);
		pathLabel.setText("Output folder:");

		// Path text field
		pathValueText = new Text(composite, SWT.BORDER | SWT.SINGLE
				| SWT.V_SCROLL | SWT.H_SCROLL);

		GridDataFactory.fillDefaults().grab(true, false).applyTo(pathValueText);

		// populate path text field
		try {
			String path = getResource().getPersistentProperty(
					ETriceConnectorProperties.ETRICE_GEN_MODEL_PATH_QN);
			pathValueText.setText((path != null) ? path
					: ETriceConnectorProperties.ETRICE_GEN_MODEL_PATH_DEFAULT);
		} catch (CoreException e) {
			pathValueText.setText(ETriceConnectorProperties.ETRICE_GEN_MODEL_PATH_DEFAULT);
		}
		return composite;
	}

	/**
	 * @see PreferencePage#performDefaults
	 */
	protected void performDefaults() {
		super.performDefaults();
		pathValueText.setText(ETriceConnectorProperties.ETRICE_GEN_MODEL_PATH_DEFAULT);
	}

	/**
	 * @see PreferencePage#performOk()
	 */
	public boolean performOk() {

		try {
			getResource()
					.setPersistentProperty(ETriceConnectorProperties.ETRICE_GEN_MODEL_PATH_QN,
							pathValueText.getText());
		} catch (CoreException e) {
			return false;
		}

		return true;
	}

	private IResource getResource() {
		return (IResource) getElement().getAdapter(IResource.class);
	}
}
