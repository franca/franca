package org.franca.core.dsl.tests.compare;

import java.util.Arrays;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.franca.core.dsl.tests.compare.ComparisonTextReportGenerator;
import org.franca.core.franca.FModel;

@SuppressWarnings("all")
public class FrancaComparisonTextReportGenerator extends ComparisonTextReportGenerator {
  protected String _generateModelElement(final FModel n) {
    StringConcatenation _builder = new StringConcatenation();
    {
      String _name = n.getName();
      boolean _isNullOrEmpty = StringExtensions.isNullOrEmpty(_name);
      boolean _not = (!_isNullOrEmpty);
      if (_not) {
        String _name_1 = n.getName();
        _builder.append(_name_1, "");
        _builder.append(" : ");
      }
    }
    String _simpleName = this.simpleName(n);
    _builder.append(_simpleName, "");
    return _builder.toString();
  }
  
  protected String _getName(final FModel n) {
    String _elvis = null;
    String _name = n.getName();
    if (_name != null) {
      _elvis = _name;
    } else {
      String _simpleName = this.simpleName(n);
      _elvis = _simpleName;
    }
    return _elvis;
  }
  
  public String generateModelElement(final Object n) {
    if (n instanceof FModel) {
      return _generateModelElement((FModel)n);
    } else if (n instanceof EObject) {
      return _generateModelElement((EObject)n);
    } else if (n != null) {
      return _generateModelElement(n);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(n).toString());
    }
  }
  
  public String getName(final Object n) {
    if (n instanceof FModel) {
      return _getName((FModel)n);
    } else if (n instanceof EObject) {
      return _getName((EObject)n);
    } else if (n != null) {
      return _getName(n);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(n).toString());
    }
  }
}
