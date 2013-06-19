package org.franca.tools.contracts.tracegen.strategies

import org.franca.tools.contracts.tracegen.strategies.collect.SimpleCollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.strategies.selectors.LimitedUseTransitionSelector

class Cycle10StrategyCollection implements StrategyCollection {
	
	override getCollectTransitionsStrategy() {
		new SimpleCollectTransitionsStrategy
	}
	
	override getPathSelector() {
		new LimitedUseTransitionSelector(10)
	}
	
}