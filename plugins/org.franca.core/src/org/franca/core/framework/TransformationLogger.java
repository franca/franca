/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.framework;

import java.util.Set;

import org.eclipse.emf.ecore.EObject;

import com.google.common.collect.Sets;

/**
 * A logger extension for transformations to/from Franca models to/from other models.
 * 
 * @author kbirken
 */
public class TransformationLogger {
	
	private Set<TransformationIssue> issues = Sets.newHashSet();
	
	/**
	 * Clear the issue store.
	 */
	public void clearIssues() {
		issues.clear();
	}
	
	/**
	 * Add an issue during transformation. Duplicate issues will be detected and
	 * stored only once. This is typically called by the specific transformation
	 * subclass.
	 *  
	 * @param reason    the issue id (see nested class <em>Issue</em> for details)
	 * @param obj       the EObject which triggered the issue (or its EClass)
	 * @param featureId the EMF feature id (from the ecore-model's EPackage)
	 */
	public void addIssue (int reason, EObject obj, int featureId) {
		issues.add(new TransformationIssue(reason, obj, featureId, null));
	}

	/**
	 * Add an issue during transformation. Duplicate issues will be detected and
	 * stored only once. This is typically called by the specific transformation
	 * subclass.
	 *  
	 * @param reason    the issue id (see nested class <em>Issue</em> for details)
	 * @param obj       the EObject which triggered the issue (or its EClass)
	 * @param featureId the EMF feature id (from the ecore-model's EPackage)
	 * @param detail    optional: detail string, typically a feature's runtime value
	 */
	public void addIssue (int reason, EObject obj, int featureId, String detail) {
		issues.add(new TransformationIssue(reason, obj, featureId, detail));
	}

	/**
	 * Return the set of all issues. Typically called after the transformation is done.
	 * 
	 * @return the set of all issues recorded during the transformation.
	 */
	public Set<TransformationIssue> getIssues() {
		return issues;
	}
}

