package org.franca.tools.contracts.tracegen.traces;

import com.google.common.base.Objects;
import com.google.common.collect.Maps;
import java.util.HashMap;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

@SuppressWarnings("all")
public class TraceUsageStatistics {
  private FState state;
  
  private Integer visits;
  
  private HashMap<FTransition,Integer> usesOfTransition;
  
  public TraceUsageStatistics(final TraceUsageStatistics original) {
    this.state = original.state;
    this.visits = original.visits;
    HashMap<FTransition,Integer> _newHashMap = Maps.<FTransition, Integer>newHashMap(original.usesOfTransition);
    this.usesOfTransition = _newHashMap;
  }
  
  public TraceUsageStatistics(final FTransition transition) {
    EObject _eContainer = transition.eContainer();
    this.state = ((FState) _eContainer);
    this.visits = Integer.valueOf(1);
    EList<FTransition> _transitions = this.state.getTransitions();
    int _size = _transitions.size();
    HashMap<FTransition,Integer> _hashMap = new HashMap<FTransition,Integer>(_size, 1.0f);
    this.usesOfTransition = _hashMap;
    this.usesOfTransition.put(transition, Integer.valueOf(1));
  }
  
  /**
   * Precondition: the container of transition (starting state) must be the same as the one, the statistics object
   * had been created with.
   */
  public Integer use(final FTransition transition) {
    Integer _xblockexpression = null;
    {
      int _plus = ((this.visits).intValue() + 1);
      this.visits = Integer.valueOf(_plus);
      Integer uses = this.usesOfTransition.get(transition);
      boolean _equals = Objects.equal(uses, null);
      if (_equals) {
        uses = Integer.valueOf(0);
      }
      int _plus_1 = ((uses).intValue() + 1);
      Integer _put = this.usesOfTransition.put(transition, Integer.valueOf(_plus_1));
      _xblockexpression = (_put);
    }
    return _xblockexpression;
  }
  
  public int getUses(final FTransition transition) {
    final Integer result = this.usesOfTransition.get(transition);
    boolean _equals = Objects.equal(result, null);
    if (_equals) {
      return 0;
    }
    return result;
  }
}
