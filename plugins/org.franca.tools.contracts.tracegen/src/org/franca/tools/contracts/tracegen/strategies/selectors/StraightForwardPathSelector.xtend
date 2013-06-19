package org.franca.tools.contracts.tracegen.strategies.selectors

import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.Trace

class StraightForwardPathSelector implements TransitionSelector {
	
	override FTransition execute(Trace currentTrace, Iterable<FTransition> possibilities) {
		for (FTransition transition : possibilities) {
			if (! currentTrace.contains(transition)) {
				return transition
			}
		}
		return null
	}
}