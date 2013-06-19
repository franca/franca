package org.franca.tools.contracts.tracegen.strategies;

import org.franca.tools.contracts.tracegen.strategies.collect.BehaviourAwareCollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.selectors.LimitedUseTransitionSelector;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;

public class BahaviourAwareStrategyCollection implements StrategyCollection {

	@Override
	public CollectTransitionsStrategy getCollectTransitionsStrategy() {
		return new BehaviourAwareCollectTransitionsStrategy();
	}

	@Override
	public TransitionSelector getPathSelector() {
		return new LimitedUseTransitionSelector(10);
	}

}
