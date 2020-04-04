// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;
using Toybox.Position;

class DataField extends WatchUi.SimpleDataField {
	const REPEAT_RESET = 5;
	var repeat = REPEAT_RESET;
	var limit;
	const THRESHOLD = 50;

	var range_field;

	function maybe_warn(distance) {
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
		label = "Range Warning";

		limit = Application.getApp().getProperty("range");

		range_field = createField(
				"range", 0, FitContributor.DATA_TYPE_SINT32,
				{:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"m"});
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

		if (start == null) {
			return limit;
		}

		if (cur == null) {
			return "---";
		}

		range = limit - distance_points(cur.toRadians(), start.toRadians());

		maybe_warn(range);

		range_field.setData(range);
		return range.format("%.0f");
	}
}
