/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.extensions

import com.google.common.collect.Lists
import java.util.Collection
import java.util.List
import org.franca.deploymodel.extensions.IFDeployExtension.AbstractElementDef
import org.franca.deploymodel.extensions.IFDeployExtension.Host

class ExtensionUtils {

	def static Collection<Host> getAllHosts(IFDeployExtension ext) {
		val List<Host> result = Lists.newArrayList
		
		// add all hosts from the root definitions 
		ext.roots.forEach[getHosts(ext, result)]
		
		// add all additional hosts
		result.addAll(ext.additionalHosts.values.flatten)

		result
	}

	def private static void getHosts(AbstractElementDef elem, IFDeployExtension ext, List<Host> result) {
		result.addAll(elem.hosts)
		
		// traverse children recursively
		for(child : elem.children) {
			child.getHosts(ext, result)
		} 
	}

	 
}