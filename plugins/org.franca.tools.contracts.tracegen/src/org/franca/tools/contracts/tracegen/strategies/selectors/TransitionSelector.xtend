package org.franca.tools.contracts.tracegen.strategies.selectors

import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.Trace

interface TransitionSelector {
	
	def FTransition execute(Trace currentTrace, Iterable<FTransition> possibilities)
	
}