/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.websocket

import org.franca.core.franca.FInterface

import static extension org.franca.generators.websocket.WebsocketGeneratorUtils.*
import static org.franca.core.franca.FrancaPackage$Literals.*

class ServerJSStubGenerator {

	def getStubName (FInterface api) {
		api.name.toFirstUpper + "Stub"
	}

	def generate(FInterface api) '''
	function «getStubName(api)»(port) {
		this.wsio = require('websocket.io');
		this.socket = this.wsio.listen(port);
		this.server = new (require('«FOR t : api.eContainer.eGet(FMODEL_ELEMENT__NAME).toString.split("\\.")»../«ENDFOR»../base/server'))();
		«FOR attribute : api.attributes»
		this.«attribute.name» = null;
		«ENDFOR»
	}

	// export the "constructor" function to provide a class-like interface
	module.exports = «getStubName(api)»;

	«getStubName(api)».prototype.getClients = function() {
		return Objects.keys(this.server.clients);
	};

	«getStubName(api)».prototype.init = function() {
		var _this = this;
		
		_this.socket.on('connection', function(client) {
			_this.server.onConnection(client);
			if (typeof(_this.onClientConnected) === "function") {
				_this.onClientConnected(client.id);
			}
			
			client.on('close', function() {
				if (typeof(_this.onClientDisconnected) === "function") {
					_this.onClientDisconnected(client.id);
				}
			});
		});
		
		_this.server.on('publishAll', function(topicURI, event) {
			_this.server.publishAll(topicURI, event);
		});
		
		_this.server.on('publishExcludeSingle', function(client, topicURI, event) {
			_this.server.publishExcludeSingle(client, topicURI, event);
		});
		
		_this.server.on('publishEligibleList', function(topicURI, event, eligible) {
			_this.server.publishEligibleList(topicURI, event, eligible);
		});
		
		«FOR attribute : api.attributes»
		// RPC stub for the getter of attribute «attribute.name»
		_this.server.rpc('get', function() {
			this.register('«attribute.name»', function(client, cb) {
				cb(null, _this.«attribute.name»);
			});
		});
		
		«IF !attribute.readonly»
		// RPC stub for the setter of attribute «attribute.name»
		_this.server.rpc('set', function() {
			this.register('«attribute.name»', function(client, cb, «attribute.name») {
				var newValue = _this.onSet«attribute.name.toFirstUpper»(«attribute.name»);
				// send callID back to client
				cb(null, null);
				
				// events will only be sent to subscribed clients if the value has changed
				if (newValue !== this.«attribute.name») {
					_this.«attribute.name» = newValue;
					_this.server.emit('publishExcludeSingle', client, "signal:«attribute.name»", newValue);
				}
			});
		});
		
		«ENDIF»
		«ENDFOR»
		«FOR method : api.methods»
		// RPC stub for method «method.name»
		_this.server.rpc('invoke', function() {
			this.register('«method.name»', function(client, cb, args) {
				// fireAndForget = «method.fireAndForget»
				var result = _this.«method.name»(«FOR arg : method.inArgs SEPARATOR ", "»args["«arg.name»"]«ENDFOR»);
				«IF !method.fireAndForget»
				cb(null, JSON.stringify(result));
				«ENDIF»
			});
		});
		«ENDFOR»
	};
	
	«FOR broadcast : api.broadcasts»
	«getStubName(api)».prototype.«broadcast.name» = function(data) {
		this.server.emit('publishAll', "broadcast:«broadcast.name»", data);
	};
	«ENDFOR»
	
	«api.types.genEnumerations(true)»
	'''
}
