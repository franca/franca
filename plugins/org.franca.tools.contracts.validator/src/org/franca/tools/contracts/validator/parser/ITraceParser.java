/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.validator.parser;

import java.io.InputStream;
import java.util.List;

import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FModel;

import com.google.inject.ImplementedBy;

@ImplementedBy(DefaultTraceParser.class)
public interface ITraceParser {
	
	public List<FEventOnIf> parseTrace(FModel model, InputStream inputStream);
	
}
