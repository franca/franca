/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.search.regexp;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.franca.core.franca.FContract;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracevalidator.search.FrancaTraceElement;
import org.franca.tools.contracts.tracevalidator.search.TraceElement;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

/**
 * Helper methods to construct regular expressions for a given Franca contract. 
 * 
 * @author Tamas Szabo
 *
 */
public class RegexpBuilder {

	/**
	 * Constructs the regular expression that accepts the traces matching the
	 * given contract.
	 * 
	 * @param contract
	 *            the Franca contract for the interface
	 * @return the regular expression associated to the contract
	 */
	public static RegexpElement buildRegexp(FContract contract) {
		Set<FState> statesVisited = new HashSet<FState>();
		List<FState> statesToVisit = new LinkedList<FState>();
		FState initial = contract.getStateGraph().getInitial();
		statesToVisit.add(initial);
		Map<FState, Multimap<FState, TraceElement>> traceElementMap = new HashMap<FState, Multimap<FState, TraceElement>>();
		Set<TraceElement> traceElements = new HashSet<TraceElement>();
		int stateNum = contract.getStateGraph().getStates().size();
		List<FState> states = contract.getStateGraph().getStates();
		RegexpElement[][][] regexpArray = new RegexpElement[stateNum][stateNum][stateNum];

		// Create trace elements between the states of the contract's state
		// machine. The state machine must be strongly connected
		while (!statesToVisit.isEmpty()) {
			FState state = statesToVisit.remove(0);
			statesVisited.add(state);
			
			Multimap<FState, TraceElement> innerMap = ArrayListMultimap.create();
			
			for (FTransition transition : state.getTransitions()) {
				TraceElement traceElement = new FrancaTraceElement(state, transition);
				traceElements.add(traceElement);
				innerMap.put(transition.getTo(), traceElement);

				if (!statesVisited.contains(transition.getTo())) {
					statesToVisit.add(transition.getTo());
				}
			}

			traceElementMap.put(state, innerMap);
		}

		for (int i = 0; i < stateNum; i++) {
			for (int j = 0; j < stateNum; j++) {

				Collection<TraceElement> elements = traceElementMap.get(states.get(i)).get(states.get(j));
				if (elements != null) {
					Collection<RegexpElement> regexpElements = new ArrayList<RegexpElement>();
					for (TraceElement e : elements) {
						regexpElements.add(new SingleElement(e));
					}
					
					if (i != j) {
						regexpArray[i][j][0] = new OrElement(regexpElements.toArray(new RegexpElement[0]));	
					}
					else {
						regexpArray[i][j][0] = RegexpHelper.union(new OrElement(regexpElements.toArray(new RegexpElement[0])), EmptyElement.INSTANCE);
					}
				} else {
					regexpArray[i][j][0] = NullElement.INSTANCE;
				}
			}
		}
		
		if (states.size() > 0) {
			for (int k = 1; k < stateNum; k++) {
				for (int i = 0; i < stateNum; i++) {
					for (int j = 0; j < stateNum; j++) {
						regexpArray[i][j][k] = RegexpHelper.union(regexpArray[i][j][k-1], 
								RegexpHelper.and(RegexpHelper.and(regexpArray[i][k][k-1], RegexpHelper.closure(regexpArray[k][k][k-1])), regexpArray[k][j][k-1]));
					}
				}
			}
		}
		
		RegexpElement result = regexpArray[0][0][stateNum-1];
		
		if (states.size() > 1) {
			for (int i = 1; i < stateNum; i++) {
				result = RegexpHelper.union(result, regexpArray[0][i][stateNum-1]);
			}
		}
		//All states are accepting?
		return result;
	}

}
