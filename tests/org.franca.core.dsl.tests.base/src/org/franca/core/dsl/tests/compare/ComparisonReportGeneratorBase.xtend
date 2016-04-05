package org.franca.core.dsl.tests.compare

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.compare.AttributeChange
import org.eclipse.emf.compare.ReferenceChange
import org.eclipse.emf.compare.Match
import org.eclipse.emf.common.util.EList

abstract class ComparisonReportGeneratorBase implements IComparisonReportGenerator {
	protected enum Side { LEFT, RIGHT }
	
	protected def boolean hasDifferences(Match m) {
		if( m.differences.size>0 ) return true
		return m.submatches.exists[it.hasDifferences]
	}
	
	protected def String simpleName(EObject o) { o.eClass.instanceClass.simpleName }
	
	protected def String generateAttrValue( AttributeChange ac, Side side ) {
		val value = switch(side) {
			case LEFT: ac.match.left
			case RIGHT: ac.match.right
		}.eGet(ac.attribute)
		value.generateAttrib
	}
	
	protected def String generateRefValue(ReferenceChange rc, Side side) {
		if(rc.match.right==null) return 'null'
		val value = switch(side) {
			case LEFT: rc.match.left
			case RIGHT: rc.match.right
		}//.eGet(rc.reference)
		value.generateRef
	}
	
	protected def generateAttrib(Object value) { if(value!=null) value.toString else 'null' }
	protected def generateRef(Object value) {
		if(value==null)  
			return 'null'
			
		if(value instanceof EObject) 
			return value.name
			
		if(value instanceof EList<?>) 
			return '''[ «FOR o : value.filter(EObject) SEPARATOR ', '»«o.simpleName»«ENDFOR» ]'''
	
		'??'
	}
	
	protected def dispatch String getName(Object o)  '''«o.class.simpleName»'''
	protected def dispatch String getName(EObject o) '''«IF o.eContainer !=null»«o.eContainer.name».«ENDIF»«o.simpleName»'''
}