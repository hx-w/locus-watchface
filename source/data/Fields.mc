import Toybox.Complications;
import Toybox.Lang;
import Toybox.WatchUi;

// Stable setting IDs. No network, calories or unsupported API-6 metrics.
module Fields {
    const COUNT = 15;
    const DEFAULTS = [1, 2, 3, 4, 5, 6];
    const LABELS = ["", "HR", "REST", "BODY", "RUN", "BIKE", "STEPS", "BATT", "STRESS", "SPO2", "RESP", "VO2 R", "VO2 B", "FLOORS", "ACTIVE"];
    function title(id as Number) as String {
        var names = [Rez.Strings.Hidden, Rez.Strings.HeartRate, Rez.Strings.Recovery, Rez.Strings.BodyBattery,
            Rez.Strings.MonthlyRun, Rez.Strings.MonthlyBike, Rez.Strings.Steps, Rez.Strings.DeviceBattery,
            Rez.Strings.Stress, Rez.Strings.PulseOx, Rez.Strings.Respiration, Rez.Strings.RunVo2,
            Rez.Strings.BikeVo2, Rez.Strings.Floors, Rez.Strings.Intensity];
        return WatchUi.loadResource(names[id]) as String;
    }
    function type(id as Number) as Complications.Type {
        var types = [Complications.COMPLICATION_TYPE_INVALID, Complications.COMPLICATION_TYPE_HEART_RATE,
            Complications.COMPLICATION_TYPE_RECOVERY_TIME, Complications.COMPLICATION_TYPE_BODY_BATTERY,
            Complications.COMPLICATION_TYPE_INVALID, Complications.COMPLICATION_TYPE_INVALID,
            Complications.COMPLICATION_TYPE_STEPS, Complications.COMPLICATION_TYPE_BATTERY,
            Complications.COMPLICATION_TYPE_STRESS, Complications.COMPLICATION_TYPE_PULSE_OX,
            Complications.COMPLICATION_TYPE_RESPIRATION_RATE, Complications.COMPLICATION_TYPE_VO2MAX_RUN,
            Complications.COMPLICATION_TYPE_VO2MAX_BIKE, Complications.COMPLICATION_TYPE_FLOORS_CLIMBED,
            Complications.COMPLICATION_TYPE_INTENSITY_MINUTES];
        return types[id];
    }
    function isPercent(id as Number) as Boolean { return id == 3 || id == 7 || id == 8 || id == 9; }
    function valid(id as Number, n as Numeric) as Boolean {
        if (n != n || n < 0) { return false; }
        if (isPercent(id) && n > 100) { return false; }
        if ((id == 1 || id == 10 || id == 11 || id == 12) && n == 0) { return false; }
        return true;
    }
    function format(id as Number, s as AthleteSnapshot, miles as Boolean) as String {
        var n = s.get(id);
        if (id == 0) { return ""; }
        if (n != null && !valid(id, n)) { n = null; }
        if (id == 2) { return MetricFormat.recovery(n); }
        if (id == 4 || id == 5) { return MetricFormat.distance(n, miles); }
        if (id == 6) { return MetricFormat.steps(n); }
        if (isPercent(id)) { return MetricFormat.percent(n); }
        return MetricFormat.whole(n);
    }
    function unit(id as Number, miles as Boolean) as String {
        if (id == 4 || id == 5) { return miles ? "mi" : "km"; }
        if (id == 9 || id == 7) { return "%"; }
        if (id == 14) { return "m"; }
        return "";
    }
}
