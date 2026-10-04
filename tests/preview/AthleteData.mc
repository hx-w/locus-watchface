import Toybox.Lang;
import Toybox.Math;

// Simulator-only observations. Excluded from production and test builds.
(:preview)
module AthleteData {
    const SCENARIO = 0;
    function read(cfg as LocusSettings) as AthleteSnapshot {
        var s = new AthleteSnapshot();
        var normal = [null,58,1080,72,24800.0,86000.0,8200,82,24,98,14,52,49,8,160];
        var extreme = [null,220,60000,100,10000000.0,10000000.0,1000000,100,100,100,99,99,99,10000,10000];
        for (var i = 0; i < Fields.COUNT; i += 1) {
            s.values[i] = SCENARIO == 1 ? null : (SCENARIO == 2 ? extreme[i] : normal[i]);
        }
        s.stamp = 1000; s.demo = true; s.demoAod = SCENARIO == 3;
        if (SCENARIO == 0 || SCENARIO == 4) {
            for (var j = 0; j < 73; j += 1) {
                if (SCENARIO == 4) {
                    var theta = 2 * Math.PI * 1.125 * j / 72;
                    var x = 50 + 26 * Math.sin(theta);
                    var y = 55 + 22 * Math.sin(2 * theta);
                    if (j == 72) { x = 68.4; y = 77; }
                    s.trail.add([640 + 5 * j, x, y]);
                } else {
                    s.trail.add([640 + 5 * j, 1440 - 5 * j, j == 72 ? 72 : 44 + 28 * j / 72.0 + 2 * Math.sin(j / 9.0)]);
                }
            }
        }
        if (SCENARIO == 4) { s.values[3] = 77; s.values[8] = 68.4; }
        return s;
    }
}
