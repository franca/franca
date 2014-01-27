// create http server and listen to port 8080
// we need this to serve index.html and other files to the client
var HttpServer = require('./util/HttpServer');
var http = new HttpServer();
http.init(8080, '../client');

// MusicPlayer stuff
var MusicPlayer = require('./MusicPlayer');
var player = new MusicPlayer();


// create websocket stub for SimpleUI interface and listen to websocket port.
var SimpleUIStub = require('./gen/org/example/SimpleUIStub');
var stub = new SimpleUIStub(8081);

// set initial values for attributes
stub.clock = getTime();

stub.init();

stub.onClientConnected = function(clientID) {
	console.log('The ID of the newly connected client is ' + clientID);
};

stub.onClientDisconnected = function(clientID) {
	console.log('The client with ID ' + clientID + ' has disconnected');
}

stub.playMusic = function (genre) {
	var d = "";
	
	switch (genre) {
		case SimpleUIStub.Genre.M_NONE:   player.stop(); break;
		case SimpleUIStub.Genre.M_POP:    player.play('http://icecast.radio24.ch/radio24pop'); break;
		case SimpleUIStub.Genre.M_TECHNO: player.play('http://firewall.pulsradio.com'); break;
		case SimpleUIStub.Genre.M_TRANCE: player.play('http://firewall.trance.pulsradio.com'); break;
		default: console.error("Invalid value " + genre + " for parameter 'genre'!");
	}
}

player.onStreamTitle = function(title) {
	// forward to UI
	stub.playingTitle(title);
}

stub.startNavigation = function (street, city) {
	console.log("startNavigation: street=" + street + " city=" + city);
	return {"routeLength" : street.length + 10*city.length, "arrivalTime" : "22:00"};
};


var driveTimerID = setInterval(function() {
	stub.setClock(getTime());
}, 1000);

function getTime() {
	var date = new Date();
    var hour = date.getHours();
    hour = (hour < 10 ? "0" : "") + hour;

    var min  = date.getMinutes();
    min = (min < 10 ? "0" : "") + min;

    var sec  = date.getSeconds();
    sec = (sec < 10 ? "0" : "") + sec;

    return hour + ":" + min + ":" + sec
}


// simulation of driving car, sending broadcasts for current velocity
var vTarget = 0.0;
var vActual = 0.0;
var acc = 0.0;
var phase = 0;
var t = 0;
var driveTimerID = setInterval(function() {
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

