/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.parser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

/**
 * The default trace parser can be used to parse traces from streams which were
 * generated with Franca's trace generator. The parser creates a mapping between the 
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
	
	Map<FModel, Map<EventType, Multimap<String, FEventOnIf>>> eventMapCache = new HashMap<FModel, Map<EventType,Multimap<String,FEventOnIf>>>();
	
	private void initialize(FModel model) {
		Map<EventType, Multimap<String, FEventOnIf>> eventMap = new HashMap<DefaultTraceParser.EventType, Multimap<String,FEventOnIf>>();
		for (EventType type : EventType.values()) {
			Multimap<String, FEventOnIf> map = ArrayListMultimap.create();
			eventMap.put(type, map);			
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

		eventMapCache.put(model, eventMap);
	}

	@Override
	public List<Set<FEventOnIf>> parseAll(FModel model, InputStream inputStream) {
		InputStreamReader streamReader = null;
		BufferedReader bufferedReader = null;
		List<Set<FEventOnIf>> trace = new ArrayList<Set<FEventOnIf>>();
		try {
			streamReader = new InputStreamReader(inputStream);
			bufferedReader = new BufferedReader(streamReader);
			String line = null;
			while ((line = bufferedReader.readLine()) != null) {
				Set<FEventOnIf> element = parseSingle(model, line);
				if (element != null) {
					trace.add(element);
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

	@Override
	public Set<FEventOnIf> parseSingle(FModel model, String traceElement) {
		if (!eventMapCache.containsKey(model)) {
			initialize(model);
		}
		
		Map<EventType, Multimap<String, FEventOnIf>> eventMap = eventMapCache.get(model);
		Set<FEventOnIf> events = new HashSet<FEventOnIf>();
		String[] tokens = traceElement.split("_");
		if (tokens.length == 2) {
			Collection<FEventOnIf> value = eventMap.get(EventType.valueOf(tokens[0].toUpperCase())).get(tokens[1]);
			if (!value.isEmpty()) {
				events.addAll(value);
				return Collections.unmodifiableSet(events);
			}
		}
		return null;
	}

}
