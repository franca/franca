/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.websocket

import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FVersion

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.generators.websocket.WebsocketGeneratorUtils.*

class ClientJSProxyGenerator {

	public enum Mode { WAMP_RAW, AUTOBAHN }
	
	def getFileName(FInterface api) {
		api.name.toFirstUpper + "Proxy"
	}
	
	def generate(FInterface api, Mode mode) {
		val fullName = '''«api.model.name».«api.name»'''
		'''
			function «getFileName(api)»() {
				«IF mode==Mode.WAMP_RAW»
				this.socket = null;
				«ELSE»
				this.connection = null;
				this.session = null;
				this.address = "local:«fullName»:«api.version.gen»:«fullName»"
				«ENDIF»
				this.callID = 0;
			}
			
			«getFileName(api)».prototype.getNextCallID = function() {
				this.callID = this.callID + 1;
				return this.callID;
			};

			«IF mode==Mode.WAMP_RAW»
			«FOR attribute : api.attributes»
				«attribute.gen(api)»

			«ENDFOR»
			«ENDIF»
			«FOR method : api.methods»
				«method.gen(api, mode)»
				
			«ENDFOR»
			«getFileName(api)».prototype.connect = function(address) {
				var _this = this;
				
				«IF mode==Mode.WAMP_RAW»
				«api.genWampSocketHandling»
				«ELSE»
				«api.genAutobahnHandling»
				«ENDIF»
			};
			
			«api.types.genEnumerations(false)»
		'''
	}
	
	def private gen(FVersion version) {
		if (version===null)
			"v0_0"
		else
			'''v«version.major»_«version.minor»'''
	}

	def private gen(FAttribute attribute, FInterface api) '''
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
	'''

	def private gen(FMethod method, FInterface api, Mode mode) '''
		// call this method to invoke «method.name» on the server side
		«getFileName(api)».prototype.«method.name» = function(«method.inArgs.genArgList("", ", ")») {
			var cid = this.getNextCallID();
			«IF mode==Mode.WAMP_RAW»
			this.socket.send('[2, "invoke:«method.name»:' + cid + '", "invoke:«method.name»"«IF !method.inArgs.empty», ' + JSON.stringify({«FOR arg : method.inArgs SEPARATOR ", "»"«arg.name»" : «arg.name»«ENDFOR»})«ELSE»'«ENDIF» + ']');
			«ELSE»
			var _this = this;
			this.session.call(this.address + '.«method.name»', [cid«FOR arg : method.inArgs», «arg.name»«ENDFOR»]).then(
				function (res) {
					«val replyMethod = "_this.reply"+method.name.toFirstUpper»
					if (typeof(«replyMethod») === "function") {
						«replyMethod»(cid«method.genReplyArgs»);
					}
				},
				function (err) {
					console.log("Call failed, error message: ", err);
					_this.replyError();
				}
			);
			«ENDIF»
			return cid;
		};
	'''
	
	def private genWampSocketHandling(FInterface api) '''
		// create WebSocket for this proxy	
		_this.socket = new WebSocket(address);

		_this.socket.onopen = function () {
			// subscribing to all broadcasts
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
					«api.genHandleCALLRESULT»
				}
				// handling of EVENT messages
				else if (messageType === 8) {
					«api.genHandleEVENT»
				}
			}
		};
	'''
	
	def private genHandleCALLRESULT(FInterface api) '''
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
	'''
	
	def private genHandleEVENT(FInterface api) '''
		var topicURI = message.shift();
		var data = message.shift();
		«FOR attribute : api.attributes»
		if (topicURI === "signal:«attribute.name»" && typeof(_this.onChanged«attribute.name.toFirstUpper») === "function") {
			_this.onChanged«attribute.name.toFirstUpper»(data);
		}
		«ENDFOR»
		«FOR broadcast : api.broadcasts»
		if (topicURI === "broadcast:«broadcast.name»" && typeof(«broadcast.callback») === "function") {
			«broadcast.callback»(data);
		}
		«ENDFOR»
	'''
	
	def private callback(FBroadcast it) '''_this.signal«name.toFirstUpper»'''
	
	def private genAutobahnHandling(FInterface api) '''
		_this.connection = new autobahn.Connection({
			url: address,
			realm: 'realm1'}
		);

		_this.connection.onopen = function(session, details) {
			console.log("Connected", details);
			if (typeof(_this.onOpened) === "function") {
				_this.onOpened();
			}
			
			_this.session = session;

			// subscribing to all broadcasts
			«FOR broadcast : api.broadcasts»
			session.subscribe(_this.address + '.«broadcast.name»', function(args) {
				if (typeof(«broadcast.callback») === "function") {
					«broadcast.callback»(«FOR i : 0..broadcast.outArgs.size-1 SEPARATOR ", "»args[«i»]«ENDFOR»);
				}
				
			});
			«ENDFOR»
		}

		_this.connection.onclose = function(reason, details) {
			console.log("Connection closed", reason, details);
			if (typeof(_this.onClosed) === "function") {
				_this.onClosed(reason);
			}
		}

		setStatus("Connecting to server...");
		_this.connection.open();

	'''
	
	def private genReplyArgs(FMethod method) {
		if (method.outArgs.empty) {
			""
		} else if (method.outArgs.size==1) {
			", res"
		} else {
			val sb = new StringBuilder
			val n = method.outArgs.size
			for(i : 0..n-1)
				sb.append(''', res.args[«i»]''')
			sb.toString
		}
	}
}
