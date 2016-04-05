package org.franca.core.dsl.tests.compare;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.compare.AttributeChange;
import org.eclipse.emf.compare.Comparison;
import org.eclipse.emf.compare.Diff;
import org.eclipse.emf.compare.DifferenceKind;
import org.eclipse.emf.compare.Match;
import org.eclipse.emf.compare.ReferenceChange;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.franca.core.dsl.tests.compare.ComparisonReportGeneratorBase;

@SuppressWarnings("all")
public class ComparisonHtmlReportGenerator extends ComparisonReportGeneratorBase {
  public String generateReport(final Match m) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<html>");
    _builder.newLine();
    _builder.append("<head>");
    _builder.newLine();
    _builder.append("<title>EMF Compare Diff Report</title>");
    _builder.newLine();
    _builder.append("<style>");
    _builder.newLine();
    _builder.append("table { margin: 0; font-family: Consolas, monaco, monospace; }");
    _builder.newLine();
    _builder.append("td { padding: 2px; }");
    _builder.newLine();
    _builder.newLine();
    _builder.append("tr.add \t  { color: White; background-color: Green;  }");
    _builder.newLine();
    _builder.append("tr.change { background-color: Yellow; }");
    _builder.newLine();
    _builder.append("tr.delete { color: White; background-color: Red;    }");
    _builder.newLine();
    _builder.newLine();
    {
      ExclusiveRange _doubleDotLessThan = new ExclusiveRange(0, 10, true);
      for(final Integer i : _doubleDotLessThan) {
        _builder.append("td.l");
        _builder.append(i, "");
        _builder.append(" { padding-left: ");
        _builder.append((10 * (i).intValue()), "");
        _builder.append("px; }");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</style>");
    _builder.newLine();
    _builder.append("</head>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<body>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<table>");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("<thead>");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("<th>Name</th><th>Type</th><th>Modification</th><th>Left</th><th>Right</th>");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("</thead>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("\t");
    String _generateMatch = this.generateMatch(m);
    _builder.append(_generateMatch, "\t");
    _builder.newLineIfNotEmpty();
    _builder.append("</table>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("</body>");
    _builder.newLine();
    _builder.append("</html>");
    _builder.newLine();
    return _builder.toString();
  }
  
  public String tr(final Diff d, final String content) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<tr class=");
    DifferenceKind _kind = d.getKind();
    String _string = _kind.toString();
    String _lowerCase = _string.toLowerCase();
    _builder.append(_lowerCase, "");
    _builder.append(">");
    _builder.append(content, "");
    _builder.append("</tr>");
    return _builder.toString();
  }
  
  public String td(final int depth) {
    return this.td(depth, null);
  }
  
  public String td(final int depth, final String content) {
    String _xblockexpression = null;
    {
      if ((depth > 0)) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("<td class=l");
        _builder.append(depth, "");
        _builder.append(">");
        _builder.append(content, "");
        _builder.append("</td>");
        return _builder.toString();
      }
      StringConcatenation _builder_1 = new StringConcatenation();
      _builder_1.append("<td>");
      _builder_1.append(content, "");
      _builder_1.append("</td>");
      _xblockexpression = _builder_1.toString();
    }
    return _xblockexpression;
  }
  
  public String generateMatch(final Match m) {
    return this.generateMatch(m, 0);
  }
  
  public String generateMatch(final Match m, final int depth) {
    StringConcatenation _builder = new StringConcatenation();
    EObject _left = m.getLeft();
    String _generateModelElement = null;
    if (_left!=null) {
      _generateModelElement=this.generateModelElement(_left, depth);
    }
    _builder.append(_generateModelElement, "");
    _builder.newLineIfNotEmpty();
    {
      EList<Diff> _differences = m.getDifferences();
      for(final Diff d : _differences) {
        String _generateDiff = this.generateDiff(d, (depth + 1));
        _builder.append(_generateDiff, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      EList<Match> _submatches = m.getSubmatches();
      final Function1<Match, Boolean> _function = new Function1<Match, Boolean>() {
        public Boolean apply(final Match it) {
          return Boolean.valueOf(ComparisonHtmlReportGenerator.this.hasDifferences(it));
        }
      };
      Iterable<Match> _filter = IterableExtensions.<Match>filter(_submatches, _function);
      for(final Match s : _filter) {
        String _generateMatch = this.generateMatch(s, (depth + 1));
        _builder.append(_generateMatch, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder.toString();
  }
  
  protected String _generateDiff(final AttributeChange ac, final int depth) {
    StringConcatenation _builder = new StringConcatenation();
    EAttribute _attribute = ac.getAttribute();
    String _name = _attribute.getName();
    String _td = this.td(depth, _name);
    _builder.append(_td, "");
    _builder.newLineIfNotEmpty();
    _builder.append("<td>");
    EAttribute _attribute_1 = ac.getAttribute();
    String _simpleName = this.simpleName(_attribute_1);
    _builder.append(_simpleName, "");
    _builder.append("</td>");
    _builder.newLineIfNotEmpty();
    _builder.append("<td>");
    DifferenceKind _kind = ac.getKind();
    _builder.append(_kind, "");
    _builder.append("</td>");
    _builder.newLineIfNotEmpty();
    _builder.append("<td>");
    String _generateAttrValue = this.generateAttrValue(ac, ComparisonReportGeneratorBase.Side.LEFT);
    _builder.append(_generateAttrValue, "");
    _builder.append("</td>");
    _builder.newLineIfNotEmpty();
    _builder.append("<td>");
    String _generateAttrValue_1 = this.generateAttrValue(ac, ComparisonReportGeneratorBase.Side.RIGHT);
    _builder.append(_generateAttrValue_1, "");
    _builder.append("</td>");
    _builder.newLineIfNotEmpty();
    return this.tr(ac, _builder.toString());
  }
  
  protected String _generateDiff(final ReferenceChange rc, final int depth) {
    String _xblockexpression = null;
    {
      Match _match = rc.getMatch();
      Comparison _comparison = _match.getComparison();
      EObject _value = rc.getValue();
      final Match valueMatch = _comparison.getMatch(_value);
      String _switchResult = null;
      DifferenceKind _kind = rc.getKind();
      if (_kind != null) {
        switch (_kind) {
          case ADD:
            StringConcatenation _builder = new StringConcatenation();
            EReference _reference = rc.getReference();
            String _name = _reference.getName();
            String _td = this.td(depth, _name);
            _builder.append(_td, "");
            _builder.newLineIfNotEmpty();
            _builder.append("<td>");
            EReference _reference_1 = rc.getReference();
            String _simpleName = this.simpleName(_reference_1);
            _builder.append(_simpleName, "");
            _builder.append("</td>");
            _builder.newLineIfNotEmpty();
            _builder.append("<td>");
            DifferenceKind _kind_1 = rc.getKind();
            _builder.append(_kind_1, "");
            _builder.append("</td>");
            _builder.newLineIfNotEmpty();
            _builder.append("<td>");
            EObject _value_1 = rc.getValue();
            String _generateRef = this.generateRef(_value_1);
            _builder.append(_generateRef, "");
            _builder.append("</td>");
            _builder.newLineIfNotEmpty();
            _builder.append("<td></td>");
            _builder.newLine();
            _switchResult = this.tr(rc, _builder.toString());
            break;
          case CHANGE:
            StringConcatenation _builder_1 = new StringConcatenation();
            EReference _reference_2 = rc.getReference();
            String _name_1 = _reference_2.getName();
            String _td_1 = this.td(depth, _name_1);
            _builder_1.append(_td_1, "");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("<td>");
            EReference _reference_3 = rc.getReference();
            String _simpleName_1 = this.simpleName(_reference_3);
            _builder_1.append(_simpleName_1, "");
            _builder_1.append("</td>");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("<td>");
            DifferenceKind _kind_2 = rc.getKind();
            _builder_1.append(_kind_2, "");
            _builder_1.append("</td>");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("<td>");
            EObject _value_2 = rc.getValue();
            String _generateRef_1 = this.generateRef(_value_2);
            _builder_1.append(_generateRef_1, "");
            _builder_1.append("</td>");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("<td></td>");
            _builder_1.newLine();
            _switchResult = this.tr(rc, _builder_1.toString());
            break;
          default:
            StringConcatenation _builder_2 = new StringConcatenation();
            EReference _reference_4 = rc.getReference();
            String _name_2 = _reference_4.getName();
            String _td_2 = this.td(depth, _name_2);
            _builder_2.append(_td_2, "");
            _builder_2.newLineIfNotEmpty();
            _builder_2.append("<td>");
            EReference _reference_5 = rc.getReference();
            String _simpleName_2 = this.simpleName(_reference_5);
            _builder_2.append(_simpleName_2, "");
            _builder_2.append("</td>");
            _builder_2.newLineIfNotEmpty();
            _builder_2.append("<td>");
            DifferenceKind _kind_3 = rc.getKind();
            _builder_2.append(_kind_3, "");
            _builder_2.append("</td>");
            _builder_2.newLineIfNotEmpty();
            _builder_2.append("<td>");
            EObject _left = valueMatch.getLeft();
            String _generateRef_2 = this.generateRef(_left);
            _builder_2.append(_generateRef_2, "");
            _builder_2.append("</td>");
            _builder_2.newLineIfNotEmpty();
            _builder_2.append("<td>");
            EObject _right = valueMatch.getRight();
            String _generateRef_3 = this.generateRef(_right);
            _builder_2.append(_generateRef_3, "");
            _builder_2.append("</td>");
            _builder_2.newLineIfNotEmpty();
            _switchResult = this.tr(rc, _builder_2.toString());
            break;
        }
      } else {
        StringConcatenation _builder_2 = new StringConcatenation();
        EReference _reference_4 = rc.getReference();
        String _name_2 = _reference_4.getName();
        String _td_2 = this.td(depth, _name_2);
        _builder_2.append(_td_2, "");
        _builder_2.newLineIfNotEmpty();
        _builder_2.append("<td>");
        EReference _reference_5 = rc.getReference();
        String _simpleName_2 = this.simpleName(_reference_5);
        _builder_2.append(_simpleName_2, "");
        _builder_2.append("</td>");
        _builder_2.newLineIfNotEmpty();
        _builder_2.append("<td>");
        DifferenceKind _kind_3 = rc.getKind();
        _builder_2.append(_kind_3, "");
        _builder_2.append("</td>");
        _builder_2.newLineIfNotEmpty();
        _builder_2.append("<td>");
        EObject _left = valueMatch.getLeft();
        String _generateRef_2 = this.generateRef(_left);
        _builder_2.append(_generateRef_2, "");
        _builder_2.append("</td>");
        _builder_2.newLineIfNotEmpty();
        _builder_2.append("<td>");
        EObject _right = valueMatch.getRight();
        String _generateRef_3 = this.generateRef(_right);
        _builder_2.append(_generateRef_3, "");
        _builder_2.append("</td>");
        _builder_2.newLineIfNotEmpty();
        _switchResult = this.tr(rc, _builder_2.toString());
      }
      _xblockexpression = _switchResult;
    }
    return _xblockexpression;
  }
  
  protected String _generateModelElement(final Object o, final int depth) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<tr> ");
    String _td = this.td(depth);
    _builder.append(_td, "");
    _builder.append("  <td>");
    String _string = o.toString();
    _builder.append(_string, "");
    _builder.append("</td> </tr>");
    return _builder.toString();
  }
  
  protected String _generateModelElement(final EObject o, final int depth) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<tr> ");
    String _td = this.td(depth);
    _builder.append(_td, "");
    _builder.append(" <td>");
    String _simpleName = this.simpleName(o);
    _builder.append(_simpleName, "");
    _builder.append("</td> </tr>");
    return _builder.toString();
  }
  
  public String generateRef(final Object value) {
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
        _builder.append("<ol>");
        {
          Iterable<EObject> _filter = Iterables.<EObject>filter(((Iterable<?>)value), EObject.class);
          for(final EObject o : _filter) {
            _builder.append("<li>");
            String _simpleName = this.simpleName(o);
            _builder.append(_simpleName, "");
            _builder.append("</li>");
          }
        }
        _builder.append("</ol>");
        return _builder.toString();
      }
      _xblockexpression = "??";
    }
    return _xblockexpression;
  }
  
  protected String generateDiff(final Diff ac, final int depth) {
    if (ac instanceof AttributeChange) {
      return _generateDiff((AttributeChange)ac, depth);
    } else if (ac instanceof ReferenceChange) {
      return _generateDiff((ReferenceChange)ac, depth);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(ac, depth).toString());
    }
  }
  
  protected String generateModelElement(final Object o, final int depth) {
    if (o instanceof EObject) {
      return _generateModelElement((EObject)o, depth);
    } else if (o != null) {
      return _generateModelElement(o, depth);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(o, depth).toString());
    }
  }
}
