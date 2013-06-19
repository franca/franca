package org.franca.tools.contracts.tracegen.traces;

import com.google.common.base.Objects;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.franca.core.franca.FAssignment;
import org.franca.core.franca.FBinaryOperation;
import org.franca.core.franca.FBlockExpression;
import org.franca.core.franca.FBooleanConstant;
import org.franca.core.franca.FDeclaration;
import org.franca.core.franca.FExpression;
import org.franca.core.franca.FIntegerConstant;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FState;
import org.franca.core.franca.FStringConstant;
import org.franca.core.franca.FTransition;
import org.franca.core.franca.FTypedElement;
import org.franca.core.franca.FTypedElementRef;
import org.franca.tools.contracts.tracegen.traces.Operators;
import org.franca.tools.contracts.tracegen.traces.Trace;
import org.franca.tools.contracts.tracegen.traces.ValuedDeclaration;

@SuppressWarnings("all")
public class BehaviourAwareTrace extends Trace {
  @Extension
  private Operators operators = new Function0<Operators>() {
    public Operators apply() {
      Operators _operators = new Operators();
      return _operators;
    }
  }.apply();
  
  private FInterface iface;
  
  private HashMap<FDeclaration,ValuedDeclaration> declarationInstances = new Function0<HashMap<FDeclaration,ValuedDeclaration>>() {
    public HashMap<FDeclaration,ValuedDeclaration> apply() {
      HashMap<FDeclaration,ValuedDeclaration> _newHashMap = CollectionLiterals.<FDeclaration, ValuedDeclaration>newHashMap();
      return _newHashMap;
    }
  }.apply();
  
  public BehaviourAwareTrace(final BehaviourAwareTrace base) {
    super(base);
    this.iface = base.iface;
  }
  
  public BehaviourAwareTrace(final FState start) {
    super(start);
    EcoreUtil2.<FInterface>getContainerOfType(start, FInterface.class);
  }
  
  public Object use(final FTransition transition) {
    Object _xblockexpression = null;
    {
      FExpression _action = transition.getAction();
      boolean _notEquals = (!Objects.equal(_action, null));
      if (_notEquals) {
        FExpression _action_1 = transition.getAction();
        this.evaluate(_action_1);
      }
      Object _use = super.use(transition);
      _xblockexpression = (_use);
    }
    return _xblockexpression;
  }
  
  public ValuedDeclaration getOrCreate(final FDeclaration d) {
    ValuedDeclaration currentInstance = this.declarationInstances.get(d);
    boolean _equals = Objects.equal(currentInstance, null);
    if (_equals) {
      ValuedDeclaration _valuedDeclaration = new ValuedDeclaration(d);
      currentInstance = _valuedDeclaration;
      this.declarationInstances.put(d, currentInstance);
    }
    return currentInstance;
  }
  
  protected Object _evaluate(final FExpression expr) {
    Class<? extends FExpression> _class = expr.getClass();
    String _name = _class.getName();
    String _plus = ("Unknown type: \'" + _name);
    String _plus_1 = (_plus + "\'");
    IllegalArgumentException _illegalArgumentException = new IllegalArgumentException(_plus_1);
    throw _illegalArgumentException;
  }
  
  protected Object _evaluate(final FTypedElementRef expr) {
    boolean _and = false;
    FTypedElement _element = expr.getElement();
    boolean _notEquals = (!Objects.equal(_element, null));
    if (!_notEquals) {
      _and = false;
    } else {
      FTypedElement _element_1 = expr.getElement();
      _and = (_notEquals && (_element_1 instanceof FDeclaration));
    }
    if (_and) {
      FTypedElement _element_2 = expr.getElement();
      ValuedDeclaration _orCreate = this.getOrCreate(((FDeclaration) _element_2));
      return _orCreate.getValue();
    }
    UnsupportedOperationException _unsupportedOperationException = new UnsupportedOperationException();
    throw _unsupportedOperationException;
  }
  
