import Toybox.Application;
import Toybox.Lang;

// Only observed live values. Bounded six-hour window, five-minute samples.
// Rows are [UTC minute, raw X, raw Y], so unit changes never reinterpret data.
module HistoryPolicy {
    // Preserve stored observations across the app rename.
    const KEY = "PlaneHistory";
    const WINDOW = 360;
    const INTERVAL = 5;
    const MAX_POINTS = 73;
    const MAX_GAP = 15;
}

class ChartHistory {
    var points as Array<Array<Numeric>> = [];
    private var _xid as Number = -1;
    private var _yid as Number = -1;
    function initialize() {
        try {
            var saved = Application.Storage.getValue(HistoryPolicy.KEY);
            if (!(saved instanceof Dictionary)) { return; }
            var version = saved["version"];
            if (!(version instanceof Number) || (version != 1 && version != 2)) { return; }
            var x = saved["x"]; var y = saved["y"]; var rows = saved["points"];
            if (!(x instanceof Number) || !(y instanceof Number) || x < 1 || x >= Fields.COUNT || y < 1 || y >= Fields.COUNT || !(rows instanceof Array) || rows.size() > HistoryPolicy.MAX_POINTS) { return; }
            // Older distance axes were weekly. Do not join them to monthly readings.
            if (version == 1 && (x == 4 || x == 5 || y == 4 || y == 5)) { return; }
            var valid = [] as Array<Array<Numeric>>;
            var previous = -1;
            for (var i = 0; i < rows.size(); i += 1) {
                var row = rows[i];
                if (!(row instanceof Array) || row.size() != 3) { return; }
                if (!(row[0] instanceof Number) || !numeric(row[1]) || !numeric(row[2])) { return; }
                var time = row[0] as Number;
                var vx = row[1] as Numeric; var vy = row[2] as Numeric;
                if (!Fields.valid(x, vx) || !Fields.valid(y, vy) || time <= previous) { return; }
                valid.add([time, vx, vy]); previous = time;
            }
            _xid = x; _yid = y; points = valid;
        } catch (e) { points = []; }
    }
    private function numeric(v as Object?) as Boolean { return v instanceof Number || v instanceof Float || v instanceof Double || v instanceof Long; }
    function record(s as AthleteSnapshot, cfg as LocusSettings, stamp as Number) as Void {
        var dirty = false;
        if (_xid != cfg.fields[1] || _yid != cfg.fields[2]) {
            _xid = cfg.fields[1]; _yid = cfg.fields[2]; points = []; dirty = true;
        }
        var kept = [] as Array<Array<Numeric>>;
        for (var i = 0; i < points.size(); i += 1) {
            var point = points[i] as Array<Numeric>;
            var t = point[0];
            if (t <= stamp && stamp - t <= HistoryPolicy.WINDOW) { kept.add(point); }
        }
        if (kept.size() != points.size()) { dirty = true; }
        points = kept;
        var x = s.get(_xid); var y = s.get(_yid);
        if (_xid != 0 && _yid != 0 && x != null && y != null && Fields.valid(_xid, x) && Fields.valid(_yid, y) &&
            (points.size() == 0 || stamp - points[points.size() - 1][0] >= HistoryPolicy.INTERVAL)) {
            points.add([stamp, x, y]); dirty = true;
        }
        if (points.size() > HistoryPolicy.MAX_POINTS) { points = points.slice(points.size() - HistoryPolicy.MAX_POINTS, points.size()); }
        if (dirty) {
            try { Application.Storage.setValue(HistoryPolicy.KEY, {"version" => 2, "x" => _xid, "y" => _yid, "points" => points}); } catch (e) { }
        }
        s.trail = points; s.stamp = stamp;
    }
}
