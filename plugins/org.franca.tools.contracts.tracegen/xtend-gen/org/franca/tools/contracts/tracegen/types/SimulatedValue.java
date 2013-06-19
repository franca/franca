package org.franca.tools.contracts.tracegen.types;

import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.franca.tools.contracts.tracegen.types.NULL;

@SuppressWarnings("all")
public abstract class SimulatedValue {
  protected final static NULL nil = new Function0<NULL>() {
    public NULL apply() {
      NULL _instance = NULL.getInstance();
      return _instance;
    }
  }.apply();
  
  protected Object getDefault(final Class<? extends Object> type) {
    boolean _equals = String.class.equals(type);
    if (_equals) {
      return "";
    }
    boolean _equals_1 = Boolean.class.equals(type);
    if (_equals_1) {
      return Boolean.valueOf(false);
    }
    boolean _isAssignableFrom = Number.class.isAssignableFrom(type);
    if (_isAssignableFrom) {
      return Integer.valueOf(0);
    }
    return SimulatedValue.nil;
  }
}
