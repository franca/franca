// create http server and listen to port 8080
// we need this to serve index.html and other files to the client
var HttpServer = require('./base/util/HttpServer');
var http = new HttpServer();
http.init(8080, '../client');

// MusicPlayer application
var MusicPlayer = require('./applications/MusicPlayer');
var player = new MusicPlayer();

// Vehicle application
var Vehicle = require('./applications/Vehicle');
var vehicle = new Vehicle();
vehicle.init();

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

vehicle.onUpdateVelocity = function(vel) {
    // send velocity broadcast
    stub.updateVelocity(vel);
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



