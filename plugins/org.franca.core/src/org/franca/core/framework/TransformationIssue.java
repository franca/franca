package org.franca.core.framework;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

/**
 * This class decribes an issue that occurred during a model transformation 
 * to/from Franca. It contains all data necessary to analyse the issue after
 * the transformation has been executed.
 * 
 * Note: The current implementation relies on the source model of the model
 * transformation being an EMF ecore model.  
 */
public class TransformationIssue {
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
	public static final int FEATURE_NOT_HANDLED_YET   = 4;

	/**
	 * Issue id: A feature of the source model is not fully supported. 
	 * Some information can be lost or the whole information can be lost for certain cases. 
	 */
	public static final int FEATURE_NOT_FULLY_SUPPORTED   = 5;
	
	/**
	 * Issue id: Some error was detected when importing into Franca, the imported model is not consistent.  
	 */
	public static final int  IMPORT_ERROR  = 6;
	
	/**
	 * Issue id: Some non critical inconsistency was detected when importing into Franca, the imported model is not consistent.  
	 */
	public static final int  IMPORT_WARNING  = 7;

	
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
	public TransformationIssue (int reason, EObject obj, int featureId, String detail) {
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
		if (feature != null)
		{
			String featureType = feature.getEType().getName();
			return featureType + " " + clazz.getName() + "." + feature.getName();
		}
		else
		{
			return null;
		}
	}
	
	@Override
	public boolean equals(Object other) {
		boolean result = false;
		if (other instanceof TransformationIssue) {
			TransformationIssue that = (TransformationIssue) other;
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