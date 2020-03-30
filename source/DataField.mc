// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;
using Toybox.Position;

class DataField extends WatchUi.SimpleDataField {
	var repeat;
	const REPEAT_RESET = 5;
	const LIMIT = 2000;
	const THRESHOLD = 50;

	function maybe_warn(distance) {
		System.println(distance + " " + repeat);
		if (distance > THRESHOLD) {
			repeat = REPEAT_RESET;
			return;
		}

		if (repeat == 0) {
			return;
		}
		repeat--;

		Attention.playTone(Attention.TONE_LOUD_BEEP);

                var vibrateData = [new Attention.VibeProfile(100, 300)];
		Attention.vibrate(vibrateData);
	}

	function initialize() {
		SimpleDataField.initialize();
		label = "2k Warning";
	}

	// From: https://forums.garmin.com/developer/connect-iq/f/discussion/1095/calculate-distance-between-two-positions
	function distance_points(p1, p2) {
		var lat1 = p1[0];
		var lon1 = p1[1];
		var lat2 = p2[0];
		var lon2 = p2[1];
		var dy = lat2 - lat1;
		var dx = lon2 - lon1;

		var sy = Math.sin(dy / 2);
		sy *= sy;

		var sx = Math.sin(dx / 2);
		sx *= sx;

		var a = sy + Math.cos(lat1) * Math.cos(lat2) * sx;

		var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

		var R = 6371000; // Radius of earth in meters

		return R * c;
	}

	function compute(info) {
		var cur = info.currentLocation;
		var start = info.startLocation;
		var range;

		if (cur == null || start == null) {
			return "---";
		}

		range = LIMIT - distance_points(cur.toRadians(), start.toRadians());

		maybe_warn(range);

		return range.format("%.0f");
	}
}
