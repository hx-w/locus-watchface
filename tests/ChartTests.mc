import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Test;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:test)
function chartFieldsAndHistoryBounds(logger as Test.Logger) as Boolean {
    var cfg = new LocusSettings();
    var renderer = new LocusRenderer(); renderer.canvas.measureBounds = true;
    var width = System.getDeviceSettings().screenWidth;
    var bitmap = Graphics.createBufferedBitmap({:width => width, :height => width});
    var dc = (bitmap.get() as Graphics.BufferedBitmap).getDc();
    var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    for (var scenario = 0; scenario < 3; scenario += 1) {
        var s = Fixtures.snapshot(scenario);
        for (var id = -1; id < Fields.COUNT; id += 1) {
            cfg.fields = id == -1 ? [1,2,3,4,5,6] : [id,id,id,id,id,id];
            renderer.canvas.failures = [];
            s.trail = []; s.stamp = 1000;
            if (id != 0 && scenario != 1) {
                var xid = cfg.fields[1]; var yid = cfg.fields[2];
                for (var t = 0; t <= 360; t += 5) { s.trail.add([640+t, s.get(xid) as Numeric, s.get(yid) as Numeric]); }
            }
            cfg.is24 = true; cfg.miles = false; cfg.showDate = true;
            renderer.render(dc, s, cfg, 23, 59, date, false);
            cfg.is24 = false; cfg.miles = true; cfg.showDate = false;
            renderer.render(dc, s, cfg, 0, 0, date, false);
            for (var j = 0; j < renderer.canvas.failures.size(); j += 1) { logger.error(renderer.canvas.failures[j]); }
            Test.assertMessage(renderer.canvas.failures.size() == 0, "Locus bounds: field " + id + " scenario " + scenario);
        }
    }
    cfg.fields = [1,2,3,4,5,6]; cfg.showDate = true;
    var demo = Fixtures.snapshot(0); demo.demo = true;
    for (var accent = 0; accent < 6; accent += 1) {
        cfg.accent = accent; renderer.canvas.failures = [];
        renderer.render(dc, demo, cfg, 10, 8, date, false);
        for (var failure = 0; failure < renderer.canvas.failures.size(); failure += 1) { logger.error(renderer.canvas.failures[failure]); }
        Test.assertMessage(renderer.canvas.failures.size() == 0, "Locus palettes and DEMO label fit");
    }
    // A self-crossing pressure/body trail, including filled closed faces.
    cfg.fields = [1,8,3,4,5,6];
    demo.stamp = 1000;
    demo.values[8] = 70; demo.values[3] = 75;
    demo.trail = [[960,30,40],[965,70,80],[970,30,80],[975,70,40],
        [980,30,40],[985,50,60],[990,70,75]];
    renderer.canvas.failures = [];
    renderer.render(dc, demo, cfg, 10, 8, date, false);
    Test.assertMessage(renderer.canvas.failures.size() == 0, "Loop faces and crossing marks stay inside the chart");
    demo.trail = [];
    demo.values[8] = 68.4; demo.values[3] = 77;
    for (var sample = 0; sample < 73; sample += 1) {
        var theta = 2 * Math.PI * 1.125 * sample / 72;
        demo.trail.add([640 + 5 * sample, 50 + 26 * Math.sin(theta), 55 + 22 * Math.sin(2 * theta)]);
    }
    renderer.canvas.failures = [];
    renderer.render(dc, demo, cfg, 10, 8, date, false);
    Test.assertMessage(renderer.canvas.failures.size() == 0, "Full 73-point closed trace and crossing stress scene");
    // Low power must not prepare the Canvas or cache vector fonts, even cold.
    renderer = new LocusRenderer();
    for (var minute = 0; minute < 4; minute += 1) { renderer.render(dc, new AthleteSnapshot(), cfg, 23, minute, date, true); }
    Test.assert(!renderer.canvas.hasFonts());
    logger.debug("Locus: 104 renders, all fields/icons, 73 history samples, loop/crossing, 6 colors, missing/extreme, 12/24h and km/mi at " + width + "px");
    return true;
}

