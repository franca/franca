/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies

import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.strategies.collect.SimpleCollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.strategies.selectors.StraightForwardPathSelector
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector
import org.franca.tools.contracts.tracegen.strategies.events.TriggerSimualtionStrategy

class DefaultStrategyCollection implements StrategyCollection {
	
	override CollectTransitionsStrategy getCollectTransitionsStrategy() {
		return new SimpleCollectTransitionsStrategy
	}
	
	override TransitionSelector getPathSelector() {
		return new StraightForwardPathSelector
	}
	
	override getTriggerSimulator() {
		return new TriggerSimualtionStrategy
	}
	
}