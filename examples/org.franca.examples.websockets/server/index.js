/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/

/*
	This is an example websocket server which uses the JS-stub as generated
	by Franca's WAMP/Websocket generator in org.franca.generators.websocket. 

	The server is implemented in JavaScript and is based on node.js and
	the websocket.io library.
*/

// create http server and listen to port 8080
// we need this to serve index.html and other files to the client
var HttpServer = require('./base/util/HttpServer');
var http = new HttpServer();
http.init(8080, '../client');

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
		case SimpleUIStub.Genre.M_NONE:   break;
		case SimpleUIStub.Genre.M_POP:    break;
		case SimpleUIStub.Genre.M_TECHNO: break;
		case SimpleUIStub.Genre.M_TRANCE: break;
		default: console.error("Invalid value " + genre + " for parameter 'genre'!");
	}
}

stub.startNavigation = function (street, city) {
	console.log("startNavigation: street=" + street + " city=" + city);
	return {"routeLength" : street.length + 10*city.length, "arrivalTime" : "22:00"};
};


var timerID = setInterval(function() {
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



