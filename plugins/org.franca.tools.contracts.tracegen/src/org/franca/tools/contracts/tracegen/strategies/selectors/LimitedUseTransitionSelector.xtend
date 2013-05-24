package org.franca.tools.contracts.tracegen.strategies.selectors

import com.google.common.collect.Iterables
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.Trace

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
		
	override FTransition execute(Trace currentTrace, Iterable<FTransition> possibilities) {
		var statistics = currentTrace.getStatistics(currentTrace.currentState)
		if (statistics == null) {
			return possibilities.head
		}
		for (FTransition transition : possibilities) {
			if (statistics.getUses(transition) < limit) {
				return transition
			}
		}
		return null
	}
	
}