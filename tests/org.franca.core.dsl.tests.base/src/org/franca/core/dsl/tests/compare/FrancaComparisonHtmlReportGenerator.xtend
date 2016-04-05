package org.franca.core.dsl.tests.compare


import org.franca.core.franca.FModel

class FrancaComparisonHtmlReportGenerator extends ComparisonHtmlReportGenerator {
	def dispatch String generateModelElement(FModel n, int depth) 
		'''<tr> «td(depth, n.name ?: '&lt;no-name&gt;' )» <td>«n.simpleName»</td> </tr>'''
	
	def dispatch String getName(FModel n) { n.name ?: n.simpleName }
}