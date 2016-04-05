package org.franca.core.dsl.tests.compare;

import java.util.Arrays;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.franca.core.dsl.tests.compare.ComparisonHtmlReportGenerator;
import org.franca.core.franca.FModel;

@SuppressWarnings("all")
public class FrancaComparisonHtmlReportGenerator extends ComparisonHtmlReportGenerator {
  protected String _generateModelElement(final FModel n, final int depth) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<tr> ");
    String _elvis = null;
    String _name = n.getName();
    if (_name != null) {
      _elvis = _name;
    } else {
      _elvis = "&lt;no-name&gt;";
    }
    String _td = this.td(depth, _elvis);
    _builder.append(_td, "");
    _builder.append(" <td>");
    String _simpleName = this.simpleName(n);
    _builder.append(_simpleName, "");
    _builder.append("</td> </tr>");
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
  
  public String generateModelElement(final Object n, final int depth) {
    if (n instanceof FModel) {
      return _generateModelElement((FModel)n, depth);
    } else if (n instanceof EObject) {
      return _generateModelElement((EObject)n, depth);
    } else if (n != null) {
      return _generateModelElement(n, depth);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(n, depth).toString());
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
