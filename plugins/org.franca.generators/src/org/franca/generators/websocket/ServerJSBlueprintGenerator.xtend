/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.websocket

import org.franca.core.franca.FInterface

import static org.franca.core.franca.FrancaPackage.Literals.*
import static org.franca.generators.websocket.WebsocketGeneratorUtils.*

class ServerJSBlueprintGenerator {

	def getFileName(FInterface api) {
		api.name.toFirstUpper + "Blueprint"
	} 

	def getStubName (FInterface api) {
		api.name.toFirstUpper + "Stub"
	}

	def generate(FInterface api) '''
	/**
	 * This is an example websocket server which uses the JS-stub as generated
	 * by Franca's WAMP/Websocket generator in org.franca.generators.websocket. 
	 * 
	 * The server is implemented in JavaScript and is based on node.js and
	 * the websocket.io library.
	 */
	
	// create http server and listen to port 8080
	// we need this to serve index.html and other files to the client
	var HttpServer = require('«genPathToRoot(api.eContainer.eGet(FMODEL_ELEMENT__NAME).toString)»base/util/HttpServer');
	var http = new HttpServer();
	http.init(8080, '«genPathToRoot(api.eContainer.eGet(FMODEL_ELEMENT__NAME).toString)»../client');

	// create websocket stub for SimpleUI interface and listen to websocket port.
	var «getStubName(api)» = require('./«getStubName(api)»');
	var stub = new «getStubName(api)»(8081);
	
	stub.init();
	
	/**
	 * The callback will be called when a new client connects to the server.
	 *
	 * @param {Number} clientID the id of the client
	 */
	stub.onClientConnected = function(clientID) {
		// here goes your code
	};

	/**
	 * The callback will be called when a client disconnects from the server.
	 *
	 * @param {Number} clientID the id of the client
	 */
	stub.onClientDisconnected = function(clientID) {
		// here goes your code
	};
	«FOR attribute : api.attributes»
	«IF !attribute.readonly»
	
	/**
	 * The callback will be called by the server when a client tries to set the 
	 * value of attribute '«attribute.name»'. The returned value will be stored 
	 * by the server. 
	 *
	 * @param «attribute.name»
	 * @return the new value of '«attribute.name»'
	 */
	stub.onSet«attribute.name.toFirstUpper»(«attribute.name») {
		// here goes your code
	};
	«ENDIF»
	«ENDFOR»
	
	«FOR method : api.methods»
	
	/**
	 * The function carries out the async invocation of method '«method.name»'.
	 * 
	 «IF method.outArgs.size > 1»
	 * The returned value must be a Javascript Map, with keys «FOR arg : method.outArgs SEPARATOR ", "»«arg.name»«ENDFOR».
	 *
	 «ENDIF»
	 «FOR arg : method.inArgs»
	 * @param «arg.name»
	 «ENDFOR»
	 «IF method.outArgs.size > 0»
	 * @return the value that should be returned to the client
	 «ENDIF» 
	 */
	stub.«method.name» = function(«FOR arg : method.inArgs SEPARATOR ", "»«arg.name»«ENDFOR») {
		// here goes your code
	};
	«ENDFOR»
	'''
}
