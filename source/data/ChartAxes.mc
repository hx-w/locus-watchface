import Toybox.Lang;
import Toybox.Math;

// Axis values are presentation units; snapshots always retain minutes/meters.
module ChartAxes {
    function min(a as Numeric, b as Numeric) as Numeric { return a < b ? a : b; }
    function max(a as Numeric, b as Numeric) as Numeric { return a > b ? a : b; }
    function value(id as Number, s as AthleteSnapshot, miles as Boolean) as Numeric? {
        if (id == 0) { return null; }
        var n = s.get(id);
        if (n == null || !Fields.valid(id, n)) { return null; }
        return convert(id, n, miles);
    }
    function convert(id as Number, n as Numeric, miles as Boolean) as Numeric {
        if (id == 2) { return n / 60.0; }
        if (id == 4 || id == 5) { return n / (miles ? 1609.344 : 1000.0); }
        return n;
    }
    function ceiling(id as Number, n as Numeric?) as Numeric {
        var bases = [100, 240, 48, 100, 100, 100, 10000, 100, 100, 100, 40, 80, 80, 20, 300];
        var top = bases[id];
        // Expand rather than pinning a >48h recovery value to a false endpoint.
        while (n != null && n > top) { top *= 2; }
        return top;
    }
    function unit(id as Number, miles as Boolean) as String {
        var units = ["", "bpm", "h", "", miles ? "mi" : "km", miles ? "mi" : "km", "", "%", "", "%", "rpm", "", "", "", "m"];
        return units[id];
    }
    function format(n as Numeric?) as String {
        if (n == null) { return "--"; }
        if (n >= 1000) { return MetricFormat.steps(n); }
        if (n == Math.round(n)) { return n.format("%d"); }
        return n.format(n < 1 ? "%.2f" : "%.1f");
    }
}
