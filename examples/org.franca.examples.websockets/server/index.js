// create http server and listen to port 8080
// we need this to serve index.html and other files to the client
var HttpServer = require('./util/HttpServer');
var http = new HttpServer();
http.init(8080, '../client');

// create websocket stub for SimpleUI interface and listen to websocket port.
var SimpleUIServerStub = require('./gen/SimpleUIServerStub');
var stub = new SimpleUIServerStub(8081);
stub.init();

stub.setMode = function (mode) {
	var d = "";
	
	switch (mode) {
		case SimpleUIServerStub.Mode.M_RADIO:      d = "Bay Radio FM"; break;
		case SimpleUIServerStub.Mode.M_NAVIGATION: d = "Destination?"; break;
		case SimpleUIServerStub.Mode.M_MULTIMEDIA: d = "Ring, ring!"; break;
		case SimpleUIServerStub.Mode.M_SETTINGS:   d = "Your settings"; break;
		default: d = "Weird JS radio";
	}
	
	stub.updateVelocity(Math.floor((Math.random()*100)+1));

	return d;
}