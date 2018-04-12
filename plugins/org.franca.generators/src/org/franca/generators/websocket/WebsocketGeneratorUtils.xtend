/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.websocket

import org.franca.core.franca.FArgument
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FInterface
import org.franca.core.franca.FType
import org.franca.core.utils.ExpressionEvaluator

import static extension org.franca.core.FrancaModelExtensions.*

class WebsocketGeneratorUtils {
	
	def static genEnumerations (Iterable<FType> types, boolean withExport) '''
		«FOR t : types.filter(typeof(FEnumerationType))»
		// definition of enumeration '«t.name»'
		var «t.name» = function(){
			return {
				«FOR e : t.enumerators SEPARATOR ','»
				'«e.name»':«e.enumValue»
				«ENDFOR»
			}
		}();
		«IF withExport»
		module.exports.«t.name» = «t.name»;
		«ENDIF»

		«ENDFOR»
	'''
	
	def static getEnumValue(FEnumerator e) {
		if (e.value!==null) {
			ExpressionEvaluator::evaluateInteger(e.value)
		} else {
			val parent = e.enumeration
			parent.enumerators.indexOf(e)
		}
	}

	def static getPackage(FInterface api) {
		val fmodel = api.model
		if (fmodel===null) {
			""
		} else {
			fmodel.name
		}
	}
	
	def static genPathToRoot (String packageName) '''../«FOR t : packageName.split("\\.")»../«ENDFOR»'''

	def static genArgList (Iterable<FArgument> args, String prefix, String separator)
	'''«FOR a : args SEPARATOR separator»«prefix + a.name»«ENDFOR»'''

}