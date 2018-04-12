package org.franca.core.dsl.tests

import com.itemis.xtext.testing.XtextTest
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class ContractTests extends XtextTest {//ValidationTestBase {

	val static private basePath = "testcases/contracts/"
	
	@Before
    override void before() {
        suppressSerialization();
    }
    
	@Test
	def void validateValidExpressionsContainingErrorKeywords() {
		testFile(basePath + "ValidUsageOfErrorKeywords.fidl")
		assertConstraints(
			issues.oneOfThemContains("Method is not covered by contract, not needed?")
				.nOfThemContain(4, "This transition's guard might overlap with other transitions with same trigger")
		)
	}
	
	@Test
	def void validateOverloadedMethodsInContract() {
		testFile(basePath + "OverloadedMethodsInContract.fidl")
		assertConstraints(
			issues.inLine(26).theOneAndOnlyContains("Broadcast is not covered by contract, not needed?")
		)
	}
	
}