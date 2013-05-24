package org.franca.tools.contracts.tracegen

import java.util.Collection
import java.util.HashSet
import org.franca.core.franca.FState
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.strategies.DefaultStrategyCollection
import org.franca.tools.contracts.tracegen.strategies.StrategyCollection
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.traces.BehaviourAwareTrace
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector

class TraceGenerator {
	
	HashSet<FTransition> transitionsATraceStartedWith = newHashSet
	CollectTransitionsStrategy collector
	TransitionSelector selector
	
	new() {
		this(null)
	}
	
	new (StrategyCollection strategies) {
		val StrategyCollection localStrategies = 
			if (strategies == null) new DefaultStrategyCollection else strategies 
		
		collector = localStrategies.collectTransitionsStrategy
		selector = localStrategies.pathSelector
	}
	
	def public simulate(FState startingState) {
		val startingTrace = new BehaviourAwareTrace(startingState);
		val Collection<BehaviourAwareTrace> traces = newHashSet

		val Collection<FTransition> possibleTransitions = collector.execute(startingTrace)
		val FTransition nextTransition = selector.execute(startingTrace, possibleTransitions)
		startTrace(startingTrace, nextTransition, traces)
		
		return traces
	}
	
	def private startTrace(BehaviourAwareTrace trace, FTransition nextTransition, Collection<BehaviourAwareTrace> traces) {
		traces += trace
		trace.use(nextTransition)
		this.transitionsATraceStartedWith += nextTransition
		
		simulate(trace, traces)
	}
	
	def private simulate(BehaviourAwareTrace trace, Collection<BehaviourAwareTrace> traces) {
		var Collection<FTransition> possibleTransitions = collector.execute(trace)
		var FTransition nextTransition = selector.execute(trace, possibleTransitions)
		while (nextTransition != null) {
			trace.use(nextTransition)
			possiblyStartNewTraces(trace, nextTransition, possibleTransitions, traces)
			possibleTransitions = collector.execute(trace)
			nextTransition = selector.execute(trace, possibleTransitions)
		}
	}
	
	def void possiblyStartNewTraces(BehaviourAwareTrace currentTrace, FTransition lastTransition, Collection<FTransition> possibleTransitions, Collection<BehaviourAwareTrace> traces) {
		if (traces.size >= 1000) {return;}
		
		for (next : possibleTransitions) {
			if (! next.equals(lastTransition) && !this.transitionsATraceStartedWith.contains(next)) {
				// TODO:
				// right now each transition starts one trace. improve this! 
				startTrace(new BehaviourAwareTrace(currentTrace), next, traces)
			}
		}
	}
	
//	def public Iterable<Trace> simulate(FState state) {
//		val Trace startingTrace = new BehaviourAwareTrace(state)
//		val result = newArrayList(startingTrace);
//		result += simulate(startingTrace, state)
//		return result
//	}
//	
//	def private Iterable<Trace> simulate(Trace currentTrace, FState state) {
//		val additionalTraces = <Trace>newArrayList
//		var workingTrace = currentTrace
//		
//		val possibleTransitions = pcc.execute(workingTrace, state)
//			reduceStrategy.reduce(possibleTransitions, state, workingTrace)			
//		var nextTransition = selector.execute(workingTrace, possibleTransitions)
//		
//		while (nextTransition != null) {
//			val nextState = walk(currentTrace, nextTransition)
//			additionalTraces += simulate(workingTrace, nextState)
//			nextTransition = selector.execute(workingTrace, possibleTransitions)
//			if (nextTransition != null) {
//				workingTrace = new BehaviourAwareTrace(currentTrace as BehaviourAwareTrace)
//				additionalTraces += workingTrace
//			}
//		}
//		return additionalTraces
//	}
//	
//	def private FState walk(Trace currentTrace, FTransition transition) {
//		currentTrace.use(transition)
//		return transition.getTo()
//	}
}