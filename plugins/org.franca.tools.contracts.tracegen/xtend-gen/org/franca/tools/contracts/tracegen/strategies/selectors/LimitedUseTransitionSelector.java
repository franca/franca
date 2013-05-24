package org.franca.tools.contracts.tracegen.strategies.selectors;

import com.google.common.base.Objects;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;
import org.franca.tools.contracts.tracegen.traces.Trace;
import org.franca.tools.contracts.tracegen.traces.TraceUsageStatistics;

@SuppressWarnings("all")
public class LimitedUseTransitionSelector implements TransitionSelector {
  private int limit;
  
  public LimitedUseTransitionSelector() {
    this(null);
  }
  
  public LimitedUseTransitionSelector(final Integer limit) {
    boolean _equals = Objects.equal(limit, null);
    if (_equals) {
      this.limit = 10;
    } else {
      this.limit = (limit).intValue();
    }
  }
  
  public FTransition execute(final Trace currentTrace, final Iterable<FTransition> possibilities) {
    FState _currentState = currentTrace.getCurrentState();
    TraceUsageStatistics statistics = currentTrace.getStatistics(_currentState);
    boolean _equals = Objects.equal(statistics, null);
    if (_equals) {
      return IterableExtensions.<FTransition>head(possibilities);
    }
    for (final FTransition transition : possibilities) {
      int _uses = statistics.getUses(transition);
      boolean _lessThan = (_uses < this.limit);
      if (_lessThan) {
        return transition;
      }
    }
    return null;
  }
}
