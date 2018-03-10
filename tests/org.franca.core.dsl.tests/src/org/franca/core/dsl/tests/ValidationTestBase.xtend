package org.franca.core.dsl.tests

import com.google.inject.Inject
import org.franca.core.dsl.FrancaValidationTestHelper
import org.eclipse.xtext.testing.util.ParseHelper
import org.franca.core.franca.FModel

class ValidationTestBase {

	@Inject ParseHelper<FModel> parser
	@Inject FrancaValidationTestHelper validationHelper
	
	def protected _getIssues (CharSequence text) {
		val model = parser.parse(text)
		return validationHelper.getValidationIssues(model)
	}	
}