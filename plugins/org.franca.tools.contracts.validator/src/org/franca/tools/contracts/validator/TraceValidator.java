/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.validator;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.WeakHashMap;

import org.franca.core.franca.FContract;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

import com.google.common.collect.Sets;

/**
 * This utility class contains methods to check whether a given trace matches a Franca {@link FContract}.
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public class TraceValidator {

	/**
	 * Checks whether the given trace can be matched for the given Franca {@link FContract}.
	 * It is not necessary for the trace to start at the initial state of the {@link FContract}.
	 * 
	 * @param contract the contract that defines the state machine
	 * @param trace the saved trace as a list of set of events
	 * @return the validation result
	 */
	public static TraceValidationResult isValidTrace(FContract contract, List<Set<FEventOnIf>> trace) {
		return isValidTrace0(contract, trace, null);
	}
	
	/**
	 * Checks whether the given trace can be matched for the given Franca {@link FContract}.
	 * It is not necessary for the trace to start at the initial state of the {@link FContract}.
	 * 
	 * @param contract the contract that defines the state machine
	 * @param trace the saved trace as a list of events
	 * @return the validation result
	 */
	public static TraceValidationResult isValidTracePure(FContract contract, List<FEventOnIf> trace) {
		return isValidTrace0(contract, trace, null);
	}
	
	/**
	 * Checks whether the given trace can be matched for the given Franca {@link FContract} 
	 * where the initial set of trace groups (for the first trace element) is also provided.
	 * It is not necessary for the trace to start at the initial state of the {@link FContract}.
	 * 
	 * @param contract the contract that defines the state machine 
	 * @param trace the saved trace as a list of events
	 * @param initialTraceGroup the set of initial trace groups
	 * @return the validation result
	 */
	public static TraceValidationResult isValidTrace(FContract contract, List<Set<FEventOnIf>> trace, Set<Set<FTransition>> initialTraceGroup) {
		return isValidTrace0(contract, trace, initialTraceGroup);
	}
	
	private static TraceValidationResult isValidTrace0(FContract contract, List<? extends Object> trace, Set<Set<FTransition>> initialTraceGroup) {
		if (trace.size() == 0) {
			return TraceValidationResult.TRUE;
		}
		else {			
			Map<FEventOnIf, Set<FTransition>> guessMap = constructGuessMap(contract);
			
			// one set inside the set corresponds to a given execution path (possible transition along one path)
			// it always holds that the starting state of the transitions inside a set is the same
			Set<Set<FTransition>> traceGroups = new HashSet<Set<FTransition>>();
			
			// to store the trace groups temporarily for the next trace element 
			// the elements correspond to different elements of paths but on the same level 
			Set<Set<FTransition>> temporaryTraceGroups = new HashSet<Set<FTransition>>();
			
			Set<FTransition> expected = new HashSet<FTransition>();
			
			if (trace.size() == 1) {
				Set<FEventOnIf> events = normalizeEvents(trace.get(0));
				if (initialTraceGroup == null) {
					for (FEventOnIf event : events) {
						traceGroups.add(guessMap.get(event));
					}
					// if the trace contains only one element, the trace is always valid (suppose that the trace belongs the the contract)
					return new TraceValidationResult(true, traceGroups);					
				}
				else {
					for (FEventOnIf event : events) {
						fun0(event, guessMap, new HashSet<FTransition>(), initialTraceGroup, temporaryTraceGroups);
					}
					if (temporaryTraceGroups.isEmpty()) {
						return new TraceValidationResult(false, expected, 0, temporaryTraceGroups);
					}
					else {
						return new TraceValidationResult(true, temporaryTraceGroups);
					}
				}
			}
			
			// initialize trace groups
			if (initialTraceGroup == null) {
				for (FEventOnIf event : normalizeEvents(trace.get(0))) {
					traceGroups.add(guessMap.get(event));					
				}
			}
			else {
				traceGroups.addAll(initialTraceGroup);
			}

			for (int i = 1; i < trace.size(); i++) {
				expected.clear();
				for (FEventOnIf event : normalizeEvents(trace.get(i))) {
					fun0(event, guessMap, expected, traceGroups, temporaryTraceGroups);
				}
				
				// No transition can be found that matches the actual trace
				// element, it is not possible to follow further the execution
				// steps
				if (temporaryTraceGroups.isEmpty()) {
					return new TraceValidationResult(false, expected, i, null);
				}
				
				// Swap between temporary and actual groups
				traceGroups.clear();
				traceGroups.addAll(temporaryTraceGroups);
				temporaryTraceGroups.clear();
			}

			// if we reached this statement then the trace is a valid one
			return new TraceValidationResult(true, traceGroups);
		}
	}
	
	private static void fun0(
			FEventOnIf event, 
			Map<FEventOnIf, Set<FTransition>> guessMap, 
			Set<FTransition> expected, 
			Set<Set<FTransition>> traceGroups, 
			Set<Set<FTransition>> temporaryTraceGroups
		) {
		Set<FTransition> guess = guessMap.get(event);
		expected.addAll(guess);
		// check whether we can follow the execution on any path
		for (Set<FTransition> transitions : traceGroups) {
			for (FTransition transition : transitions) {
				Set<FTransition> isect = intersection(transition.getTo().getTransitions(), guess);
				// only add the new element if it contains at least one element
				// empty set indicates that the path cannot be followed
				if (!isect.isEmpty()) {
					temporaryTraceGroups.add(isect);
				}
			}						
		}
	}
	
	@SuppressWarnings("unchecked")
	private static Set<FEventOnIf> normalizeEvents(Object obj) {
		if (obj instanceof FEventOnIf) {
			return Sets.newHashSet((FEventOnIf) obj);
		}
		else {
			// it is guaranteed that in this case the type is Set<FEventOnIf>
			return (Set<FEventOnIf>) obj;
		}
	}
	
	private static Set<FTransition> intersection(Collection<FTransition> left, Set<FTransition> right) {
		Set<FTransition> result = new HashSet<FTransition>(left);
		result.retainAll(right);
		return result;
	}
	
	private static Map<FContract, Map<FEventOnIf, Set<FTransition>>> guessMapCache = new HashMap<FContract, Map<FEventOnIf,Set<FTransition>>>();
	
	/**
	 * Returns a map where the keys will be the events and the values are those transitions 
	 * which can be triggered by the given event.
	 * 
	 * @param contract the interface definition 
	 * @return the a map projecting the events to the triggered transitions
	 */
	private static Map<FEventOnIf, Set<FTransition>> constructGuessMap(FContract contract) {
		if (!guessMapCache.containsKey(contract)) {
			Map<FEventOnIf, Set<FTransition>> guessMap = new WeakHashMap<FEventOnIf, Set<FTransition>>();
			
			for (FState state : contract.getStateGraph().getStates()) {
				for (FTransition transition : state.getTransitions()) {
					FEventOnIf key = transition.getTrigger().getEvent();
					//String key = getCallName(transition);
					if (guessMap.get(key) == null) {
						Set<FTransition> transitions = new HashSet<FTransition>();
						transitions.add(transition);
						guessMap.put(key, transitions);
					}
					else {
						guessMap.get(key).add(transition);
					}
				}
			}
			guessMapCache.put(contract, guessMap);
		}
		return guessMapCache.get(contract);
	}
}
