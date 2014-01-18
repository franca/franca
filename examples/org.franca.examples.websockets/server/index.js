var SimpleUIServerStub = require('./gen/SimpleUIServerStub');
var stub = new SimpleUIServerStub(8000);
stub.init();

stub.onGetTitle = function() {
	return this.title;
}

stub.onSetTitle = function(title) {
	return title;
}