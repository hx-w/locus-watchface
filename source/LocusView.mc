import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class LocusView extends WatchUi.WatchFace {
    private var _settings as LocusSettings;
    private var _renderer as LocusRenderer;
    private var _snapshot as AthleteSnapshot;
    private var _history as ChartHistory?;
    private var _minute as Number = -1;
    private var _sleeping as Boolean = false;
    function initialize() {
        WatchFace.initialize();
        _settings = new LocusSettings(); _renderer = new LocusRenderer(); _snapshot = new AthleteSnapshot();
    }
    function reload() as Void { _settings.reload(); _minute = -1; subscribe(); }
    function onShow() as Void { _minute = -1; subscribe(); }
    function onHide() as Void { Complications.unsubscribeFromAllUpdates(); }
    function onEnterSleep() as Void { _sleeping = true; WatchUi.requestUpdate(); }
    function onExitSleep() as Void { _sleeping = false; _minute = -1; WatchUi.requestUpdate(); }
    function changed(id as Complications.Id) as Void {
        _minute = -1;
        if (!_sleeping && System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER) { WatchUi.requestUpdate(); }
    }
    private function subscribe() as Void {
        Complications.unsubscribeFromAllUpdates();
        Complications.registerComplicationChangeCallback(method(:changed));
        var seen = [7];
        for (var i = 0; i < _settings.fields.size(); i += 1) {
            var id = _settings.fields[i];
            if (id != 0 && seen.indexOf(id) == -1) { seen.add(id); }
        }
        for (var j = 0; j < seen.size(); j += 1) {
            try { Complications.subscribeToUpdates(new Complications.Id(Fields.type(seen[j]))); } catch (e) { }
        }
    }
    function onUpdate(dc as Graphics.Dc) as Void {
        var mode = System.getDisplayMode();
        if (mode == System.DISPLAY_MODE_OFF) { dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); dc.clear(); return; }
        var low = _sleeping || mode == System.DISPLAY_MODE_LOW_POWER;
        var stamp = (Time.now().value() / 60).toNumber();
        if (!low && stamp != _minute) {
            _snapshot = AthleteData.read(_settings);
            if (!_snapshot.demo) {
                if (_history == null) { _history = new ChartHistory(); }
                _history.record(_snapshot, _settings, stamp);
            }
            _minute = stamp;
        }
        var clock = System.getClockTime();
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        _renderer.render(dc, _snapshot, _settings, _snapshot.demo ? 10 : clock.hour, _snapshot.demo ? 8 : clock.min, date, low || _snapshot.demoAod);
    }
}
