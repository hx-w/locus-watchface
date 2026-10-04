import Toybox.Graphics;
import Toybox.Lang;

module AlwaysOn {
    function previewMark(dc as Graphics.Dc) as Void {
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + 65 * dc.getWidth() / 416.0,
            Graphics.FONT_XTINY, "DEMO", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    function draw(dc as Graphics.Dc, clock as String, minute as Number) as Void {
        var scale = dc.getWidth() / 416.0;
        var dx = [0, 12, 0, -12][minute % 4]; var dy = [-16, 0, 16, 0][minute % 4];
        dc.setColor(0x555555, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2 + dx * scale, dc.getHeight() / 2 + dy * scale,
            Graphics.FONT_NUMBER_MEDIUM, clock, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
