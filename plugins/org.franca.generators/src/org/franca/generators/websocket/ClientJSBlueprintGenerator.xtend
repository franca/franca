/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.websocket

import org.franca.core.franca.FInterface

class ClientJSBlueprintGenerator {

	def getFileName(FInterface api) {
		api.name.toFirstUpper + "Blueprint"
	}
	
	def getStubName(FInterface api) {
		api.name.toFirstUpper + "Proxy"
	}
	
	def generate(FInterface api) '''
	var proxy = new «getStubName(api)»();
	proxy.connect('ws://localhost:8081');

	/**
	 * The function will be called when the connection to the server has been established.
	 */
	proxy.onOpened = function() {
		// your code goes here
	};
	
	/**
	 * The function will be called when the connection to the server has been terminated.
	 */ 
	proxy.onClosed = function() {
		// your code goes here
	};
	
	«FOR attribute : api.attributes»
	/**
	 * Async callback in response to a 'get«attribute.name.toFirstUpper»' call.
	 *
	 * @param {Number} cid the id of the client
	 * @param «attribute.name» the value of the attribute '«attribute.name»'
	 */
	proxy.onGet«attribute.name.toFirstUpper» = function(cid, «attribute.name») {
		// your code goes here
	};

	«IF !attribute.readonly»
	/**
	 * Async callback in response to a 'set«attribute.name.toFirstUpper»' call.
	 * 
	 * @param {Number} cid the id of the client
	 */
	proxy.onSet«attribute.name.toFirstUpper» = function(cid) {
		// your code goes here
	};
	«ENDIF»
	
	/**
	 * Callback to notify that a change has occurred in the value of attribute '«attribute.name»' on the server side.
	 * The function will only be called if the client has subscribed to the changes of this attribute by calling 
	 * 'subscribe«attribute.name.toFirstUpper»Changed'. 
	 * 
	 * @param «attribute.name» the value of the attribute '«attribute.name»'
	 */
	proxy.onChanged«attribute.name.toFirstUpper» = function(«attribute.name») {
		// your code goes here
	};
	«ENDFOR»
	
	«FOR method : api.methods»
	/**
	 * Async callback in response to a '«method.name»' call.
	 * 
	 * @param cid the call id
	 «FOR arg : method.outArgs»
	 * @param «arg.name»
	 «ENDFOR»
	 */
	proxy.reply«method.name.toFirstUpper» = function(cid«IF !method.outArgs.empty», «FOR arg : method.outArgs SEPARATOR ", "»«arg.name»«ENDFOR»«ENDIF») {
		// your code goes here
	};
	«ENDFOR»
	
	«FOR broadcast : api.broadcasts»
	/**
	 * The callback is called when the '«broadcast.name»' broadcast is called on the server side. 
	 * No prior subscription is needed to receive these notifications. 
	 * 
	 * @param «broadcast.name» the value which is broadcasted
	 */
	proxy.signal«broadcast.name.toFirstUpper» = function(«broadcast.name») {
		// here goes your code
	};
	«ENDFOR»
	'''
}