(:test)
function trailTopologyClosedFacesAndGaps(logger as Test.Logger) as Boolean {
    var square = new TrailTopology([[0,0,100],[10,0,105],[10,10,110],[0,10,115],[0,0,120]]);
    Test.assertEqual(square.loops.size(), 1);
    Test.assertEqual(TrailTopology.area(square.loops[0]), 100.0);
    var crossed = new TrailTopology([[0,0,100],[10,10,105],[0,10,110],[10,0,115]]);
    Test.assertEqual(crossed.loops.size(), 1);
    Test.assertEqual(crossed.crossings.size(), 1);
    Test.assertEqual(crossed.crossings[0][0], 5.0);
    Test.assertEqual(TrailTopology.area(crossed.loops[0]), 25.0);
    var gap = new TrailTopology([[0,0,100],[10,10,105],[0,10,200],[10,0,205]]);
    Test.assertEqual(gap.loops.size(), 0); Test.assertEqual(gap.crossings.size(), 0);
    var parallel = new TrailTopology([[0,0,100],[10,0,105],[5,0,110],[15,0,115]]);
    Test.assertEqual(parallel.loops.size(), 0);
    var still = new TrailTopology([[2,2,100],[2,2,105],[2,2,110]]);
    Test.assertEqual(still.crossings.size(), 0);
    Test.assert(TrailTopology.intersection([0,0],[10,0],[11,-5],[11,5]) == null);
    return true;
}

(:test)
function chartAxisUnitsAndExpansion(logger as Test.Logger) as Boolean {
    var s = Fixtures.snapshot(0);
    Test.assertEqual(ChartAxes.value(2, s, false) as Numeric, 18.0);
    Test.assertEqual(ChartAxes.value(4, s, false) as Numeric, 24.8);
    Test.assert(ChartAxes.value(0, s, false) == null);
    Test.assertEqual(ChartAxes.ceiling(2, 49), 96);
    Test.assertEqual(ChartAxes.ceiling(3, 72), 100);
    s.values[3] = 101; Test.assert(ChartAxes.value(3, s, false) == null);
    Test.assertEqual(ChartAxes.unit(2, false), "h");
    Test.assertEqual(ChartAxes.unit(4, true), "mi");
    Test.assertEqual(ChartAxes.unit(8, false), ""); // Stress is a score, not percent.
    Test.assertEqual(ChartAxes.format(0), "0");
    Test.assertEqual(ChartAxes.format(null), "--");
    Test.assertEqual(NativeIcons.heartSize(null), 20);
    Test.assertEqual(NativeIcons.heartSize(20), 20);
    Test.assertEqual(NativeIcons.heartSize(40), 20);
    Test.assertEqual(NativeIcons.heartSize(110), 27);
    Test.assertEqual(NativeIcons.heartSize(180), 34);
    Test.assertEqual(NativeIcons.heartSize(220), 34);
    return true;
}

(:test)
function chartHistoryPersistenceAndGaps(logger as Test.Logger) as Boolean {
    var original = Application.Storage.getValue(HistoryPolicy.KEY);
    Application.Storage.deleteValue(HistoryPolicy.KEY);
    var cfg = new LocusSettings(); cfg.fields = [1,2,3,4,5,6];
    var s = Fixtures.snapshot(0); var history = new ChartHistory();
    history.record(s, cfg, 1000); history.record(s, cfg, 1001);
    Test.assertEqual(history.points.size(), 1);
    s.values[2] = 1020; history.record(s, cfg, 1005);
    Test.assertEqual(history.points.size(), 2);
    var restarted = new ChartHistory();
    Test.assertEqual(restarted.points.size(), 2);
    Test.assertEqual(restarted.points[0][1], 1080);
    s.values[2] = null; history.record(s, cfg, 1010);
    Test.assertEqual(history.points.size(), 2);
    s.values[2] = 900; history.record(s, cfg, 1030);
    Test.assert(history.points[2][0] - history.points[1][0] > HistoryPolicy.MAX_GAP);
    // Continuous wake updates are bounded and expire after six hours.
    for (var t = 1035; t <= 1500; t += 5) { history.record(s, cfg, t); }
    Test.assertEqual(history.points.size(), 73);
    Test.assertEqual(history.points[0][0], 1140);
    cfg.miles = true; history.record(s, cfg, 1500);
    Test.assertEqual(history.points.size(), 73);
    cfg.fields[1] = 4; history.record(s, cfg, 1502);
    Test.assertEqual(history.points.size(), 1);
    Test.assertEqual(history.points[0][1], 24800.0);
    // A backward clock adjustment cannot connect to future samples.
    history.record(s, cfg, 900); Test.assertEqual(history.points.size(), 1);
    Test.assertEqual(history.points[0][0], 900);
    if (original == null) { Application.Storage.deleteValue(HistoryPolicy.KEY); }
    else { Application.Storage.setValue(HistoryPolicy.KEY, original); }
    return true;
}
