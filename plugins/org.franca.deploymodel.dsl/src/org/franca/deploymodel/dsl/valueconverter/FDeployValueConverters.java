/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.valueconverter;

import org.eclipse.xtext.common.services.DefaultTerminalConverters;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.impl.AbstractIDValueConverter;

import com.google.inject.Inject;

public class FDeployValueConverters extends DefaultTerminalConverters {

	@ValueConverter(rule = "FQN")
	public IValueConverter<String> FQN() {
		return ID();
	}

	@ValueConverter(rule = "FQN_WITH_SELECTOR")
	public IValueConverter<String> FQN_WITH_SELECTOR() {
		return ID();
	}
}
