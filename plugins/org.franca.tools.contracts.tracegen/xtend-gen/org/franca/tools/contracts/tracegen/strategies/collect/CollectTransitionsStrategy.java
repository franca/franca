package org.franca.tools.contracts.tracegen.strategies.collect;

import java.util.Collection;
import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.traces.Trace;

@SuppressWarnings("all")
public interface CollectTransitionsStrategy {
  public abstract <T extends Trace> Collection<FTransition> execute(final T currentTrace);
}
