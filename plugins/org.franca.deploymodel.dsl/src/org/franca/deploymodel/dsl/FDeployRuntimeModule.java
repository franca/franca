/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl;

import org.eclipse.xtext.conversion.IValueConverterService;
import org.eclipse.xtext.conversion.impl.AbstractIDValueConverter;
import org.franca.deploymodel.dsl.generator.internal.ImportManager;
import org.franca.deploymodel.dsl.valueconverter.FDeployValueConverters;

import com.google.inject.Binder;
import com.google.inject.Singleton;

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class FDeployRuntimeModule extends AbstractFDeployRuntimeModule {

	@Override
	public void configure(Binder binder) {
		super.configure(binder);
		binder.bind(ImportManager.class).in(Singleton.class);
	}

	@Override
	public Class<? extends IValueConverterService> bindIValueConverterService() {
		return FDeployValueConverters.class;
	}
}
