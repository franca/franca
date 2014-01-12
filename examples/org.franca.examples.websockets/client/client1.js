var WebSocket = require('ws'), ws = new WebSocket('http://localhost:8000');

ws.id = 11;

ws.on('open', function() {
    ws.send('[2, "1", "http://localhost/set#title", "This is the new title"]');
    ws.send('[2, "2", "http://localhost/get#title"]');
});

ws.on('message', function(message) {
    console.log('Client 1 received: %s', message);
});