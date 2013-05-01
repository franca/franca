package org.franca.deploymodel.dsl.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import org.franca.deploymodel.dsl.FDeployValidationTestHelper

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class SpecValidationTests {

	@Inject ParseHelper<FDModel> parser
	@Inject FDeployValidationTestHelper validationHelper

	@Test
	def validateSpecNameUnique() {
		val text = '''
			specification MySpec { }
			specification MySpec { }
		'''
		
		assertEquals('''
			1:Duplicate specification name 'MySpec'
			2:Duplicate specification name 'MySpec'
		'''.toString, text.getIssues)
	}
	

	def private getIssues (CharSequence text) {
		val model = parser.parse(text)
		return validationHelper.getValidationIssues(model)
	}
}

