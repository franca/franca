/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.framework

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FModel

class FrancaModelContainer implements IModelContainer, IImportedModelProvider {
	
	/** The main model in this container */
	val FModel mainModel
	
	/**
	 * The main model's name, which is an indication of how to name the
	 * resulting *.fidl file.
	 */
	 val String mainModelName
	
	/**
	 * If this is a multi-resource model created by some transformation,
	 * we will store a mapping from the importURIs to the actual models here.
	 * This will be used during saving the model in order to create proper
	 * resources for each importURI which contain the corresponding FModel.
	 */
	val Map<String, EObject> importedModels
	
	new(FModel fmodel) {
		this.mainModel = fmodel
		this.mainModelName = null
		this.importedModels = newLinkedHashMap
	}
	
	new(FModel fmodel, String fmodelName, Map<String, EObject> importedModels) {
		this.mainModel = fmodel
		this.mainModelName = fmodelName
		this.importedModels = importedModels
	}
	
	def model() {
		this.mainModel
	}
	
	def modelName() {
		this.mainModelName
	}
	
	override getModel(String importURI) {
		if (importedModels.containsKey(importURI)) {
			importedModels.get(importURI)
		} else {
			null
		}
	}
	
	override getNModels() {
		importedModels.size
	}
	
}
