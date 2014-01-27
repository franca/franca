
// switch page programmatically: $.mobile.changePage("#pNav")

function initApp() {
	// initialize tacho widget	
	var tacho = Raphael("tacho", 260, 260).tachometer(0, {
		interactive: true,
		needleAnimationEasing: "linear", // or: <>, bounce, elastic
		needleAnimationDuration: 500,
		numberMax: 160,
		longScaleCount: 8,
		shortScaleCount: 80,
		numberUnit: " km/h"
	});
	
	// this fixes a tachometer layout issue on WebKit (Chrome, Safari)
	var elems = $('tspan');
	for(var i = 0; i < elems.length; i++) {
		elems[i].setAttribute('dy', 0);
	}

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

	/*
	 * Google Maps documentation: http://code.google.com/apis/maps/documentation/javascript/basics.html
	 * Geolocation documentation: http://dev.w3.org/geo/api/spec-source.html
	 */
	$(document).on( "pageinit", "#pMap", function() {
		var defaultLatLng = new google.maps.LatLng(34.0983425, -118.3267434);  // Default to Hollywood, CA when no geolocation support
		if ( navigator.geolocation ) {
			function success(pos) {
				// Location found, show map with these coordinates
				drawMap(new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude));
			}
			function fail(error) {
				drawMap(defaultLatLng);  // Failed to find location, show default map
			}
			// Find the users current position.  Cache the location for 5 minutes, timeout after 6 seconds
			navigator.geolocation.getCurrentPosition(success, fail, {maximumAge: 500000, enableHighAccuracy:true, timeout: 6000});
		} else {
			drawMap(defaultLatLng);  // No geolocation support, show default map
		}

		function drawMap(latlng) {
			var myOptions = {
				zoom: 10,
				center: latlng,
				mapTypeId: google.maps.MapTypeId.ROADMAP
			};
			var map = new google.maps.Map(document.getElementById("map-canvas"), myOptions);

			// Add an overlay to the map of current lat/lng
			var marker = new google.maps.Marker({
				position: latlng,
				map: map,
				title: "You are here!"
			});
		}
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
