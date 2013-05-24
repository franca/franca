package org.franca.tools.contracts.tracegen.strategies

import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector

interface StrategyCollection {
	
	def CollectTransitionsStrategy getCollectTransitionsStrategy();
	
	def TransitionSelector getPathSelector();
}