/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.core;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeRef;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumerator;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDGeneric;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDOverwriteElement;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDValue;

/**
 * Helper functions for navigation in deployment models.
 * 
 * @author Klaus Birken (itemis AG)
 *
 */
public class FDModelUtils {

	public static FDModel getModel(EObject obj) {
		EObject x = obj;
		while (x != null) {
			if (x instanceof FDModel)
				return (FDModel) x;
			x = x.eContainer();
		};
		return null;
	}

	public static FDRootElement getRootElement(FDElement obj) {
		EObject x = obj;
		while (x != null) {
			if (x instanceof FDRootElement)
				return (FDRootElement) x;
			x = x.eContainer();
		};
		return null;
	}

	/**
	 * Check if a property value is of type FDInterfaceInstance.
	 * 
	 * @param val the property value
	 * @return true if the value is of type FDInterfaceInstance, false otherwise
	 */
	public static boolean isInstanceRef(FDValue val) {
		if (val instanceof FDGeneric) {
			return getInstanceRef(val) != null;
		}
		return false;
	}

	/**
	 * Get the FDInterfaceInstance value of a property value.
	 * 
	 * This will return null if the property has a different type.
	 * 
	 * @param val the property value
	 * @return the property value (if it is a FDInterfaceInstance) or null
	 */
	public static FDInterfaceInstance getInstanceRef(FDValue val) {
		if (val instanceof FDGeneric) {
			EObject vgen = ((FDGeneric)val).getValue();
			if (vgen!=null && (vgen instanceof FDInterfaceInstance)) {
				return (FDInterfaceInstance)vgen;
			}
		}
		return null;
	}

	/**
	 * Check if a property value is of type FDEnumerator.
	 * 
	 * @param val the property value
	 * @return true if the value is of type FDEnumerator, false otherwise
	 */
	public static boolean isEnumerator(FDValue val) {
		if (val instanceof FDGeneric) {
			return getEnumerator(val) != null;
		}
		return false;
	}

	/**
	 * Get the FDEnumerator value of a property value.
	 * 
	 * This will return null if the property has a different type.
	 * 
	 * @param val the property value
	 * @return the property value (if it is a FDEnumerator) or null
	 */
	public static FDEnumerator getEnumerator(FDValue val) {
		if (val instanceof FDGeneric) {
			EObject vgen = ((FDGeneric)val).getValue();
			if (vgen!=null && (vgen instanceof FDEnumerator)) {
				return (FDEnumerator)vgen;
			}
		}
		return null;
	}
	
	/**
	 * Get the target type of an overwrites element.
	 */
	public static FType getOverwriteTargetType(FDOverwriteElement elem) {
		// get Franca type reference depending on type of elem element 
		FTypeRef typeref = null;
		if (elem instanceof FDAttribute) {
			typeref = ((FDAttribute)elem).getTarget().getType();
		} else if (elem instanceof FDArgument) {
			typeref = ((FDArgument)elem).getTarget().getType();
		} else if (elem instanceof FDField) {
			typeref = ((FDField)elem).getTarget().getType();
		} else if (elem instanceof FDArray) {
			typeref = ((FDArray)elem).getTarget().getElementType();
		}
		
		// get type from type reference
		if (typeref==null)
			return null;
		else
			return typeref.getDerived();
	}
}
