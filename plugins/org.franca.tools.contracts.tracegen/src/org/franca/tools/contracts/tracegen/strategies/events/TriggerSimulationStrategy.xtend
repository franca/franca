/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies.events

import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.values.ValueGenerator
import org.franca.tools.contracts.tracegen.values.simple.RandomlyInitializingSimpleValueGenerator

/**
 * This class only creates one random event Data that triggers the transition
 * Future implementations may provide multiple events, that could trigger the transition
 */
class TriggerSimualtionStrategy {
	
	extension ValueGenerator jvg = new ValueGenerator(new RandomlyInitializingSimpleValueGenerator)
	
	def Iterable<EventData> createEventData(FTransition transition) {
		val event = transition.trigger.event
		val  actualArguments = 
				if (event.call != null) {
					event.call.inArgs.map[it -> createActualValue]
				} else if (event.respond != null) {
					event.respond.outArgs.map[it -> createActualValue]
				} else if (event.set != null) {
					throw new IllegalArgumentException("Not yet implemented: Triggering transitions by setting attributes)")
				} else if (event.signal != null) {
					throw new IllegalArgumentException("Not yet implemented: Triggering transitions by signals)")
				} else if (event.update != null) {
					throw new IllegalArgumentException("Not yet implemented: Triggering transitions by updating attributes)")
				} else {
					throw new IllegalArgumentException("Unknown kind of triggering event!")
				}
		
		return newArrayList(
			new EventData(event, actualArguments)
		)
	}
	
}