import Toybox.Complications;
import Toybox.Lang;

class AthleteSnapshot {
    var values as Array<Numeric?>;
    var demo as Boolean = false;
    var demoAod as Boolean = false;
    var trail as Array<Array<Numeric>> = [];
    var stamp as Number = 0;
    function initialize() { values = new [15]; }
    function get(id as Number) as Numeric? { return values[id]; }
}

module AthleteData {
    // Preview replaces only this method in an isolated build source path.
    (:live)
    function read(cfg as LocusSettings) as AthleteSnapshot {
        var s = new AthleteSnapshot();
        if (cfg.fields.indexOf(4) != -1 || cfg.fields.indexOf(5) != -1) {
            var monthly = MonthlyActivity.read();
            s.values[4] = monthly.run; s.values[5] = monthly.bike;
        }
        for (var i = 0; i < cfg.fields.size(); i += 1) {
            var id = cfg.fields[i];
            if (id > 0 && id != 4 && id != 5 && s.values[id] == null) { s.values[id] = value(id); }
        }
        s.values[7] = value(7); // Device battery remains independent of body battery.
        return s;
    }
    function value(id as Number) as Numeric? {
        if (id == 4 || id == 5) { return null; }
        try {
            var c = Complications.getComplication(new Complications.Id(Fields.type(id)));
            var v = c.value;
            if (v instanceof Number || v instanceof Float || v instanceof Double || v instanceof Long) {
                return Fields.valid(id, v) ? v : null;
            }
        } catch (e) { }
        return null;
    }
}
