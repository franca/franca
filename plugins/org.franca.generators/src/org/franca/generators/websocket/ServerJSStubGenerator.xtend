package org.franca.generators.websocket

import org.franca.core.franca.FInterface
import static extension org.franca.generators.websocket.WebsocketGeneratorUtils.*

class ServerJSStubGenerator {

	def getStubName (FInterface api) {
		api.name.toFirstUpper + "ServerStub"
	}

	def generate(FInterface api) '''
	function «getStubName(api)»(port) {
		this.wsio = require('websocket.io');
		this.socket = this.wsio.listen(port);
		this.server = new (require('../base/server'))();
		«FOR attribute : api.attributes»
		this.«attribute.name» = null;
		«ENDFOR»
	}

	// export the "constructor" function to provide a class-like interface
	module.exports = «getStubName(api)»;

	«getStubName(api)».prototype.init = function() {
		var _this = this;
		
		_this.socket.on('connection', function(client) {
			_this.server.onConnection(client);
		});
		
		_this.server.on('publishChanges', function(topicURI, event) {
			_this.server.publishChanges(topicURI, event);
		});
		
		«FOR attribute : api.attributes»
		_this.server.rpc('get', function() {
			this.register('«attribute.name»', function(cb) {
				cb(null, _this.onGet«attribute.name.toFirstUpper»());
			});
		});
		
		«IF !attribute.readonly»
		_this.server.rpc('set', function() {
			this.register('«attribute.name»', function(cb, «attribute.name») {
				var newValue = _this.onSet«attribute.name.toFirstUpper»(«attribute.name»);
				// send callID back to client
				cb(null, null);
				
				// events will only be sent to subscribed clients if the value has changed
				if (newValue !== this.«attribute.name») {
					_this.«attribute.name» = newValue;
					_this.server.emit('publishChanges', "topic:«attribute.name»", newValue);
				}
			});
		});
		
		«ENDIF»
		«ENDFOR»
		«FOR method : api.methods»
		this.server.rpc('invoke', function() {
			this.register('«method.name»', function(cb, callID«IF !method.inArgs.empty», «method.inArgs.genArgList("", ", ")»«ENDIF») {
				var result = «method.name»(«method.inArgs.genArgList("", ", ")»);
				if (result !== 'undefined') { 
					cb(null, result);
				};
			});
		});
		«ENDFOR»
	};
	
	«api.types.genEnumerations(true)»
	'''
}
