/*******************************************************************************
 * iowamp - WAMP(TM) server in NodeJS Copyright (c) 2013 Pascal Mathis
 * <dev@snapserv.net>
 *
 * Code changes: Tamas Szabo (itemis AG)
 ******************************************************************************/
var EventEmitter = require('events'), protocol = require('./wamp_v1'), packets = protocol.packets, handlers = protocol.handlers;
var log4js = require('log4js');
log4js.configure('log4js-conf.json');
var logger = log4js.getLogger('WampServer');

function Server() {
	this.rpcClasses = {};
	this.topics = {}; // this maps the topic URI to set of client ids
	this.clients = {};
};
Server.prototype.__proto__ = EventEmitter.prototype;

/**
 * Generates a random UUID
 */
function generateUUID(a) {
	return a ? (a ^ Math.random() * 16 >> a / 4).toString(16) : ([ 1e7 ] + -1e3
			+ -4e3 + -8e3 + -1e11).replace(/[018]/g, generateUUID);
};

Server.prototype.publishAll = function(topicURI, event) {
	handlers['PUBLISH'].apply(this, [ this, null, [topicURI, event] ]);
};

Server.prototype.publishExcludeSingle = function(client, topicURI, event) {
	handlers['PUBLISH'].apply(this, [ this, client, [topicURI, event, true] ]);
};

Server.prototype.publishEligibleList = function(topicURI, event, eligible) {
	handlers['PUBLISH'].apply(this, [ this, null, [topicURI, event, null, eligible] ]);
};

/**
 * Handles new connections
 *
 * @param {wsio.Socket} client Client instance
 * @return {Server} Own instance for chaining
 */
Server.prototype.onConnection = function(client) {
	var _this = this;

	if (!client.id)
		client.id = generateUUID();
	client.sid = client.id.split('-')[0];
	client.topics = [];
	client.prefixes = {};

	// Add client to client list and send welcome message
	_this.clients[client.id] = client;

	logger.info('[' + client.sid + '] New connection');
	client.send(packets.WELCOME(client.id, 'iowamp'));

	// React if client sends a message
	client.on('message', function(data) {
		_this.onMessage(client, data);
	});

	// React if client closes connection
	client.on('close', function() {
		_this.onClose(client);
	});

	// Specify an empty error handler
	client.on('error', function(error) {
		_this.onError(client, error);
	});

	return this;
};

Server.prototype.onError = function(client, error) {
	logger.info('[' + client.sid + '] ' + error.toString());
};

Server.prototype.onClose = function(client) {
	var _this = this;
	logger.info('[' + client.sid + '] Closed connection');
	if (!client.id)
		return;

	// Remove client in all topics and the client list
	for ( var i in client.topics) {
		logger.info('Client ' + client + ' has unsubscribed from topic '
				+ client.topics[i]);
		var id = _this.topics[client.topics[i]].indexOf(client.id);
		if (id > -1) {
			_this.topics[client.topics[i]].splice(id, 1);
		}
	}

	// this will also delete the prefixes stored for the given client
	delete _this.clients[client.id];
};

Server.prototype.onMessage = function(client, data) {
	var _this = this;
	// Try to parse the received data as JSON
	logger.info('[' + client.sid + '] Data received: ' + data);
	try {
		var msg = JSON.parse(data);
	} catch (e) {
		logger.info('[' + client.sid + '] Can not parse as JSON');
		return;
	}

	// The parsed JSON data should be an array
	if (!Array.isArray(msg)) {
		logger.info('[' + client.sid
				+ '] Invalid packet (should be an array)');
		return;
	}

	// Checks if an handler exists
	var messageType = protocol.getMessageType(msg.shift());
	if (!handlers.hasOwnProperty(messageType)) {
		logger.info('[' + client.sid
				+ '] No handler implemented for message type: '
				+ messageType);
		return;
	}

	// Call the handler with its arguments
	handlers[messageType].apply(_this, [ _this, client ].concat(msg));
};

Server.prototype.rpc = function(baseURI, rpcClass) {
	var _this = this;

	var rpcClassConstructor = {
		register : function(name, method) {
			logger.info('Registered new rcp method: ' + baseURI + ":" + name);
			_this.rpcClasses[baseURI][name] = method;
		}
	};

	// Validate parameters
	var baseURIPattern = /^(http|https):\/\/\S+\/[\w_-]+$/;
	var curiePattern =  /^[\w_-]+$/;

	if (!(baseURIPattern.test(baseURI) || curiePattern.test(baseURI))) {
		throw new Error('Invalid URI specified. (CURIE is not allowed)');
	}
	if (!rpcClass || rpcClass.constructor != Function) {
		throw new Error('No constructor for RPC class specified');
	}

	// Create a new RPC class
	if (!_this.rpcClasses.hasOwnProperty(baseURI)) {
		this.rpcClasses[baseURI] = {};
	}
	rpcClass.apply(rpcClassConstructor);
};

/**
 * Module exports
 *
 * @type Server
 */
module.exports = Server;
