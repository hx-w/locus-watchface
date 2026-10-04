import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;

// Calendar-month totals from saved activities visible on this watch, in meters.
// Do not infer monthly totals from weekly complications or keep partial running sums.
class MonthlyDistances {
    var run as Numeric? = 0.0;
    var bike as Numeric? = 0.0;
    private var _now as Number;
    private var _month as Number;
    function initialize(now as Time.Moment) {
        _now = now.value(); _month = MonthlyActivity.monthKey(now);
    }
    function add(start as Time.Moment?, sport as Activity.Sport?, distance as Numeric?) as Void {
        if (start == null || start.value() > _now || MonthlyActivity.monthKey(start) != _month) { return; }
        if (sport != Activity.SPORT_RUNNING && sport != Activity.SPORT_CYCLING) { return; }
        var valid = distance != null && distance == distance && distance >= 0;
        if (sport == Activity.SPORT_RUNNING) {
            if (!valid) { run = null; }
            else if (run != null) { run += distance as Numeric; }
        } else {
            if (!valid) { bike = null; }
            else if (bike != null) { bike += distance as Numeric; }
        }
    }
}

module MonthlyActivity {
    var _totals as MonthlyDistances?;
    var _stamp as Number = -1;
    var _month as Number = -1;
    function monthKey(moment as Time.Moment) as Number {
        var date = Gregorian.info(moment, Time.FORMAT_SHORT);
        return date.year * 100 + (date.month as Number);
    }
    function invalidate() as Void { _stamp = -1; }
    function read() as MonthlyDistances {
        var now = Time.now(); var stamp = now.value(); var month = monthKey(now);
        if (_totals != null && _stamp >= 0 && stamp >= _stamp && stamp - _stamp < 300 && month == _month) { return _totals; }
        var totals = new MonthlyDistances(now);
        try {
            if (!(UserProfile has :getUserActivityHistory)) { throw new Lang.Exception(); }
            var history = UserProfile.getUserActivityHistory();
            var entry = history.next();
            // History order is not guaranteed: inspect every entry, without retaining it.
            while (entry != null) {
                totals.add(entry.startTime, entry.type, entry.distance);
                entry = history.next();
            }
        } catch (e) { totals.run = null; totals.bike = null; }
        _totals = totals; _stamp = stamp; _month = month;
        return totals;
    }
}
