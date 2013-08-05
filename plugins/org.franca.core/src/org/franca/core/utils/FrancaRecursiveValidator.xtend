/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils

import org.eclipse.emf.ecore.resource.Resource
import org.franca.core.franca.FModel

import org.eclipse.xtext.diagnostics.Severity;

/**
 * Uses Xtext validators of Franca IDL to validate a Franca resource (*.fidl).
 * It will validate imported files recursively.
 * 
 * @author Klaus Birken (itemis)
 */
class FrancaRecursiveValidator extends AbstractFrancaValidator {

	override void validateImportedResources(Resource resource) {
		val model = resource.contents.get(0)
		switch (model) {
			FModel: model.imports.map[importURI].doValidate(resource.resourceSet)
			default: new Exception("Unknown resource content '" + model.toString + "'")
		}
	}

	def boolean hasErrors(Resource resource) {
		val issues = this.validate(resource);
		for (issue : issues) {
			if (issue.getSeverity() == Severity::ERROR) {
				return true;
			}
		}
		return false;
	}

}
