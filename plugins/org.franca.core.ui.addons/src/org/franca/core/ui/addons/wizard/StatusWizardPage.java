/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.jface.dialogs.IMessageProvider;
import org.eclipse.jface.wizard.WizardPage;

/**
 * A {@link WizardPage} with additional support for the convenient setting of status information.
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public abstract class StatusWizardPage extends WizardPage {

	protected StatusWizardPage(String name) {
		super(name);
	}

	/**
	 * Applies the status to the status line of the wizard page.
	 * @param status the status to apply
	 */
	protected void applyStatus (IStatus status) {
		String msg = status.getMessage();
		if (msg != null && msg.length() == 0) {
			msg = null;
		}

		switch (status.getSeverity()) {
			case IStatus.OK:
				setMessage(msg, IMessageProvider.NONE);
				setErrorMessage(null);
				break;
			case IStatus.WARNING:
				setMessage(msg, IMessageProvider.WARNING);
				setErrorMessage(null);
				break;
			case IStatus.INFO:
				setMessage(msg, IMessageProvider.INFORMATION);
				setErrorMessage(null);
				break;
			default:
				setMessage(null);
				setErrorMessage(msg);
				break;
		}
	}
}
