import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

module SettingChoices {
    function title(key as String) as String {
        var titles = {"Field1" => Rez.Strings.Field1Title, "Field2" => Rez.Strings.Field2Title,
            "Field3" => Rez.Strings.Field3Title, "Field4" => Rez.Strings.Field4Title,
            "Field5" => Rez.Strings.Field5Title, "Field6" => Rez.Strings.Field6Title,
            "Accent" => Rez.Strings.AccentTitle, "ClockMode" => Rez.Strings.ClockMode,
            "Units" => Rez.Strings.UnitsTitle, "ShowDate" => Rez.Strings.ShowDate,
            "AlwaysOn" => Rez.Strings.AlwaysOn};
        return WatchUi.loadResource(titles[key] as ResourceId) as String;
    }
    function labels(key as String) as Array<String> {
        var result = [];
        if (key.find("Field") == 0) {
            for (var i = 0; i < Fields.COUNT; i += 1) { result.add(Fields.title(i)); }
            return result;
        }
        var resources = {"Accent" => [Rez.Strings.DefaultAccent, Rez.Strings.Ivory, Rez.Strings.Sage, Rez.Strings.Coral, Rez.Strings.Slate, Rez.Strings.Copper],
            "ClockMode" => [Rez.Strings.SystemClock, Rez.Strings.Clock24, Rez.Strings.Clock12],
            "Units" => [Rez.Strings.Metric, Rez.Strings.Imperial],
            "ShowDate" => [Rez.Strings.Off, Rez.Strings.On], "AlwaysOn" => [Rez.Strings.Off, Rez.Strings.On]};
        var ids = resources[key] as Array<ResourceId>;
        for (var j = 0; j < ids.size(); j += 1) { result.add(WatchUi.loadResource(ids[j]) as String); }
        return result;
    }
    function current(key as String) as Number {
        var cfg = new LocusSettings();
        if (key.equals("ShowDate") || key.equals("AlwaysOn")) { return cfg.flag(key, true) ? 1 : 0; }
        if (key.find("Field") == 0) {
            var index = (key.substring(5, 6) as String).toNumber() as Number;
            return cfg.fields[index - 1];
        }
        return cfg.number(key, 0, 0, labels(key).size() - 1);
    }
    function save(key as String, value as Number) as Void {
        var max = labels(key).size() - 1;
        if (value < 0 || value > max) { return; }
        if (key.equals("ShowDate") || key.equals("AlwaysOn")) { Application.Properties.setValue(key, value == 1); }
        else { Application.Properties.setValue(key, value); }
        (Application.getApp() as LocusApp).onSettingsChanged();
    }
}

class SettingsMenu extends WatchUi.Menu2 {
    private var _keys as Array<String> = ["Field1", "Field2", "Field3", "Field4", "Field5", "Field6", "Accent", "ClockMode", "Units", "ShowDate", "AlwaysOn"];
    function initialize() {
        Menu2.initialize({:title => Rez.Strings.SettingsTitle});
        for (var i = 0; i < _keys.size(); i += 1) {
            var key = _keys[i];
            addItem(new WatchUi.MenuItem(SettingChoices.title(key), SettingChoices.labels(key)[SettingChoices.current(key)], key, null));
        }
        addItem(new WatchUi.MenuItem(Rez.Strings.Reset, null, "Reset", null));
    }
    function refreshLabels() as Void {
        for (var i = 0; i < _keys.size(); i += 1) {
            var item = getItem(i) as WatchUi.MenuItem;
            item.setLabel(SettingChoices.title(_keys[i]));
            item.setSubLabel(SettingChoices.labels(_keys[i])[SettingChoices.current(_keys[i])]);
        }
    }
}

class SettingsDelegate extends WatchUi.Menu2InputDelegate {
    private var _menu as SettingsMenu;
    function initialize(menu as SettingsMenu) { Menu2InputDelegate.initialize(); _menu = menu; }
    function onSelect(item as WatchUi.MenuItem) as Void {
        var key = item.getId() as String;
        if (key.equals("Reset")) {
            for (var i = 0; i < 6; i += 1) { Application.Properties.setValue("Field" + (i + 1), Fields.DEFAULTS[i]); }
            Application.Properties.setValue("Accent", 0); Application.Properties.setValue("ClockMode", 0);
            Application.Properties.setValue("Units", 0); Application.Properties.setValue("ShowDate", true);
            Application.Properties.setValue("AlwaysOn", true);
            (Application.getApp() as LocusApp).onSettingsChanged();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); return;
        }
        var labels = SettingChoices.labels(key);
        var menu = new WatchUi.Menu2({:title => SettingChoices.title(key), :focus => SettingChoices.current(key)});
        for (var j = 0; j < labels.size(); j += 1) { menu.addItem(new WatchUi.MenuItem(labels[j], null, j, null)); }
        WatchUi.pushView(menu, new ChoiceDelegate(key, _menu), WatchUi.SLIDE_IMMEDIATE);
    }
}

class ChoiceDelegate extends WatchUi.Menu2InputDelegate {
    private var _key as String;
    private var _menu as SettingsMenu;
    function initialize(key as String, menu as SettingsMenu) { Menu2InputDelegate.initialize(); _key = key; _menu = menu; }
    function onSelect(item as WatchUi.MenuItem) as Void {
        var value = item.getId() as Number;
        SettingChoices.save(_key, value);
        _menu.refreshLabels();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
