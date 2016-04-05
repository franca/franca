package org.franca.core.dsl.tests.compare;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.compare.AttributeChange;
import org.eclipse.emf.compare.Diff;
import org.eclipse.emf.compare.Match;
import org.eclipse.emf.compare.ReferenceChange;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.franca.core.dsl.tests.compare.IComparisonReportGenerator;

@SuppressWarnings("all")
public abstract class ComparisonReportGeneratorBase implements IComparisonReportGenerator {
  protected enum Side {
    LEFT,
    
    RIGHT;
  }
  
  protected boolean hasDifferences(final Match m) {
    EList<Diff> _differences = m.getDifferences();
    int _size = _differences.size();
    boolean _greaterThan = (_size > 0);
    if (_greaterThan) {
      return true;
    }
    EList<Match> _submatches = m.getSubmatches();
    final Function1<Match, Boolean> _function = new Function1<Match, Boolean>() {
      public Boolean apply(final Match it) {
        return Boolean.valueOf(ComparisonReportGeneratorBase.this.hasDifferences(it));
      }
    };
    return IterableExtensions.<Match>exists(_submatches, _function);
  }
  
  protected String simpleName(final EObject o) {
    EClass _eClass = o.eClass();
    Class<?> _instanceClass = _eClass.getInstanceClass();
    return _instanceClass.getSimpleName();
  }
  
  protected String generateAttrValue(final AttributeChange ac, final ComparisonReportGeneratorBase.Side side) {
    String _xblockexpression = null;
    {
      EObject _switchResult = null;
      if (side != null) {
        switch (side) {
          case LEFT:
            Match _match = ac.getMatch();
            _switchResult = _match.getLeft();
            break;
          case RIGHT:
            Match _match_1 = ac.getMatch();
            _switchResult = _match_1.getRight();
            break;
          default:
            break;
        }
      }
      EAttribute _attribute = ac.getAttribute();
      final Object value = _switchResult.eGet(_attribute);
      _xblockexpression = this.generateAttrib(value);
    }
    return _xblockexpression;
  }
  
  protected String generateRefValue(final ReferenceChange rc, final ComparisonReportGeneratorBase.Side side) {
    String _xblockexpression = null;
    {
      Match _match = rc.getMatch();
      EObject _right = _match.getRight();
      boolean _equals = Objects.equal(_right, null);
      if (_equals) {
        return "null";
      }
      EObject _switchResult = null;
      if (side != null) {
        switch (side) {
          case LEFT:
            Match _match_1 = rc.getMatch();
            _switchResult = _match_1.getLeft();
            break;
          case RIGHT:
            Match _match_2 = rc.getMatch();
            _switchResult = _match_2.getRight();
            break;
          default:
            break;
        }
      }
      final EObject value = _switchResult;
      _xblockexpression = this.generateRef(value);
    }
    return _xblockexpression;
  }
  
  protected String generateAttrib(final Object value) {
    String _xifexpression = null;
    boolean _notEquals = (!Objects.equal(value, null));
    if (_notEquals) {
      _xifexpression = value.toString();
    } else {
      _xifexpression = "null";
    }
    return _xifexpression;
  }
  
  protected String generateRef(final Object value) {
    String _xblockexpression = null;
    {
      boolean _equals = Objects.equal(value, null);
      if (_equals) {
        return "null";
      }
      if ((value instanceof EObject)) {
        return this.getName(value);
      }
      if ((value instanceof EList<?>)) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("[ ");
        {
          Iterable<EObject> _filter = Iterables.<EObject>filter(((Iterable<?>)value), EObject.class);
          boolean _hasElements = false;
          for(final EObject o : _filter) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            String _simpleName = this.simpleName(o);
            _builder.append(_simpleName, "");
          }
        }
        _builder.append(" ]");
        return _builder.toString();
      }
      _xblockexpression = "??";
    }
    return _xblockexpression;
  }
  
  protected String _getName(final Object o) {
    StringConcatenation _builder = new StringConcatenation();
    Class<?> _class = o.getClass();
    String _simpleName = _class.getSimpleName();
    _builder.append(_simpleName, "");
    return _builder.toString();
  }
  
  protected String _getName(final EObject o) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EObject _eContainer = o.eContainer();
      boolean _notEquals = (!Objects.equal(_eContainer, null));
      if (_notEquals) {
        EObject _eContainer_1 = o.eContainer();
        String _name = this.getName(_eContainer_1);
        _builder.append(_name, "");
        _builder.append(".");
      }
    }
    String _simpleName = this.simpleName(o);
    _builder.append(_simpleName, "");
    return _builder.toString();
  }
  
  protected String getName(final Object o) {
    if (o instanceof EObject) {
      return _getName((EObject)o);
    } else if (o != null) {
      return _getName(o);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(o).toString());
    }
  }
}
