package org.franca.core.dsl.tests

import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class ContractTests extends XtextTest {//ValidationTestBase {

	val static private basePath = "testcases/contracts"
	
	@Before
    override void before() {
        suppressSerialization();
    }
    
	@Test
	def void validateValidExpressionsContainingErrorKeywords() {
		testFile(basePath + "ValidUsageOfErrorKeywords.fidl")
		ignoreUnassertedWarnings
	}
	
}