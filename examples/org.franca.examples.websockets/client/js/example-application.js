/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/


function initApp() {
	// initialize proxy for SimpleUI interface
	var proxy = new SimpleUIProxy();
	proxy.connect('ws://localhost:8081');

	// register callback for SimpleUI.onChangedClock() updates
	proxy.onChangedClock = function(clock) {
		$('#tClock').text(clock);
	};

	proxy.onOpened = function() {
		$('#user-message').text("Connection to server established.");
		proxy.subscribeClockChanged();
	}
	
	// this callback is invoked when the server connection is closed
	proxy.onClosed = function() {
		$('#user-message').text("Connection to server lost!");
		$('#tClock').text("???");
	}

	// register callback for SimpleUI.userMessage() broadcast
	proxy.signalUserMessage = function(text) {
		$('#user-message').text(text);
	};
	
	// connect UI buttons with setOperation() calls
	$("#m1").click(function() { proxy.setOperation(Operation.OP_ADD);      callCompute(); });
	$("#m2").click(function() { proxy.setOperation(Operation.OP_SUBTRACT); callCompute(); });
	$("#m3").click(function() { proxy.setOperation(Operation.OP_MULTIPLY); callCompute(); });
	$("#m4").click(function() { proxy.setOperation(Operation.OP_DIVIDE);   callCompute(); });

	// connect operand input fields with compute() calls
	$("#number-1").bind('change', function() { callCompute(); });
	$("#number-2").bind('change', function() { callCompute(); });
	$("#number-1").bind('keyup', function() { callCompute(); });
	$("#number-2").bind('keyup', function() { callCompute(); });

	function callCompute() {
		var a = $("#number-1").val();
		var b = $("#number-2").val();
		if (a.length>0 && b.length>0) {
			proxy.compute(parseInt(a), parseInt(b));
		}
	}

	// register callback for SimpleUI.compute() response
	proxy.replyCompute = function(cid, result) {
		$('#result').text("Result: " + result);
	};

}


function initFixedHeaders() {
	jQuery.fn.headerOnAllPages = function() {
		var theHeader = $('#constantheader-wrapper').html();
			var allPages = $('div[pagetype="standard"]');

		for (var i = 1; i < allPages.length; i++) {
			allPages[i].innerHTML = theHeader + allPages[i].innerHTML;
			}
	};

	$(function() {
		$().headerOnAllPages();
		$( "[data-role='navbar']" ).navbar();
		$( "[data-role='header'], [data-role='footer']" ).toolbar();
	});


}
