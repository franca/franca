/*******************************************************************************
 * iowamp - WAMP(TM) server in NodeJS Copyright (c) 2013 Pascal Mathis
 * <dev@snapserv.net>
 * 
 * Code changes: Tamas Szabo (itemis AG)
 ******************************************************************************/
exports.resolveURI = function(client, uri) {
	var regexURI = /^(http|https):\/\/\S+\/[\w_-]+#[\w_-]+$/;
	var regexCURIE = /^[\w_-]+:[\w_-]+$/;

	if (regexURI.test(uri)) {
		var _uri = uri.split('#');
		if (_uri.length != 2)
			return null;
		return {
			baseURI : _uri[0],
			methodURI : _uri[1]
		};
	} else if (regexCURIE.test(uri)) {
		var _uri = uri.split(':');
		//if (client.prefixes.hasOwnProperty(_uri[0])) {
			return {
				baseURI : /*client.prefixes[*/_uri[0]/*]*/,
				methodURI : _uri[1]
			};
		//} else {
		//	return null;
		//}
	} else {
		return null;
	}
};