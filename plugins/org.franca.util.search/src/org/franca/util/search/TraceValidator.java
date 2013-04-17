package org.franca.util.search;

import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.WeakHashMap;

import org.franca.core.franca.FContract;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

/**
 * This utility class contains methods to check whether a given trace matches a Franca {@link FContract}.
 * 
 * @author Tamas Szabo
 *
 */
public class TraceValidator {

	/**
	 * Checks whether the given trace can be matched for the given Franca {@link FContract}.
	 * It is not necessary for the trace to start at the initial state of the {@link FContract}. 
	 * 
	 * @param contract the contract that defines the state machine
	 * @param trace the saved trace
	 * @return true if the trace is valid for the contract, false otherwise
	 */
	public static boolean isValidTrace(FContract contract, List<String> trace) {
		if (trace.size() == 0) {
			return true;
		}
		else {
			Map<String, Set<FTransition>> guessMap = constructGuessMap(contract);
			Set<Set<FTransition>> traceGroups = new HashSet<Set<FTransition>>();
			Set<Set<FTransition>> temporaryTraceGroups = new HashSet<Set<FTransition>>();
			Set<FTransition> initialGuess = guessMap.get(trace.get(0));
			
			if (trace.size() == 1) {
				return (initialGuess.size() > 0) ? true : false;
			}
			else {
				traceGroups.add(initialGuess);
				
				for (int i = 1;i<trace.size();i++) {
					temporaryTraceGroups.clear();
					Set<FTransition> guess = guessMap.get(trace.get(i));
					
					//Check if there are traces in the groups that match the current transition
					for (Set<FTransition> currentTraceGroup : traceGroups) {
						for (FTransition t : currentTraceGroup) {
							Set<FTransition> isect = intersection(t.getTo().getTransitions(), guess);
							if (!isect.isEmpty()) {
								temporaryTraceGroups.add(isect);
							}
						}
					}
					
					//No transition can be found that matches the actual trace element, it is not possible to follow further the execution steps
					if (temporaryTraceGroups.isEmpty()) {
						return false;
					}
					//Swap between tmp and actual groups
					else {
						traceGroups.clear();
						traceGroups.addAll(temporaryTraceGroups);
					}
				}
				
				//if no return happened so far then the trace is a valid one
				return true;
			}
		}
	}
	
	private static Set<FTransition> intersection(Collection<FTransition> left, Set<FTransition> right) {
		Set<FTransition> result = new HashSet<FTransition>();
		
		for (FTransition t : left) {
			if (right.contains(t)) {
				result.add(t);
			}
		}
		
		return result;
	}
	
	@SuppressWarnings("unused")
	private static boolean equalTransition(FTransition t1, FTransition t2) {
		return (getCallName(t1) == getCallName(t2) /*&& t1.getTo().equals(t2.getTo())*/);
	}
	
	private static String getCallName(FTransition transition) {
		return transition.getTrigger().getEvent().getCall().getName();
	}
	
	private static Map<String, Set<FTransition>> constructGuessMap(FContract contract) {
		Map<String, Set<FTransition>> guessMap = new WeakHashMap<String, Set<FTransition>>();
		
		for (FState state : contract.getStateGraph().getStates()) {
			for (FTransition transition : state.getTransitions()) {
				String key = getCallName(transition);
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
		
		return guessMap;
	}
}
