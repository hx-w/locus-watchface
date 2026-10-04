import Toybox.Lang;
import Toybox.Math;

module MetricFormat {
    function distance(meters as Numeric?, miles as Boolean) as String {
        if (meters == null || meters < 0) { return "--"; }
        var n = meters / (miles ? 1609.344 : 1000.0);
        if (n >= 9999.5) { return "9999+"; }
        if (n >= 99.95) { return Math.round(n).format("%d"); }
        if (n >= 10 && n == Math.round(n)) { return n.format("%d"); }
        return n.format("%.1f");
    }
    function whole(n as Numeric?) as String {
        if (n == null || n < 0) { return "--"; }
        if (n >= 9999.5) { return "9999+"; }
        return Math.round(n).format("%d");
    }
    function percent(n as Numeric?) as String {
        if (n == null || n < 0 || n > 100) { return "--"; }
        return whole(n);
    }
    function steps(n as Numeric?) as String {
        if (n == null || n < 0) { return "--"; }
        if (n >= 999950) { return "999k+"; }
        if (n >= 9995) { return Math.round(n / 1000.0).format("%d") + "k"; }
        if (n >= 1000) { return (n / 1000.0).format("%.1f") + "k"; }
        return whole(n);
    }
    function recovery(n as Numeric?) as String {
        if (n == null || n < 0) { return "--"; }
        if (n == 0) { return "0h"; }
        if (n < 60) { return Math.ceil(n).format("%d") + "m"; }
        if (n > 59940) { return "999h+"; }
        return Math.ceil(n / 60.0).format("%d") + "h";
    }
    function hour(h as Number, is24 as Boolean) as String {
        if (!is24) { h = h % 12; if (h == 0) { h = 12; } }
        return h.format("%02d");
    }
}
