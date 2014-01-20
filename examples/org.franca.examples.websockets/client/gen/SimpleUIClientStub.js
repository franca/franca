function SimpleUIClientStub() {
	this.socket = null;
	this.callID = 0;
}

SimpleUIClientStub.prototype.getNextCallID = function() {
	this.callID = this.callID + 1;
	return this.callID;
};

// call this method to invoke setMode on the server side
SimpleUIClientStub.prototype.setMode = function(mode) {
	var cid = this.getNextCallID();
	this.socket.send('[2, "invoke:setMode:' + cid + '", "invoke:setMode", ["' + mode + '"]]');
	return cid;
};

SimpleUIClientStub.prototype.connect = function(address) {
	var _this = this;
	
	// create WebSocket for this proxy	
	_this.socket = new WebSocket(address);

	_this.socket.onopen = function () {
		// subscribing for all broadcasts
		_this.socket.send('[5, "broadcast:updateVelocity"]');
	};

	// store reference for this proxy in the WebSocket object
	_this.socket.proxy = _this;
	
	_this.socket.onmessage = function(data) {
		var message = JSON.parse(data.data);
		if (Array.isArray(message)) {
			var messageType = message.shift();
			
			// handling of CALLRESULT messages
			if (messageType === 3) {
				var tokens = message.shift().split(":");
				var mode = tokens[0];
				var name = tokens[1];
				var cid = tokens[2];
				
				if (mode === "get") {
				}
				else if (mode === "set") {
				}
				else if (mode === "invoke") {
					if (name === "setMode" && typeof(_this.replySetMode) === "function") {
						_this.replySetMode(cid, message);
					}
				}
			}
			// handling of EVENT messages
			else if (messageType === 8) {
				var topicURI = message.shift();
				if (topicURI === "broadcast:updateVelocity" && typeof(_this.signalUpdateVelocity) === "function") {
					_this.signalUpdateVelocity(message);
				}
			}
		}
	};	
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

