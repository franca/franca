var wsio = require('websocket.io');
var socket = wsio.listen(8000);
var server = new (require('./server'))();

socket.on('connection', function(client) {
	server.onConnection(client);
});

server.on('publishChanges', function(topicURI, event) {
	server.publishChanges(topicURI, event);
});

server.nonSubscribableAttributes = [];

// Generated code for attribute title
server.title = null;

server.rpc('http://localhost/get', function() {
	this.register('title', function(cb) {
		cb(null, onGetTitleAttribute());
	});
});

server.rpc('http://localhost/set', function() {
	this.register('title', function(cb, title) {
		var newValue = onSetTitleAttribute(title);
		server.title = newValue;
		server.emit('publishChanges', "topic#title", newValue);
	});
});

function onGetTitleAttribute() {
	return server.title;
};

function onSetTitleAttribute(title) {
	return title;
};

