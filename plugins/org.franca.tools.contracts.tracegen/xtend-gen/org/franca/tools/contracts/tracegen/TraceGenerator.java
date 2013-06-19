package org.franca.tools.contracts.tracegen;

import com.google.common.base.Objects;
import java.util.Collection;
import java.util.HashSet;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.strategies.DefaultStrategyCollection;
import org.franca.tools.contracts.tracegen.strategies.StrategyCollection;
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;
import org.franca.tools.contracts.tracegen.traces.BehaviourAwareTrace;

@SuppressWarnings("all")
public class TraceGenerator {
  private HashSet<FTransition> transitionsATraceStartedWith = new Function0<HashSet<FTransition>>() {
    public HashSet<FTransition> apply() {
      HashSet<FTransition> _newHashSet = CollectionLiterals.<FTransition>newHashSet();
      return _newHashSet;
    }
  }.apply();
  
  private CollectTransitionsStrategy collector;
  
  private TransitionSelector selector;
  
  public TraceGenerator() {
    this(null);
  }
  
  public TraceGenerator(final StrategyCollection strategies) {
    StrategyCollection _xifexpression = null;
    boolean _equals = Objects.equal(strategies, null);
    if (_equals) {
      DefaultStrategyCollection _defaultStrategyCollection = new DefaultStrategyCollection();
      _xifexpression = _defaultStrategyCollection;
    } else {
      _xifexpression = strategies;
    }
    final StrategyCollection localStrategies = _xifexpression;
    CollectTransitionsStrategy _collectTransitionsStrategy = localStrategies.getCollectTransitionsStrategy();
    this.collector = _collectTransitionsStrategy;
    TransitionSelector _pathSelector = localStrategies.getPathSelector();
    this.selector = _pathSelector;
  }
  
  public Collection<BehaviourAwareTrace> simulate(final FState startingState) {
    BehaviourAwareTrace _behaviourAwareTrace = new BehaviourAwareTrace(startingState);
    final BehaviourAwareTrace startingTrace = _behaviourAwareTrace;
    final Collection<BehaviourAwareTrace> traces = CollectionLiterals.<BehaviourAwareTrace>newHashSet();
    final Collection<FTransition> possibleTransitions = this.collector.<BehaviourAwareTrace>execute(startingTrace);
    final FTransition nextTransition = this.selector.execute(startingTrace, possibleTransitions);
    this.startTrace(startingTrace, nextTransition, traces);
    return traces;
  }
  
  private void startTrace(final BehaviourAwareTrace trace, final FTransition nextTransition, final Collection<BehaviourAwareTrace> traces) {
    traces.add(trace);
    trace.use(nextTransition);
    this.transitionsATraceStartedWith.add(nextTransition);
    this.simulate(trace, traces);
  }
  
  private void simulate(final BehaviourAwareTrace trace, final Collection<BehaviourAwareTrace> traces) {
    Collection<FTransition> possibleTransitions = this.collector.<BehaviourAwareTrace>execute(trace);
    FTransition nextTransition = this.selector.execute(trace, possibleTransitions);
    boolean _notEquals = (!Objects.equal(nextTransition, null));
    boolean _while = _notEquals;
    while (_while) {
      {
        trace.use(nextTransition);
        this.possiblyStartNewTraces(trace, nextTransition, possibleTransitions, traces);
        Collection<FTransition> _execute = this.collector.<BehaviourAwareTrace>execute(trace);
        possibleTransitions = _execute;
        FTransition _execute_1 = this.selector.execute(trace, possibleTransitions);
        nextTransition = _execute_1;
      }
      boolean _notEquals_1 = (!Objects.equal(nextTransition, null));
      _while = _notEquals_1;
    }
  }
  
  public void possiblyStartNewTraces(final BehaviourAwareTrace currentTrace, final FTransition lastTransition, final Collection<FTransition> possibleTransitions, final Collection<BehaviourAwareTrace> traces) {
    int _size = traces.size();
    boolean _greaterEqualsThan = (_size >= 1000);
    if (_greaterEqualsThan) {
      return;
    }
    for (final FTransition next : possibleTransitions) {
      boolean _and = false;
      boolean _equals = next.equals(lastTransition);
      boolean _not = (!_equals);
      if (!_not) {
        _and = false;
      } else {
        boolean _contains = this.transitionsATraceStartedWith.contains(next);
        boolean _not_1 = (!_contains);
        _and = (_not && _not_1);
      }
      if (_and) {
        BehaviourAwareTrace _behaviourAwareTrace = new BehaviourAwareTrace(currentTrace);
        this.startTrace(_behaviourAwareTrace, next, traces);
      }
    }
  }
}
