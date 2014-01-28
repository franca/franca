/*******************************************************************************
 * iowamp - WAMP(TM) server in NodeJS Copyright (c) 2013 Pascal Mathis
 * <dev@snapserv.net>
 * 
 * Code changes: Tamas Szabo (itemis AG)
 ******************************************************************************/
var util = require('./util');

var messageTypes = {
	WELCOME : 0,
	PREFIX : 1,
	CALL : 2,
	CALLRESULT : 3,
	CALLERROR : 4,
	SUBSCRIBE : 5,
	UNSUBSCRIBE : 6,
	PUBLISH : 7,
	EVENT : 8
};

function getMessageType(typeID) {
	for ( var key in messageTypes) {
		if (messageTypes[key] == typeID) {
			return key;
		}
	}
	return 'Unknown message type: ' + typeID;
}

var packets = {};

packets.WELCOME = function(sessionID, serverIdent) {
	var packet = [ messageTypes.WELCOME, sessionID, 1, serverIdent ];
	return JSON.stringify(packet);
};

packets.CALLRESULT = function(callID, result) {
	var packet = [ messageTypes.CALLRESULT, callID, result ];
	return JSON.stringify(packet);
};

packets.CALLERROR = function(callID, errorURI, errorDesc) {
	var packet = [ messageTypes.CALLERROR, callID, errorURI, errorDesc ];
	return JSON.stringify(packet);
};

packets.EVENT = function(topicURI, event) {
	var packet = [ messageTypes.EVENT, topicURI, event ];
	return JSON.stringify(packet);
};

var handlers = {};

handlers.PREFIX = function(server, client, prefix, uri) {
	client.prefixes[prefix] = uri;
};

handlers.CALL = function(server, client, callID, procURI) {
	// Get function arguments and parse procURI
	var args = Array.prototype.slice.call(arguments, 4);
	procURI = util.resolveURI(client, procURI);

	// Create callback function
	var cb = function(err, result) {
		if (err !== null) {
			client.send(packets.CALLERROR(callID, 'error:generic', err.toString()));
		} else {
			client.send(packets.CALLRESULT(callID, result));
		}
	};

	// Try to call the method
	if (procURI !== null) {
		if (server.rpcClasses.hasOwnProperty(procURI.baseURI)) {
			var rpcClass = server.rpcClasses[procURI.baseURI];
			if (rpcClass.hasOwnProperty(procURI.methodURI)) {
				var rpcMethod = rpcClass[procURI.methodURI];
				rpcMethod.apply(null, [ client, cb ].concat(args));
				return;
			}
		}

		// Class or method is unknown
		server.emit('unknownCall', procURI.baseURI, procURI.methodURI, [ cb ]
				.concat(args));
	}

};

handlers.SUBSCRIBE = function(server, client, topicURI) {
	if (topicURI !== null) {
		var id = client.topics.indexOf(topicURI);
		if (id === -1) {
			client.topics.push(topicURI);
		}
		
		if (!(topicURI in server.topics)) {
			server.topics[topicURI] = new Array();
		}
		
		id = server.topics[topicURI].indexOf(client.id);
		if (id === -1) {
			server.topics[topicURI].push(client.id);
		}
	}
};

handlers.UNSUBSCRIBE = function(server, client, topicURI) {
	if (topicURI !== null && server.topics[topicURI] !== null) {
		var id = client.topics.indexOf(topicURI);
		if (id > -1) {
			client.topics.splice(id, 1);
		}

		id = server.topics[topicURI].indexOf(client.id);
		if (id > -1) {
			server.topics[topicURI].splice(id, 1);
		}
	}
};

// topicURI, event
// topicURI, event, excludeMe
// topicURI, event, exclude, eligible
handlers.PUBLISH = function(server, client, data) {
	if (data !== null) {
		var topicURI = data[0];
		var event = data[1];
		
		if (data.length === 2) {
			for ( var cid in server.topics[topicURI]) {			
				// sends the EVENT to every client
				server.clients[server.topics[topicURI][cid]].send(packets.EVENT(topicURI, event));
			}			
		}
		else if (data.length === 3) {
			var excludeMe = data[2];
			for ( var cid in server.topics[topicURI]) {			
				// sends the EVENT to every client except client if excludeMe is set
				if (!(server.topics[topicURI][cid] == client.id && excludeMe)) {
					server.clients[server.topics[topicURI][cid]].send(packets.EVENT(topicURI, event));
				}
			}	
		}
	}
};

/**
 * Module exports
 */
exports.getMessageType = getMessageType;
exports.messageTypes = messageTypes;
exports.packets = packets;
exports.handlers = handlers;