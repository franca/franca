package org.franca.core.ui.addons.contractviewer.util;

import org.franca.core.dsl.ui.FrancaIDLExecutableExtensionFactory;
import org.franca.core.ui.addons.contractviewer.Activator;
import org.osgi.framework.Bundle;

public class ContractViewerExecutableExtensionFactory extends FrancaIDLExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return Activator.getDefault().getBundle();
	}
}