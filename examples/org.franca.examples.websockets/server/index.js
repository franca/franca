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

// initialize logger
var log4js = require('log4js');
log4js.configure('log4js-conf.json');
var logger = log4js.getLogger('Application');

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
	logger.info('The ID of the newly connected client is ' + clientID);
};

stub.onClientDisconnected = function(clientID) {
	logger.info('The client with ID ' + clientID + ' has disconnected');
}

var currentOperation = -1;

stub.setOperation = function (operation) {
	currentOperation = operation;
}

stub.computeSync = function (a, b) {
	if (currentOperation<0) {
		stub.userMessage("Please select an operation first!");
		return 0;
	} else {
		stub.userMessage("");
	}

	var result = 0;
	switch (currentOperation) {
		case SimpleUIStub.Operation.OP_ADD:       result = a + b; break;
		case SimpleUIStub.Operation.OP_SUBTRACT:  result = a - b; break;
		case SimpleUIStub.Operation.OP_MULTIPLY:  result = a * b; break;
		case SimpleUIStub.Operation.OP_DIVIDE:
			if (b==0) {
				stub.userMessage("Division by zero!");
			} else {
				result = a / b;
			}
			break;
	}
	return result;
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



