package org.franca.tools.contracts.tracegen.traces

import org.franca.core.franca.FState
import org.franca.core.franca.FInterface
import org.eclipse.xtext.EcoreUtil2
import org.franca.core.franca.FTransition
import org.franca.core.franca.FExpression
import org.franca.core.franca.FAssignment
import java.util.HashMap
import org.franca.core.franca.FDeclaration
import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FStringConstant
import org.franca.core.franca.FBlockExpression
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FTypedElementRef

class BehaviourAwareTrace extends Trace {
	
	extension Operators operators = new Operators
	
	FInterface iface
	
	HashMap<FDeclaration, ValuedDeclaration> declarationInstances = newHashMap
	
	new(BehaviourAwareTrace base) {
		super(base)
		this.iface = base.iface
	}
	
	new(FState start) {
		super(start)
		EcoreUtil2::getContainerOfType(start, typeof(FInterface))
	}
	
	override use(FTransition transition) {
		if (transition.action != null) {
			evaluate(transition.action)
		}
		super.use(transition)
	}
	
	def ValuedDeclaration getOrCreate(FDeclaration d) {
		var currentInstance = declarationInstances.get(d)
		if (currentInstance == null) {
			currentInstance = new ValuedDeclaration(d)
			declarationInstances.put(d, currentInstance)
		}
		return currentInstance
	}
	
	def dispatch Object evaluate(FExpression expr) {
		throw new IllegalArgumentException("Unknown type: '" + (expr.class).name+ "'")
		//it is unknown what to do here, right now
	}
	
	def dispatch Object evaluate(FTypedElementRef expr) {
		if (expr.element != null && expr.element instanceof FDeclaration) {
			return getOrCreate(expr.element as FDeclaration).value
		}
		throw new UnsupportedOperationException
	}
	
	def dispatch Object evaluate(FBinaryOperation expr) {
		var left = evaluate(expr.left)
		var right = evaluate(expr.right)
		switch (expr.op) {
			case '||': return (left as Boolean || right as Boolean)
			case '&&': return (left as Boolean && right as Boolean)
			case '==': return (left.equals(right))
			case '!=': return (! left.equals(right))
			case '<': return ((left as Comparable<Object>) < (right as Comparable<Object>))
			case '>': return ((left as Comparable<Object>) > (right as Comparable<Object>))
			case '<=': return ((left as Comparable<Object>) <= (right as Comparable<Object>))
			case '>=': return ((left as Comparable<Object>) >= (right as Comparable<Object>))
			case '+': return ((left as Number) + (right as Number))
			case '-': return ((left as Number) - (right as Number))
			case '*': return ((left as Number) * (right as Number))
			case '/': return ((left as Number) / (right as Number))
		}	
	}
	
	def dispatch Object evaluate(FBlockExpression expr) {
		val iter = expr.expressions.iterator
		while (iter.hasNext) {
			val result = iter.next.evaluate
			if (! iter.hasNext) {return result}
		}
		return null;
	}
	
	def dispatch Object evaluate(FBooleanConstant expr) {
		expr.isVal
	}
	def dispatch Object evaluate(FIntegerConstant expr) {
		expr.^val
	}
	def dispatch Object evaluate(FStringConstant expr) {
		expr.^val
	}
	
	def dispatch Object evaluate(FAssignment a) {
		val declaration = a.lhs
		val currentInstance = getOrCreate(declaration)
		val newValue = evaluate(a.rhs)
		currentInstance.setValue(newValue)
		return newValue;
	}
	
}