package org.franca.tools.contracts.tracegen.traces;

import com.google.common.base.Objects;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;
import org.apache.commons.lang3.StringUtils;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FGuard;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.core.franca.FTrigger;
import org.franca.tools.contracts.tracegen.traces.TraceUsageStatistics;

@SuppressWarnings("all")
public class Trace {
  private List<FTransition> orderedTransitions = new Function0<List<FTransition>>() {
    public List<FTransition> apply() {
      LinkedList<FTransition> _newLinkedList = CollectionLiterals.<FTransition>newLinkedList();
      return _newLinkedList;
    }
  }.apply();
  
  private HashSet<FState> states = new Function0<HashSet<FState>>() {
    public HashSet<FState> apply() {
      HashSet<FState> _newHashSet = CollectionLiterals.<FState>newHashSet();
      return _newHashSet;
    }
  }.apply();
  
  private HashSet<FTransition> usedTransitions = new Function0<HashSet<FTransition>>() {
    public HashSet<FTransition> apply() {
      HashSet<FTransition> _newHashSet = CollectionLiterals.<FTransition>newHashSet();
      return _newHashSet;
    }
  }.apply();
  
  private HashMap<FState,TraceUsageStatistics> statistics = new Function0<HashMap<FState,TraceUsageStatistics>>() {
    public HashMap<FState,TraceUsageStatistics> apply() {
      HashMap<FState,TraceUsageStatistics> _newHashMap = CollectionLiterals.<FState, TraceUsageStatistics>newHashMap();
      return _newHashMap;
    }
  }.apply();
  
  private FState currentState;
  
  public Trace(final FState start) {
    this.states.add(start);
    this.currentState = start;
  }
  
  public Trace(final Trace base) {
    this.orderedTransitions.addAll(base.orderedTransitions);
    this.states.addAll(base.states);
    this.usedTransitions.addAll(base.usedTransitions);
    this.currentState = base.currentState;
    HashMap<FState,TraceUsageStatistics> _newHashMap = CollectionLiterals.<FState, TraceUsageStatistics>newHashMap();
    this.statistics = _newHashMap;
    Set<Entry<FState,TraceUsageStatistics>> _entrySet = base.statistics.entrySet();
    for (final Entry<FState,TraceUsageStatistics> entry : _entrySet) {
      FState _key = entry.getKey();
      TraceUsageStatistics _value = entry.getValue();
      TraceUsageStatistics _traceUsageStatistics = new TraceUsageStatistics(_value);
      this.statistics.put(_key, _traceUsageStatistics);
    }
  }
  
  public FState getCurrentState() {
    return this.currentState;
  }
  
