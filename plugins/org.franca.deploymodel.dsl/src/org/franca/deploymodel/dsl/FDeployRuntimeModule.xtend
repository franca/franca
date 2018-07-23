/** 
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl

import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.formatting.IFormatter
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider
import org.eclipse.xtext.serializer.tokens.IValueSerializer
import org.franca.deploymodel.dsl.formatting.FDeployFormatter
import org.franca.deploymodel.dsl.serializer.FDeployValueSerializer
import org.franca.deploymodel.dsl.valueconverter.FDeployValueConverters

/** 
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class FDeployRuntimeModule extends AbstractFDeployRuntimeModule {

	// support importURI global scoping
	override Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
		ImportUriGlobalScopeProvider
	}

//    override Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
//        FDeployDeclarativeNameProvider
//    }

	override Class<? extends IFormatter> bindIFormatter() {
		FDeployFormatter
	}

	override Class<? extends IValueConverterService> bindIValueConverterService() {
		FDeployValueConverters
	}

	def Class<? extends IValueSerializer> bindIValueSerializer() {
		FDeployValueSerializer
	}
}
