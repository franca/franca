package org.franca.connectors.dbus.ui;

import org.franca.core.dsl.ui.FrancaIDLExecutableExtensionFactory;
import org.osgi.framework.Bundle;

public class DBusUIExecutableExtensionFactory extends FrancaIDLExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return Activator.getDefault().getBundle();
	}
}
