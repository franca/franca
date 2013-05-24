package org.franca.tools.contracts.tracegen.strategies;

import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;

@SuppressWarnings("all")
public interface StrategyCollection {
  public abstract CollectTransitionsStrategy getCollectTransitionsStrategy();
  
  public abstract TransitionSelector getPathSelector();
}
