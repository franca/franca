package org.franca.tools.contracts.tracegen.strategies.selectors;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import java.util.HashMap;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;
import org.franca.tools.contracts.tracegen.traces.Trace;

@SuppressWarnings("all")
public class GloballyLimitedUseTransitionSelector implements TransitionSelector {
  private HashMap<FTransition,Integer> visitCounter = new Function0<HashMap<FTransition,Integer>>() {
    public HashMap<FTransition,Integer> apply() {
      HashMap<FTransition,Integer> _newHashMap = CollectionLiterals.<FTransition, Integer>newHashMap();
      return _newHashMap;
    }
  }.apply();
  
  private int limit;
  
  public GloballyLimitedUseTransitionSelector() {
    this(null);
  }
  
  public GloballyLimitedUseTransitionSelector(final Integer limit) {
    boolean _equals = Objects.equal(limit, null);
    if (_equals) {
      this.limit = 10;
    } else {
      this.limit = (limit).intValue();
    }
  }
  
  public FTransition execute(final Trace currentTrace, final Iterable<FTransition> possibilities) {
    int countTransitionsToMarkAsUnusable = IterableExtensions.size(possibilities);
    Iterable<FTransition> _cycle = Iterables.<FTransition>cycle(possibilities);
    for (final FTransition transition : _cycle) {
      {
        boolean _equals = (countTransitionsToMarkAsUnusable == 0);
        if (_equals) {
          return null;
        }
        boolean _checkTransition = this.checkTransition(transition);
        if (_checkTransition) {
          return transition;
        } else {
          int _minus = (countTransitionsToMarkAsUnusable - 1);
          countTransitionsToMarkAsUnusable = _minus;
        }
      }
    }
    return null;
  }
  
  public boolean checkTransition(final FTransition transition) {
    Integer count = this.visitCounter.get(transition);
    boolean _equals = Objects.equal(count, null);
    if (_equals) {
      this.visitCounter.put(transition, Integer.valueOf(1));
      return true;
    } else {
      boolean _lessThan = ((count).intValue() < this.limit);
      if (_lessThan) {
        this.visitCounter.remove(transition);
        int _plus = ((count).intValue() + 1);
        this.visitCounter.put(transition, Integer.valueOf(_plus));
        return true;
      }
    }
    return false;
  }
}
