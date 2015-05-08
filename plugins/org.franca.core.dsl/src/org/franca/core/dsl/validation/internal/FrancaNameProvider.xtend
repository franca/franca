/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FMethod
import org.franca.core.franca.FArgument
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FBroadcast
import static org.franca.core.franca.FrancaPackage$Literals.*

import static extension org.franca.core.framework.FrancaHelpers.*

class FrancaNameProvider {
	
	/**
	 * Helper function that computes the name of a method or broadcast including
	 * its signature. Used to identify uniquely the element in a restricted
	 * scope.
	 * 
	 * @param e  the object to get the name
	 * @return the name representing the full signature
	 */
	def static getName (EObject obj) {
		val sb = new StringBuilder

		switch (obj) {
			FMethod: {
				sb.append(obj.name)
				for(arg : obj.inArgs) {
					sb.append('_')
					sb.append(arg.typeNameStrict)
				}
				if (! obj.outArgs.empty)
					sb.append('_')
				for(arg : obj.outArgs) {
					sb.append('_')
					sb.append(arg.typeNameStrict)
				}
			}
			FBroadcast: {
				sb.append(obj.name)
				for(arg : obj.outArgs) {
					sb.append('_')
					sb.append(arg.typeNameStrict)
				}
			}
			FTypeRef: {
				sb.append(obj.name)
			}
			default: {
				val modelElementName = obj.eGet(FMODEL_ELEMENT__NAME)
				// while editing the model the modelElementName might not be set
				if (modelElementName != null) {
					sb.append(modelElementName.toString)
				}
			}
		}
		sb.toString
	}

	def private static String getTypeNameStrict (FArgument arg) {
		val sb = new StringBuilder
		sb.append(arg.type.nameStrict)
		if (arg.isArray) {
			sb.append("[]")
		}
		sb.toString
	}

	/**
	 * Get the type name for a given FTypeRef using strict equality rules.
	 * 
	 * Note: All integer types are mapped to the same name "Integer".
	 *       This ensures that different concrete integer types will
	 *       be regarded as conflicting during method overloading.
	 */
	def private static String getNameStrict (FTypeRef type) {
		if (type.derived!=null) {
			type.derived.name
		} else if (type.interval!=null) {
			"Integer"
		} else {
			if (type.isInteger)
				"Integer"
			else
				type.predefined.literal
		}
	}

	/**
	 * Get the type name for a given FTypeRef using relaxed rules.
	 * 
	 * Note: All integer types are regarded as pairwise different.
	 *       This might not be true depending how the ranged "Integer" type
	 *       will be mapped to an actual implementation type.
	 */
	def private static String getName (FTypeRef type) {
		if (type.derived!=null) {
			type.derived.name
		} else if (type.interval!=null) {
			"Integer"
		} else {
			type.predefined.literal
		}
	}
}