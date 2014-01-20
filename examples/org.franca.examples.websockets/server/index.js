// create http server and listen to port 8080
// we need this to serve index.html and other files to the client
var HttpServer = require('./util/HttpServer');
var http = new HttpServer();
http.init(8080, '../client');

// create websocket stub for SimpleUI interface and listen to websocket port.
var SimpleUIStub = require('./gen/SimpleUIStub');
var stub = new SimpleUIStub(8081);
stub.init();

stub.setMode = function (mode) {
	var d = "";
	
	switch (parseInt(mode)) {
		case SimpleUIStub.Mode.M_RADIO:      d = "Bay Radio FM"; break;
		case SimpleUIStub.Mode.M_NAVIGATION: d = "Destination?"; break;
		case SimpleUIStub.Mode.M_MULTIMEDIA: d = "Ring, ring!"; break;
		case SimpleUIStub.Mode.M_SETTINGS:   d = "Your settings"; break;
	}
	
	stub.updateVelocity(Math.floor((Math.random()*100)+1));

	return d;
}