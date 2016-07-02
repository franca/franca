/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.framework;

import java.util.Set;

/**
 * A helper class which provides human-readable representations of 
 * issues recorded during a model2model transformation.
 * 
 * @author kbirken
 * @see TransformationBase
 */
public class IssueReporter {
	
	/**
	 * Provide a human-readable report for all issues during a transformation.
	 * 
	 * @param trafo  the transformation
	 * @return the report string (usually multi-line)
	 * 
	 * @deprecated Use getReportString(Set<TransformationIssue> issues) instead
	 */
	public static String getReportString (TransformationBase trafo) {
		return getReportString(trafo.getIssues());
	}


	/**
	 * Provide a human-readable report for all issues during a transformation.
	 * 
	 * @param logger  the transformation logger
	 * @return the report string (usually multi-line)
	 */
	public static String getReportString (Set<TransformationIssue> issues) {
		if (issues.isEmpty()) {
			return "Transformation completed without issues.";
		}
		
		String res = "Transformation completed with " + issues.size() + " issues:\n";
		for(TransformationIssue issue : issues) {
			res += "\t" + getIssueString(issue);
		}
		return res;
	}

	
	/**
	 * Provide a human-readable string for a given issue.
	 * 
	 * @param issue  the transformation issue
	 * @return human-readable string describing the issue
	 */
	public static String getIssueString (TransformationIssue issue) {
		String feature = issue.getFeatureString();
		String ret = "";
		switch (issue.getReason()) {
		case TransformationIssue.FEATURE_NOT_SUPPORTED:
			ret = "Transformation does not support feature";
			break;
		case TransformationIssue.FEATURE_IS_IGNORED:
			ret = "Transformation deliberately ignores feature";
			break;
		case TransformationIssue.FEATURE_UNSUPPORTED_VALUE:
			ret = "Transformation doesn't support the value of this feature";
			break;
		case TransformationIssue.FEATURE_NOT_HANDLED_YET:
			ret = "TODO: Transformation should handle feature";
			break;
		case TransformationIssue.FEATURE_NOT_FULLY_SUPPORTED:
			ret = "Transformation handles partially the feature";
			break;
		case TransformationIssue.IMPORT_ERROR:
			ret = "Error when importing from other IDL";
			break;
		case TransformationIssue.IMPORT_WARNING:
			ret = "Warning when importing from other IDL";
			break;

		default:
			ret = "Transformation issued unspecified problem (id=" + issue.getReason() + ") with feature";
		}
		String detail = issue.getDetail();
		if (! detail.isEmpty()) {
			detail = " (" + detail + ")";
		}
		return ret + " '" + feature + "'" + detail + ".\n";
	}

}
