/*******************************************************************************
* Copyright (c) 2018 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.core

import org.franca.deploymodel.dsl.fDeploy.FDBuiltInPropertyHost

/**
 * A property host defines an aspect of a metamodel which can be annotated with
 * deployment properties.</p>
 * 
 * The property host might be either built-in to Franca (referring to concepts 
 * from Franca IDL models like method, number, struct, ...) or provided via
 * a deployment extension.</p>
 * 
 * @author: Klaus Birken (itemis AG)
 */
class FDPropertyHost {
	val FDBuiltInPropertyHost builtinHost
	val String extensionHost
	
	// TODO: introduce cache
	def static builtIn(FDBuiltInPropertyHost asBuiltin) {
		new FDPropertyHost(asBuiltin)
	}

	new(FDBuiltInPropertyHost asBuiltin) {
		builtinHost = asBuiltin
		extensionHost = null
	}
	
	new(String asExtension) {
		builtinHost = null
		extensionHost = asExtension
	}
	
	def getName() {
		if (extensionHost!==null)
			extensionHost
		else
			builtinHost.getName
	}

	def isBuiltIn(FDBuiltInPropertyHost type) {
		builtinHost!==null && builtinHost===type
	}

	def getBuiltIn() {
		builtinHost
	}

	override boolean equals(Object other) {
		if (this===other)
			return true
		if (other===null)
			return false
		if (other.class != this.class)
			return false
			
		val cmp = other as FDPropertyHost
		if (builtinHost != cmp.builtinHost)
			return false
		if (extensionHost != cmp.extensionHost)
			return false
		return true
	}
	
	override int hashCode() {
		var result = 17
		if (builtinHost!==null)
			result = 31 * result + builtinHost.literal.hashCode
		if (extensionHost!==null)
			result = 37 * result + extensionHost.hashCode
		result 
	}
	
	override String toString() {
		if (builtinHost!==null)
			builtinHost.getName
		else
			extensionHost + "!"
	}
}
