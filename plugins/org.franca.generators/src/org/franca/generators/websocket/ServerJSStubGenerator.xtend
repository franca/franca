package org.franca.generators.websocket

import org.franca.core.franca.FInterface

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
	
	server.nonSubscribableAttributes = [«FOR attribute : api.attributes.filter[it.noSubscriptions] SEPARATOR ', '»«attribute.name»«ENDFOR»];
	
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
	'''
}
