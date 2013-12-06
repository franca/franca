/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.traces

import java.util.HashMap
import java.util.HashSet
import java.util.List
import org.apache.commons.lang3.StringUtils
import org.franca.core.franca.FEventOnIf
import org.franca.core.franca.FState
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.strategies.events.EventData
import com.google.common.collect.Lists

class TraceUsageStatistics {
	
	FState state
	Integer visits
	HashMap<FTransition, List<EventData>> usesOfTransition
	
	new (TraceUsageStatistics original) {
		state = original.state
		visits = original.visits
		usesOfTransition = newHashMap
		for (entry : original.usesOfTransition.entrySet) {
			//TODO: clearify, whether it is sufficient not to copy the event data object but only copy the links
			usesOfTransition.put(entry.key, Lists::newArrayList(entry.value))
		}
	}
	
	new (FTransition transition, EventData triggeringEventData) {
		this.state = transition.eContainer as FState
		this.visits = 1
		usesOfTransition = new HashMap<FTransition, List<EventData>>(this.state.transitions.size, 1.0f)
		usesOfTransition.put(transition, newArrayList(triggeringEventData))
	}
	
	/**
	 * Precondition: the container of transition (starting state) must be the same as the one, the statistics object
	 * had been created with.
	 */
	def void use(FTransition transition, EventData triggeringEventData) {
		visits = visits + 1
		var events = usesOfTransition.get(transition)
		if (events == null) {
			events = newArrayList(triggeringEventData);
			usesOfTransition.put(transition, events)
		} else {
			events += triggeringEventData
		}
	}
	
	def getNumberOfUses (FTransition transition) {
		val result = usesOfTransition.get(transition)
		if (result == null) {
			return 0;
		}
		return result.size;
	}
	
	def getTriggeringEventDataList(FTransition transition) {
		usesOfTransition.get(transition) ?: emptyList
	}
	
}

class Trace {
	
	List<Pair<FTransition, EventData>> orderedTransitions = newLinkedList
	HashSet<FState> states = newHashSet
	HashSet<FTransition> usedTransitions = newHashSet
	
	HashMap<FState, TraceUsageStatistics> statistics = newHashMap
	FState currentState
	
	new(FState start) {
		this.states += start
		this.currentState = start
	}
	
	new(Trace base) {
		this.orderedTransitions.addAll(base.orderedTransitions)
		this.states.addAll(base.states)
		this.usedTransitions.addAll(base.usedTransitions)
		this.currentState = base.currentState
		
		this.statistics = newHashMap
		for (entry : base.statistics.entrySet) {
			this.statistics.put(entry.key, new TraceUsageStatistics(entry.value))
		}
	}
	
	def getCurrentState() {
		return currentState
	}
	
	/**
	 * precondition: transition.from == oderedTransitions.last.to || (states.size == 1 && transition.from == states.head)
	 */
	def use(FTransition transition, EventData triggeringEventData) {
		orderedTransitions += transition -> triggeringEventData
		usedTransitions += transition
		this.currentState = transition.to
		
		val start = transition.eContainer as FState
		val statistics = this.statistics.get(start)
		if (statistics == null) {
			this.statistics.put(start, new TraceUsageStatistics(transition, triggeringEventData))
		} else {
			statistics.use(transition, triggeringEventData)
		}
	}
	
	
	def getStatistics(FState state) {
		return this.statistics.get(state);		
	}
	
	def List<FEventOnIf> toEventList() {
		orderedTransitions.map[value.event]
	}
	
	def List<EventData> toActualEventDataList() {
		orderedTransitions.map[value]		
	}
	
	override toString() {
		val max = 38
		'''
			 CLIENT                                SERVER  | STATE TRACE
			«FOR tr : orderedTransitions»
				«val evData = tr.value»
				«val ev = evData.event»
				«val direction = if (ev.getUpdate()!=null || ev.getRespond()!=null || ev.getSignal()!=null) "<--" else "-->"»
				«val actuals = tr.value.actualArguments.map[value].join(", ")»
				«val trg = StringUtils::rightPad(StringUtils::abbreviate(getTriggerString(ev) + '''(«actuals»)''', max), max)»
				«direction» «trg» «direction» | «tr.key.to.name»
			«ENDFOR»
		'''
	}
	
	def	private String getTriggerString (FEventOnIf ev) {
		if (ev.getSet()!=null) {
			"set_" + ev.getSet().getName();
		} else if (ev.getUpdate()!=null) {
			"update_" + ev.getUpdate().getName();
		} else if (ev.getCall()!=null) {
			"call_" + ev.getCall().getName();
		} else if (ev.getRespond()!=null) {
			"respond_" + ev.getRespond().getName();
		} else if (ev.getSignal()!=null) {
			"signal_" + ev.getSignal().getName();
		}
	}
	
	def contains(FState state) {
		return this.states.contains(state)
	}
	
	def contains(FTransition transition) {
		return this.usedTransitions.contains(transition)
	}
	
}