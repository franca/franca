package org.franca.tools.contracts.testcasegen

import org.franca.core.franca.FMethod

abstract class TestCaseGenerator {
	
	abstract def public Iterable<FrancaTestCase> getTestCases(FMethod method);
	
}