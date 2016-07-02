/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.framework

import org.eclipse.emf.ecore.EObject

interface IImportedModelProvider {

	/**
	 * Return a top-level model object (e.g., FModel or FDModel) for a given
	 * importURI string.</p>
	 * 
	 * This interface can be used to get the models resulting from a
	 * model-to-model transformation which produces some Franca and FDeploy models.
	 */
	abstract def EObject getModel(String importURI)	
	
	/**
	 * Return the number of import URIs supported by this provider.
	 */
	abstract def int getNModels()
	
}