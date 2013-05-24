package org.franca.tools.contracts.tracegen.strategies;

import org.franca.tools.contracts.tracegen.strategies.StrategyCollection;
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.collect.SimpleCollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.selectors.LimitedUseTransitionSelector;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;

@SuppressWarnings("all")
public class Cycle10StrategyCollection implements StrategyCollection {
  public CollectTransitionsStrategy getCollectTransitionsStrategy() {
    SimpleCollectTransitionsStrategy _simpleCollectTransitionsStrategy = new SimpleCollectTransitionsStrategy();
    return _simpleCollectTransitionsStrategy;
  }
  
  public TransitionSelector getPathSelector() {
    LimitedUseTransitionSelector _limitedUseTransitionSelector = new LimitedUseTransitionSelector(Integer.valueOf(10));
    return _limitedUseTransitionSelector;
  }
}
