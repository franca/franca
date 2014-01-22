// create http server and listen to port 8080
// we need this to serve index.html and other files to the client
var HttpServer = require('./util/HttpServer');
var http = new HttpServer();
http.init(8080, '../client');

// create websocket stub for SimpleUI interface and listen to websocket port.
var SimpleUIStub = require('./gen/org/example/SimpleUIStub');
var stub = new SimpleUIStub(8081);
stub.init();

// TODO: will this really work? We need a setClock function in the stub which also sends updates to the clients
stub.clock = "11:55";

stub.setMode = function (mode) {
	var d = "";
	
	console.log("setMode: mode=" + mode);
	switch (mode) {
		case SimpleUIStub.Mode.M_RADIO:      d = "Bay Radio FM"; break;
		case SimpleUIStub.Mode.M_NAVIGATION: d = "Destination?"; break;
		case SimpleUIStub.Mode.M_MULTIMEDIA: d = "Ring, ring!"; break;
		case SimpleUIStub.Mode.M_SETTINGS:   d = "Your settings"; break;
		default: console.error("Invalid value " + mode + " for parameter 'mode'!");
	}

	return d;
}

stub.startNavigation = function (street, city) {
	console.log("startNavigation: street=" + street + " city=" + city);
	return {"routeLength" : street.length + 10*city.length, "arrivalTime" : "22:00"};
}


// simulation of driving car, sending broadcasts for current velocity
var vTarget = 0.0;
var vActual = 0.0;
var acc = 0.0;
var phase = 0;
var t = 0;
var timerID = setInterval(function() {
	switch (phase) {
		case 0: // set target values
			vTarget = 1 + Math.random()*120;
			acc = 3.0 + Math.random()*8.0;
			if (vTarget<vActual) acc = -acc;
			phase = 1;
			break;

		case 1: // accelerate / decelerate
			vActual += acc;

			// send velocity broadcast
			stub.updateVelocity(vActual);

			if (sign(acc) == sign(vActual-vTarget)) {
				t = 1 + Math.floor(Math.random()*10);
				phase = 2;
			}
			break;

		case 2: // wait
			t -= 1;
			if (t<=0) { phase = 0; }
			break;
	}
}, 500);

function sign(x) { return x ? x < 0 ? -1 : 1 : 0; }

