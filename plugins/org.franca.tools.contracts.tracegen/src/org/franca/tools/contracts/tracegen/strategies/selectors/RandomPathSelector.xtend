package org.franca.tools.contracts.tracegen.strategies.selectors

import org.franca.tools.contracts.tracegen.traces.Trace
import org.franca.core.franca.FTransition

class RandomPathSelector implements TransitionSelector {
	
	override execute(Trace currentTrace, Iterable<FTransition> possibilities) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}