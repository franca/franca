/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.typesystem

import java.util.Collection
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature

class IssueCollector {
	val List<TypeIssue> issues = newArrayList
	
	def Collection<TypeIssue> getIssues() {
		issues
	}
	
	def addIssue (String message, EObject location, EStructuralFeature feature) {
		val issue = new TypeIssue(message, location, feature)
		issues.add(issue)
	}
}