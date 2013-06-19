package org.franca.tools.contracts.tracegen.strategies.collect;

import com.google.common.base.Objects;
import java.util.Arrays;
import java.util.Collection;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.franca.core.franca.FExpression;
import org.franca.core.franca.FGuard;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.traces.BehaviourAwareTrace;
import org.franca.tools.contracts.tracegen.traces.Trace;

@SuppressWarnings("all")
public class BehaviourAwareCollectTransitionsStrategy implements CollectTransitionsStrategy {
  public Collection<FTransition> execute(final Trace currentTrace) {
    final Collection<FTransition> result = CollectionLiterals.<FTransition>newArrayList();
    FState _currentState = currentTrace.getCurrentState();
    EList<FTransition> _transitions = _currentState.getTransitions();
    for (final FTransition transition : _transitions) {
      boolean _check = this.check(currentTrace, transition);
      if (_check) {
        result.add(transition);
      }
    }
    return result;
  }
  
  protected boolean _check(final Trace currentTrace, final FTransition transition) {
    IllegalArgumentException _illegalArgumentException = new IllegalArgumentException();
    throw _illegalArgumentException;
  }
  
  protected boolean _check(final BehaviourAwareTrace currentTrace, final FTransition transition) {
    FGuard _guard = transition.getGuard();
    boolean _equals = Objects.equal(_guard, null);
    if (_equals) {
      return true;
    }
    FGuard _guard_1 = transition.getGuard();
    FExpression _condition = _guard_1.getCondition();
    final Object result = currentTrace.evaluate(_condition);
    if ((result instanceof Boolean)) {
      return (((Boolean) result)).booleanValue();
    }
    return true;
  }
  
  public boolean check(final Trace currentTrace, final FTransition transition) {
    if (currentTrace instanceof BehaviourAwareTrace) {
      return _check((BehaviourAwareTrace)currentTrace, transition);
    } else if (currentTrace != null) {
      return _check(currentTrace, transition);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(currentTrace, transition).toString());
    }
  }
}
