package org.franca.generators.websocket

import org.franca.core.franca.FInterface
import static extension org.franca.generators.websocket.WebsocketGeneratorUtils.*

class ServerJSStubGenerator {

	def getStubName (FInterface api) {
		api.name.toFirstUpper + "Server"
	}

	def generate(FInterface api) '''
	var wsio = require('websocket.io');
	var socket = wsio.listen(8000);
	var server = new (require('./server'))();

	socket.on('connection', function(client) {
		server.onConnection(client);
	});
	
	server.on('publishChanges', function(topicURI, event) {
		server.publishChanges(topicURI, event);
	});
	
	«FOR attribute : api.attributes»
	// Generated code for attribute «attribute.name»
	server.«attribute.name» = null;
	
	server.rpc('http://localhost/get', function() {
		this.register('«attribute.name»', function(cb) {
			cb(null, onGet«attribute.name.toFirstUpper»Attribute());
		});
	});

	«IF !attribute.readonly»
	server.rpc('http://localhost/set', function() {
		this.register('«attribute.name»', function(cb, «attribute.name») {
			var newValue = onSet«attribute.name.toFirstUpper»Attribute(«attribute.name»);
			server.«attribute.name» = newValue;
			server.emit('publishChanges', "topic#«attribute.name»", newValue);
		});
	});
	
	«ENDIF»
	function onGet«attribute.name.toFirstUpper»Attribute() {
		return server.«attribute.name»;
	};
	
	«IF !attribute.readonly»
	function onSet«attribute.name.toFirstUpper»Attribute(«attribute.name») {
		return «attribute.name»;
	};
	
	«ENDIF»
	«ENDFOR»
	«FOR method : api.methods»
	server.rpc('http://localhost/invoke', function() {
		this.register('«method.name»', function(cb«IF !method.inArgs.empty», «method.inArgs.genArgList("", ", ")»«ENDIF») {
			var result = «method.name»(«method.inArgs.genArgList("", ", ")»);
			if (result !== 'undefined') { 
				cb(null, result);
			};
		});
	});
	
	function «method.name»(«method.inArgs.genArgList("", ", ")») {
		
	};
	«ENDFOR»
	
	«api.types.genEnumerations(true)»
	'''
}
