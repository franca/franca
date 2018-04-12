/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.ext.providers

import org.franca.deploymodel.core.FDeployedRootElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot

/** 
 * This class provides type-safe access to deployment properties which are
 * related to interface providers and interface instances.</p>
 * 
 * It is a wrapper for FDeployedRootElement and provided for convenience.</p>
 * 
 * @author Klaus Birken (itemis AG)
 * @see FDeployedInterface
 */
class FDeployedProvider extends FDeployedRootElement<FDExtensionRoot> {
	new(FDExtensionRoot provider) {
		super(provider)
	}
	
	def getProvider() {
		rootElement
	}
}
