/*******************************************************************************
* Copyright (c) 2013 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.websocket

import org.franca.core.franca.FInterface
import org.franca.core.franca.FArgument
import org.franca.core.franca.FEnumerationType

import static extension org.franca.generators.websocket.WebsocketGeneratorUtils.*

class WebsocketJSStubGenerator {
	
	def getStubName (FInterface api) {
		api.name.toFirstUpper + "Stub"
	}

	def generate (FInterface api) '''
		/*
			Stub class for server-side websocket communication.
			The server is a node.js application written in JavaScript.
			JS code generated by Franca's WebsocketJSStubGenerator.
		*/

		function �api.stubName�() {
			// attributes of stub object
			this.ws = require('websocket.io');
			this.domain = require('domain');
			this.socketDomain = this.domain.create();
			this.sockets = [];
		}

		// export the "constructor" function to provide a class-like interface
		module.exports = �api.stubName�;

		�api.stubName�.prototype.init = function(port) {
			this.socketDomain.on('error', function(err) {
				console.log('Error caught in socket domain:' + err);
			});
		
			var stub = this;
			this.socketDomain.run(function() {
				var socketServer = stub.ws.listen(port);
		
				socketServer.on('listening', function() {
					console.log('SocketServer is running (port ' + port + ')');
				});
		
				socketServer.on('connection', function (socket) {
					console.log('Connected to client');
					stub.sockets.push(socket);
					
					// indicate new connection
					if (stub.onConnected) {
						stub.onConnected();
					}
		
					socket.on('message', function (message) { 
						console.log('Message received: ', message);
						var msg = JSON.parse(message);
						switch (msg.tag) {
							�FOR m : api.methods�
							case "�m.name�":
								�IF m.fireAndForget==null�
									var ret = stub.setMode(�m.inArgs.genArgList("msg.")�);
									ret.tag = "�m.name�";
									stub.sendSingle(this, ret);
								�ELSE�
									stub.setMode(msg.mode);
								�ENDIF�
								break;
							�ENDFOR�
						};
					});
		
					// TODO: this could probably moved to base class
					socket.on('close', function () {
						try {
							socket.close();
							socket.destroy();
							console.log('Socket closed!');                       
							for (var i = 0; i < stub.sockets.length; i++) {
								if (stub.sockets[i] == socket) {
									stub.sockets.splice(i, 1);
									console.log(
										'Removing socket from collection. ' + 
										'Collection length: ' + stub.sockets.length);
									break;
								}
							}
		
							if (stub.sockets.length == 0) {
								if (stub.onAllDisconnected) {
									stub.onAllDisconnected();
								}
							}
						}
						catch (e) {
							console.log(e);
						}
					});
				});
			});
		
		}
		

		�FOR b : api.broadcasts�
		�api.stubName�.prototype.�b.name� = function(data) {
			console.log('Sending �b.name� ...');
			data.tag = "�b.name�";
			this.sendAll(data);
		};

		�ENDFOR�
		
		
		// TODO: move to base class
		�api.stubName�.prototype.sendSingle = function (socket, data) {
			var encoded = JSON.stringify(data);
			console.log("  " + encoded);
			try {
				socket.send(encoded);
			}   
			catch (e) {
				console.log(e);                
			}
		};
		
		
		// TODO: move to base class
		�api.stubName�.prototype.sendAll = function (data) {
			if (this.sockets.length) {
				var encoded = JSON.stringify(data);
				console.log("  " + encoded);
				for(i=0; i<this.sockets.length; i++) {
					try {
						this.sockets[i].send(encoded);
					}
					catch (e) {
						console.log(e);                
					}
				}
			}
		}

		�FOR t : api.types.filter(typeof(FEnumerationType))�
		// definition of enumeration '�t.name�'
		var �t.name� = function(){
			return {
				�FOR e : t.enumerators SEPARATOR ','�
				'�e.name�':�t.enumerators.indexOf(e)�
				�ENDFOR�
			}
		}();

		�api.types.genEnumerations�

		�ENDFOR�

	'''
	
}
