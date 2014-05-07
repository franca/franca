/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.parser;

import java.io.InputStream;
import java.util.List;
import java.util.Set;

import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FModel;

import com.google.inject.ImplementedBy;

/**
 * A trace parser is responsible to parse a stream of traces of a given Franca
 * contract. It produces a {@link List} of {@link Set}s {@link FEventOnIf}
 * events. It is entirely the parser's responsibility to know the format of the
 * serialized trace.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
@ImplementedBy(DefaultTraceParser.class)
public interface ITraceParser {

	/**
	 * Parses a serialized trace of the given Franca contract model. For each
	 * trace element there may belong one or more corresponding event (it is
	 * possible that one cannot make a unique guess about the actual event,
	 * because other events have also the same signature), these are collected
	 * in a set. The parser may make a unique guess from this set, in this case,
	 * the set should only contain one element.
	 * 
	 * @param model
	 *            the Franca model
	 * @param inputStream
	 *            the input stream
	 * @return the the list of sets of possible events
	 */
	public List<Set<FEventOnIf>> parseAll(FModel model, InputStream inputStream);

	/**
	 * Parses one serialized trace element of the given Franca contract model.
	 * For the given trace element there may belong one or more corresponding
	 * event (it is possible that one cannot make a unique guess about the
	 * actual event, because other events have also the same signature), these
	 * are collected in a set. The parser may make a unique guess from this set,
	 * in this case, the set should only contain one element.
	 * 
	 * @param model
	 *            the Franca model
	 * @param traceElement
	 *            the trace element
	 * @return the set of possible events
	 */
	public Set<FEventOnIf> parseSingle(FModel model, String traceElement);

}
