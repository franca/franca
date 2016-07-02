package org.franca.core.dsl.tests.compare

import org.eclipse.emf.compare.Match

interface IComparisonReportGenerator {
	def String generateReport(Match m)
}