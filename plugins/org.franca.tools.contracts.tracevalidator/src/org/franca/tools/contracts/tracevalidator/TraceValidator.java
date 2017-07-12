/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.WeakHashMap;

import org.franca.core.contracts.FEventUtils;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

import com.google.common.collect.Sets;

/**
 * This utility class contains methods to check whether a given trace matches a
 * Franca {@link FContract}.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public class TraceValidator {

	/**
	 * Checks whether the given trace can be matched against the given Franca
	 * {@link FContract}. It is not necessary for the trace to start at the
	 * initial state of the {@link FContract}.
	 * 
	 * @param contract
	 *            the contract that defines the state machine
	 * @param trace
	 *            the saved trace as a list of set of events
	 * @return the validation result
	 */
	public static TraceValidationResult isValidTrace(FContract contract,
			List<Set<FEventOnIf>> trace) {
		return isValidTrace0(contract, null, trace.toArray());
	}

	/**
	 * Checks whether the given trace element can be matched against the given
	 * Franca {@link FContract}. The validity of a single trace element can be
	 * defined in respect to to the initial trace group as follows: <br/>
	 * - if the initial trace group is null, then the trace element is valid if
	 * transitions can be mapped to the given event <br/>
	 * - if the initial trace group is not null, then the transitions mapped to
	 * the event must have at least one common transition with at least one
	 * trace group (this means that the program execution can be continued on
	 * the given path)
	 * 
	 * @param contract
	 *            the contract that defines the state machine
	 * @param traceElement
	 *            the saved trace element as a set of events
	 * @param initialTraceGroup
	 *            the set of initial trace groups
	 * @return the validation result
	 */
	public static TraceValidationResult isValidTrace(FContract contract,
			Set<FEventOnIf> traceElement,
			Set<Set<FTransition>> initialTraceGroup) {
		return isValidTrace0(contract, initialTraceGroup, traceElement);
	}

	/**
	 * Checks whether the given trace can be matched against the given Franca
	 * {@link FContract}. It is not necessary for the trace to start at the
	 * initial state of the {@link FContract}.
	 * 
	 * @param contract
	 *            the contract that defines the state machine
	 * @param trace
	 *            the saved trace as a list of events
	 * @return the validation result
	 */
	public static TraceValidationResult isValidTracePure(FContract contract,
			List<FEventOnIf> trace) {
		return isValidTrace0(contract, null, trace.toArray());
	}

	/**
	 * Checks whether the given trace can be matched against the given Franca
	 * {@link FContract} where the initial set of trace groups (for the first
	 * trace element) is also provided. It is not necessary for the trace to
	 * start at the initial state of the {@link FContract}.
	 * 
	 * @param contract
	 *            the contract that defines the state machine
	 * @param initialTraceGroup
	 *            the set of initial trace groups
	 * @param trace
	 *            the saved trace as a var arg of events
	 * @return the validation result
	 */
	public static TraceValidationResult isValidTrace(FContract contract,
			List<Set<FEventOnIf>> trace, Set<Set<FTransition>> initialTraceGroup) {
		return isValidTrace0(contract, initialTraceGroup, trace.toArray());
	}

	private static TraceValidationResult isValidTrace0(FContract contract,
			Set<Set<FTransition>> initialTraceGroup, Object... trace) {
		if (trace.length == 0) {
			return new TraceValidationResult(false, null);
		} else {
			Map<EventWrapper, Set<FTransition>> guessMap = constructGuessMap(contract);

			// one set inside the set corresponds to a given execution path
			// (possible transition along one path)
			// it always holds that the starting state of the transitions inside
			// a set is the same
			Set<Set<FTransition>> traceGroups = new HashSet<Set<FTransition>>();

			// to store the trace groups temporarily for the next trace element
			// the elements correspond to different elements of paths but on the
			// same level
			Set<Set<FTransition>> temporaryTraceGroups = new HashSet<Set<FTransition>>();

			Set<FTransition> expected = new HashSet<FTransition>();

			if (trace.length == 1) {
				Set<EventWrapper> events = wrap(trace[0]);
				if (initialTraceGroup == null) {
					for (EventWrapper event : events) {
						Set<FTransition> guess = guessMap.get(event);
						if (guess==null) {
							System.err.println("TraceValidator warning 001: " +
									"Event " + FEventUtils.getEventID(event.event) + " not found in guessMap!");
							System.out.println("GuessMap: #cached_maps: " + guessMapCache.size() +
									" #events in current: " + guessMap.size());
						} else {
							traceGroups.add(guess);
						}
					}
					// if the trace contains only one element and 
					// the initial trace group is null, then the trace is
					// always valid (suppose that the trace belongs the the
					// contract)
					return new TraceValidationResult(true, traceGroups);
				} else {
					for (EventWrapper event : events) {
						fun0(event, guessMap, expected,
								initialTraceGroup, temporaryTraceGroups);
					}
					if (temporaryTraceGroups.isEmpty()) {
						return new TraceValidationResult(false, expected, 0,
								null);
					} else {
						return new TraceValidationResult(true,
								temporaryTraceGroups);
					}
				}
			}

			// initialize trace groups
			if (initialTraceGroup == null) {
				for (EventWrapper event : wrap(trace[0])) {
					traceGroups.add(guessMap.get(event));
				}
			} else {
				traceGroups.addAll(initialTraceGroup);
			}

			for (int i = 1; i < trace.length; i++) {
				expected.clear();
				for (EventWrapper event : wrap(trace[i])) {
					fun0(event, guessMap, expected, traceGroups,
							temporaryTraceGroups);
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

	private static void fun0(EventWrapper event,
			Map<EventWrapper, Set<FTransition>> guessMap,
			Set<FTransition> expected, Set<Set<FTransition>> traceGroups,
			Set<Set<FTransition>> temporaryTraceGroups) {
		Set<FTransition> guess = guessMap.get(event);
		if (guess==null) {
			System.err.println("TraceValidator warning 002: " +
					"Event " + FEventUtils.getEventID(event.event) + " not found in guessMap!");
			System.out.println("GuessMap: #cached_maps: " + guessMapCache.size() +
					" #events in current: " + guessMap.size());
		}
		
		// check whether we can follow the execution on any path
		for (Set<FTransition> transitions : traceGroups) {
			for (FTransition transition : transitions) {
				expected.addAll(transition.getTo().getTransitions());
				if (guess!=null) {
					// if guess==null, the intersection will always be empty
					Set<FTransition> isect = intersection(transition.getTo()
							.getTransitions(), guess);
					// only add the new element if it contains at least one element
					// empty set indicates that the path cannot be followed
					if (!isect.isEmpty()) {
						temporaryTraceGroups.add(isect);
					}
				}
			}
		}
	}

	@SuppressWarnings("unchecked")
	private static Set<EventWrapper> wrap(Object obj) {
		Set<EventWrapper> events = Sets.newHashSet();
		if (obj instanceof FEventOnIf) {
			events.add(wrap((FEventOnIf) obj));
		} else {
			// it is guaranteed that in this case the type is Set<FEventOnIf>
			for (FEventOnIf event : (Set<FEventOnIf>) obj) {
				events.add(wrap(event));
			}	
		}
		return events;
	}
	
	private static EventWrapper wrap(FEventOnIf event) {
		return new EventWrapper(event);
	}

	private static Set<FTransition> intersection(Collection<FTransition> left,
			Set<FTransition> right) {
		Set<FTransition> result = new HashSet<FTransition>(left);
		result.retainAll(right);
		return result;
	}

	private static Map<FContract, Map<EventWrapper, Set<FTransition>>> guessMapCache = new HashMap<FContract, Map<EventWrapper, Set<FTransition>>>();

	/**
	 * Returns a map where the keys will be the events and the values are those
	 * transitions which can be triggered by the given event.
	 * 
	 * @param contract
	 *            the interface definition
	 * @return a map projecting the events to the triggered transitions
	 */
	private static Map<EventWrapper, Set<FTransition>> constructGuessMap(
			FContract contract) {
		if (!guessMapCache.containsKey(contract)) {
			Map<EventWrapper, Set<FTransition>> guessMap = new WeakHashMap<EventWrapper, Set<FTransition>>();

			for (FState state : contract.getStateGraph().getStates()) {
				for (FTransition transition : state.getTransitions()) {
					EventWrapper key = wrap(transition.getTrigger().getEvent());
					
					// String key = getCallName(transition);
					if (guessMap.get(key) == null) {
						Set<FTransition> transitions = new HashSet<FTransition>();
						transitions.add(transition);
						guessMap.put(key, transitions);
					} else {
						guessMap.get(key).add(transition);
					}
				}
			}
			guessMapCache.put(contract, guessMap);
		}
		return guessMapCache.get(contract);
	}
	
	/**
	 * The wrapper is used to specify a custom equals and hashCode implementation for the {@link FEventOnIf} instances.
	 * 
	 * @author Tamas Szabo (itemis AG)
	 */
	private static class EventWrapper {
		
		private FEventOnIf event;
		
		public EventWrapper(FEventOnIf event) {
			this.event = event;
		}
		
		@Override
		public boolean equals(Object obj) {
			if (obj == null || obj.getClass() != this.getClass()) {
				return false;
			}
			else if (obj == this) {
				return true;
			}
			else {
				EventWrapper that = (EventWrapper) obj;
				return 
				(this.event.getCall() != null && that.event.getCall() != null) ? this.event.getCall().equals(that.event.getCall()) : true &&
				(this.event.getRespond() != null && that.event.getRespond() != null) ? this.event.getRespond().equals(that.event.getRespond()) : true &&
				(this.event.getError() != null && that.event.getError() != null) ? this.event.getError().equals(that.event.getError()) : true &&
				(this.event.getSignal() != null && that.event.getSignal() != null) ? this.event.getSignal().equals(that.event.getSignal()) : true &&
				(this.event.getSet() != null && that.event.getSet() != null) ? this.event.getSet().equals(that.event.getSet()) : true &&
				(this.event.getUpdate() != null && that.event.getUpdate() != null) ? this.event.getUpdate().equals(that.event.getUpdate()) : true;
			}
		}
		
		@Override
		public int hashCode() {
			int hash = 1;
	        hash = hash * 17 + ((event.getCall() != null) ? event.getCall().hashCode() : 1);
	        hash = hash * 31 + ((event.getRespond() != null) ? event.getRespond().hashCode() : 1);
	        hash = hash * 19 + ((event.getError() != null) ? event.getError().hashCode() : 1);
	        hash = hash * 13 + ((event.getSignal() != null) ? event.getSignal().hashCode() : 1);
	        hash = hash * 17 + ((event.getSet() != null) ? event.getSet().hashCode() : 1);
	        hash = hash * 31 + ((event.getUpdate() != null) ? event.getUpdate().hashCode() : 1);
	        return hash;
		}
		
	}
}
