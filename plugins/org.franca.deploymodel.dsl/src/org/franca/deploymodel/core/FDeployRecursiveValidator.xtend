/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.core

import org.eclipse.emf.ecore.resource.Resource
import org.franca.core.franca.FModel
import org.franca.core.utils.AbstractFrancaValidator
import org.franca.deploymodel.dsl.fDeploy.FDModel

/**
 * Uses Xtext validators of Franca IDL and Franca deployment DSL to validate
 * a Franca resource (*.fidl or *.fdepl). It will validate imported files 
 * recursively.
 * 
 * @author Klaus Birken (itemis)
 */
class FDeployRecursiveValidator extends AbstractFrancaValidator {
	
	override void validateImportedResources (Resource resource) {
		val model = resource.contents.get(0)
		switch (model) {
			FModel:  model.imports.map[importURI].doValidate(resource.resourceSet)
			FDModel: model.imports.map[importURI].doValidate(resource.resourceSet)
			default: new Exception("Unknown resource content '" + model.toString + "'")
		}
	}
}