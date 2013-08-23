/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies.selectors

import org.eclipse.xtext.xbase.lib.Pair
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.strategies.events.EventData
import org.franca.tools.contracts.tracegen.traces.Trace
import java.util.Collections

class LimitedUseTransitionSelector implements TransitionSelector {
	
	int limit;
	
	new () {
		this(null);
	}
	
	new (Integer limit) {
		if (limit == null) {
			this.limit = 10
		} else {
			this.limit = limit
		}
	}
		
	override execute(Trace currentTrace, Iterable<Pair<FTransition, Iterable<EventData>>> possibilities) {
		if (possibilities.nullOrEmpty) {
			return null
		}

		val shuffledPossibilities = newArrayList
		shuffledPossibilities.addAll(possibilities)
		Collections::shuffle(shuffledPossibilities)
		
		var statistics = currentTrace.getStatistics(currentTrace.currentState)
		if (statistics == null) {
			return new Pair(shuffledPossibilities.head.key, shuffledPossibilities.head.value.head)
		}
		
		
		for (possibility : shuffledPossibilities) {
			if (statistics.getNumberOfUses(possibility.key) < limit) {
				return new Pair(possibility.key, possibility.value.head)
			}
		}
		return null
	}
	
}