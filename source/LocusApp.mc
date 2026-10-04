import Toybox.Application;
import Toybox.WatchUi;

class LocusApp extends Application.AppBase {
    private var _view as LocusView?;
    function initialize() { AppBase.initialize(); }
    function getInitialView() {
        _view = new LocusView();
        return [_view];
    }
    function onSettingsChanged() as Void {
        if (_view != null) { _view.reload(); }
        WatchUi.requestUpdate();
    }
    function getSettingsView() {
        var menu = new SettingsMenu();
        return [menu, new SettingsDelegate(menu)];
    }
}
