/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.validator.parser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

public class DefaultTraceParser implements ITraceParser {
	
	private Map<String, FEventOnIf> initialize(FModel model) {
		Map<String, FEventOnIf> eventMap = new HashMap<String, FEventOnIf>();
		
		for (FInterface _interface : model.getInterfaces()) {
			for (FState state : _interface.getContract().getStateGraph().getStates()) {
				for (FTransition transition : state.getTransitions()) {
					FEventOnIf event = transition.getTrigger().getEvent();
					eventMap.put(event.getCall().getName(), event);
				}
			}
		}
		
		return eventMap;
	}

	@Override
	public List<FEventOnIf> parseTrace(FModel model, InputStream inputStream) {
		Map<String, FEventOnIf> eventMap = initialize(model);
		
		InputStreamReader streamReader = null;
		BufferedReader bufferedReader = null;
		List<FEventOnIf> trace = new ArrayList<FEventOnIf>();
		try {
			streamReader = new InputStreamReader(inputStream);
			bufferedReader = new BufferedReader(streamReader);
			String line = null;
			while ((line = bufferedReader.readLine()) != null) {
				trace.add(eventMap.get(line));
			}
			return trace;
		} catch (IOException e) {
			e.printStackTrace();
		}
		finally {
			if (streamReader != null) {
				try {
					streamReader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (bufferedReader != null) {
				try {
					bufferedReader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return null;
	}

}
