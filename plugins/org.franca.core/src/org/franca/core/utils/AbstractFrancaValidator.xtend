/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils

import com.google.inject.Inject
import org.eclipse.xtext.resource.IResourceServiceProvider$Registry
import java.util.List
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.validation.CheckMode
import java.util.Set

abstract class AbstractFrancaValidator implements IFrancaValidator {

	@Inject IResourceServiceProvider$Registry registry

	Set<Resource> visited = newHashSet
	List<Issue> issues = newArrayList

	override validate (Resource resource) {
		issues.clear
		doValidate(resource, true)
		return issues
	}

	override validate (Resource resource, boolean recursive) {
		issues.clear
		doValidate(resource, recursive)
		return issues
	}

	def private void doValidate (Resource resource, boolean recursive) {
		// check visited flag
		if (! visited.contains(resource)) {
			visited.add(resource)
			
			// validate resource itself
			validateSingle(resource);
			
			// validate imported resources
			if (recursive) {
				resource.validateImportedResources
			}
		}
	}
	
	def protected void doValidate (List<String> uris, ResourceSet resourceSet) {
		for(uri : uris) {
			val resource = resourceSet.getResource(URI::createFileURI(uri), true)
			doValidate(resource, true)
		}
	}

	def private validateSingle (Resource resource) {
		// get DSL-specific validator via ServiceProvider for this URI
		val resourceServiceProvider = registry.getResourceServiceProvider(resource.URI)
		val validator = resourceServiceProvider.getResourceValidator
		issues.addAll(validator.validate(resource, CheckMode::ALL, null))
	}
	
	/**
	 * This model-specific method has to be implemented by concrete derived class.
	 * It will use method doValidate() for calling validation for imported resources. 
	 */
	def protected void validateImportedResources (Resource resource)
}

