package org.franca.connectors.c_header.ui;

import org.franca.core.dsl.ui.FrancaIDLExecutableExtensionFactory;
import org.osgi.framework.Bundle;

public class CHeaderUIExecutableExtensionFactory extends FrancaIDLExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return Activator.getDefault().getBundle();
	}
}
