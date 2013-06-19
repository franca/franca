package org.franca.tools.contracts.tracegen.strategies.collect

import java.util.ArrayList
import java.util.Collection
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.Trace

class SimpleCollectTransitionsStrategy implements CollectTransitionsStrategy {
	
	override public Collection<FTransition> execute(Trace currentTrace) {
		new ArrayList<FTransition>(currentTrace.currentState.transitions)
	}
}