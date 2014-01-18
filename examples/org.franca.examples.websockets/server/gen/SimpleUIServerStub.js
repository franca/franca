function SimpleUIServerStub(port) {
	this.wsio = require('websocket.io');
	this.socket = this.wsio.listen(port);
	this.server = new (require('../base/server'))();
	this.title = null;
}

// export the "constructor" function to provide a class-like interface
module.exports = SimpleUIServerStub;

SimpleUIServerStub.prototype.getClients = function() {
	return Objects.keys(this.server.clients);
};

SimpleUIServerStub.prototype.init = function() {
	var _this = this;
	
	_this.socket.on('connection', function(client) {
		_this.server.onConnection(client);
	});
	
	_this.server.on('publishChanges', function(topicURI, event) {
		_this.server.publishChanges(topicURI, event);
	});
	
	// RPC stub for the getter of attribute title
	_this.server.rpc('get', function() {
		this.register('title', function(cb) {
			cb(null, _this.onGetTitle());
		});
	});
	
	// RPC stub for the setter of attribute title
	_this.server.rpc('set', function() {
		this.register('title', function(cb, title) {
			var newValue = _this.onSetTitle(title);
			// send callID back to client
			cb(null, null);
			
			// events will only be sent to subscribed clients if the value has changed
			if (newValue !== this.title) {
				_this.title = newValue;
				_this.server.emit('publishChanges', "signal:title", newValue);
			}
		});
	});
	
	// RPC stub for method setMode
	_this.server.rpc('invoke', function() {
		this.register('setMode', function(cb, callID, p1) {
			// fireAndForget = true
			var result = _this.setMode(p1);
		});
	});
};

SimpleUIServerStub.prototype.updateVelocity = function(data) {
	this.server.emit('publishChanges', "broadcast:updateVelocity", data);
};

// definition of enumeration 'Mode'
var Mode = function(){
	return {
		'M_RADIO':0,
		'M_NAVIGATION':1,
		'M_MULTIMEDIA':2,
		'M_SETTINGS':3
	}
}();
module.exports.Mode = Mode;

