package org.franca.generators.websocket

import org.franca.core.franca.FInterface

class ClientJSStubGenerator {

	def getStubName(FInterface api) {
		api.name.toFirstUpper + "Client"
	}
	
	def generate(FInterface api) '''
	var WebSocket = require('ws'), ws = new WebSocket('http://localhost:8000');

	«FOR attribute : api.attributes»
	// call to get the value of «attribute.name» asynchronously
	function get«attribute.name.toFirstUpper»() {
		ws.send('[2, "«attribute.name»", "http://localhost/get#«attribute.name»"]');
	};
	
	«IF !attribute.readonly»
	// call to set the value of «attribute.name» asynchronously
	function set«attribute.name.toFirstUpper»(«attribute.name») {
		ws.send('[2, "«attribute.name»", "http://localhost/set#«attribute.name»", "' + «attribute.name» + '"]');
	};
	«ENDIF»
	
	// callback for the value getter for attribute «attribute.name»
	function onGet«attribute.name.toFirstUpper»(«attribute.name») {
		console.log('The value of «attribute.name» is ' + «attribute.name»);
	};
	
	«IF !attribute.noSubscriptions»
	// asynchronous callback which is called if the value of «attribute.name» has changed on the server side
	function on«attribute.name.toFirstUpper»Changed(«attribute.name») {
		console.log('The value of «attribute.name» has changed ' + «attribute.name»);
	};
	
	// call this method to subscribe for the changes of the attribute «attribute.name»
	function subscribe«attribute.name.toFirstUpper»Changed() {
		ws.send('[5, "topic#«attribute.name»"]');
	};
	
	// call this method to unsubscribe from the changes of the attribute «attribute.name»
	function unsubscribe«attribute.name.toFirstUpper»Changed() {
		ws.send('[6, "topic#«attribute.name»"]');
	};
	«ENDIF»
	«ENDFOR»

	ws.on('open', function() {
	    subscribeTitleChanged();
		setTitle("2014");
		getTitle();
	});
	
	ws.on('message', function(data) {
		var message = JSON.parse(data);
		if (Array.isArray(message)) {
			var messageType = message.shift();
			
			// handling of CALLRESULT messages
			if (messageType === 3) {
				var callID = message.shift();
				«FOR attribute : api.attributes»
				if (callID === "«attribute.name»") {
					onGet«attribute.name.toFirstUpper»(message);
				}
				«ENDFOR»
			}
			// handling of EVENT messages
			else if (messageType === 8) {
				var topicURI = message.shift();
				«FOR attribute : api.attributes»
				if (topicURI === "topic#«attribute.name»") {
					on«attribute.name.toFirstUpper»Changed(message);
				}
				«ENDFOR»
			}
		}
	});
	'''

}
