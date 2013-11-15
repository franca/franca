package org.franca.core.dsl.tests

import org.franca.core.dsl.tests.ValidationTestBase
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.junit.Test

import static org.junit.Assert.*
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before

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
		this.assertConstraints(errors.inLine(23) => [
			theOneAndOnlyContains("expected boolean type for guard expression (is <Type>)")
		])
		this.assertConstraints(errors.inLine(24) => [
			theOneAndOnlyContains("expected boolean type for guard expression (is Errors)")
		])
		
		this.assertConstraints(errors.inLine(25).oneOfThemContains("expected boolean (is <Type>)"))
		this.assertConstraints(errors.inLine(25).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(25).sizeIs(2))
		
		this.assertConstraints(errors.inLine(26).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(26).sizeIs(2))
		this.assertConstraints(errors.inLine(26).oneOfThemContains("expected boolean (is Errors)"))
	
		//TODO: what we realy want is the following, but currently the result depends on the order of the constraints
//		this.assertConstraints(errors.inLine(26) => [
//			oneOfThemContains("expected boolean type for guard expression (is Errors)")
//			sizeIs(2)
//			oneOfThemContains("expected boolean (is Errors)asdfasdf")
//		])
	}
	
	@Test
	def void validatePresenceOfErrorsWhenUsingTypesInsteadOfBooleans() {
		testFile(basePath + "ErrorsWhenUsingTypesInsteadOfBooleans.fidl")
		ignoreUnassertedWarnings
		val errors = issues.errorsOnly;
		this.assertConstraints(errors.inLine(23) => [
			theOneAndOnlyContains("expected boolean type for guard expression (is Errors)")
		])
		this.assertConstraints(errors.inLine(24) => [
			theOneAndOnlyContains("expected boolean type for guard expression (is <Type>)")
		])
		this.assertConstraints(errors.inLine(25) => [
			theOneAndOnlyContains("expected boolean type for guard expression (is <Type>)")
		])
		this.assertConstraints(errors.inLine(26) => [
			theOneAndOnlyContains("expected boolean type for guard expression (is <Type>)")
		])
		
		this.assertConstraints(errors.inLine(28).oneOfThemContains("expected boolean (is Errors)"))
		this.assertConstraints(errors.inLine(28).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(28).sizeIs(2))

		this.assertConstraints(errors.inLine(29).oneOfThemContains("expected boolean (is <Type>)"))
		this.assertConstraints(errors.inLine(29).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(29).sizeIs(2))

		this.assertConstraints(errors.inLine(30).oneOfThemContains("expected boolean (is <Type>)"))
		this.assertConstraints(errors.inLine(30).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(30).sizeIs(2))

		this.assertConstraints(errors.inLine(31).oneOfThemContains("expected boolean (is <Type>)"))
		this.assertConstraints(errors.inLine(31).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(31).sizeIs(2))
		
		this.assertConstraints(errors.inLine(33).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(33).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(33).sizeIs(2))

		this.assertConstraints(errors.inLine(34).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(34).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(34).sizeIs(2))
		
		this.assertConstraints(errors.inLine(35).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(35).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(35).sizeIs(2))
		
		this.assertConstraints(errors.inLine(36).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(36).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(36).sizeIs(2))
		
		this.assertConstraints(errors.inLine(37).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(37).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(37).sizeIs(2))
		
		this.assertConstraints(errors.inLine(38).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(38).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(38).sizeIs(2))

		this.assertConstraints(errors.inLine(39).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(39).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(39).sizeIs(2))

		this.assertConstraints(errors.inLine(40).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(40).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(40).sizeIs(2))
		
		this.assertConstraints(errors.inLine(41).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(41).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(41).sizeIs(2))
		
		this.assertConstraints(errors.inLine(44).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(44).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(44).sizeIs(2))
		
		this.assertConstraints(errors.inLine(45).oneOfThemContains("operations on type level are not allowed"))
		this.assertConstraints(errors.inLine(45).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(45).sizeIs(2))
	}
	
	@Test
	def void validatePresenceOfErrorsWhenUsingErrorValuesInExpressions() {
		testFile(basePath + "ErrorsWhenUsingErrorValuesInExpressions.fidl")
		ignoreUnassertedWarnings
		
		val errors = issues.errorsOnly;
		this.assertConstraints(errors.inLine(23).theOneAndOnlyContains("expected boolean type for guard expression (is Errors)"))
		
		this.assertConstraints(errors.inLine(24).oneOfThemContains("expected boolean (is Errors)"))
		this.assertConstraints(errors.inLine(24).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(24).sizeIs(2))
		
		this.assertConstraints(errors.inLine(26).oneOfThemContains("operands must have compatible type"))
		this.assertConstraints(errors.inLine(26).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(26).sizeIs(2))
		
		this.assertConstraints(errors.inLine(27).oneOfThemContains("operands must have compatible type"))
		this.assertConstraints(errors.inLine(27).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(27).sizeIs(2))
				
		this.assertConstraints(errors.inLine(28).oneOfThemContains("operands must have compatible type"))
		this.assertConstraints(errors.inLine(28).oneOfThemContains("expected boolean type for guard expression (is <Type>)"))
		this.assertConstraints(errors.inLine(28).sizeIs(2))
	}
	
}