/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen

import java.util.Collection
import java.util.HashMap
import java.util.List
import org.eclipse.xtext.xbase.lib.Pair
import org.franca.core.franca.FState
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.strategies.DefaultStrategyCollection
import org.franca.tools.contracts.tracegen.strategies.StrategyCollection
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.strategies.events.EventData
import org.franca.tools.contracts.tracegen.strategies.events.TriggerSimualtionStrategy
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector
import org.franca.tools.contracts.tracegen.traces.BehaviourAwareTrace

class TraceGenerator {
	
	HashMap<FTransition, List<EventData>> traceStartingData = newHashMap
	CollectTransitionsStrategy collector
	TransitionSelector selector
	TriggerSimualtionStrategy triggersim
	
	new() {
		this(null)
	}
	
	new (StrategyCollection strategies) {
		val StrategyCollection localStrategies = 
			if (strategies == null) new DefaultStrategyCollection else strategies 
		
		collector = localStrategies.collectTransitionsStrategy
		selector = localStrategies.pathSelector
		triggersim = localStrategies.triggerSimulator
	}
	
	def public simulate(FState startingState) {
		val startingTrace = new BehaviourAwareTrace(startingState);
		val Collection<BehaviourAwareTrace> traces = newHashSet

		val Collection<Pair<FTransition, Iterable<EventData>>> possibleTransitions = collector.execute(startingTrace)
		val nextStep = selector.execute(startingTrace, possibleTransitions)
		startTrace(startingTrace, nextStep, traces)
		
		return traces
	}
	
	def private startTrace(BehaviourAwareTrace trace, Pair<FTransition, EventData> nextStep, Collection<BehaviourAwareTrace> traces) {
		traces += trace
		trace.use(nextStep.key, nextStep.value)
		var startingData = this.traceStartingData.get(nextStep.key)
		if (startingData == null) {
			startingData = newArrayList(nextStep.value)
			this.traceStartingData.put(nextStep.key, startingData)
		} else {
			startingData += nextStep.value
		}
		
		simulate(trace, traces)
	}
	
	def private simulate(BehaviourAwareTrace trace, Collection<BehaviourAwareTrace> traces) {
		var possibleSteps = collector.execute(trace)
		var nextStep = selector.execute(trace, possibleSteps)
		while (nextStep != null) {
			if (trace.currentState.name.equals("ReqCancel") && !nextStep.key.to.name.equals("Idle")) {
				println("bullshit")
			}
			possiblyStartNewTraces(trace, nextStep.value, possibleSteps, traces)
			trace.use(nextStep.key, nextStep.value)
			possibleSteps = collector.execute(trace)
			nextStep = selector.execute(trace, possibleSteps)
		}
	}
	
	def void possiblyStartNewTraces(
		BehaviourAwareTrace currentTrace,
		EventData latestUsedEventData,
		Collection<Pair<FTransition, Iterable<EventData>>> possibleSteps,
		Collection<BehaviourAwareTrace> traces
	) {
		if (traces.size >= 1000) {return;}
		
		val unused = possibleSteps.map[
			val tr = it.key;
			tr -> it.value.filter[
				val startingData = this.traceStartingData.get(tr);
				(! (it === latestUsedEventData)) && (startingData == null || ! startingData.contains(it))
			]
		].filter[! it.value.empty]
		val newStart = selector.execute(currentTrace, unused)
		if (newStart != null) {
			startTrace(new BehaviourAwareTrace(currentTrace), newStart, traces)
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