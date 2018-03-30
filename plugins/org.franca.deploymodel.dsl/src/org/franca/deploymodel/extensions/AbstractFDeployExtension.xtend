/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.extensions

import java.util.Collection
import org.eclipse.emf.ecore.EClass
import org.franca.core.franca.FrancaPackage
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.franca.deploymodel.extensions.IFDeployExtension.HostMixinDef.AccessorArgumentStyle

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
	override Collection<HostMixinDef> getMixins() {
		#[ ]
	}

	/**
	 * Empty default implementation of interface method.</p>
	 */
	override Collection<TypeDef> getTypes() {
		#[ ]
	}

	/**
	 * Helper to easily access elements of Franca IDL EMF package.</p> 
	 */
	def protected fidl()    { FrancaPackage.eINSTANCE }	

	/**
	 * Helper to easily access elements of Franca Deployment EMF package.</p> 
	 */
	def protected fdeploy() { FDeployPackage.eINSTANCE }

	/**
	 * Helper to create a new HostMixinDef descriptor.
	 */
	def protected mixin(EClass clazz, AccessorArgumentStyle argStyle, Collection<Host> hosts) {
		new HostMixinDef(clazz, argStyle, hosts)
	}

	/**
	 * Helper to create a new HostMixinDef descriptor.
	 * 
	 * @param accessorPrefix prefix for property accessor class name, or CHILD_ELEMENT if this mixin
	 *                       should be added to other property accessor based on class hierarchy  
	 */
	def protected mixin(EClass clazz, AccessorArgumentStyle argStyle, String accessorPrefix, Collection<Host> hosts) {
		new HostMixinDef(clazz, argStyle, accessorPrefix, hosts)
	}
}
