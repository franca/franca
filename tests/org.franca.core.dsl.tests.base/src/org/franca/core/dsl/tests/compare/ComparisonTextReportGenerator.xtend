package org.franca.core.dsl.tests.compare

import org.eclipse.emf.compare.AttributeChange
import org.eclipse.emf.compare.Match
import org.eclipse.emf.compare.ReferenceChange
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.compare.DifferenceKind
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypeRef

class ComparisonTextReportGenerator extends ComparisonReportGeneratorBase {
	override String generateReport(Match m) { generateMatch(m) }
	
	protected def String generateMatch(Match m) '''
	«m.left?.generateModelElement»
	  «FOR s : m.submatches.filter[it.hasDifferences]»
	  «s.generateMatch»
	    «FOR d : s.differences»
	    «d.kind» - «d.generateDiff»
	    «ENDFOR»
	  «ENDFOR»
	'''
	
	protected def dispatch String generateDiff(AttributeChange ac) 
	'''A «ac.attribute.name»  «ac.generateAttrValue(Side.LEFT)» - «ac.generateAttrValue(Side.RIGHT)»'''
	
	protected def dispatch String generateDiff(ReferenceChange rc)  {
		val valueMatch = rc.match.getComparison().getMatch(rc.value);
		switch(rc.kind) {
			case DifferenceKind.ADD:
				 '''R «rc.reference.name»  «rc.value.generateRef» - «rc.generateRefValue(Side.RIGHT)»'''
			case DifferenceKind.CHANGE:
				 '''R «rc.reference.name»  «rc.value.generateRef» - «rc.generateRefValue(Side.RIGHT)»'''
			default:
				 '''R «rc.reference.name»  «valueMatch.left.generateRef» - «valueMatch.right.generateRef»'''
		}
	
	}
	
	protected def dispatch String generateModelElement(Object o) '''«o.toString»'''
	protected def dispatch String generateModelElement(EObject o) {
	
		o.displayName
	
}
	def dispatch getDisplayName(FModel element){
		'''«element.simpleName» «element.name»'''.toString
	}
	def dispatch getDisplayName(FModelElement element){
		'''«element.simpleName» «element.name»'''.toString
	}
	def dispatch getDisplayName(EObject element){
		'''«element.simpleName» «element.name»'''.toString
	}
	def dispatch getDisplayName(FTypeRef element){
		'''«element.simpleName»'''.toString
	}
	
}
