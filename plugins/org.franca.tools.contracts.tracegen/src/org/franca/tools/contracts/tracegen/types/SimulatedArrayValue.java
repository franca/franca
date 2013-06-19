package org.franca.tools.contracts.tracegen.types;

import java.util.ArrayList;

import com.google.common.collect.Lists;

public class SimulatedArrayValue extends SimulatedValue {	
	
	private ArrayList<Object> array = Lists.newArrayList();
	
	public void setValue(int idx, Object value) {
		Object setableValue = value;
		if (setableValue == null) {
			setableValue = nil;
		}
		array.set(idx, value);
	}
	
	public Object getValue(int idx) {
		return array.get(idx);
	}
	
	public void initDefaultValue(int idx, Class<?> type) {
		array.set(idx, getDefault(type));
	}

}
