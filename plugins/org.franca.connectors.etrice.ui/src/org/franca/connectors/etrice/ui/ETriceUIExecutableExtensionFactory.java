package org.franca.connectors.etrice.ui;

import org.franca.core.dsl.ui.FrancaIDLExecutableExtensionFactory;
import org.franca.core.dsl.ui.internal.FrancaIDLActivator;
import org.osgi.framework.Bundle;

import com.google.inject.Injector;

public class ETriceUIExecutableExtensionFactory extends FrancaIDLExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return Activator.getDefault().getBundle();
	}

	@Override
	protected Injector getInjector() {
		return Activator.getDefault().getInjector();
	}
}
