package org.franca.connectors.c_header;

import com.google.common.base.Objects;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBasicTypeId;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FTypeDef;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FUnionType;

@SuppressWarnings("all")
public class Franca2CHeaderTransformation {
  private static String LINE_BREAK = "\n";
  
  public StringBuffer transform(final FModel model) {
    StringBuilder _stringBuilder = new StringBuilder();
    final StringBuilder sb = _stringBuilder;
    EList<FTypeCollection> _typeCollections = model.getTypeCollections();
    FTypeCollection _get = _typeCollections.get(0);
    EList<FType> _types = _get.getTypes();
    for (final FType type : _types) {
      {
        String _genFType = this.genFType(type);
        sb.append(_genFType);
        sb.append(Franca2CHeaderTransformation.LINE_BREAK);
      }
    }
    sb.append(Franca2CHeaderTransformation.LINE_BREAK);
    EList<FInterface> _interfaces = model.getInterfaces();
    FInterface _get_1 = _interfaces.get(0);
    EList<FMethod> _methods = _get_1.getMethods();
    for (final FMethod method : _methods) {
      {
        String _genFMethod = this.genFMethod(method);
        sb.append(_genFMethod);
        sb.append(Franca2CHeaderTransformation.LINE_BREAK);
      }
    }
    sb.append(Franca2CHeaderTransformation.LINE_BREAK);
    EList<FInterface> _interfaces_1 = model.getInterfaces();
    FInterface _get_2 = _interfaces_1.get(0);
    EList<FAttribute> _attributes = _get_2.getAttributes();
    for (final FAttribute attribute : _attributes) {
      {
        String _genFAttribute = this.genFAttribute(attribute);
        sb.append(_genFAttribute);
        sb.append(Franca2CHeaderTransformation.LINE_BREAK);
      }
    }
    String _string = sb.toString();
    StringBuffer _stringBuffer = new StringBuffer(_string);
    return _stringBuffer;
  }
  
  public String genFMethod(final FMethod method) {
    StringBuilder _stringBuilder = new StringBuilder();
    final StringBuilder sb = _stringBuilder;
    EList<FArgument> _outArgs = method.getOutArgs();
    FArgument _get = _outArgs.get(0);
    FTypeRef _type = _get.getType();
    String _genFTypeRef = this.genFTypeRef(_type);
    sb.append(_genFTypeRef);
    sb.append(" ");
    String _name = method.getName();
    sb.append(_name);
    sb.append("(");
    int i = 0;
    EList<FArgument> _inArgs = method.getInArgs();
    for (final FArgument argument : _inArgs) {
      {
        String _genFArgument = this.genFArgument(argument);
        sb.append(_genFArgument);
        EList<FArgument> _inArgs_1 = method.getInArgs();
        int _size = _inArgs_1.size();
        int _minus = (_size - 1);
        boolean _lessThan = (i < _minus);
        if (_lessThan) {
          sb.append(", ");
        }
        int _plus = (i + 1);
        i = _plus;
      }
    }
    sb.append(");");
    return sb.toString();
  }
  
  public String genFAttribute(final FAttribute attribute) {
    FTypeRef _type = attribute.getType();
    String _genFTypeRef = this.genFTypeRef(_type);
    String _plus = ("extern " + _genFTypeRef);
    String _plus_1 = (_plus + " ");
    String _name = attribute.getName();
    String _plus_2 = (_plus_1 + _name);
    String _plus_3 = (_plus_2 + ";");
    return _plus_3;
  }
  
  public String genFArgument(final FArgument argument) {
    FTypeRef _type = argument.getType();
    String _genFTypeRef = this.genFTypeRef(_type);
    String _plus = (_genFTypeRef + " ");
    String _name = argument.getName();
    String _plus_1 = (_plus + _name);
    return _plus_1;
  }
  
  protected String _genFType(final FStructType structType) {
    StringBuilder _stringBuilder = new StringBuilder();
    final StringBuilder sb = _stringBuilder;
    sb.append("typedef struct {");
    sb.append(Franca2CHeaderTransformation.LINE_BREAK);
    EList<FField> _elements = structType.getElements();
    for (final FField element : _elements) {
      {
        String _genFField = this.genFField(element);
        String _plus = ("\t" + _genFField);
        sb.append(_plus);
        sb.append(";\n");
      }
    }
    String _name = structType.getName();
    String _plus = ("} " + _name);
    String _plus_1 = (_plus + ";");
    sb.append(_plus_1);
    return sb.toString();
  }
  
  protected String _genFType(final FUnionType unionType) {
    StringBuilder _stringBuilder = new StringBuilder();
    final StringBuilder sb = _stringBuilder;
    sb.append("typedef union {");
    sb.append(Franca2CHeaderTransformation.LINE_BREAK);
    EList<FField> _elements = unionType.getElements();
    for (final FField element : _elements) {
      {
        String _genFField = this.genFField(element);
        String _plus = ("\t" + _genFField);
        sb.append(_plus);
        sb.append(";\n");
      }
    }
    String _name = unionType.getName();
    String _plus = ("} " + _name);
    String _plus_1 = (_plus + ";");
    sb.append(_plus_1);
    return sb.toString();
  }
  
