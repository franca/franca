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

server.rpc('http://localhost/calc', function() {
	this.register('add', function(cb, a, b) {
		cb(null, a + b);
	});
});