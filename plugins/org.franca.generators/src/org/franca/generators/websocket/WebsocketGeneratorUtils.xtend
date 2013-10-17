/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.websocket

import org.franca.core.franca.FType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FArgument

class WebsocketGeneratorUtils {
	
	def static genEnumerations (Iterable<FType> types) '''
		«FOR t : types.filter(typeof(FEnumerationType))»
		// definition of enumeration '«t.name»'
		var «t.name» = function(){
			return {
				«FOR e : t.enumerators SEPARATOR ','»
				'«e.name»':«t.enumerators.indexOf(e)»
				«ENDFOR»
			}
		}();

		«ENDFOR»
	'''

	def static genArgList (Iterable<FArgument> args, String prefix)
		'''«FOR a : args SEPARATOR ", "»«prefix + a.name»«ENDFOR»'''

}