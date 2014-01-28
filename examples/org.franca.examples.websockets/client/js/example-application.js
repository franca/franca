
// switch page programmatically: $.mobile.changePage("#pNav")

function initApp() {
	// initialize proxy for SimpleUI interface
	var proxy = new SimpleUIProxy();
	proxy.connect('ws://localhost:8081');

	// register callback for SimpleUI.onChangedClock() updates
	proxy.onChangedClock = function(clock) {
		$('#tClock').text(clock);
	};

	// register callback for SimpleUI.playingTitle() broadcast
	proxy.signalPlayingTitle = function(title) {
		document.getElementById('current-title').innerHTML = title;
	};

	// register callback for SimpleUI.updateVelocity() broadcast
	proxy.signalUpdateVelocity = function(velocity) {
		tacho.set(velocity);
	};
	
	proxy.onOpened = function() {
		console.log('The connection has been opened!')
		proxy.subscribeClockChanged();
	}
	
	proxy.onClosed = function() {
		console.log('The connection has been closed!')
	}

	// connect UI buttons with playMusic() calls
	$("#m1").click(function() { proxy.playMusic(Genre.M_NONE); });
	$("#m2").click(function() { proxy.playMusic(Genre.M_POP); });
	$("#m3").click(function() { proxy.playMusic(Genre.M_TECHNO); });
	$("#m4").click(function() { proxy.playMusic(Genre.M_TRANCE); });


	$(document).on( "pageinit", "#pNav", function() {
		$("#mStart").click(function() {
			proxy.startNavigation(
				document.getElementById("street").value,
				document.getElementById("city").value);
		});

		// register callback for SimpleUI.startNavigation() replies
		proxy.replyStartNavigation = function(cid, routeLength) {
			$('#navresult').text("Distance to destination: " + routeLength + " km");
		};

	});

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
