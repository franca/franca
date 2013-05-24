package org.franca.tools.contracts.tracegen.strategies

import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.strategies.collect.SimpleCollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.strategies.selectors.StraightForwardPathSelector
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector

class DefaultStrategyCollection implements StrategyCollection {
	
	override CollectTransitionsStrategy getCollectTransitionsStrategy() {
		return new SimpleCollectTransitionsStrategy
	}
	
	override TransitionSelector getPathSelector() {
		return new StraightForwardPathSelector
	}
	
}