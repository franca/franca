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

import static extension org.franca.generators.websocket.WebsocketGeneratorUtils.*
import static extension org.franca.core.FrancaModelExtensions.*

class ServerJSStubGenerator {

	def getFileName (FInterface api) {
		api.name.toFirstUpper + "Stub"
	}

	def generate(FInterface api) '''
	'use strict';
	var log4js = require('log4js');
	log4js.configure('log4js-conf.json');
	var logger = log4js.getLogger('«api.fileName»');

	function «getFileName(api)»(port) {
		this.wsio = require('websocket.io');
		this.socket = this.wsio.listen(port);
		this.server = new (require('«genPathToRoot(api.package)»base/iowamp/server'))();
		«FOR attribute : api.attributes»
		this.«attribute.name» = null;
		«ENDFOR»
	}

	// export the "constructor" function to provide a class-like interface
	module.exports = «getFileName(api)»;

	«getFileName(api)».prototype.getClients = function() {
		return Objects.keys(this.server.clients);
	};
	
	«FOR attribute : api.attributes»
	«getFileName(api)».prototype.set«attribute.name.toFirstUpper» = function(newValue) {
		logger.info(JSON.stringify({type: "attribute", name:'«attribute.name»', params:newValue}));
		this.«attribute.name» = newValue;
		this.server.emit('publishAll', "signal:«attribute.name»", newValue);
	};
	«ENDFOR»

	«getFileName(api)».prototype.init = function() {
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
					logger.info('«attribute.name»: ' + newValue);
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
				logger.info(JSON.stringify({type: "request", name:'«method.name»', params:args}));						
				«IF method.fireAndForget»
					_this.«method.name»(«method.inArgs.genArgs»);
				«ELSE»
					if (typeof(_this.«method.name»Sync) === "function") {
						var result = _this.«method.name»Sync(«method.inArgs.genArgs»);
						logger.info('request: «method.name»');
						// TODO: How to handle error responses in the synchronous case?
						cb(null, JSON.stringify(result));
						logger.info(JSON.stringify({type: "response", name:'«method.name»', params:result}));						
					} else if (typeof(_this.«method.name») === "function") {
						_this.«method.name»(«method.inArgs.genArgs»«IF !method.inArgs.empty»,«ENDIF»
							function(result) {
								cb(null, JSON.stringify(result));
								logger.info(JSON.stringify({type: "response", name:'«method.name»', params:result}));						
							}«IF method.hasErrorResponse»,«ENDIF»
							«IF method.hasErrorResponse»
								function(error) {
									cb(error, null);
									logger.error(JSON.stringify({type: "error", name:'«method.name»', params:error}));						
								}
							«ENDIF»
						);
					}
				«ENDIF»
			});
		});
		«ENDFOR»
	};
	
	«FOR broadcast : api.broadcasts»
	«getFileName(api)».prototype.«broadcast.name» = function(data) {
		this.server.emit('publishAll', "broadcast:«broadcast.name»", data);
		logger.info('signal: «broadcast.name» ' + JSON.stringify(data));
	};
	«ENDFOR»
	
	«api.types.genEnumerations(true)»
	'''

	def private genArgs(List<FArgument> args) '''«FOR arg : args SEPARATOR ", "»args["«arg.name»"]«ENDFOR»'''
}
