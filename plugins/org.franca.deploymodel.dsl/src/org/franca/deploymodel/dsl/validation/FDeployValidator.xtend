/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.validation


/**
 * This class contains custom validation rules for the Franca deployment DSL.</p> 
 *
 * Currently this is just delegating to Franca's old-style Java validator.
 * TODO: This should be replaced in future by converting the Java validator to Xtend and put it here.</p>
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 * </p>
 */
class FDeployValidator extends FDeployJavaValidator {
	
}
