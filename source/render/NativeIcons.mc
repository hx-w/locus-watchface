import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

// Official MIT-licensed Tabler outlines. Original SVGs/license/commit are vendored.
// All icons use one flat color; only the heart takes the semantic coral red.
class NativeIcons {
    private var _cache as Dictionary<Number, WatchUi.BitmapResource> = {};
    function initialize() { }
    static function heartSize(bpm as Numeric?) as Number {
        if (bpm == null || !Fields.valid(1, bpm)) { return 20; }
        var bounded = ChartAxes.max(40, ChartAxes.min(180, bpm));
        return Math.round(20 + (bounded - 40) * 14 / 140.0).toNumber();
    }
    function draw(c as Canvas, dc as Graphics.Dc, id as Number, x as Numeric, y as Numeric, color as Number, size as Number) as Void {
        if (id == 0) { return; }
        if (id == 1) { color = Palette.HEART; }
        var resources = [Rez.Drawables.IconChartBar, Rez.Drawables.IconHeartFilled, Rez.Drawables.IconHourglass,
            Rez.Drawables.IconBattery3, Rez.Drawables.IconRun, Rez.Drawables.IconBike, Rez.Drawables.IconShoe,
            Rez.Drawables.IconBattery3, Rez.Drawables.IconActivityHeartbeat, Rez.Drawables.IconDroplet,
            Rez.Drawables.IconLungs, Rez.Drawables.IconChartBar, Rez.Drawables.IconChartBar, Rez.Drawables.IconStairsUp,
            Rez.Drawables.IconClock];
        if (!_cache.hasKey(id)) { _cache[id] = WatchUi.loadResource(resources[id]) as WatchUi.BitmapResource; }
        var bitmap = _cache[id] as WatchUi.BitmapResource;
        var width = size * c.scale;
        if (c.measureBounds) {
            var left = x * c.scale - width / 2 - dc.getWidth() / 2;
            var right = left + width;
            var top = y * c.scale - width / 2 - dc.getHeight() / 2;
            var bottom = top + width;
            var r = dc.getWidth() / 2 - 7 * c.scale;
            if (left * left + top * top > r * r || right * right + top * top > r * r ||
                left * left + bottom * bottom > r * r || right * right + bottom * bottom > r * r) {
                c.failures.add("Icon " + id + " at " + x + "," + y);
            }
        }
        var transform = new Graphics.AffineTransform();
        transform.scale((width / bitmap.getWidth()).toFloat(), (width / bitmap.getHeight()).toFloat());
        dc.drawBitmap2((x * c.scale - width / 2), (y * c.scale - width / 2), bitmap,
            {:tintColor => color, :transform => transform, :filterMode => Graphics.FILTER_MODE_BILINEAR});
    }
}
