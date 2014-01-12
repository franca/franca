var WebSocket = require('ws'), ws = new WebSocket('http://localhost:8000');

ws.id = 11;

ws.on('open', function() {
    ws.send('[5, "news"]');
    ws.send('[5, "weather"]');
});

ws.on('message', function(message) {
    console.log('Client 1 received: %s', message);
});