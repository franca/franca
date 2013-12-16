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
class ExpressionValidationTests extends XtextTest {//ValidationTestBase {

	val static private basePath = "testcases/errorTypesAndValues/"
	
	@Before
    override void before() {
        suppressSerialization();
    }
    
	@Test
	def void validateValidExpressionsContainingErrorKeywords() {
		testFile(basePath + "ValidUsageOfErrorKeywords.fidl")
		ignoreUnassertedWarnings
	}
	
	@Test
	def void validatePresenceOfErrorsWithErrorKeywordsUsedInsteadOfBooleans() {
		testFile(basePath + "ErrorsWithErrorKeywordsUsedInsteadOfBooleans.fidl")
		ignoreUnassertedWarnings
		val errors = issues.errorsOnly;

		for(i : #[23, 25])
			this.assertConstraints(errors.inLine(i).
				theOneAndOnlyContains("expected typed expression"))

		for(i : #[24, 26])
			this.assertConstraints(errors.inLine(i).
				theOneAndOnlyContains("invalid error enumerator (expected Boolean)"))
	}
	
	@Test
	def void validatePresenceOfErrorsWhenUsingTypesInsteadOfBooleans() {
		testFile(basePath + "ErrorsWhenUsingTypesInsteadOfBooleans.fidl")
		ignoreUnassertedWarnings
		val errors = issues.errorsOnly;

		for(i : #[23, 28])
			this.assertConstraints(errors.inLine(i).
				theOneAndOnlyContains("invalid type (is enumeration 'Errors', expected Boolean"))

		for(i : #[24, 25, 26, 29, 30, 31, 33, 35, 36, 37, 38, 39, 40, 41])
			this.assertConstraints(errors.inLine(i).
				theOneAndOnlyContains("expected typed expression"))

		for(i : #[34, 44, 45])
			this.assertConstraints(errors.inLine(i).sizeIs(2).
				allOfThemContain("expected typed expression"))
	}
	
	@Test
	def void validatePresenceOfErrorsWhenUsingErrorValuesInExpressions() {
		testFile(basePath + "ErrorsWhenUsingErrorValuesInExpressions.fidl")
		ignoreUnassertedWarnings
		val errors = issues.errorsOnly;

		for(i : #[23, 24])
			this.assertConstraints(errors.inLine(i).
				theOneAndOnlyContains("invalid type (is enumeration 'Errors', expected Boolean"))

		for(i : #[26, 27, 28])
			this.assertConstraints(errors.inLine(i).
				theOneAndOnlyContains("operands must have compatible type"))
	}
	
}