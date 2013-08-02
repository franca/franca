/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies

import org.franca.tools.contracts.tracegen.strategies.collect.SimpleCollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.strategies.selectors.LimitedUseTransitionSelector
import org.franca.tools.contracts.tracegen.strategies.events.TriggerSimualtionStrategy

class Cycle10StrategyCollection implements StrategyCollection {
	
	override getCollectTransitionsStrategy() {
		new SimpleCollectTransitionsStrategy
	}
	
	override getPathSelector() {
		new LimitedUseTransitionSelector(10)
	}
	
	override getTriggerSimulator() {
		return new TriggerSimualtionStrategy
	}
	
}