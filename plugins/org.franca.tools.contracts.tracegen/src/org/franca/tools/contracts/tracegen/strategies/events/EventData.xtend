/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies.events

import java.util.HashMap
import org.franca.core.franca.FArgument
import org.franca.core.franca.FEventOnIf
import com.google.common.collect.Iterators

@Data
public class EventData {
	
	FEventOnIf event
	HashMap<FArgument, Object> actualArguments
	
	new (FEventOnIf event, Iterable<Pair<FArgument, Object>> actualArguments) {
		this._event = event;
		this._actualArguments = newHashMap
		for (Pair<FArgument, Object> pair : actualArguments) {
			this._actualArguments.put(pair.key, pair.value);
		}
	}
	
//	def public FEventOnIf getEvent() {
//		return _event;
//	}
	
	def public Object getActualValue(FArgument argument) {
		return this._actualArguments.get(argument);
	}
	
	def public getActualArguments() {
		//TODO: which one is better?
		//this.actualArguments.unmodifiableView.entrySet.iterator
		Iterators::unmodifiableIterator(this._actualArguments.entrySet.iterator)
	}
	
//	TODO: implement a good one, that takes respect to the equals function!
//	override hashCode() {
//		
//	}
	
	override equals(Object o) {
		if (this === o) return true;
		if (! (o instanceof EventData)) return false;
		
		val other = o as EventData
		
		this._actualArguments.entrySet.forall[
			val current = it; //necessary because it will be reused in subsequent closures
			val otherValue = other._actualArguments.get(current.key);
			
			other._actualArguments.containsKey[current.key] &&
			(
				(current.value == null && otherValue == null) ||
				(current.value != null && current.value.equals(otherValue))
			)			
		]
	}

}