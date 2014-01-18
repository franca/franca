var SimpleUIClientStub = require('./gen/SimpleUIClientStub');
var stub = new SimpleUIClientStub('http://localhost:8000');
stub.init();

stub.socket.on('open', function() {
	stub.setMode("mode1");
});

stub.onGetTitle = function(callID, title) {
	console.log('Client1 onGetTitle ' + callID + ' ' + title);
}

stub.onSetTitle = function(callID) {
	console.log('Client1 onSetTitle ' + callID);
}

stub.onChangedTitle = function(title) {
	console.log('Client1 onChangedTitle ' + title);
}

stub.replySetMode = function(callID) {
	console.log('Client1 replySetMode ' + callID);
} 

//stub.replySetMode = function(callID, p2) {
//	console.log('Client1 replySetMode ' + callID + ' ' + p2);
//} 