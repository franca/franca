// create http server and listen to port 8080
// we need this to serve index.html and other files to the client
var HttpServer = require('./util/HttpServer');
var http = new HttpServer();
http.init(8080, '../client');

// create websocket stub for SimpleUI interface and listen to websocket port.
var SimpleUIServerStub = require('./gen/SimpleUIServerStub');
var stub = new SimpleUIServerStub(8081);
stub.init();

stub.onGetTitle = function() {
	return this.title;
}

stub.onSetTitle = function(title) {
	return title;
}

stub.setMode = function(p1, p2) {
	setInterval(function() { stub.updateVelocity(11); }, 1000);
	return ["mode2", 334]
}