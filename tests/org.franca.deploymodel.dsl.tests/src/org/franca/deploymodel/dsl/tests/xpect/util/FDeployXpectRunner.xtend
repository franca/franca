/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests.xpect.util

import org.franca.deploymodel.ext.providers.ProviderExtension
import org.franca.deploymodel.extensions.ExtensionRegistry
import org.junit.runners.model.InitializationError
import org.xpect.runner.XpectRunner
import org.junit.runner.notification.RunNotifier

class FDeployXpectRunner extends XpectRunner {
	
	new(Class<?> testClass) throws InitializationError {
		super(testClass)
	}

	override void run(RunNotifier notifier) {
		// for some of the tests we need the ProviderExtension
		ExtensionRegistry.addExtension(new ProviderExtension)		

		super.run(notifier)
		
		ExtensionRegistry.reset
	}
}
