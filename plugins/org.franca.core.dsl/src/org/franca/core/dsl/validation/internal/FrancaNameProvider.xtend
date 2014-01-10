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

class FrancaNameProvider {
	
	/**
	 * Helper function that computes the name of a method, broadcast including
	 * its signature. Used to identify uniquely the element in a restricted
	 * scope.
	 * 
	 * @param e   the object to get the name
	 * @return the name
	 */
	def static getName (EObject obj) {
		val sb = new StringBuilder

		switch (obj) {
			FMethod: {
				sb.append(obj.name)
				for(arg : obj.inArgs) {
					sb.append(arg.typeName)
				}
				for(arg : obj.outArgs) {
					sb.append(arg.typeName)
				}
			}
			FBroadcast: {
				sb.append(obj.name)
				for(arg : obj.outArgs) {
					sb.append(arg.typeName)
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

	def private static String getTypeName (FArgument arg) {
		val sb = new StringBuilder
		sb.append(arg.type.name)
		if (arg.isArray) {
			sb.append("[]")
		}
		sb.toString
	}

	def private static String getName (FTypeRef type) {
		if (type.derived==null) {
			type.predefined.literal
		} else {
			type.derived.name
		}
	}
}