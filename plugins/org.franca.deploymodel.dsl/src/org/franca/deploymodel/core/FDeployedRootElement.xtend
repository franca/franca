/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.core

import org.franca.deploymodel.dsl.fDeploy.FDRootElement

/** 
 * This class provides type-safe access to deployment properties which are
 * related to a given root element type of a deployment extensions.</p>
 * 
 * The actual get-functions for reading property values are provided
 * by the base class GenericPropertyAccessor in a generic, but 
 * nevertheless type-safe way. The returned value will be the actual
 * property value or the default value as defined in the specification.</p>
 * 
 * @author Klaus Birken (itemis AG)
 * 
 * @see FDeployedInterface, GenericPropertyAccessor
 */
class FDeployedRootElement<T extends FDRootElement> extends GenericPropertyAccessor {
	val T rootElement

	new(T rootElement) {
		super(rootElement.spec)
		this.rootElement = rootElement
	}

	def T getRootElement() {
		return rootElement
	}
}
