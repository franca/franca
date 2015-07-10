/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.typesystem

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature

//@Data
class TypeIssue {
	String message
	EObject location
	EStructuralFeature feature
	
	new (String message, EObject location, EStructuralFeature feature) {
		this.message = message
		this.location = location
		this.feature = feature
	}
	
	def String getMessage() {
		this.message
	}
	
	def EObject getLocation() {
		this.location
	}
	
	def EStructuralFeature getFeature() {
		this.feature
	}
	
}