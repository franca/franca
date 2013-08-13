/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies.selectors

import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.Trace
import org.eclipse.xtext.xbase.lib.Pair
import org.franca.tools.contracts.tracegen.strategies.events.EventData

class StraightForwardPathSelector implements TransitionSelector {
	
	override execute(Trace currentTrace, Iterable<Pair<FTransition, Iterable<EventData>>> possibilities) {
		for (possibility : possibilities) {
			if (! currentTrace.contains(possibility.key)) {
				return new Pair(possibility.key, possibility.value.head)
			}
		}
		return null
	}
	
}