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
import static extension org.franca.core.FrancaModelExtensions.*

class ClientJSProxyGenerator {

	def getFileName(FInterface api) {
		api.name.toFirstUpper + "Proxy"
	}
	
	def generate(FInterface api) '''
	function «getFileName(api)»() {
		this.socket = null;
		this.callID = 0;
	}
	
	«getFileName(api)».prototype.getNextCallID = function() {
		this.callID = this.callID + 1;
		return this.callID;
	};

	«FOR attribute : api.attributes»
	// call to get the value of «attribute.name» asynchronously
	«getFileName(api)».prototype.get«attribute.name.toFirstUpper» = function() {
		var cid = this.getNextCallID();
		this.socket.send('[2, "get:«attribute.name»:' + cid + '", "get:«attribute.name»"]');
		return cid;
	};
	
	«IF !attribute.readonly»
	// call to set the value of «attribute.name» asynchronously
	«getFileName(api)».prototype.set«attribute.name.toFirstUpper» = function(«attribute.name») {
		var cid = this.getNextCallID();
		this.socket.send('[2, "set:«attribute.name»:' + cid + '", "set:«attribute.name»", ' + «attribute.name» + ']');
		return cid;
	};
	
	«ENDIF»	
	«IF !attribute.noSubscriptions»	
	// call this method to subscribe for the changes of the attribute «attribute.name»
	«getFileName(api)».prototype.subscribe«attribute.name.toFirstUpper»Changed = function() {
		this.socket.send('[5, "signal:«attribute.name»"]');
	};
	
	// call this method to unsubscribe from the changes of the attribute «attribute.name»
	«getFileName(api)».prototype.unsubscribe«attribute.name.toFirstUpper»Changed = function() {
		this.socket.send('[6, "signal:«attribute.name»"]');
	};
	
	«ENDIF»
	«ENDFOR»
	«FOR method : api.methods»
	// call this method to invoke «method.name» on the server side
	«getFileName(api)».prototype.«method.name» = function(«method.inArgs.genArgList("", ", ")») {
		var cid = this.getNextCallID();
		this.socket.send('[2, "invoke:«method.name»:' + cid + '", "invoke:«method.name»"«IF !method.inArgs.empty», ' + JSON.stringify({«FOR arg : method.inArgs SEPARATOR ", "»"«arg.name»" : «arg.name»«ENDFOR»})«ELSE»'«ENDIF» + ']');
		return cid;
	};
	«ENDFOR»
	
	«getFileName(api)».prototype.connect = function(address) {
		var _this = this;
		
		// create WebSocket for this proxy	
		_this.socket = new WebSocket(address);
	
		_this.socket.onopen = function () {
			// subscribing for all broadcasts
			«FOR broadcast : api.broadcasts»
			_this.socket.send('[5, "broadcast:«broadcast.name»"]');
			«ENDFOR»
			if (typeof(_this.onOpened) === "function") {
				_this.onOpened();
			}
		};

		_this.socket.onerror = function () {
			if (typeof(_this.onError) === "function") {
				_this.onError();
			}
		};
	
		// store reference for this proxy in the WebSocket object
		_this.socket.proxy = _this;
		
		_this.socket.onclose = function(event) {
			if (typeof(_this.onClosed) === "function") {
				_this.onClosed(event);
			}
		};
		
		_this.socket.onmessage = function(data) {
			var message = JSON.parse(data.data);
			if (Array.isArray(message)) {
				var messageType = message.shift();
				
				// handling of CALLRESULT messages
				if (messageType === 3 || messageType === 4) {
					var tokens = message.shift().split(":");
					var mode = tokens[0];
					var name = tokens[1];
					var cid = tokens[2];
					
					if (mode === "get") {
						«FOR attribute : api.attributes»
						if (name === "«attribute.name»" && typeof(_this.onGet«attribute.name.toFirstUpper») === "function") {
							_this.onGet«attribute.name.toFirstUpper»(cid, message);
						}
						«ENDFOR»
					}
					else if (mode === "set") {
						«FOR attribute : api.attributes»
						if (name === "«attribute.name»" && typeof(_this.onSet«attribute.name.toFirstUpper») === "function") {
							// no message is passed
							_this.onSet«attribute.name.toFirstUpper»(cid);
						}
						«ENDFOR»
					}
					else if (mode === "invoke") {
						«FOR method : api.methods»
						if (name === "«method.name»") {
							if (messageType === 3 && typeof(_this.reply«method.name.toFirstUpper») === "function") {
								«IF method.outArgs.size > 1»
								// needs to parse the map which contains the multiple output parameters
								message = JSON.parse(message);
								«ENDIF»
								_this.reply«method.name.toFirstUpper»(cid«IF !method.outArgs.empty», «IF method.outArgs.size == 1»message«ELSE»«FOR arg : method.outArgs SEPARATOR ", "»message["«arg.name»"]«ENDFOR»«ENDIF»«ENDIF»);
							«IF method.hasErrorResponse»
							} else if (messageType === 4 && typeof(_this.error«method.name.toFirstUpper») === "function") {
								var error = message[1];
								_this.error«method.name.toFirstUpper»(cid, error);
							«ENDIF»	
							}
						}
						«ENDFOR»
					}
				}
				// handling of EVENT messages
				else if (messageType === 8) {
					var topicURI = message.shift();
					var data = message.shift();
					«FOR attribute : api.attributes»
					if (topicURI === "signal:«attribute.name»" && typeof(_this.onChanged«attribute.name.toFirstUpper») === "function") {
						_this.onChanged«attribute.name.toFirstUpper»(data);
					}
					«ENDFOR»
					«FOR broadcast : api.broadcasts»
					if (topicURI === "broadcast:«broadcast.name»" && typeof(_this.signal«broadcast.name.toFirstUpper») === "function") {
						_this.signal«broadcast.name.toFirstUpper»(data);
					}
					«ENDFOR»
				}
			}
		};	
	};
	
	«api.types.genEnumerations(false)»
	'''
}
