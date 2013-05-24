package org.franca.tools.contracts.tracegen.strategies.collect;

import java.util.ArrayList;
import java.util.Collection;
import org.eclipse.emf.common.util.EList;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.traces.Trace;

@SuppressWarnings("all")
public class SimpleCollectTransitionsStrategy implements CollectTransitionsStrategy {
  public Collection<FTransition> execute(final Trace currentTrace) {
    FState _currentState = currentTrace.getCurrentState();
    EList<FTransition> _transitions = _currentState.getTransitions();
    ArrayList<FTransition> _arrayList = new ArrayList<FTransition>(_transitions);
    return _arrayList;
  }
}
