package org.franca.tools.contracts.tracegen.strategies;

import org.franca.tools.contracts.tracegen.strategies.StrategyCollection;
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.collect.SimpleCollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.selectors.StraightForwardPathSelector;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;

@SuppressWarnings("all")
public class DefaultStrategyCollection implements StrategyCollection {
  public CollectTransitionsStrategy getCollectTransitionsStrategy() {
    SimpleCollectTransitionsStrategy _simpleCollectTransitionsStrategy = new SimpleCollectTransitionsStrategy();
    return _simpleCollectTransitionsStrategy;
  }
  
  public TransitionSelector getPathSelector() {
    StraightForwardPathSelector _straightForwardPathSelector = new StraightForwardPathSelector();
    return _straightForwardPathSelector;
  }
}
