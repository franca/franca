/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies.collect

import java.util.Collection
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.BehaviourAwareTrace
import org.franca.tools.contracts.tracegen.traces.Trace
import org.franca.tools.contracts.tracegen.strategies.events.EventData
import org.franca.tools.contracts.tracegen.strategies.events.TriggerSimualtionStrategy
import java.util.ArrayList

class BehaviourAwareCollectTransitionsStrategy implements CollectTransitionsStrategy {
	
	TriggerSimualtionStrategy triggersim
	
	new (TriggerSimualtionStrategy triggersim) {
		this.triggersim = triggersim
	}
	
	override public Collection<Pair<FTransition, Iterable<EventData>>> execute(Trace currentTrace) {
		if (currentTrace.currentState.name.equals("ReqCancel")) {
			println
		}
		val Collection<Pair<FTransition, Iterable<EventData>>> result = newArrayList
		for (transition : currentTrace.currentState.transitions) {
			val Iterable<EventData> possibleEvents = check(currentTrace, transition)
			if (!possibleEvents.empty) {
				result += transition -> possibleEvents
			}
		}
		return result
	}
	
	def dispatch Iterable<EventData> check(Trace currentTrace, FTransition transition) {
		throw new IllegalArgumentException;
	}
	
	/**
	 * return a list of EventData Objects that might be used to trigger this transition
	 */
	def dispatch Iterable<EventData> check(BehaviourAwareTrace currentTrace, FTransition transition) {
		//TODO: create Event data, that can past the guard
		val possibleTriggerEvents = triggersim.createEventData(transition)
		
		if (transition.guard == null) return possibleTriggerEvents;
		
		// usage of a filter only is dangerous! it would be evaluated later and meanwhile the action of a transition could change
		// some values and so the possible events would vary when questioning before and directly after usage of a transition
//		return possibleTriggerEvents.filter[Boolean::TRUE.equals(currentTrace.evaluate(transition.guard.condition, it))]

		return new ArrayList( possibleTriggerEvents.filter[Boolean::TRUE.equals(currentTrace.evaluate(transition.guard.condition, it))].toList)

		
	}
	
}