package org.franca.tools.contracts.tracegen.traces

import java.util.HashMap
import java.util.HashSet
import java.util.List
import org.apache.commons.lang3.StringUtils
import org.franca.core.franca.FEventOnIf
import org.franca.core.franca.FState
import org.franca.core.franca.FTransition
import com.google.common.collect.Maps

class TraceUsageStatistics {
	
	FState state
	Integer visits
	HashMap<FTransition, Integer> usesOfTransition
	
	new (TraceUsageStatistics original) {
		state = original.state
		visits = original.visits
		usesOfTransition = Maps::newHashMap(original.usesOfTransition)
	}
	
	new (FTransition transition) {
		this.state = transition.eContainer as FState
		this.visits = 1
		usesOfTransition = new HashMap<FTransition, Integer>(this.state.transitions.size, 1.0f)
		usesOfTransition.put(transition, 1)
	}
	
	/**
	 * Precondition: the container of transition (starting state) must be the same as the one, the statistics object
	 * had been created with.
	 */
	def use(FTransition transition) {
		visits = visits + 1
		var uses = usesOfTransition.get(transition)
		if (uses == null) {
			uses = 0;
		}
		usesOfTransition.put(transition, uses + 1)
	}
	
	def getUses (FTransition transition) {
		val result = usesOfTransition.get(transition)
		if (result == null) {
			return 0;
		}
		return result;
	}
	
}

class Trace {
	
	List<FTransition> orderedTransitions = newLinkedList
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
	def use(FTransition transition) {
		orderedTransitions += transition
		usedTransitions += transition
		this.currentState = transition.to
		
		val start = transition.eContainer as FState
		val statistics = this.statistics.get(start)
		if (statistics == null) {
			this.statistics.put(start, new TraceUsageStatistics(transition))
		} else {
			statistics.use(transition)
		}
	}
	
	
	def getStatistics(FState state) {
		return this.statistics.get(state);		
	}
	
	def List<FEventOnIf> toEventList() {
		orderedTransitions.map[trigger.event]
	}
	
	override toString() {
		val max = 38
		'''
			 CLIENT                                SERVER  | STATE TRACE
			«FOR tr : orderedTransitions»
				«val ev = tr.trigger.event»
				«val direction = if (ev.getUpdate()!=null || ev.getRespond()!=null || ev.getSignal()!=null) "<--" else "-->"»
				«val trg = StringUtils::rightPad(StringUtils::abbreviate(getTriggerString(ev), max), max)»
				«direction» «trg» «direction» | «tr.to.name»
			«ENDFOR»
		'''
	}
	
	def simpleToString() {
		'''
		BEGIN TRACE
		«FOR it : orderedTransitions»
			transition from «(it.eContainer as FState).name» --> «to.name»
		«ENDFOR»
		END TRACE
		'''
	}
	
	def richToString() {
		'''
		BEGIN TRACE
		«FOR it : orderedTransitions»
			from «(it.eContainer as FState).name» take unnamed transition with
				guard <missing toString for> «guard»
				trigger <missing toString for> «trigger»
				to «to.name»
		«ENDFOR»
		END TRACE
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