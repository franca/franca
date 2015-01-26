package org.franca.connectors.idl;

import com.google.common.base.Objects;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.nodemodel.ICompositeNode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.franca.FAnnotation;
import org.franca.core.franca.FAnnotationBlock;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBasicTypeId;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FConstantDef;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FExpression;
import org.franca.core.franca.FField;
import org.franca.core.franca.FInitializerExpression;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMapType;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FModelElement;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FTypeDef;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FUnionType;

@SuppressWarnings("all")
public class Franca2IdlConverter {
  public Franca2IdlConverter(final String file) {
    FrancaIDLStandaloneSetup.doSetup();
    ResourceSetImpl resourceSet = new ResourceSetImpl();
    URI _createFileURI = URI.createFileURI(file);
    final Resource createResource = resourceSet.getResource(_createFileURI, true);
    EList<EObject> _contents = createResource.getContents();
    EObject _get = _contents.get(0);
    this.root = _get;
  }
  
  private String IN = "in";
  
  private String OUT = "out";
  
  private EObject root;
  
  public CharSequence generateContents() {
    CharSequence _xblockexpression = null;
    {
      FModel franca = null;
      if ((this.root instanceof FModel)) {
        franca = ((FModel) this.root);
      }
      final Function1<FInterface, CharSequence> _function = new Function1<FInterface, CharSequence>() {
        public CharSequence apply(final FInterface it) {
          return Franca2IdlConverter.this.transformInterface(it);
        }
      };
      final Function1<FInterface, CharSequence> function = _function;
      EList<FInterface> _interfaces = franca.getInterfaces();
      List<CharSequence> _map = null;
      if (_interfaces!=null) {
        _map=ListExtensions.<FInterface, CharSequence>map(_interfaces, function);
      }
      final List<CharSequence> interfaces = _map;
      final Function1<FTypeCollection, CharSequence> _function_1 = new Function1<FTypeCollection, CharSequence>() {
        public CharSequence apply(final FTypeCollection it) {
          return Franca2IdlConverter.this.tramsformTypeCollection(it);
        }
      };
      final Function1<FTypeCollection, CharSequence> function1 = _function_1;
      EList<FTypeCollection> _typeCollections = franca.getTypeCollections();
      List<CharSequence> _map_1 = null;
      if (_typeCollections!=null) {
        _map_1=ListExtensions.<FTypeCollection, CharSequence>map(_typeCollections, function1);
      }
      final List<CharSequence> typeCollections = _map_1;
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("module ");
      String _name = franca.getName();
      _builder.append(_name, "");
      _builder.append(" {");
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      String _join = IterableExtensions.join(interfaces);
      _builder.append(_join, "\t");
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      String _join_1 = IterableExtensions.join(typeCollections);
      _builder.append(_join_1, "\t");
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      _builder.append("};");
      _builder.newLine();
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence tramsformTypeCollection(final FTypeCollection typeCollection) {
    CharSequence _xblockexpression = null;
    {
      EList<FType> _types = typeCollection.getTypes();
      List<CharSequence> _map = null;
      if (_types!=null) {
        final Function1<FType, CharSequence> _function = new Function1<FType, CharSequence>() {
          public CharSequence apply(final FType it) {
            return Franca2IdlConverter.this.transformTypes(it);
          }
        };
        _map=ListExtensions.<FType, CharSequence>map(_types, _function);
      }
      final String types = IterableExtensions.join(_map, "\n");
      String typename = typeCollection.getName();
      EList<FConstantDef> _constants = typeCollection.getConstants();
      List<CharSequence> _map_1 = null;
      if (_constants!=null) {
        final Function1<FConstantDef, CharSequence> _function_1 = new Function1<FConstantDef, CharSequence>() {
          public CharSequence apply(final FConstantDef it) {
            return Franca2IdlConverter.this.transformConstants(it);
          }
        };
        _map_1=ListExtensions.<FConstantDef, CharSequence>map(_constants, _function_1);
      }
      String constants = IterableExtensions.join(_map_1, "\n");
      final String generateComment = this.generateComment(typeCollection);
      StringConcatenation _builder = new StringConcatenation();
      {
        boolean _and = false;
        boolean _notEquals = (!Objects.equal(generateComment, null));
        if (!_notEquals) {
          _and = false;
        } else {
          boolean _notEquals_1 = (!Objects.equal(generateComment, ""));
          _and = _notEquals_1;
        }
        if (_and) {
          _builder.append("/** ");
          _builder.append(generateComment, "");
          _builder.append(" ");
          _builder.newLineIfNotEmpty();
          _builder.append("*/");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      _builder.append("interface ");
      _builder.append(typename, "\t");
      _builder.append(" {");
      _builder.newLineIfNotEmpty();
      _builder.append("\t\t");
      _builder.append(types, "\t\t");
      _builder.newLineIfNotEmpty();
      _builder.append("\t\t");
      _builder.append(constants, "\t\t");
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      _builder.append("};");
      _builder.newLine();
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence transformConstants(final FConstantDef constant) {
    CharSequence _xblockexpression = null;
    {
      final String generateComment = this.generateComment(constant);
      StringConcatenation _builder = new StringConcatenation();
      {
        boolean _and = false;
        boolean _notEquals = (!Objects.equal(generateComment, null));
        if (!_notEquals) {
          _and = false;
        } else {
          boolean _notEquals_1 = (!Objects.equal(generateComment, ""));
          _and = _notEquals_1;
        }
        if (_and) {
          _builder.append("/** ");
          _builder.append(generateComment, "");
          _builder.append(" ");
          _builder.newLineIfNotEmpty();
          _builder.append("*/");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append(" ");
      _builder.append("const ");
      FTypeRef _type = constant.getType();
      String _transformType2TypeString = this.transformType2TypeString(_type);
      _builder.append(_transformType2TypeString, " ");
      _builder.append(" ");
      String _name = constant.getName();
      _builder.append(_name, " ");
      _builder.append(" = ");
      FInitializerExpression _rhs = constant.getRhs();
      ICompositeNode _node = NodeModelUtils.getNode(_rhs);
      String _tokenText = NodeModelUtils.getTokenText(_node);
      _builder.append(_tokenText, " ");
      _builder.append(";");
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public String generateComment(final FModelElement element) {
    String _xblockexpression = null;
    {
      final StringBuffer bufferText = new StringBuffer();
      FAnnotationBlock _comment = element.getComment();
      EList<FAnnotation> _elements = null;
      if (_comment!=null) {
        _elements=_comment.getElements();
      }
      if (_elements!=null) {
        final Procedure1<FAnnotation> _function = new Procedure1<FAnnotation>() {
          public void apply(final FAnnotation it) {
            String _rawText = it.getRawText();
            bufferText.append(_rawText);
          }
        };
        IterableExtensions.<FAnnotation>forEach(_elements, _function);
      }
      String _string = bufferText.toString();
      String str = _string.replaceAll("@description", "#comment");
      _xblockexpression = str;
    }
    return _xblockexpression;
  }
  
  /**
   * Mapping from Franca to IDL
   * Interface -- > Interface
   */
  public CharSequence transformInterface(final FInterface fInterface) {
    CharSequence _xblockexpression = null;
    {
      EList<FType> _types = fInterface.getTypes();
      List<CharSequence> _map = null;
      if (_types!=null) {
        final Function1<FType, CharSequence> _function = new Function1<FType, CharSequence>() {
          public CharSequence apply(final FType it) {
            return Franca2IdlConverter.this.transformTypes(it);
          }
        };
        _map=ListExtensions.<FType, CharSequence>map(_types, _function);
      }
      final String types = IterableExtensions.join(_map, "\n");
      FInterface _base = fInterface.getBase();
      String _name = null;
      if (_base!=null) {
        _name=_base.getName();
      }
      String baseInterface = _name;
      final String generateComment = this.generateComment(fInterface);
      EList<FConstantDef> _constants = fInterface.getConstants();
      List<CharSequence> _map_1 = null;
      if (_constants!=null) {
        final Function1<FConstantDef, CharSequence> _function_1 = new Function1<FConstantDef, CharSequence>() {
          public CharSequence apply(final FConstantDef it) {
            return Franca2IdlConverter.this.transformConstants(it);
          }
        };
        _map_1=ListExtensions.<FConstantDef, CharSequence>map(_constants, _function_1);
      }
      String constants = IterableExtensions.join(_map_1, "\n");
      EList<FBroadcast> _broadcasts = fInterface.getBroadcasts();
      List<CharSequence> _map_2 = null;
      if (_broadcasts!=null) {
        final Function1<FBroadcast, CharSequence> _function_2 = new Function1<FBroadcast, CharSequence>() {
          public CharSequence apply(final FBroadcast it) {
            return Franca2IdlConverter.this.transformBroadcasts(it);
          }
        };
        _map_2=ListExtensions.<FBroadcast, CharSequence>map(_broadcasts, _function_2);
      }
      String broadcasts = IterableExtensions.join(_map_2, "\n");
      StringConcatenation _builder = new StringConcatenation();
      {
        boolean _and = false;
        boolean _notEquals = (!Objects.equal(generateComment, null));
        if (!_notEquals) {
          _and = false;
        } else {
          boolean _notEquals_1 = (!Objects.equal(generateComment, ""));
          _and = _notEquals_1;
        }
        if (_and) {
          _builder.append("/** ");
          _builder.append(generateComment, "");
          _builder.append(" ");
          _builder.newLineIfNotEmpty();
          _builder.append("\t");
          _builder.append("*/");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      _builder.append("interface ");
      String _name_1 = fInterface.getName();
      _builder.append(_name_1, "\t");
      {
        boolean _notEquals_2 = (!Objects.equal(baseInterface, null));
        if (_notEquals_2) {
          _builder.append(":");
          _builder.append(baseInterface, "\t");
        }
      }
      _builder.append(" {");
      _builder.newLineIfNotEmpty();
      _builder.append("\t\t");
      EList<FAttribute> _attributes = fInterface.getAttributes();
      List<CharSequence> _map_3 = null;
      if (_attributes!=null) {
        final Function1<FAttribute, CharSequence> _function_3 = new Function1<FAttribute, CharSequence>() {
          public CharSequence apply(final FAttribute it) {
            return Franca2IdlConverter.this.transformAttributes(it);
          }
        };
        _map_3=ListExtensions.<FAttribute, CharSequence>map(_attributes, _function_3);
      }
      String _join = IterableExtensions.join(_map_3, "\n");
      _builder.append(_join, "\t\t");
      _builder.newLineIfNotEmpty();
      _builder.append(" \t\t");
      EList<FMethod> _methods = fInterface.getMethods();
      List<CharSequence> _map_4 = null;
      if (_methods!=null) {
        final Function1<FMethod, CharSequence> _function_4 = new Function1<FMethod, CharSequence>() {
          public CharSequence apply(final FMethod it) {
            return Franca2IdlConverter.this.transformMethods(it);
          }
        };
        _map_4=ListExtensions.<FMethod, CharSequence>map(_methods, _function_4);
      }
      String _join_1 = IterableExtensions.join(_map_4, "\n");
      _builder.append(_join_1, " \t\t");
      _builder.newLineIfNotEmpty();
      _builder.append(" \t\t");
      _builder.append(types, " \t\t");
      _builder.newLineIfNotEmpty();
      _builder.append(" \t\t");
      _builder.append(constants, " \t\t");
      _builder.newLineIfNotEmpty();
      _builder.append("\t");
      _builder.append("};");
      _builder.newLine();
      {
        boolean _and_1 = false;
        boolean _notEquals_3 = (!Objects.equal(broadcasts, null));
        if (!_notEquals_3) {
          _and_1 = false;
        } else {
          boolean _notEquals_4 = (!Objects.equal(broadcasts, ""));
          _and_1 = _notEquals_4;
        }
        if (_and_1) {
          _builder.append("\t");
          _builder.append("interface ");
          String _name_2 = fInterface.getName();
          _builder.append(_name_2, "\t");
          _builder.append("_client {");
          _builder.newLineIfNotEmpty();
          _builder.append("\t");
          _builder.append("\t");
          _builder.append(broadcasts, "\t\t");
          _builder.newLineIfNotEmpty();
          _builder.append("\t");
          _builder.append("};");
          _builder.newLine();
        }
      }
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence transformBroadcasts(final FBroadcast broadcast) {
    CharSequence _xblockexpression = null;
    {
      final String generateComment = this.generateComment(broadcast);
      String name = broadcast.getName();
      EList<FArgument> _outArgs = broadcast.getOutArgs();
      List<String> _map = null;
      if (_outArgs!=null) {
        final Function1<FArgument, String> _function = new Function1<FArgument, String>() {
          public String apply(final FArgument it) {
            return Franca2IdlConverter.this.transformArgument(it, "in");
          }
        };
        _map=ListExtensions.<FArgument, String>map(_outArgs, _function);
      }
      String arguments = IterableExtensions.join(_map, ",");
      StringConcatenation _builder = new StringConcatenation();
      {
        boolean _and = false;
        boolean _notEquals = (!Objects.equal(generateComment, null));
        if (!_notEquals) {
          _and = false;
        } else {
          boolean _notEquals_1 = (!Objects.equal(generateComment, ""));
          _and = _notEquals_1;
        }
        if (_and) {
          _builder.append("/**broadcast ");
          _builder.newLine();
          _builder.append("*");
          _builder.append(generateComment, "");
          _builder.append(" ");
          _builder.newLineIfNotEmpty();
          _builder.append("*/");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append("void ");
      _builder.append(name, "");
      _builder.append(" ( ");
      _builder.append(arguments, "");
      _builder.append(" );");
      _builder.newLineIfNotEmpty();
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence transformTypes(final FType type) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (type instanceof FArrayType) {
        _matched=true;
        CharSequence _xblockexpression = null;
        {
          final FArrayType fArrayType = ((FArrayType) type);
          StringConcatenation _builder = new StringConcatenation();
          _builder.append(" ");
          _builder.append("typedef ");
          FTypeRef _elementType = fArrayType.getElementType();
          String _transformType2TypeString = this.transformType2TypeString(_elementType);
          _builder.append(_transformType2TypeString, " ");
          _builder.append("[ ] ");
          String _name = fArrayType.getName();
          _builder.append(_name, " ");
          _builder.append(";");
          _xblockexpression = _builder;
        }
        _switchResult = _xblockexpression;
      }
    }
    if (!_matched) {
      if (type instanceof FStructType) {
        _matched=true;
        CharSequence _xblockexpression = null;
        {
          FStructType struct = ((FStructType) type);
          EList<FField> _elements = struct.getElements();
          final Function1<FField, CharSequence> _function = new Function1<FField, CharSequence>() {
            public CharSequence apply(final FField it) {
              return Franca2IdlConverter.this.transformFields(it);
            }
          };
          List<CharSequence> _map = ListExtensions.<FField, CharSequence>map(_elements, _function);
          final String fieldContent = IterableExtensions.join(_map, "\n");
          FStructType _base = struct.getBase();
          String _name = null;
          if (_base!=null) {
            _name=_base.getName();
          }
          String baseStruct = _name;
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("struct ");
          String _name_1 = struct.getName();
          _builder.append(_name_1, "");
          _builder.append(" ");
          {
            boolean _notEquals = (!Objects.equal(baseStruct, null));
            if (_notEquals) {
              _builder.append(":");
              _builder.append(baseStruct, "");
              _builder.append(" ");
            }
          }
          _builder.append("{");
          _builder.newLineIfNotEmpty();
          _builder.append("\t\t\t\t\t\t");
          _builder.append(fieldContent, "\t\t\t\t\t\t");
          _builder.newLineIfNotEmpty();
          _builder.append("\t\t\t\t\t\t");
          _builder.append("};");
          _builder.newLine();
          _xblockexpression = _builder;
        }
        _switchResult = _xblockexpression;
      }
    }
    if (!_matched) {
      if (type instanceof FUnionType) {
        _matched=true;
        CharSequence _xblockexpression = null;
        {
          FUnionType union = ((FUnionType) type);
          FUnionType _base = union.getBase();
          String _name = null;
          if (_base!=null) {
            _name=_base.getName();
          }
          String baseUnion = _name;
          EList<FField> _elements = union.getElements();
          final Function1<FField, CharSequence> _function = new Function1<FField, CharSequence>() {
            public CharSequence apply(final FField it) {
              return Franca2IdlConverter.this.transformFields(it);
            }
          };
          List<CharSequence> _map = ListExtensions.<FField, CharSequence>map(_elements, _function);
          final String fieldContent = IterableExtensions.join(_map, "\n");
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("union ");
          String _name_1 = union.getName();
          _builder.append(_name_1, "");
          _builder.append(" ");
          {
            boolean _notEquals = (!Objects.equal(baseUnion, null));
            if (_notEquals) {
              _builder.append(":");
              _builder.append(baseUnion, "");
              _builder.append(" ");
            }
          }
          _builder.append("{");
          _builder.newLineIfNotEmpty();
          _builder.append("\t\t\t\t\t\t");
          _builder.append(fieldContent, "\t\t\t\t\t\t");
          _builder.newLineIfNotEmpty();
          _builder.append("\t\t\t\t\t\t");
          _builder.append("};");
          _builder.newLine();
          _xblockexpression = _builder;
        }
        _switchResult = _xblockexpression;
      }
    }
    if (!_matched) {
      if (type instanceof FEnumerationType) {
        _matched=true;
        CharSequence _xblockexpression = null;
        {
          FEnumerationType enumtype = ((FEnumerationType) type);
          FEnumerationType _base = enumtype.getBase();
          String _name = null;
          if (_base!=null) {
            _name=_base.getName();
          }
          String baseEnum = _name;
          EList<FEnumerator> _enumerators = enumtype.getEnumerators();
          final Function1<FEnumerator, CharSequence> _function = new Function1<FEnumerator, CharSequence>() {
            public CharSequence apply(final FEnumerator it) {
              return Franca2IdlConverter.this.transformEnumerators(it);
            }
          };
          List<CharSequence> _map = ListExtensions.<FEnumerator, CharSequence>map(_enumerators, _function);
          final String Content = IterableExtensions.join(_map, ",\n");
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("enum ");
          String _name_1 = enumtype.getName();
          _builder.append(_name_1, "");
          _builder.append("  ");
          {
            boolean _notEquals = (!Objects.equal(baseEnum, null));
            if (_notEquals) {
              _builder.append(":");
              _builder.append(baseEnum, "");
              _builder.append(" ");
            }
          }
          _builder.append("{");
          _builder.newLineIfNotEmpty();
          _builder.append("\t\t\t\t\t\t");
          _builder.append(Content, "\t\t\t\t\t\t");
          _builder.newLineIfNotEmpty();
          _builder.append("\t\t\t\t\t\t");
          _builder.append("};");
          _builder.newLine();
          _xblockexpression = _builder;
        }
        _switchResult = _xblockexpression;
      }
    }
    if (!_matched) {
      if (type instanceof FMapType) {
        _matched=true;
        CharSequence _xblockexpression = null;
        {
          FMapType map = ((FMapType) type);
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("map_");
          String _name = map.getName();
          _builder.append(_name, "");
          _builder.append(" ");
          FTypeRef _keyType = map.getKeyType();
          String _transformType2TypeString = this.transformType2TypeString(_keyType);
          _builder.append(_transformType2TypeString, "");
          _builder.append("=>");
          FTypeRef _valueType = map.getValueType();
          String _transformType2TypeString_1 = this.transformType2TypeString(_valueType);
          _builder.append(_transformType2TypeString_1, "");
          _builder.append(" ;");
          _xblockexpression = _builder;
        }
        _switchResult = _xblockexpression;
      }
    }
    if (!_matched) {
      if (type instanceof FTypeDef) {
        _matched=true;
        CharSequence _xblockexpression = null;
        {
          FTypeDef typedef = ((FTypeDef) type);
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("typedef \t");
          FTypeRef _actualType = typedef.getActualType();
          String _transformType2TypeString = this.transformType2TypeString(_actualType);
          _builder.append(_transformType2TypeString, "");
          _builder.append(" ");
          String _name = ((FTypeDef)type).getName();
          _builder.append(_name, "");
          _builder.append(";");
          _xblockexpression = _builder;
        }
        _switchResult = _xblockexpression;
      }
    }
    return _switchResult;
  }
  
  public CharSequence isArray(final FTypeRef ref) {
    CharSequence _xifexpression = null;
    FType _derived = ref.getDerived();
    boolean _equals = Objects.equal(_derived, null);
    if (_equals) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append(" ");
      _xifexpression = _builder;
    } else {
      CharSequence _xblockexpression = null;
      {
        FType type = ref.getDerived();
        CharSequence _switchResult = null;
        boolean _matched = false;
        if (!_matched) {
          if (type instanceof FArrayType) {
            _matched=true;
            StringConcatenation _builder_1 = new StringConcatenation();
            _builder_1.append("[ ]");
            _switchResult = _builder_1;
          }
        }
        if (!_matched) {
          if (type instanceof FTypeDef) {
            _matched=true;
            FTypeRef _actualType = ((FTypeDef)type).getActualType();
            _switchResult = this.transformType2TypeString(_actualType);
          }
        }
        if (!_matched) {
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append(" ");
          _switchResult = _builder_1;
        }
        _xblockexpression = _switchResult;
      }
      _xifexpression = _xblockexpression;
    }
    return _xifexpression;
  }
  
  public CharSequence transformEnumerators(final FEnumerator eumerator) {
    CharSequence _xblockexpression = null;
    {
      String name = eumerator.getName();
      FExpression value = eumerator.getValue();
      StringConcatenation _builder = new StringConcatenation();
      _builder.append(name, "");
      _builder.append(" ");
      {
        boolean _notEquals = (!Objects.equal(value, null));
        if (_notEquals) {
          _builder.append("= ");
          FExpression _value = eumerator.getValue();
          ICompositeNode _node = NodeModelUtils.getNode(_value);
          String _tokenText = NodeModelUtils.getTokenText(_node);
          _builder.append(_tokenText, "");
        }
      }
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence transformFields(final FField field) {
    CharSequence _xblockexpression = null;
    {
      FTypeRef _type = field.getType();
      String type = this.transformType2TypeString(_type);
      String name = field.getName();
      final boolean isArray1 = field.isArray();
      FTypeRef _type_1 = field.getType();
      CharSequence isArray = this.isArray(_type_1);
      StringConcatenation _builder = new StringConcatenation();
      _builder.append(type, "");
      {
        if (isArray1) {
          _builder.append("[ ]");
        }
      }
      _builder.append(" ");
      _builder.append(name, "");
      _builder.append(";");
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence transformAttributes(final FAttribute attribute) {
    CharSequence _xblockexpression = null;
    {
      String name = attribute.getName();
      FTypeRef _type = attribute.getType();
      String _transformType2TypeString = null;
      if (_type!=null) {
        _transformType2TypeString=this.transformType2TypeString(_type);
      }
      String type = _transformType2TypeString;
      final String generateComment = this.generateComment(attribute);
      StringConcatenation _builder = new StringConcatenation();
      {
        boolean _and = false;
        boolean _notEquals = (!Objects.equal(generateComment, null));
        if (!_notEquals) {
          _and = false;
        } else {
          boolean _notEquals_1 = (!Objects.equal(generateComment, ""));
          _and = _notEquals_1;
        }
        if (_and) {
          _builder.append("/** ");
          _builder.append(generateComment, "");
          _builder.append(" ");
          _builder.newLineIfNotEmpty();
          _builder.append("*/");
        }
      }
      _builder.newLineIfNotEmpty();
      {
        boolean _isReadonly = attribute.isReadonly();
        if (_isReadonly) {
          _builder.append("readonly");
        }
      }
      _builder.append(name, "");
      _builder.append(" ");
      _builder.append(type, "");
      _builder.append(" ;");
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public CharSequence transformMethods(final FMethod method) {
    CharSequence _xblockexpression = null;
    {
      final String transformParameters1 = this.transformParameters(method);
      final String generateComment = this.generateComment(method);
      StringConcatenation _builder = new StringConcatenation();
      {
        boolean _and = false;
        boolean _notEquals = (!Objects.equal(generateComment, null));
        if (!_notEquals) {
          _and = false;
        } else {
          boolean _notEquals_1 = (!Objects.equal(generateComment, ""));
          _and = _notEquals_1;
        }
        if (_and) {
          _builder.append("/** ");
          _builder.append(generateComment, "");
          _builder.append(" ");
          _builder.newLineIfNotEmpty();
          _builder.append("*/");
        }
      }
      _builder.newLineIfNotEmpty();
      _builder.append("void ");
      String _name = method.getName();
      _builder.append(_name, "");
      _builder.append(" ( ");
      _builder.append(transformParameters1, "");
      _builder.append(" );");
      _builder.newLineIfNotEmpty();
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  public String transformParameters(final FMethod method) {
    String _xblockexpression = null;
    {
      final ArrayList<Object> parameters = CollectionLiterals.<Object>newArrayList();
      EList<FArgument> _inArgs = method.getInArgs();
      List<String> _map = null;
      if (_inArgs!=null) {
        final Function1<FArgument, String> _function = new Function1<FArgument, String>() {
          public String apply(final FArgument it) {
            return Franca2IdlConverter.this.transformArgument(it, "in");
          }
        };
        _map=ListExtensions.<FArgument, String>map(_inArgs, _function);
      }
      parameters.addAll(_map);
      EList<FArgument> _outArgs = method.getOutArgs();
      List<String> _map_1 = null;
      if (_outArgs!=null) {
        final Function1<FArgument, String> _function_1 = new Function1<FArgument, String>() {
          public String apply(final FArgument it) {
            return Franca2IdlConverter.this.transformArgument(it, "out");
          }
        };
        _map_1=ListExtensions.<FArgument, String>map(_outArgs, _function_1);
      }
      parameters.addAll(_map_1);
      _xblockexpression = IterableExtensions.join(parameters, ",");
    }
    return _xblockexpression;
  }
  
  public String transformArgument(final FArgument src, final String paramType) {
    String name = src.getName();
    FTypeRef _type = src.getType();
    String type = this.transformType2TypeString(_type);
    boolean _equals = Objects.equal(paramType, "in");
    if (_equals) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("in ");
      _builder.append(type, "");
      _builder.append(" ");
      _builder.append(name, "");
      return _builder.toString();
    }
    StringConcatenation _builder_1 = new StringConcatenation();
    _builder_1.append("out ");
    _builder_1.append(type, "");
    _builder_1.append(" ");
    _builder_1.append(name, "");
    return _builder_1.toString();
  }
  
  public String transformType2TypeString(final FTypeRef ref) {
    String _xifexpression = null;
    FType _derived = ref.getDerived();
    boolean _equals = Objects.equal(_derived, null);
    if (_equals) {
      _xifexpression = this.transformBasicType(ref);
    } else {
      String _xblockexpression = null;
      {
        FType type = ref.getDerived();
        _xblockexpression = type.getName();
      }
      _xifexpression = _xblockexpression;
    }
    return _xifexpression;
  }
  
  public String transformBasicType(final FTypeRef src) {
    String _switchResult = null;
    FBasicTypeId _predefined = src.getPredefined();
    if (_predefined != null) {
      switch (_predefined) {
        case INT8:
          _switchResult = "Int8";
          break;
        case UINT8:
          _switchResult = "UInt8";
          break;
        case INT16:
          _switchResult = "Int16";
          break;
        case UINT16:
          _switchResult = "UInt16";
          break;
        case INT32:
          _switchResult = "Int32";
          break;
        case UINT32:
          _switchResult = "UInt32";
          break;
        case INT64:
          _switchResult = "Int64";
          break;
        case UINT64:
          _switchResult = "UInt64";
          break;
        case BOOLEAN:
          _switchResult = "Boolean";
          break;
        case STRING:
          _switchResult = "String";
          break;
        case FLOAT:
          _switchResult = "Float";
          break;
        case DOUBLE:
          _switchResult = "Double";
          break;
        case BYTE_BUFFER:
          _switchResult = "ByteBuffer";
          break;
        default:
          _switchResult = "?";
          break;
      }
    } else {
      _switchResult = "?";
    }
    return _switchResult;
  }
  
  public static void main(final String[] args) {
    String francaFile = args[0];
    Franca2IdlConverter convertor = new Franca2IdlConverter(francaFile);
    CharSequence idlContents = convertor.generateContents();
    InputOutput.<CharSequence>print(idlContents);
  }
}
