/** 
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl

import com.google.inject.Binder
import com.google.inject.Singleton
import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.formatting.IFormatter
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider
import org.franca.deploymodel.dsl.formatting.FDeployFormatter
import org.franca.deploymodel.dsl.generator.internal.ImportManager
import org.franca.deploymodel.dsl.valueconverter.FDeployValueConverters

/** 
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class FDeployRuntimeModule extends AbstractFDeployRuntimeModule {
	override void configure(Binder binder) {
		super.configure(binder)
		binder.bind(ImportManager).in(Singleton)
	}

	// support importURI global scoping
	override Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
		return ImportUriGlobalScopeProvider
	}

	override Class<? extends IFormatter> bindIFormatter() {
		return FDeployFormatter
	}

	override Class<? extends IValueConverterService> bindIValueConverterService() {
		return FDeployValueConverters
	}
}
