function SimpleUIServerStub(port) {
	this.wsio = require('websocket.io');
	this.socket = this.wsio.listen(port);
	this.server = new (require('../base/server'))();
	this.title = null;
}

// export the "constructor" function to provide a class-like interface
module.exports = SimpleUIServerStub;

SimpleUIServerStub.prototype.init = function() {
	var _this = this;
	
	_this.socket.on('connection', function(client) {
		_this.server.onConnection(client);
	});
	
	_this.server.on('publishChanges', function(topicURI, event) {
		_this.server.publishChanges(topicURI, event);
	});
	
	_this.server.rpc('get', function() {
		this.register('title', function(cb) {
			cb(null, _this.onGetTitle());
		});
	});
	
	_this.server.rpc('set', function() {
		this.register('title', function(cb, title) {
			var newValue = _this.onSetTitle(title);
			// send callID back to client
			cb(null, null);
			
			// events will only be sent to subscribed clients if the value has changed
			if (newValue !== this.title) {
				_this.title = newValue;
				_this.server.emit('publishChanges', "topic:title", newValue);
			}
		});
	});
	
};

