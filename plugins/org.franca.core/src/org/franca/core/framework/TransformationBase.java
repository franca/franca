/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.framework;

import java.util.Set;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import com.google.common.collect.Sets;

/**
 * The base class for all transformations to/from Franca models to/from other models.
 * 
 * @author kbirken
 */
public class TransformationBase {
	
	/**
	 * This class decribes an issue that occurred during a model transformation 
	 * to/from Franca. It contains all data necessary to analyse the issue after
	 * the transformation has been executed.
	 * 
	 * Note: The current implementation relies on the source model of the model
	 * transformation being an EMF ecore model.  
	 */
	public class Issue {
		/**
		 * Issue id: A feature of the source model is not supported by the transformation.
		 * The information stored in this feature will be lost deliberately.
		 * If you want to fix this in a later release of the transformation, use
		 * issue id FEATURE_NOT_HANDLED_YET instead.
		 */ 
		public static final int FEATURE_NOT_SUPPORTED     = 1;
		
		/**
		 * Issue id: A feature of the source model is ignored deliberately.
		 * A reason for this might be that the corresponding information will be
		 * stored in a deployment model instead of an IDL model.
		 */ 
		public static final int FEATURE_IS_IGNORED        = 2;
		
		/**
		 * Issue id: A certain value of a source model's feature is not supported.
		 * This could be an issue on instance level, not on meta level.  
		 */
		public static final int FEATURE_UNSUPPORTED_VALUE = 3;
		
		/**
		 * Issue id: A feature of the source model is not handled yet, but
		 * should be. This indicates that the transformation flaw will be fixed
		 * in a future version of the transformation.
		 */
		public static final int FEATURE_NOT_HANDLED_YET   = 9;

		private final int reason;
		private final EClass clazz;
		private final int featureId;
		private final String detail;
		
		/**
		 * Constructor for Issue objects
		 * @param reason    the issue id (see definitions FEATURE_... for details)
		 * @param obj       the EObject which triggered the issue (or its EClass)
		 * @param featureId the EMF feature id (from the ecore-model's EPackage)
		 * @param detail    optional: detail string, typically a feature's runtime value
		 */
		public Issue (int reason, EObject obj, int featureId, String detail) {
			this.reason = reason;
			this.clazz = obj.eClass();
			this.featureId = featureId;
			this.detail = detail;
		}

		/**
		 * Get the reason for this issue. See issue id definition for further details.
		 * @return issue id
		 */
		public int getReason() {
			return reason;
		}
		
		/**
		 * Get the detail string for this issue. If there is no detail, an empty
		 * string will be returned.
		 *  
		 * @return detail string, might be empty
		 */
		public String getDetail() {
			return detail==null ? "" : detail;
		}
		
		/**
		 * A human-readable representation of the feature where this issue occurred.
		 * The detail string is not included, just the type of the feature, its class
		 * and the name of the feature itself.
		 *  
		 * @return a string with the feature description.
		 */
		public String getFeatureString() {
			EStructuralFeature feature = clazz.getEStructuralFeature(featureId);
			String featureType = feature.getEType().getName();
			return featureType + " " + clazz.getName() + "." + feature.getName();
		}
		
		@Override
		public boolean equals(Object other) {
			boolean result = false;
			if (other instanceof Issue) {
				Issue that = (Issue) other;
				result = (reason == that.reason &&
						  clazz == that.clazz &&
						  featureId == that.featureId &&
						  getDetail().equals(that.getDetail())
						 );
			}
			return result;
		}

		@Override
		public int hashCode() {
			int hash1 = (41 * (41 + reason) + clazz.hashCode());
			return (41 * (41 * hash1 + featureId) + getDetail().hashCode());
		}
	}
	
	private Set<Issue> issues = Sets.newHashSet();
	
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
		issues.add(new Issue(reason, obj, featureId, null));
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
		issues.add(new Issue(reason, obj, featureId, detail));
	}

	/**
	 * Return the set of all issues. Typically called after the transformation is done.
	 * 
	 * @return the set of all issues recorded during the transformation.
	 */
	public Set<Issue> getIssues() {
		return issues;
	}
}

