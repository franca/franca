/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.traces

import java.util.HashMap
import org.eclipse.xtext.EcoreUtil2
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAssignment
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FBlock
import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FDeclaration
import org.franca.core.franca.FExpression
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FInterface
import org.franca.core.franca.FState
import org.franca.core.franca.FStringConstant
import org.franca.core.franca.FTransition
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FTypedElementRef
import org.franca.tools.contracts.tracegen.strategies.events.EventData
import org.franca.tools.contracts.tracegen.values.ValueGenerator
import org.franca.tools.contracts.tracegen.values.complex.CompoundValue
import org.franca.tools.contracts.tracegen.values.simple.DefaultlyInitializingSimpleValueGenerator

class BehaviourAwareTrace extends Trace {
	
	extension Operators operators = new Operators
	
	ValueGenerator vgen = new ValueGenerator(new DefaultlyInitializingSimpleValueGenerator)
	
	FInterface iface
	
	HashMap<FTypedElement, ElementInstance> elementInstances = newHashMap
	
	new(BehaviourAwareTrace base) {
		super(base)
		this.iface = base.iface
		for (instance : base.elementInstances.entrySet) {
			val instanceCopy = instance.value.copy
			this.elementInstances.put(instance.key, instanceCopy)
		}
	}
	
	new(FState start) {
		super(start)
		EcoreUtil2::getContainerOfType(start, typeof(FInterface))
	}
	
	override use(FTransition transition, EventData triggeringEventData) {
		if (transition.action != null) {
			evaluate(transition.action, triggeringEventData)
		}
		super.use(transition, triggeringEventData)
	}
	
	def ElementInstance getOrCreate(FTypedElement e) {
		var currentInstance = elementInstances.get(e)
		if (currentInstance == null) {
			currentInstance = new ElementInstance(e, vgen.createActualValue(e.type))
			elementInstances.put(e, currentInstance)
		}
		return currentInstance
	}
	
// TODO delete:
//	def ElementInstance getOrCreateInitialized(FArgument arg, EventData triggeringEvent) {
//		var currentInstance = elementInstances.get(arg)
//		if (currentInstance == null) {
//			currentInstance = new ElementInstance(arg, triggeringEvent)
//			elementInstances.put(arg, currentInstance)
//		}
//		return currentInstance
//	}
	
	def dispatch Object evaluate(FExpression expr, EventData triggeringEvent) {
		throw new IllegalArgumentException("Unknown type: '" + (expr.class).name+ "'")
		//it is unknown what to do here, right now
	}
	
	def Object evaluateComplexReference(FTypedElementRef expr, EventData triggeringEvent) {
		val indirect = expr.target
		if (indirect === null)
			return evaluate(expr, triggeringEvent);
			
		val left = evaluateComplexReference(indirect, triggeringEvent) as CompoundValue
		
		return left.getValue(expr.field)
	}
	
	def dispatch Object evaluate(FTypedElementRef expr, EventData triggeringEvent) {
		val indirect = expr.target
		if (indirect !== null) {
			return evaluateComplexReference(expr, triggeringEvent)
		}
		
		if (expr.element !== null) {
			if (expr.element instanceof FDeclaration) {
				return getOrCreate(expr.element as FDeclaration).value
			} else if (expr.element instanceof FArgument) {
				val FArgument argument = expr.element as FArgument
				return triggeringEvent.getActualValue(argument)
				//TODO: delete getOrCreateInitialized(argument, triggeringEvent).value
			} 
		} 
		throw new UnsupportedOperationException
	}
	
	def dispatch Object evaluate(FBinaryOperation expr, EventData triggeringEvent) {
		val left = evaluate(expr.left, triggeringEvent)
		val right = evaluate(expr.right, triggeringEvent)
		
		var Comparable<?> leftToCompare
		var Comparable<?> rightToCompare
		if (left instanceof Float || left instanceof Double || right instanceof Float || right instanceof Double) {
			//TODO: separate Float and Double?
			leftToCompare = (left as Number).doubleValue
			rightToCompare = (right as Number).doubleValue
		} else if (left instanceof Number) {
			leftToCompare = (left as Number).longValue
			rightToCompare = (right as Number).longValue			
		} else {
			leftToCompare = left as Comparable<?>
			rightToCompare = right as Comparable<?>
		}
		
		switch (expr.op) {
			case '||': return (left as Boolean || right as Boolean)
			case '&&': return (left as Boolean && right as Boolean)
			case '==': return (leftToCompare.equals(rightToCompare))
			case '!=': return (! left.equals(right))
			case '<': return (leftToCompare as Comparable<Object> < rightToCompare)
			case '>': return ((leftToCompare as Comparable<Object>) > rightToCompare)
			case '<=': return ((leftToCompare as Comparable<Object>) <= rightToCompare)
			case '>=': return ((leftToCompare as Comparable<Object>) >= rightToCompare)
			case '+': return ((leftToCompare as Number) + (rightToCompare as Number))
			case '-': return ((leftToCompare as Number) - (rightToCompare as Number))
			case '*': return ((leftToCompare as Number) * (rightToCompare as Number))
			case '/': return ((leftToCompare as Number) / (rightToCompare as Number))
		}
		throw new UnsupportedOperationException
	}
	
	def dispatch Object evaluate(FBlock block, EventData triggeringEvent) {
		val iter = block.statements.iterator
		while (iter.hasNext) {
			val result = iter.next.evaluate(triggeringEvent)
			if (! iter.hasNext) {
				return result
			}
		}
		return null;
	}
	
	def dispatch Object evaluate(FBooleanConstant expr, EventData triggeringEvent) {
		expr.isVal
	}
	def dispatch Object evaluate(FIntegerConstant expr, EventData triggeringEvent) {
		expr.^val
	}
	def dispatch Object evaluate(FStringConstant expr, EventData triggeringEvent) {
		expr.^val
	}
	
	def dispatch Object evaluate(FAssignment a, EventData triggeringEvent) {
		val declaration = a.lhs
		val currentInstance = getOrCreate(declaration)
		val newValue = evaluate(a.rhs, triggeringEvent)
		currentInstance.setValue(newValue)
		return newValue;
	}
	
}