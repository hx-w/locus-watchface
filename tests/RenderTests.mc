import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

(:test)
module Fixtures {
    function snapshot(scenario as Number) as AthleteSnapshot {
        var s = new AthleteSnapshot();
        var normal = [null,58,1080,72,24800.0,86000.0,8200,82,24,98,14,52,49,8,160];
        var extreme = [null,220,60000,100,10000000.0,10000000.0,1000000,100,100,100,99,99,99,10000,10000];
        for (var i = 0; i < 15; i += 1) { s.values[i] = scenario == 1 ? null : (scenario == 2 ? extreme[i] : normal[i]); }
        return s;
    }
}

(:test)
function displayLifecycleAcrossScreens(logger as Test.Logger) as Boolean {
    if (System has :getDisplayMode) {
        Test.assert(DisplayPolicy.lowPower(System.DISPLAY_MODE_HIGH_POWER, true));
        Test.assert(DisplayPolicy.lowPower(System.DISPLAY_MODE_LOW_POWER, false));
        Test.assert(!DisplayPolicy.lowPower(System.DISPLAY_MODE_HIGH_POWER, false));
    } else {
        // Calling the AMOLED-only method on Solar/MIP would raise Symbol Not Found.
        Test.assertEqual(DisplayPolicy.mode(), System.DISPLAY_MODE_HIGH_POWER);
        Test.assert(!DisplayPolicy.lowPower(DisplayPolicy.mode(), true));
    }
    var width = System.getDeviceSettings().screenWidth;
    var bitmap = Graphics.createBufferedBitmap({:width => width, :height => width});
    var dc = (bitmap.get() as Graphics.BufferedBitmap).getDc();
    var view = new LocusView();
    view.onUpdate(dc); view.onEnterSleep(); view.onUpdate(dc);
    view.onExitSleep(); view.onUpdate(dc);
    return true;
}

(:test)
function aodLuminanceUpperBound(logger as Test.Logger) as Boolean {
    if (!(System has :getDisplayMode)) { return true; }
    var width = System.getDeviceSettings().screenWidth;
    var bitmap = Graphics.createBufferedBitmap({:width => 1, :height => 1});
    var dc = (bitmap.get() as Graphics.BufferedBitmap).getDc();
    var w = dc.getTextWidthInPixels("88:88", Graphics.FONT_NUMBER_MEDIUM);
    var h = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
    var fraction = w * h * (85.0 / 255) / (Math.PI * width * width / 4.0);
    logger.debug("AOD luminance envelope " + (fraction * 100).format("%.2f") + "% at " + width + "px");
    Test.assertMessage(fraction < 0.10, "Modern AMOLED luminance budget");
    return true;
}

(:test)
function settingsPersistenceAndInvalidValues(logger as Test.Logger) as Boolean {
    var keys = ["Field1", "Field2", "Field3", "Accent", "Units", "ClockMode", "ShowDate", "AlwaysOn"];
    var original = [];
    for (var i = 0; i < keys.size(); i += 1) { original.add(Application.Properties.getValue(keys[i])); }
    var cfg = new LocusSettings();
    Application.Properties.setValue("Field1", 8); Application.Properties.setValue("Accent", 2);
    Application.Properties.setValue("Field2", 3); Application.Properties.setValue("Field3", 8);
    Application.Properties.setValue("Units", 1); Application.Properties.setValue("ClockMode", 2);
    Application.Properties.setValue("ShowDate", false); Application.Properties.setValue("AlwaysOn", false);
    cfg.reload();
    var saved = cfg.fields[0] == 8 && cfg.fields[1] == 3 && cfg.fields[2] == 8 && cfg.accent == 2 && cfg.miles && !cfg.is24 && !cfg.showDate && !cfg.aod;
    var menu = new SettingsMenu();
    Application.Properties.setValue("Field1", 999); Application.Properties.setValue("Accent", -1);
    Application.Properties.setValue("ClockMode", "bad"); Application.Properties.setValue("AlwaysOn", "bad");
    cfg.reload();
    var safe = cfg.fields[0] == 1 && cfg.accent == 0 && cfg.aod;
    menu.refreshLabels();
    Test.assertEqual((menu.getItem(2) as WatchUi.MenuItem).getSubLabel() as String, Fields.title(8));
    Test.assertEqual((menu.getItem(1) as WatchUi.MenuItem).getLabel() as String, SettingChoices.title("Field2"));
    for (var k = 0; k < keys.size(); k += 1) { Application.Properties.setValue(keys[k], original[k] as Application.Properties.ValueType); }
    Test.assertMessage(saved, "Settings must persist and reload");
    Test.assertMessage(safe, "Malformed or stale properties need bounded defaults");
    // Menu and phone settings use the same IDs and value lists.
    for (var f = 1; f <= 6; f += 1) { Test.assertEqual(SettingChoices.labels("Field" + f).size(), Fields.COUNT); }
    Test.assertEqual(SettingChoices.labels("Accent").size(), 6);
    Test.assert(menu.getItem(11) != null);
    return true;
}

(:test)
function fieldValidationAndUnits(logger as Test.Logger) as Boolean {
    Test.assert(!Fields.valid(3, 101)); Test.assert(!Fields.valid(1, 0));
    Test.assert(Fields.valid(2, 0)); Test.assert(Fields.valid(6, 0));
    var s = Fixtures.snapshot(0);
    Test.assertEqual(Fields.format(2, s, false), "18h");
    Test.assertEqual(Fields.format(4, s, false), "24.8");
    Test.assertEqual(Fields.unit(4, true), "mi");
    Test.assertEqual(Fields.format(6, s, false), "8.2k");
    s.values[3] = 101; Test.assertEqual(Fields.format(3, s, false), "--");
    Test.assertEqual(Fields.format(0, s, false), "");
    return true;
}
