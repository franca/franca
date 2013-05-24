package org.franca.tools.contracts.tracegen.strategies.selectors;

import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.traces.Trace;

@SuppressWarnings("all")
public interface TransitionSelector {
  public abstract FTransition execute(final Trace currentTrace, final Iterable<FTransition> possibilities);
}
