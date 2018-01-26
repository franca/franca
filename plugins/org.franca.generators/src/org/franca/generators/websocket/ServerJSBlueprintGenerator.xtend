/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.websocket

import java.util.List
import org.franca.core.franca.FArgument
import org.franca.core.franca.FInterface

import static org.franca.generators.websocket.WebsocketGeneratorUtils.*

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.core.framework.FrancaHelpers.*

class ServerJSBlueprintGenerator {

	def getFileName(FInterface api) {
		api.name.toFirstUpper + "ServerBlueprint"
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
	var HttpServer = require('«genPathToRoot(api.model.name)»base/util/HttpServer');
	var http = new HttpServer();
	http.init(8080, '«genPathToRoot(api.model.name)»../client');

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
	 * You should either define this function or the synchronous counterpart (see below).
	 * 
	 «IF method.outArgs.size > 1»
	 * The returned value must be a Javascript map, with keys «method.outArgs.join(', ')».
	 *
	 «ENDIF»
	 «FOR arg : method.inArgs»
	 * @param «arg.name»
	 «ENDFOR»
	 * @param reply the callback function for sending a normal response for '«method.name»'
	 «IF method.hasErrorResponse»
	 * @param error the callback function for indicating an error for '«method.name»'
	 «ENDIF»
	 */
	stub.«method.name» = function(«method.inArgs.map[name+', '].join»reply«IF method.hasErrorResponse», error«ENDIF») {
		// here goes your code
		«IF method.hasErrorResponse»
		 
		if (errorOccured) {
			/* code is one of «method.allErrorEnumerators.map["'" + name + "'"].join(', ')» */
			error(code);
		} else {
			reply(«method.outArgs.map[name].join(', ')»);
		}
		«ELSE»
		 
		reply(«method.outArgs.map[name].join(', ')»);
		«ENDIF» 
	};

	/**
	 * The function carries out the synchronous invocation of method '«method.name»'.
	 *
	 * You should either define this function or the async counterpart (see above).
	 * 
	 «IF method.outArgs.size > 1»
	 * The returned value must be a Javascript map, with keys «method.outArgs.map[name].join(', ')».
	 *
	 «ENDIF»
	 «FOR arg : method.inArgs»
	 * @param «arg.name»
	 «ENDFOR»
	 «IF method.outArgs.size > 0»
	 * @return the value that should be returned to the client
	 «ENDIF» 
	 */
	stub.«method.name»Sync = function(«method.inArgs.map[name].join(', ')») {
		// here goes your code
		«IF method.outArgs.size > 0»

		return result;
		«ENDIF»
	};
	«ENDFOR»
	
	// The following attributes are defined
	«FOR attribute : api.attributes»
	stub.«attribute.name» = <«attribute.type.typeString»>;
	«ENDFOR»
	
	// These functions are provided by the stub
	stub.getClients();

	«FOR attribute : api.attributes»
	stub.set«attribute.name.toFirstUpper»(<«attribute.type.typeString»>);
	
	«ENDFOR»
	«FOR broadcast : api.broadcasts»
	stub.«broadcast.name»(«broadcast.outArgs.map[name].join(', ')»);
	
	«ENDFOR»
	'''

}
