package org.franca.tools.contracts.tracegen.strategies.selectors;

import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;
import org.franca.tools.contracts.tracegen.traces.Trace;

@SuppressWarnings("all")
public class StraightForwardPathSelector implements TransitionSelector {
  public FTransition execute(final Trace currentTrace, final Iterable<FTransition> possibilities) {
    for (final FTransition transition : possibilities) {
      boolean _contains = currentTrace.contains(transition);
      boolean _not = (!_contains);
      if (_not) {
        return transition;
      }
    }
    return null;
  }
}
