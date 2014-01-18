var SimpleUIClientStub = require('./gen/SimpleUIClientStub');
var stub = new SimpleUIClientStub('http://localhost:8000');
stub.init();

stub.socket.on('open', function() {
	stub.setTitle("This is the new title");
	stub.getTitle();
});

stub.onGetTitle = function(callID, title) {
	console.log('Client1 onGetTitle ' + callID + ' ' + title);
}

stub.onSetTitle = function(callID) {
	console.log('Client1 onSetTitle ' + callID);
}