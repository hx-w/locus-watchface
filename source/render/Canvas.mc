import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// All layout coordinates use a 416px circle. Font measurements use the real Dc.
module Palette {
    const INK = 0xF2EEE4;
    const MUTED = 0xA9A7A1;
    const TRACK = 0x303030;
    const HEART = 0xFF5E68;
}

class Canvas {
    var scale as Float = 1.0;
    var measureBounds as Boolean = false;
    var failures as Array<String> = [];
    private var _fonts as Dictionary<Number, Graphics.FontType> = {};
    function initialize() { }
    function prepare(dc as Graphics.Dc) as Void {
        var next = dc.getWidth() / 416.0;
        if (next != scale) { _fonts = {}; scale = next; }
        dc.setAntiAlias(true);
    }
    function font(size as Number) as Graphics.FontType {
        if (!_fonts.hasKey(size)) {
            var f = Graphics.getVectorFont({:face => "RobotoCondensedBold", :size => Math.round(size * scale)});
            _fonts[size] = f == null ? Graphics.FONT_XTINY : f;
        }
        return _fonts[size] as Graphics.FontType;
    }
    function hasFonts() as Boolean { return _fonts.size() > 0; }
    // Center-based placement guarantees number baselines, independent of font metrics.
    function text(dc as Graphics.Dc, x as Numeric, y as Numeric, size as Number, t as String,
        color as Number, maxWidth as Numeric) as Void {
        if (t.length() == 0) { return; }
        var f = font(size);
        var n = size;
        while (dc.getTextWidthInPixels(t, f) > maxWidth * scale && n > 14) {
            n -= 2; f = font(n);
        }
        var w = dc.getTextWidthInPixels(t, f);
        var h = dc.getFontHeight(f);
        if (measureBounds) {
            var left = x * scale - w / 2.0 - dc.getWidth() / 2.0;
            var right = left + w;
            var top = y * scale - h / 2.0 - dc.getHeight() / 2.0;
            var bottom = top + h;
            var r = dc.getWidth() / 2.0 - 7 * scale;
            if (w > maxWidth * scale + 1 || left * left + top * top > r * r || right * right + top * top > r * r ||
                left * left + bottom * bottom > r * r || right * right + bottom * bottom > r * r) {
                failures.add(t + " at " + x + "," + y + " size " + w + "x" + h);
            }
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x * scale, y * scale, f, t, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    function valueUnit(dc as Graphics.Dc, x as Numeric, y as Numeric, value as String, unit as String,
        size as Number, unitSize as Number, maxWidth as Numeric) as Void {
        var n = size;
        var uw = dc.getTextWidthInPixels(unit, font(unitSize)) / scale;
        var vw = dc.getTextWidthInPixels(value, font(n)) / scale;
        while (vw + uw + 3 > maxWidth && n > 14) { n -= 2; vw = dc.getTextWidthInPixels(value, font(n)) / scale; }
        var left = x - (vw + uw + 3) / 2;
        text(dc, left + vw / 2, y, n, value, Palette.INK, vw + 1);
        text(dc, left + vw + 3 + uw / 2, y + (dc.getFontHeight(font(n)) - dc.getFontHeight(font(unitSize))) / scale / 2,
            unitSize, unit, Palette.MUTED, uw + 1);
    }
    function line(dc as Graphics.Dc, x1 as Numeric, y1 as Numeric, x2 as Numeric, y2 as Numeric, color as Number, width as Numeric) as Void {
        var pen = width * scale;
        dc.setPenWidth(pen < 1 ? 1 : pen); dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1 * scale, y1 * scale, x2 * scale, y2 * scale); dc.setPenWidth(1);
    }
    function circle(dc as Graphics.Dc, x as Numeric, y as Numeric, r as Numeric, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT); dc.fillCircle(x * scale, y * scale, r * scale);
    }
    function ring(dc as Graphics.Dc, x as Numeric, y as Numeric, r as Numeric, color as Number) as Void {
        dc.setPenWidth(1); dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x * scale, y * scale, r * scale);
    }
    function polygon(dc as Graphics.Dc, pts as Array<Array<Numeric>>, color as Number) as Void {
        var scaled = [];
        for (var i = 0; i < pts.size(); i += 1) { scaled.add([pts[i][0] * scale, pts[i][1] * scale]); }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT); dc.fillPolygon(scaled);
    }
}