  /**
   * precondition: transition.from == oderedTransitions.last.to || (states.size == 1 && transition.from == states.head)
   */
  public Object use(final FTransition transition) {
    Object _xblockexpression = null;
    {
      this.orderedTransitions.add(transition);
      this.usedTransitions.add(transition);
      FState _to = transition.getTo();
      this.currentState = _to;
      EObject _eContainer = transition.eContainer();
      final FState start = ((FState) _eContainer);
      final TraceUsageStatistics statistics = this.statistics.get(start);
      Object _xifexpression = null;
      boolean _equals = Objects.equal(statistics, null);
      if (_equals) {
        TraceUsageStatistics _traceUsageStatistics = new TraceUsageStatistics(transition);
        TraceUsageStatistics _put = this.statistics.put(start, _traceUsageStatistics);
        _xifexpression = _put;
      } else {
        Integer _use = statistics.use(transition);
        _xifexpression = _use;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  public TraceUsageStatistics getStatistics(final FState state) {
    return this.statistics.get(state);
  }
  
  public List<FEventOnIf> toEventList() {
    final Function1<FTransition,FEventOnIf> _function = new Function1<FTransition,FEventOnIf>() {
        public FEventOnIf apply(final FTransition it) {
          FTrigger _trigger = it.getTrigger();
          FEventOnIf _event = _trigger.getEvent();
          return _event;
        }
      };
    List<FEventOnIf> _map = ListExtensions.<FTransition, FEventOnIf>map(this.orderedTransitions, _function);
    return _map;
  }
  
  public String toString() {
    String _xblockexpression = null;
    {
      final int max = 38;
      StringConcatenation _builder = new StringConcatenation();
      _builder.append(" ");
      _builder.append("CLIENT                                SERVER  | STATE TRACE");
      _builder.newLine();
      {
        for(final FTransition tr : this.orderedTransitions) {
          FTrigger _trigger = tr.getTrigger();
          final FEventOnIf ev = _trigger.getEvent();
          _builder.newLineIfNotEmpty();
          String _xifexpression = null;
          boolean _or = false;
          boolean _or_1 = false;
          FAttribute _update = ev.getUpdate();
          boolean _notEquals = (!Objects.equal(_update, null));
          if (_notEquals) {
            _or_1 = true;
          } else {
            FMethod _respond = ev.getRespond();
            boolean _notEquals_1 = (!Objects.equal(_respond, null));
            _or_1 = (_notEquals || _notEquals_1);
          }
          if (_or_1) {
            _or = true;
          } else {
            FBroadcast _signal = ev.getSignal();
            boolean _notEquals_2 = (!Objects.equal(_signal, null));
            _or = (_or_1 || _notEquals_2);
          }
          if (_or) {
            _xifexpression = "<--";
          } else {
            _xifexpression = "-->";
          }
          final String direction = _xifexpression;
          _builder.newLineIfNotEmpty();
          String _triggerString = this.getTriggerString(ev);
          String _abbreviate = StringUtils.abbreviate(_triggerString, max);
          final String trg = StringUtils.rightPad(_abbreviate, max);
          _builder.newLineIfNotEmpty();
          _builder.append(direction, "");
          _builder.append(" ");
          _builder.append(trg, "");
          _builder.append(" ");
          _builder.append(direction, "");
          _builder.append(" | ");
          FState _to = tr.getTo();
          String _name = _to.getName();
          _builder.append(_name, "");
          _builder.newLineIfNotEmpty();
        }
      }
      _xblockexpression = (_builder.toString());
    }
    return _xblockexpression;
  }
  
  public CharSequence simpleToString() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("BEGIN TRACE");
    _builder.newLine();
    {
      for(final FTransition it : this.orderedTransitions) {
        _builder.append("transition from ");
        EObject _eContainer = it.eContainer();
        String _name = ((FState) _eContainer).getName();
        _builder.append(_name, "");
        _builder.append(" --> ");
        FState _to = it.getTo();
        String _name_1 = _to.getName();
        _builder.append(_name_1, "");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("END TRACE");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence richToString() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("BEGIN TRACE");
    _builder.newLine();
    {
      for(final FTransition it : this.orderedTransitions) {
        _builder.append("from ");
        EObject _eContainer = it.eContainer();
        String _name = ((FState) _eContainer).getName();
        _builder.append(_name, "");
        _builder.append(" take unnamed transition with");
        _builder.newLineIfNotEmpty();
        _builder.append("\t");
        _builder.append("guard <missing toString for> ");
        FGuard _guard = it.getGuard();
        _builder.append(_guard, "	");
        _builder.newLineIfNotEmpty();
        _builder.append("\t");
        _builder.append("trigger <missing toString for> ");
        FTrigger _trigger = it.getTrigger();
        _builder.append(_trigger, "	");
        _builder.newLineIfNotEmpty();
        _builder.append("\t");
        _builder.append("to ");
        FState _to = it.getTo();
        String _name_1 = _to.getName();
        _builder.append(_name_1, "	");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("END TRACE");
    _builder.newLine();
    return _builder;
  }
  
  private String getTriggerString(final FEventOnIf ev) {
    String _xifexpression = null;
    FAttribute _set = ev.getSet();
    boolean _notEquals = (!Objects.equal(_set, null));
    if (_notEquals) {
      FAttribute _set_1 = ev.getSet();
      String _name = _set_1.getName();
      String _plus = ("set_" + _name);
      _xifexpression = _plus;
    } else {
      String _xifexpression_1 = null;
      FAttribute _update = ev.getUpdate();
      boolean _notEquals_1 = (!Objects.equal(_update, null));
      if (_notEquals_1) {
        FAttribute _update_1 = ev.getUpdate();
        String _name_1 = _update_1.getName();
        String _plus_1 = ("update_" + _name_1);
        _xifexpression_1 = _plus_1;
      } else {
        String _xifexpression_2 = null;
        FMethod _call = ev.getCall();
        boolean _notEquals_2 = (!Objects.equal(_call, null));
        if (_notEquals_2) {
          FMethod _call_1 = ev.getCall();
          String _name_2 = _call_1.getName();
          String _plus_2 = ("call_" + _name_2);
          _xifexpression_2 = _plus_2;
        } else {
          String _xifexpression_3 = null;
          FMethod _respond = ev.getRespond();
          boolean _notEquals_3 = (!Objects.equal(_respond, null));
          if (_notEquals_3) {
            FMethod _respond_1 = ev.getRespond();
            String _name_3 = _respond_1.getName();
            String _plus_3 = ("respond_" + _name_3);
            _xifexpression_3 = _plus_3;
          } else {
            String _xifexpression_4 = null;
            FBroadcast _signal = ev.getSignal();
            boolean _notEquals_4 = (!Objects.equal(_signal, null));
            if (_notEquals_4) {
              FBroadcast _signal_1 = ev.getSignal();
              String _name_4 = _signal_1.getName();
              String _plus_4 = ("signal_" + _name_4);
              _xifexpression_4 = _plus_4;
            }
            _xifexpression_3 = _xifexpression_4;
          }
          _xifexpression_2 = _xifexpression_3;
        }
        _xifexpression_1 = _xifexpression_2;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  public boolean contains(final FState state) {
    return this.states.contains(state);
  }
  
  public boolean contains(final FTransition transition) {
    return this.usedTransitions.contains(transition);
  }
}
