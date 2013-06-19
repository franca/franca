package org.franca.tools.contracts.tracegen.strategies.selectors

import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.Trace
import java.util.HashMap
import com.google.common.collect.Iterables

class GloballyLimitedUseTransitionSelector implements TransitionSelector {
	
	HashMap<FTransition, Integer> visitCounter = newHashMap
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
		var int countTransitionsToMarkAsUnusable = possibilities.size
		for (FTransition transition : Iterables::cycle(possibilities)) {
			if (countTransitionsToMarkAsUnusable == 0)  return null;
			if (checkTransition(transition)) {
				return transition
			} else {
				countTransitionsToMarkAsUnusable = countTransitionsToMarkAsUnusable - 1
			}
		}
		return null
	}
	
	def boolean checkTransition(FTransition transition) {
		var Integer count = visitCounter.get(transition)
		if (count == null) {
			visitCounter.put(transition, 1)
			return true;
		} else if (count < limit) {
			visitCounter.remove(transition)
			visitCounter.put(transition, count + 1)
			return true;
		}
		return false;
	}
}