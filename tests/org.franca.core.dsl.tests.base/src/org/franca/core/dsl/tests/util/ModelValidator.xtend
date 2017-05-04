package org.franca.core.dsl.tests.util

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.eclipse.xtext.validation.Issue

class ModelValidator {

	@Inject
	protected IResourceValidator validator

	def int validateModel(EObject model, boolean recursively) {
		var nErrors = 0
		val mainResource = model.eResource

		val toBeValidated = newArrayList
		if (recursively) {
			val resources = mainResource.getResourceSet.getResources
			toBeValidated.addAll(resources)
		} else {
			toBeValidated.add(mainResource)
		}

		for(Resource res : toBeValidated) {
			if (validator==null) {
				throw new RuntimeException("ModelValidator not properly initialized, no ResourceValidator available")
			}
			try {
				val List<Issue> validationErrors = validator.validate(res, CheckMode.ALL, null)
				for (Issue issue : validationErrors) {
					val msg = '''«issue.severity» at «res.URI.path» #«issue.lineNumber»: «issue.message»'''
					System.err.println(msg)
					if (issue.severity==Severity.ERROR)
						nErrors++
				}
			} catch (Exception e) {
				System.err.println("Error from Xtext validator (" + e.message + ")")
				nErrors++
			}
		}
		
		nErrors
	}

}