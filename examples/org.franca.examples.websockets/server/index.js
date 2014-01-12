/*******************************************************************************
 * iowamp - WAMP(TM) server in NodeJS Copyright (c) 2013 Pascal Mathis
 * <dev@snapserv.net>
 * 
 * Code changes: Tamas Szabo (itemis AG)
 ******************************************************************************/
var wsio = require('websocket.io');
var socket = wsio.listen(8000);
var server = new (require('./server'))();

socket.on('connection', function(client) {
    server.onConnection(client);
});

server.title = "";

server.rpc('http://localhost/get', function() {
	this.register('title', function(cb) {
		cb(null, onGetTitleAttribute());
	});
});

server.rpc('http://localhost/set', function() {
	this.register('title', function(cb, title) {
		onSetTitleAttribute(title);
	});
});

function onSetTitleAttribute(title) {
	server.title = title;
};

function onGetTitleAttribute() {
	return server.title;
}