import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

(:live)
class LocusSettings {
    var fields as Array<Number> = [1, 2, 3, 4, 5, 6];
    var accent as Number = 0;
    var miles as Boolean = false;
    var is24 as Boolean = true;
    var showDate as Boolean = true;
    var aod as Boolean = true;
    function initialize() { reload(); }
    function reload() as Void {
        for (var i = 0; i < 6; i += 1) { fields[i] = number("Field" + (i + 1), Fields.DEFAULTS[i], 0, Fields.COUNT - 1); }
        accent = number("Accent", 0, 0, 5);
        miles = number("Units", 0, 0, 1) == 1;
        var clock = number("ClockMode", 0, 0, 2);
        is24 = clock == 0 ? System.getDeviceSettings().is24Hour : clock == 1;
        showDate = flag("ShowDate", true);
        aod = flag("AlwaysOn", true);
    }
    function number(key as String, fallback as Number, lo as Number, hi as Number) as Number {
        try {
            var v = Application.Properties.getValue(key);
            if (v instanceof Number && v >= lo && v <= hi) { return v; }
        } catch (e) { }
        return fallback;
    }
    function flag(key as String, fallback as Boolean) as Boolean {
        try {
            var v = Application.Properties.getValue(key);
            if (v instanceof Boolean) { return v; }
        } catch (e) { }
        return fallback;
    }
    function color() as Number {
        if (accent == 0) { return 0xDAAF76; }
        return [0xDAAF76, 0xE9E5D9, 0xB9CFB4, 0xFF806A, 0xB7C8D8, 0xBE8968][accent];
    }
    function timeColor() as Number {
        if (accent == 0) { return 0xFFBF52; }
        var c = color();
        // Lighter tint keeps the large minute numerals ahead of the chart.
        var red = (((c >> 16) & 255) + 255) / 2;
        var green = (((c >> 8) & 255) + 255) / 2;
        var blue = ((c & 255) + 255) / 2;
        return (red << 16) | (green << 8) | blue;
    }
}