  protected String _genFType(final FEnumerationType enumerationType) {
    StringBuilder _stringBuilder = new StringBuilder();
    final StringBuilder sb = _stringBuilder;
    sb.append("typedef enum {");
    sb.append(Franca2CHeaderTransformation.LINE_BREAK);
    int i = 0;
    EList<FEnumerator> _enumerators = enumerationType.getEnumerators();
    for (final FEnumerator element : _enumerators) {
      {
        String _genFEnumerator = this.genFEnumerator(element);
        String _plus = ("\t" + _genFEnumerator);
        sb.append(_plus);
        EList<FEnumerator> _enumerators_1 = enumerationType.getEnumerators();
        int _size = _enumerators_1.size();
        int _minus = (_size - 1);
        boolean _lessThan = (i < _minus);
        if (_lessThan) {
          sb.append(",");
        }
        sb.append(Franca2CHeaderTransformation.LINE_BREAK);
        int _plus_1 = (i + 1);
        i = _plus_1;
      }
    }
    String _name = enumerationType.getName();
    String _plus = ("} " + _name);
    String _plus_1 = (_plus + ";");
    sb.append(_plus_1);
    return sb.toString();
  }
  
  protected String _genFType(final FTypeDef typeDef) {
    String _xifexpression = null;
    FTypeRef _actualType = typeDef.getActualType();
    FType _derived = _actualType.getDerived();
    boolean _equals = Objects.equal(_derived, null);
    if (_equals) {
      FTypeRef _actualType_1 = typeDef.getActualType();
      FBasicTypeId _predefined = _actualType_1.getPredefined();
      String _genFBasicTypeId = this.genFBasicTypeId(_predefined);
      _xifexpression = _genFBasicTypeId;
    } else {
      FTypeRef _actualType_2 = typeDef.getActualType();
      FType _derived_1 = _actualType_2.getDerived();
      String _name = _derived_1.getName();
      _xifexpression = _name;
    }
    String _plus = ("typedef " + _xifexpression);
    String _plus_1 = (_plus + 
      " ");
    String _name_1 = typeDef.getName();
    String _plus_2 = (_plus_1 + _name_1);
    String _plus_3 = (_plus_2 + 
      ";");
    return _plus_3;
  }
  
  public String genFEnumerator(final FEnumerator enumerator) {
    String _name = enumerator.getName();
    String _xifexpression = null;
    boolean _and = false;
    String _value = enumerator.getValue();
    boolean _notEquals = (!Objects.equal(_value, null));
    if (!_notEquals) {
      _and = false;
    } else {
      String _value_1 = enumerator.getValue();
      boolean _isEmpty = _value_1.isEmpty();
      boolean _not = (!_isEmpty);
      _and = (_notEquals && _not);
    }
    if (_and) {
      String _value_2 = enumerator.getValue();
      String _plus = (" = " + _value_2);
      _xifexpression = _plus;
    } else {
      _xifexpression = "";
    }
    String _plus_1 = (_name + _xifexpression);
    return _plus_1;
  }
  
  public String genFField(final FField field) {
    FTypeRef _type = field.getType();
    String _genFTypeRef = this.genFTypeRef(_type);
    String _plus = (_genFTypeRef + " ");
    String _name = field.getName();
    String _plus_1 = (_plus + _name);
    return _plus_1;
  }
  
  public String genFTypeRef(final FTypeRef typeRef) {
    String _xifexpression = null;
    FType _derived = typeRef.getDerived();
    boolean _equals = Objects.equal(_derived, null);
    if (_equals) {
      FBasicTypeId _predefined = typeRef.getPredefined();
      String _genFBasicTypeId = this.genFBasicTypeId(_predefined);
      _xifexpression = _genFBasicTypeId;
    } else {
      FType _derived_1 = typeRef.getDerived();
      String _name = _derived_1.getName();
      _xifexpression = _name;
    }
    return _xifexpression;
  }
  
  public String genFBasicTypeId(final FBasicTypeId id) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.BOOLEAN)) {
        _matched=true;
        _switchResult = "bool";
      }
    }
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.INT16)) {
        _matched=true;
        _switchResult = "short";
      }
    }
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.INT32)) {
        _matched=true;
        _switchResult = "int";
      }
    }
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.INT64)) {
        _matched=true;
        _switchResult = "long";
      }
    }
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.UINT16)) {
        _matched=true;
        _switchResult = "unsigned short";
      }
    }
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.UINT32)) {
        _matched=true;
        _switchResult = "unsigned int";
      }
    }
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.UINT64)) {
        _matched=true;
        _switchResult = "unsigned long";
      }
    }
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.DOUBLE)) {
        _matched=true;
        _switchResult = "double";
      }
    }
    if (!_matched) {
      if (Objects.equal(id,FBasicTypeId.FLOAT)) {
        _matched=true;
        _switchResult = "float";
      }
    }
    if (!_matched) {
      _switchResult = "int";
    }
    return _switchResult;
  }
  
  public String genFType(final FType structType) {
    if (structType instanceof FStructType) {
      return _genFType((FStructType)structType);
    } else if (structType instanceof FUnionType) {
      return _genFType((FUnionType)structType);
    } else if (structType instanceof FEnumerationType) {
      return _genFType((FEnumerationType)structType);
    } else if (structType instanceof FTypeDef) {
      return _genFType((FTypeDef)structType);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(structType).toString());
    }
  }
}
