package org.franca.tools.contracts.tracegen.strategies.collect

import java.util.Collection
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.BehaviourAwareTrace
import org.franca.tools.contracts.tracegen.traces.Trace

class BehaviourAwareCollectTransitionsStrategy implements CollectTransitionsStrategy {
	
	override public Collection<FTransition> execute(Trace currentTrace) {
		val Collection<FTransition> result = newArrayList
		for (transition : currentTrace.currentState.transitions) {
			if (check(currentTrace, transition)) {
				result += transition
			}
		}
		return result
	}
	
	def dispatch boolean check(Trace currentTrace, FTransition transition) {
		throw new IllegalArgumentException;
	}
	
	def dispatch boolean check(BehaviourAwareTrace currentTrace, FTransition transition) {
		if (transition.guard == null) return true;
		
		val Object result = currentTrace.evaluate(transition.guard.condition)
		if (result instanceof Boolean) {
			return (result as Boolean)
		}
		return true; //TODO This might be dangerous!
	}
	
}