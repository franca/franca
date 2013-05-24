package org.franca.tools.contracts.tracegen.traces;

import com.google.common.base.Objects;
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FBasicTypeId;
import org.franca.core.franca.FCompoundType;
import org.franca.core.franca.FDeclaration;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FMapType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeDef;
import org.franca.core.franca.FTypeRef;
import org.franca.tools.contracts.tracegen.types.SimulatedArrayValue;
import org.franca.tools.contracts.tracegen.types.SimulatedCompound;
import org.franca.tools.contracts.tracegen.types.SimulatedMapValue;

@SuppressWarnings("all")
public class ValuedDeclaration {
  private FDeclaration declaration;
  
  private Object value;
  
  private boolean isPrimitive;
  
  public ValuedDeclaration(final FDeclaration declaration) {
    this.declaration = declaration;
    FTypeRef _type = declaration.getType();
    Object _simulatedValue = this.getSimulatedValue(_type);
    this.value = _simulatedValue;
  }
  
  private Object getSimulatedValue(final FTypeRef typeRef) {
    final FType derived = typeRef.getDerived();
    boolean _equals = Objects.equal(derived, null);
    if (_equals) {
      this.isPrimitive = true;
      FBasicTypeId _predefined = typeRef.getPredefined();
      return this.getDefaultlyInitializedJavaObject(_predefined);
    } else {
      this.isPrimitive = false;
      try {
        Class<? extends Object> _simulatedValueClass = this.getSimulatedValueClass(derived);
        return _simulatedValueClass.newInstance();
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    }
  }
  
  private Class<? extends Object> _getSimulatedValueClass(final FArrayType type) {
    return SimulatedArrayValue.class;
  }
  
  private Class<? extends Object> _getSimulatedValueClass(final FCompoundType type) {
    return SimulatedCompound.class;
  }
  
  private Class<? extends Object> _getSimulatedValueClass(final FEnumerationType type) {
    UnsupportedOperationException _unsupportedOperationException = new UnsupportedOperationException();
    throw _unsupportedOperationException;
  }
  
  private Class<? extends Object> _getSimulatedValueClass(final FMapType type) {
    return SimulatedMapValue.class;
  }
  
  private Class<? extends Object> _getSimulatedValueClass(final FTypeDef type) {
    UnsupportedOperationException _unsupportedOperationException = new UnsupportedOperationException();
    throw _unsupportedOperationException;
  }
  
  public Object getDefaultlyInitializedJavaObject(final FBasicTypeId id) {
    Object _xblockexpression = null;
    {
      final String name = id.getLiteral();
      Object _switchResult = null;
      boolean _matched = false;
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.INT8)) {
          _matched=true;
          _switchResult = Integer.valueOf(0);
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.UINT8)) {
          _matched=true;
          _switchResult = Integer.valueOf(0);
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.INT16)) {
          _matched=true;
          _switchResult = ((Integer) Integer.valueOf(0));
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.UINT16)) {
          _matched=true;
          _switchResult = ((Integer) Integer.valueOf(0));
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.INT32)) {
          _matched=true;
          _switchResult = ((Integer) Integer.valueOf(0));
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.UINT32)) {
          _matched=true;
          _switchResult = ((Integer) Integer.valueOf(0));
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.INT64)) {
          _matched=true;
          _switchResult = Long.valueOf(0l);
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.UINT64)) {
          _matched=true;
          _switchResult = Long.valueOf(0l);
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.BOOLEAN)) {
          _matched=true;
          _switchResult = Boolean.valueOf(false);
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.STRING)) {
          _matched=true;
          _switchResult = "";
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.FLOAT)) {
          _matched=true;
          _switchResult = Float.valueOf(0.0f);
        }
      }
      if (!_matched) {
        if (Objects.equal(id,FBasicTypeId.DOUBLE)) {
          _matched=true;
          _switchResult = Double.valueOf(0.0d);
        }
      }
      if (!_matched) {
        {
          Logger _anonymousLogger = Logger.getAnonymousLogger();
          String _plus = ("Unknown primitive type: \'" + name);
          String _plus_1 = (_plus + "\'");
          _anonymousLogger.log(Level.SEVERE, _plus_1);
          String _plus_2 = ("Unknown primitive type: \'" + name);
          String _plus_3 = (_plus_2 + "\'\nMaybe the type even was not a primitive one, but a user defined type!");
          IllegalArgumentException _illegalArgumentException = new IllegalArgumentException(_plus_3);
          throw _illegalArgumentException;
        }
      }
      _xblockexpression = (_switchResult);
    }
    return ((Comparable<Object>)_xblockexpression);
  }
  
  public Object setValue(final Object object) {
    Object _xifexpression = null;
    if (this.isPrimitive) {
      Object _value = this.value = object;
      _xifexpression = _value;
    } else {
      UnsupportedOperationException _unsupportedOperationException = new UnsupportedOperationException();
      throw _unsupportedOperationException;
    }
    return _xifexpression;
  }
  
  public Object getValue() {
    if (this.isPrimitive) {
      return this.value;
    } else {
      UnsupportedOperationException _unsupportedOperationException = new UnsupportedOperationException();
      throw _unsupportedOperationException;
    }
  }
  
  private Class<? extends Object> getSimulatedValueClass(final FType type) {
    if (type instanceof FArrayType) {
      return _getSimulatedValueClass((FArrayType)type);
    } else if (type instanceof FCompoundType) {
      return _getSimulatedValueClass((FCompoundType)type);
    } else if (type instanceof FEnumerationType) {
      return _getSimulatedValueClass((FEnumerationType)type);
    } else if (type instanceof FMapType) {
      return _getSimulatedValueClass((FMapType)type);
    } else if (type instanceof FTypeDef) {
      return _getSimulatedValueClass((FTypeDef)type);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(type).toString());
    }
  }
}
