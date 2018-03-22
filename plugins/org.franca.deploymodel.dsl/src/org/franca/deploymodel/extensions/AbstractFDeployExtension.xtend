/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.extensions

import java.util.Collection
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.franca.core.franca.FrancaPackage
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage

/**
 * Abstract base class for deployment extension implementations.
 * 
 * @author Klaus Birken (itemis AG)
 */
abstract class AbstractFDeployExtension implements IFDeployExtension {

	/**
	 * Empty default implementation of interface method.</p>
	 */
	override Collection<RootDef> getRoots() {
		#[ ]
	}

	/**
	 * Empty default implementation of interface method.</p>
	 */
	override Map<EClass, Collection<Host>> getAdditionalHosts() {
		newHashMap
	}

	/**
	 * Empty default implementation of interface method.</p>
	 */
	override Map<EClass, AccessorArgumentStyle> getAccessorArgumentTypes() {
		newHashMap
	}

	/**
	 * Helper to easily access elements of Franca IDL EMF package.</p> 
	 */
	def protected fidl()    { FrancaPackage.eINSTANCE }	

	/**
	 * Helper to easily access elements of Franca Deployment EMF package.</p> 
	 */
	def protected fdeploy() { FDeployPackage.eINSTANCE }

}
