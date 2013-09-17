/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
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

/**
 * A trace parser is responsible to parse a stream of traces of a given Franca contract. 
 * It produces a {@link List} of {@link FEventOnIf} events. It is entirely the 
 * parser's responsibility to know the format of the serialized trace. 
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
@ImplementedBy(DefaultTraceParser.class)
public interface ITraceParser {
	
	/**
	 * Parses a serialized trace of the given Franca contract model.
	 * 
	 * @param model the Franca model
	 * @param inputStream the input stream
	 * @return the list of events
	 */
	public List<FEventOnIf> parseTrace(FModel model, InputStream inputStream);
	
}
