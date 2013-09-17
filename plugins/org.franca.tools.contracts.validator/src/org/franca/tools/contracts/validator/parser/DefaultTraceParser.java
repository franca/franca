/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
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

/**
 * The default trace parser can be used to parse traces from streams which were
 * generated with Steffen's trace generator. The parser creates a mapping between the 
 * name of the call/respond methods and signal broadcast of an event an the event itself. 
 * This mapping can be used during the parsing of the stream's contents.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public class DefaultTraceParser implements ITraceParser {

	private enum EventType {
		CALL, RESPOND, SIGNAL
	}
	
	private Map<EventType, Map<String, FEventOnIf>> initialize(FModel model) {
		Map<EventType, Map<String, FEventOnIf>> eventMap = new HashMap<DefaultTraceParser.EventType, Map<String,FEventOnIf>>();
		for (EventType type : EventType.values()) {
			eventMap.put(type, new HashMap<String, FEventOnIf>());			
		}
		
		for (FInterface _interface : model.getInterfaces()) {
			for (FState state : _interface.getContract().getStateGraph()
					.getStates()) {
				for (FTransition transition : state.getTransitions()) {
					FEventOnIf event = transition.getTrigger().getEvent();
					
					if (event.getCall() != null) {
						eventMap.get(EventType.CALL).put(event.getCall().getName(), event);						
					}
					else if (event.getRespond() != null) {
						eventMap.get(EventType.RESPOND).put(event.getRespond().getName(), event);
					}
					else if (event.getSignal() != null) {
						eventMap.get(EventType.SIGNAL).put(event.getSignal().getName(), event);
					}
				}
			}
		}

		return eventMap;
	}

	@Override
	public List<FEventOnIf> parseTrace(FModel model, InputStream inputStream) {
		Map<EventType, Map<String, FEventOnIf>> eventMap = initialize(model);

		InputStreamReader streamReader = null;
		BufferedReader bufferedReader = null;
		List<FEventOnIf> trace = new ArrayList<FEventOnIf>();
		try {
			streamReader = new InputStreamReader(inputStream);
			bufferedReader = new BufferedReader(streamReader);
			String line = null;
			while ((line = bufferedReader.readLine()) != null) {
				String[] tokens = line.split("_");
				if (tokens.length == 2) {
					trace.add(eventMap.get(EventType.valueOf(tokens[0].toUpperCase())).get(tokens[1]));
				}
			}
			return trace;
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
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
