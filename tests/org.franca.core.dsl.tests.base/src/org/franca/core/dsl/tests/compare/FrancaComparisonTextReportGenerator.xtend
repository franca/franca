package org.franca.core.dsl.tests.compare


import org.franca.core.franca.FModel

class FrancaComparisonTextReportGenerator extends ComparisonTextReportGenerator {
	def dispatch String generateModelElement(FModel n) '''«IF !n.name.nullOrEmpty»«n.name» : «ENDIF»«n.simpleName»'''
	def dispatch String getName(FModel n) { n.name ?: n.simpleName }
}