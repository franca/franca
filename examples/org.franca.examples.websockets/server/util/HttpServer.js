/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/

/*
	Simple HTTP server.
	The server is a node.js application written in JavaScript.
	
	NB: This HTTP server doesn't offer any kind of security. 
	    It should be used for testing purposes only.
*/

function HttpServer() {
	this.http = require('http');
	this.url = require('url');
	this.fs = require('fs');
	this.mime = require('mime');
	this.domain = require('domain');
	this.httpDomain = this.domain.create();
}

// export the "constructor" function to provide a class-like interface
module.exports = HttpServer;

HttpServer.prototype.init = function(port, root) {
	this.root = root;

	this.httpDomain.on('error', function(err) {
		console.log('Error caught in http domain:' + err);
	});

	var server = this;
	this.httpDomain.run(function() {
		server.http.createServer(function (req, res) {
			var pathname = server.url.parse(req.url).pathname;
			//console.log('HTTP request: "' + pathname + '"');
			if (pathname == '/' || pathname == '/index.html') {
				server.readFile(res, server.root + '/index.html');
			} else {
				server.readFile(res, server.root + pathname);
			}
		}).listen(port);
	});
};


HttpServer.prototype.readFile = function(res, pathname) {
	//console.log('Reading file: "' + pathname + '"');
	var mimetype = this.mime.lookup(pathname);
	
	this.fs.readFile(pathname, {encoding: 'utf8'}, function (err, data) {
		if (err) {
			console.log(err.message);
			res.writeHead(404, {'content-type': 'text/html'});
			res.write('File not found: ' + pathname);
			res.end();
		} else {
			res.useChunkedEncodingByDefault = false;
			res.setHeader("Content-Type", mimetype + '; charset=utf-8');
			res.setHeader("Connection", 'keep-alive');
			res.writeHead(200);
			res.write(data);
			res.end();
		}
	});       
};

