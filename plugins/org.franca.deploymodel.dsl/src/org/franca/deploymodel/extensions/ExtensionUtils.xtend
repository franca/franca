/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.extensions

import com.google.common.collect.Iterables
import java.util.Set
import org.franca.deploymodel.extensions.IFDeployExtension.AbstractElementDef
import org.franca.deploymodel.extensions.IFDeployExtension.Host

class ExtensionUtils {

	/**
	 * Get all hosts defined by a deployment extension.</p>
	 */
	def static Set<Host> getAllHosts(IFDeployExtension ext) {
		Iterables.concat(
			// all hosts from the root definitions 
			ext.roots.map[allHostsAux].flatten,

			// all additional hosts
			ext.mixins.map[hosts].flatten
		).toSet
	}

	/**
	 * Get the set of all hosts only for an element's children and their subtrees.<p>
	 */
	def static Set<Host> getHostsOnlyInSubtree(AbstractElementDef elem) {
		elem.hostsOnlyInSubtreeAux.toSet
	}

	/**
	 * Get the set of all hosts relevant for an element or its element subtree.</p>
	 */
	def static Set<Host> getAllHosts(AbstractElementDef elem) {
		elem.allHostsAux.toSet
	}

	/**
	 * Helper: Get all hosts only for an element's children and their subtrees.<p>
	 */
	def private static Iterable<Host> getHostsOnlyInSubtreeAux(AbstractElementDef elem) {
		elem.children.map[allHostsAux].flatten
	}

	/**
	 * Helper: Get all hosts relevant for an element or its element subtree.</p>
	 */
	def private static Iterable<Host> getAllHostsAux(AbstractElementDef elem) {
		Iterables.concat(
			elem.hosts,
			elem.getHostsOnlyInSubtreeAux
		)
	}

	 
}