  protected Object _evaluate(final FBinaryOperation expr) {
    Object _xblockexpression = null;
    {
      FExpression _left = expr.getLeft();
      Object left = this.evaluate(_left);
      FExpression _right = expr.getRight();
      Object right = this.evaluate(_right);
      Object _switchResult = null;
      String _op = expr.getOp();
      final String _switchValue = _op;
      boolean _matched = false;
      if (!_matched) {
        if (Objects.equal(_switchValue,"||")) {
          _matched=true;
          boolean _or = false;
          if ((((Boolean) left)).booleanValue()) {
            _or = true;
          } else {
            _or = ((((Boolean) left)).booleanValue() || (((Boolean) right)).booleanValue());
          }
          return Boolean.valueOf(_or);
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"&&")) {
          _matched=true;
          boolean _and = false;
          if (!(((Boolean) left)).booleanValue()) {
            _and = false;
          } else {
            _and = ((((Boolean) left)).booleanValue() && (((Boolean) right)).booleanValue());
          }
          return Boolean.valueOf(_and);
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"==")) {
          _matched=true;
          return Boolean.valueOf(left.equals(right));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"!=")) {
          _matched=true;
          boolean _equals = left.equals(right);
          return Boolean.valueOf((!_equals));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"<")) {
          _matched=true;
          return Boolean.valueOf((((Comparable<Object>) left).compareTo(((Comparable<Object>) right)) < 0));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,">")) {
          _matched=true;
          return Boolean.valueOf((((Comparable<Object>) left).compareTo(((Comparable<Object>) right)) > 0));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"<=")) {
          _matched=true;
          return Boolean.valueOf((((Comparable<Object>) left).compareTo(((Comparable<Object>) right)) <= 0));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,">=")) {
          _matched=true;
          return Boolean.valueOf((((Comparable<Object>) left).compareTo(((Comparable<Object>) right)) >= 0));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"+")) {
          _matched=true;
          return this.operators.operator_plus(((Number) left), ((Number) right));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"-")) {
          _matched=true;
          return this.operators.operator_minus(((Number) left), ((Number) right));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"*")) {
          _matched=true;
          return this.operators.operator_multiply(((Number) left), ((Number) right));
        }
      }
      if (!_matched) {
        if (Objects.equal(_switchValue,"/")) {
          _matched=true;
          return this.operators.operator_divide(((Number) left), ((Number) right));
        }
      }
      _xblockexpression = (_switchResult);
    }
    return _xblockexpression;
  }
  
  protected Object _evaluate(final FBlockExpression expr) {
    EList<FExpression> _expressions = expr.getExpressions();
    final Iterator<FExpression> iter = _expressions.iterator();
    boolean _hasNext = iter.hasNext();
    boolean _while = _hasNext;
    while (_while) {
      {
        FExpression _next = iter.next();
        final Object result = this.evaluate(_next);
        boolean _hasNext_1 = iter.hasNext();
        boolean _not = (!_hasNext_1);
        if (_not) {
          return result;
        }
      }
      boolean _hasNext_1 = iter.hasNext();
      _while = _hasNext_1;
    }
    return null;
  }
  
  protected Object _evaluate(final FBooleanConstant expr) {
    boolean _isVal = expr.isVal();
    return Boolean.valueOf(_isVal);
  }
  
  protected Object _evaluate(final FIntegerConstant expr) {
    int _val = expr.getVal();
    return Integer.valueOf(_val);
  }
  
  protected Object _evaluate(final FStringConstant expr) {
    String _val = expr.getVal();
    return _val;
  }
  
  protected Object _evaluate(final FAssignment a) {
    final FDeclaration declaration = a.getLhs();
    final ValuedDeclaration currentInstance = this.getOrCreate(declaration);
    FExpression _rhs = a.getRhs();
    final Object newValue = this.evaluate(_rhs);
    currentInstance.setValue(newValue);
    return newValue;
  }
  
  public Object evaluate(final FExpression expr) {
    if (expr instanceof FBooleanConstant) {
      return _evaluate((FBooleanConstant)expr);
    } else if (expr instanceof FIntegerConstant) {
      return _evaluate((FIntegerConstant)expr);
    } else if (expr instanceof FStringConstant) {
      return _evaluate((FStringConstant)expr);
    } else if (expr instanceof FAssignment) {
      return _evaluate((FAssignment)expr);
    } else if (expr instanceof FBinaryOperation) {
      return _evaluate((FBinaryOperation)expr);
    } else if (expr instanceof FBlockExpression) {
      return _evaluate((FBlockExpression)expr);
    } else if (expr instanceof FTypedElementRef) {
      return _evaluate((FTypedElementRef)expr);
    } else if (expr != null) {
      return _evaluate(expr);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(expr).toString());
    }
  }
}
