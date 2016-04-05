package org.franca.core.dsl.tests.compare;

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
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.franca.core.dsl.tests.compare.ComparisonReportGeneratorBase;

@SuppressWarnings("all")
public class ComparisonTextReportGenerator extends ComparisonReportGeneratorBase {
  public String generateReport(final Match m) {
    return this.generateMatch(m);
  }
  
  protected String generateMatch(final Match m) {
    StringConcatenation _builder = new StringConcatenation();
    EObject _left = m.getLeft();
    String _generateModelElement = null;
    if (_left!=null) {
      _generateModelElement=this.generateModelElement(_left);
    }
    _builder.append(_generateModelElement, "");
    _builder.newLineIfNotEmpty();
    {
      EList<Match> _submatches = m.getSubmatches();
      final Function1<Match, Boolean> _function = new Function1<Match, Boolean>() {
        public Boolean apply(final Match it) {
          return Boolean.valueOf(ComparisonTextReportGenerator.this.hasDifferences(it));
        }
      };
      Iterable<Match> _filter = IterableExtensions.<Match>filter(_submatches, _function);
      for(final Match s : _filter) {
        _builder.append("  ");
        String _generateMatch = this.generateMatch(s);
        _builder.append(_generateMatch, "  ");
        _builder.newLineIfNotEmpty();
        {
          EList<Diff> _differences = s.getDifferences();
          for(final Diff d : _differences) {
            _builder.append("  ");
            _builder.append("  ");
            DifferenceKind _kind = d.getKind();
            _builder.append(_kind, "    ");
            _builder.append(" - ");
            String _generateDiff = this.generateDiff(d);
            _builder.append(_generateDiff, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder.toString();
  }
  
  protected String _generateDiff(final AttributeChange ac) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("A ");
    EAttribute _attribute = ac.getAttribute();
    String _name = _attribute.getName();
    _builder.append(_name, "");
    _builder.append("  ");
    String _generateAttrValue = this.generateAttrValue(ac, ComparisonReportGeneratorBase.Side.LEFT);
    _builder.append(_generateAttrValue, "");
    _builder.append(" - ");
    String _generateAttrValue_1 = this.generateAttrValue(ac, ComparisonReportGeneratorBase.Side.RIGHT);
    _builder.append(_generateAttrValue_1, "");
    return _builder.toString();
  }
  
  protected String _generateDiff(final ReferenceChange rc) {
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
            _builder.append("R ");
            EReference _reference = rc.getReference();
            String _name = _reference.getName();
            _builder.append(_name, "");
            _builder.append("  ");
            EObject _value_1 = rc.getValue();
            String _generateRef = this.generateRef(_value_1);
            _builder.append(_generateRef, "");
            _builder.append(" - ");
            String _generateRefValue = this.generateRefValue(rc, ComparisonReportGeneratorBase.Side.RIGHT);
            _builder.append(_generateRefValue, "");
            _switchResult = _builder.toString();
            break;
          case CHANGE:
            StringConcatenation _builder_1 = new StringConcatenation();
            _builder_1.append("R ");
            EReference _reference_1 = rc.getReference();
            String _name_1 = _reference_1.getName();
            _builder_1.append(_name_1, "");
            _builder_1.append("  ");
            EObject _value_2 = rc.getValue();
            String _generateRef_1 = this.generateRef(_value_2);
            _builder_1.append(_generateRef_1, "");
            _builder_1.append(" - ");
            String _generateRefValue_1 = this.generateRefValue(rc, ComparisonReportGeneratorBase.Side.RIGHT);
            _builder_1.append(_generateRefValue_1, "");
            _switchResult = _builder_1.toString();
            break;
          default:
            StringConcatenation _builder_2 = new StringConcatenation();
            _builder_2.append("R ");
            EReference _reference_2 = rc.getReference();
            String _name_2 = _reference_2.getName();
            _builder_2.append(_name_2, "");
            _builder_2.append("  ");
            EObject _left = valueMatch.getLeft();
            String _generateRef_2 = this.generateRef(_left);
            _builder_2.append(_generateRef_2, "");
            _builder_2.append(" - ");
            EObject _right = valueMatch.getRight();
            String _generateRef_3 = this.generateRef(_right);
            _builder_2.append(_generateRef_3, "");
            _switchResult = _builder_2.toString();
            break;
        }
      } else {
        StringConcatenation _builder_2 = new StringConcatenation();
        _builder_2.append("R ");
        EReference _reference_2 = rc.getReference();
        String _name_2 = _reference_2.getName();
        _builder_2.append(_name_2, "");
        _builder_2.append("  ");
        EObject _left = valueMatch.getLeft();
        String _generateRef_2 = this.generateRef(_left);
        _builder_2.append(_generateRef_2, "");
        _builder_2.append(" - ");
        EObject _right = valueMatch.getRight();
        String _generateRef_3 = this.generateRef(_right);
        _builder_2.append(_generateRef_3, "");
        _switchResult = _builder_2.toString();
      }
      _xblockexpression = _switchResult;
    }
    return _xblockexpression;
  }
  
  protected String _generateModelElement(final Object o) {
    StringConcatenation _builder = new StringConcatenation();
    String _string = o.toString();
    _builder.append(_string, "");
    return _builder.toString();
  }
  
  protected String _generateModelElement(final EObject o) {
    StringConcatenation _builder = new StringConcatenation();
    String _simpleName = this.simpleName(o);
    _builder.append(_simpleName, "");
    return _builder.toString();
  }
  
  protected String generateDiff(final Diff ac) {
    if (ac instanceof AttributeChange) {
      return _generateDiff((AttributeChange)ac);
    } else if (ac instanceof ReferenceChange) {
      return _generateDiff((ReferenceChange)ac);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(ac).toString());
    }
  }
  
  protected String generateModelElement(final Object o) {
    if (o instanceof EObject) {
      return _generateModelElement((EObject)o);
    } else if (o != null) {
      return _generateModelElement(o);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(o).toString());
    }
  }
}
