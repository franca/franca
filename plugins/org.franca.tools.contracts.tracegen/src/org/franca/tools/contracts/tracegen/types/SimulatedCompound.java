package org.franca.tools.contracts.tracegen.types;

import java.util.HashMap;

import com.google.common.collect.Maps;

public class SimulatedCompound extends SimulatedValue {
	
	private HashMap<String, Object> fields = Maps.newHashMap();
	
	public void addField(String name, Class<?> type) {
		try {
			this.fields.put(name, type.newInstance());
		} catch (InstantiationException e) {
			throw new IllegalArgumentException(e);
		} catch (IllegalAccessException e) {
			throw new IllegalArgumentException(e);
		}
	}
	
	public Object getValue(String name, Class<?> type) {
		Object currentValue = fields.get(name);
		if (currentValue == null) {
			currentValue = getDefault(type);
			fields.put(name, currentValue);
		}
		return currentValue;
	}
	
	public void initDefaultValue(String name, Class<?> type) {
		fields.put(name, getDefault(type));
	}
	
	public void setValue(String name, Object value) {
		fields.put(name, value);
	}

}
