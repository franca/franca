var SimpleUIServerStub = require('./gen/SimpleUIServerStub');
var stub = new SimpleUIServerStub(8000);
stub.init();

stub.onGetTitle = function() {
	return this.title;
}

stub.onSetTitle = function(title) {
	return title;
}

stub.setMode = function(p1, p2) {
	setInterval(function() { stub.updateVelocity(11); }, 1000);
	return ["mode2", 334]
}