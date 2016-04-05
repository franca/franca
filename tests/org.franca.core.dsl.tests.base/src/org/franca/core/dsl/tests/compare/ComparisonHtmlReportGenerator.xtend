package org.franca.core.dsl.tests.compare

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.compare.AttributeChange
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.DifferenceKind
import org.eclipse.emf.compare.Match
import org.eclipse.emf.compare.ReferenceChange
import org.eclipse.emf.ecore.EObject


class ComparisonHtmlReportGenerator extends ComparisonReportGeneratorBase {
	override generateReport(Match m) {
		'''
		<html>
		<head>
		<title>EMF Compare Diff Report</title>
		<style>
		table { margin: 0; font-family: Consolas, monaco, monospace; }
		td { padding: 2px; }
		
		tr.add 	  { color: White; background-color: Green;  }
		tr.change { background-color: Yellow; }
		tr.delete { color: White; background-color: Red;    }
		
		«FOR i : 0..<10»
		td.l«i» { padding-left: «10*i»px; }
		«ENDFOR»
		</style>
		</head>
		
		<body>
		
		<table>
			<thead>
			<th>Name</th><th>Type</th><th>Modification</th><th>Left</th><th>Right</th>
			</thead>
		
			«generateMatch(m)»
		</table>
		
		</body>
		</html>
		'''
	}
	
	def String tr(Diff d, String content) '''<tr class=«d.kind.toString.toLowerCase»>«content»</tr>'''
	
	def String td(int depth) { td(depth, null) }
	def String td(int depth, String content) {
		if(depth>0) return '''<td class=l«depth»>«content»</td>'''
		'''<td>«content»</td>'''
	}
	
	def String generateMatch(Match m) { generateMatch(m,0) }
	def String generateMatch(Match m, int depth) '''
		«m.left?.generateModelElement(depth)»
		«FOR d : m.differences»
			«d.generateDiff(depth+1)»
		«ENDFOR»
		«FOR s : m.submatches.filter[it.hasDifferences]»
			«s.generateMatch(depth+1)»
		«ENDFOR»
	'''
	
	protected def dispatch String generateDiff(AttributeChange ac, int depth) {
		ac.tr( 
			'''
			«td( depth, ac.attribute.name)»
			<td>«ac.attribute.simpleName»</td>
			<td>«ac.kind»</td>
			<td>«ac.generateAttrValue(Side.LEFT)»</td>
			<td>«ac.generateAttrValue(Side.RIGHT)»</td>
			''' )
	}
	
	protected def dispatch String generateDiff(ReferenceChange rc, int depth) {
		val valueMatch = rc.match.getComparison().getMatch(rc.value);
		switch(rc.kind) { 
		case	DifferenceKind.ADD : 
			rc.tr(
				'''
				«td( depth, rc.reference.name)»
				<td>«rc.reference.simpleName»</td>
				<td>«rc.kind»</td>
				<td>«rc.value.generateRef»</td>
				<td></td>
				''' )
		case 	DifferenceKind.CHANGE : 
			rc.tr(
				'''
				«td( depth, rc.reference.name)»
				<td>«rc.reference.simpleName»</td>
				<td>«rc.kind»</td>
				<td>«rc.value.generateRef»</td>
				<td></td>
				''' )
			
		default:
			rc.tr(
				'''
				«td( depth, rc.reference.name)»
				<td>«rc.reference.simpleName»</td>
				<td>«rc.kind»</td>
				<td>«valueMatch.left.generateRef»</td>
				<td>«valueMatch.right.generateRef»</td>
				''' )
			
		}
	} 
	
	protected def dispatch String generateModelElement(Object o, int depth) '''<tr> «td(depth)»  <td>«o.toString»</td> </tr>'''
	protected def dispatch String generateModelElement(EObject o, int depth) '''<tr> «td(depth)» <td>«o.simpleName»</td> </tr>'''

	override def generateRef(Object value) {
		if(value==null)  
			return 'null'
			
		if(value instanceof EObject) 
			return value.name
			
		if(value instanceof EList<?>) 
			return '''<ol>«FOR o : value.filter(EObject)»<li>«o.simpleName»</li>«ENDFOR»</ol>'''
	
		'??'
	}
}