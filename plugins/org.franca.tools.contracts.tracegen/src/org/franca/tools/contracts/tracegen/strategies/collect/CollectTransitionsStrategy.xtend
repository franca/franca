package org.franca.tools.contracts.tracegen.strategies.collect

import java.util.Collection
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.Trace

interface CollectTransitionsStrategy {
	
	def public <T extends Trace> Collection<FTransition> execute(T currentTrace)
	
}