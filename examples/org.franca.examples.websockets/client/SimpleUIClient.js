var WebSocket = require('ws'), ws = new WebSocket('http://localhost:8000');

// call to get the value of title asynchronously
function getTitle() {
	ws.send('[2, "title", "http://localhost/get#title"]');
};

// call to set the value of title asynchronously
function setTitle(title) {
	ws.send('[2, "title", "http://localhost/set#title", "' + title + '"]');
};

// callback for the value getter for attribute title
function onGetTitle(title) {
	console.log('The value of title is ' + title);
};

// asynchronous callback which is called if the value of title has changed on the server side
function onTitleChanged(title) {
	console.log('The value of title has changed ' + title);
};

// call this method to subscribe for the changes of the attribute title
function subscribeTitleChanged() {
	ws.send('[5, "topic#title"]');
};

// call this method to unsubscribe from the changes of the attribute title
function unsubscribeTitleChanged() {
	ws.send('[6, "topic#title"]');
};

ws.on('open', function() {
    subscribeTitleChanged();
	setTitle("2014");
	getTitle();
});

ws.on('message', function(data) {
	var message = JSON.parse(data);
	if (Array.isArray(message)) {
		var messageType = message.shift();
		
		// handling of CALLRESULT messages
		if (messageType === 3) {
			var callID = message.shift();
			if (callID === "title") {
				onGetTitle(message);
			}
		}
		// handling of EVENT messages
		else if (messageType === 8) {
			var topicURI = message.shift();
			if (topicURI === "topic#title") {
				onTitleChanged(message);
			}
		}
	}
});
