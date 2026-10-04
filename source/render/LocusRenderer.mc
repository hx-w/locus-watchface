import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time.Gregorian;

class LocusRenderer {
    var canvas as Canvas;
    private var _icons as NativeIcons;
    function initialize() { canvas = new Canvas(); _icons = new NativeIcons(); }
    function render(dc as Graphics.Dc, s as AthleteSnapshot, cfg as LocusSettings, hour as Number,
        minute as Number, date as Gregorian.Info, low as Boolean) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); dc.clear();
        var clock = MetricFormat.hour(hour, cfg.is24) + ":" + minute.format("%02d");
        // Return before preparing vector fonts or accessing athlete values.
        if (low) { if (cfg.aod) { AlwaysOn.draw(dc, clock, minute); if (s.demo) { AlwaysOn.previewMark(dc); } } return; }
        canvas.prepare(dc);
        header(dc, s, cfg, date);
        time(dc, cfg, hour, minute);
        if (!cfg.is24) { canvas.text(dc, 208, 130, 14, hour < 12 ? "AM" : "PM", Palette.MUTED, 32); }
        plot(dc, s, cfg);
        canvas.line(dc, 170, 321, 170, 370, Palette.TRACK, 1);
        canvas.line(dc, 246, 321, 246, 370, Palette.TRACK, 1);
        footer(dc, s, cfg, 3, 132); footer(dc, s, cfg, 4, 208); footer(dc, s, cfg, 5, 284);
        battery(dc, s, cfg);
    }
    private function time(dc as Graphics.Dc, cfg as LocusSettings, hour as Number, minute as Number) as Void {
        var hours = MetricFormat.hour(hour, cfg.is24); var minutes = minute.format("%02d");
        var size = 102;
        var f = canvas.font(size);
        var hw = dc.getTextWidthInPixels(hours, f) / canvas.scale;
        var mw = dc.getTextWidthInPixels(minutes, f) / canvas.scale;
        // Fix the colon to the screen center, independent of digit advances.
        canvas.text(dc, 194 - hw / 2, 90, size, hours, 0xFFF3DD, hw + 1);
        canvas.circle(dc, 208, 77, 4, Palette.INK);
        canvas.circle(dc, 208, 103, 4, Palette.INK);
        canvas.text(dc, 222 + mw / 2, 90, size, minutes, cfg.timeColor(), mw + 1);
    }
    private function header(dc as Graphics.Dc, s as AthleteSnapshot, cfg as LocusSettings, date as Gregorian.Info) as Void {
        if (cfg.showDate || s.demo) {
            var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
            var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
            var text = days[(date.day_of_week as Number) - 1] + " " + date.day.format("%02d") + " " + months[(date.month as Number) - 1];
            if (s.demo) { text = cfg.showDate ? "DEMO  THU 01 OCT" : "DEMO"; }
            canvas.text(dc, 208, 34, s.demo ? 20 : 24, text, Palette.INK, 216);
        }
    }
    private function battery(dc as Graphics.Dc, s as AthleteSnapshot, cfg as LocusSettings) as Void {
        _icons.draw(canvas, dc, 7, 183, 391, Palette.MUTED, 20);
        var battery = Fields.format(7, s, cfg.miles);
        canvas.text(dc, 216, 391, 16, battery + (battery.equals("--") ? "" : "%"), Palette.MUTED, 46);
    }
    private function dashed(dc as Graphics.Dc, x1 as Numeric, y1 as Numeric, x2 as Numeric, y2 as Numeric, color as Number) as Void {
        var vertical = x1 == x2;
        var length = vertical ? y2 - y1 : x2 - x1;
        for (var step = 0; step < length; step += 6) {
            var end = ChartAxes.min(step + 3, length);
            canvas.line(dc, x1 + (vertical ? 0 : step), y1 + (vertical ? step : 0),
                x1 + (vertical ? 0 : end), y1 + (vertical ? end : 0), color, 1);
        }
    }
    private function plot(dc as Graphics.Dc, s as AthleteSnapshot, cfg as LocusSettings) as Void {
        var xid = cfg.fields[1]; var yid = cfg.fields[2];
        var xv = ChartAxes.value(xid, s, cfg.miles); var yv = ChartAxes.value(yid, s, cfg.miles);
        var xmax = ChartAxes.ceiling(xid, xv); var ymax = ChartAxes.ceiling(yid, yv);
        for (var h = 0; h < s.trail.size(); h += 1) {
            xmax = ChartAxes.max(xmax, ChartAxes.ceiling(xid, ChartAxes.convert(xid, s.trail[h][1], cfg.miles)));
            ymax = ChartAxes.max(ymax, ChartAxes.ceiling(yid, ChartAxes.convert(yid, s.trail[h][2], cfg.miles)));
        }
        var px = xv == null ? 61 : 61 + 264 * xv / xmax;
        // Reserve room above the largest heart beneath the time numerals.
        var py = yv == null ? 281 : 281 - 147 * yv / ymax;
        var geometry = [];
        for (var g = 0; g < s.trail.size(); g += 1) {
            var observation = s.trail[g];
            geometry.add([61 + 264 * ChartAxes.convert(xid, observation[1], cfg.miles) / xmax,
                281 - 147 * ChartAxes.convert(yid, observation[2], cfg.miles) / ymax, observation[0]]);
        }
        if (xv != null && yv != null) { geometry.add([px, py, s.stamp]); }
        var topology = new TrailTopology(geometry);
        for (var face = 0; face < topology.loops.size(); face += 1) {
            canvas.polygon(dc, topology.loops[face], tint(cfg.color(), canvas.mip ? 0.30 : 0.14));
        }
        dashed(dc, 61, 207.5, 325, 207.5, Palette.TRACK);
        dashed(dc, 193, 142, 193, 281, Palette.TRACK);
        trail(dc, s, cfg, xmax, ymax);
        var pointClearance = (cfg.fields[0] == 1 ? NativeIcons.heartSize(s.get(1)) / 2.0 : 10) + 6;
        for (var node = 0; node < topology.crossings.size(); node += 1) {
            var crossing = topology.crossings[node];
            if (xv == null || yv == null || TrailTopology.distance(crossing, [px, py]) > pointClearance * pointClearance) {
                canvas.ring(dc, crossing[0], crossing[1], 3, cfg.color());
                canvas.circle(dc, crossing[0], crossing[1], 0.8, Palette.INK);
            }
        }
        canvas.line(dc, 61, 286, 61, 124, Palette.INK, 1.5);
        canvas.line(dc, 56, 281, 338, 281, Palette.INK, 1.5);
        canvas.polygon(dc, [[61,121],[57,129],[65,129]], Palette.INK);
        canvas.polygon(dc, [[341,281],[333,277],[333,285]], Palette.INK);
        canvas.text(dc, 71, 111, 16, yid == 0 ? "--" : Fields.LABELS[yid], Palette.MUTED, 70);
        canvas.text(dc, 88, 128, 11, ChartAxes.unit(yid, cfg.miles), Palette.MUTED, 38);
        canvas.text(dc, 367, 275, 15, xid == 0 ? "--" : Fields.LABELS[xid], Palette.MUTED, 66);
        canvas.text(dc, 367, 291, 11, ChartAxes.unit(xid, cfg.miles), Palette.MUTED, 46);
        canvas.text(dc, 45, 134, 14, ChartAxes.format(ymax), Palette.MUTED, 34);
        canvas.text(dc, 45, 281, 14, "0", Palette.MUTED, 34);
        canvas.text(dc, 61, 298, 14, "0", Palette.MUTED, 34);
        canvas.text(dc, 325, 298, 14, ChartAxes.format(xmax), Palette.MUTED, 40);
        // Leave space for current-value projections when close to a midpoint tick.
        if (yv == null || (py - 207.5).abs() > 18) { canvas.text(dc, 45, 207.5, 14, ChartAxes.format(ymax / 2.0), Palette.MUTED, 34); }
        if (xv == null || (px - 193).abs() > 24) { canvas.text(dc, 193, 298, 14, ChartAxes.format(xmax / 2.0), Palette.MUTED, 40); }
        if (xv != null) {
            canvas.text(dc, ChartAxes.max(78, ChartAxes.min(299, px)), 298, 16, ChartAxes.format(xv), cfg.color(), 46);
        } else { canvas.text(dc, 125, 298, 16, "--", cfg.color(), 40); }
        if (yv != null) {
            // Endpoint labels already carry 0/max. Interior values use copper.
            if (py > 143 && py < 265) { canvas.text(dc, 45, py, 16, ChartAxes.format(yv), cfg.color(), 34); }
        } else { canvas.text(dc, 45, 166, 16, "--", cfg.color(), 34); }
        var id = cfg.fields[0];
        var pointSize = id == 1 ? NativeIcons.heartSize(s.get(1)) : 20;
        if (xv != null && yv != null) {
            dashed(dc, 61, py, px, py, 0x76736C);
            dashed(dc, px, py, px, 281, 0x76736C);
            // Do not mask the endpoint: the historical line must reach the icon.
            if (s.trail.size() > 0) {
                var last = s.trail[s.trail.size() - 1];
                if (s.stamp - last[0] <= HistoryPolicy.MAX_GAP) {
                    var lx = 61 + 264 * ChartAxes.convert(xid, last[1], cfg.miles) / xmax;
                    var ly = 281 - 147 * ChartAxes.convert(yid, last[2], cfg.miles) / ymax;
                    segment(dc, cfg, lx, ly, last[0], px, py, s.stamp, s.stamp);
                }
            }
            if (id == 0) { canvas.circle(dc, px, py, 5, cfg.color()); }
            else { _icons.draw(canvas, dc, id, px, py, cfg.color(), pointSize); }
        }
        if (id != 0) {
            var value = Fields.format(id, s, cfg.miles);
            var label = Fields.LABELS[id] + " " + value + (value.equals("--") ? "" : Fields.unit(id, cfg.miles));
            var width = ChartAxes.min(92, dc.getTextWidthInPixels(label, canvas.font(18)) / canvas.scale);
            var hasPoint = xv != null && yv != null;
            var gap = pointSize / 2 + 8;
            var left = hasPoint ? px + gap : 208 - width / 2;
            if (left + width > 335) { left = px - gap - width; }
            left = ChartAxes.max(84, left);
            var y = hasPoint ? ChartAxes.max(150, ChartAxes.min(258, py - 5)) : 176;
            canvas.text(dc, left + width / 2, y, 18, label, Palette.INK, width + 1);
        }
    }
    private function trailColor(cfg as LocusSettings, age as Numeric) as Number {
        var recent = 1 - ChartAxes.max(0, ChartAxes.min(HistoryPolicy.WINDOW, age)) / HistoryPolicy.WINDOW;
        // Old observations echo the accent; recent observations approach the point color.
        var start = cfg.color();
        var finish = cfg.fields[0] == 1 ? Palette.HEART : cfg.color();
        var fade = canvas.mip ? 0.65 + 0.35 * recent : 0.40 + 0.60 * recent;
        var red = Math.round((((start >> 16) & 255) * (1 - recent) + ((finish >> 16) & 255) * recent) * fade).toNumber();
        var green = Math.round((((start >> 8) & 255) * (1 - recent) + ((finish >> 8) & 255) * recent) * fade).toNumber();
        var blue = Math.round(((start & 255) * (1 - recent) + (finish & 255) * recent) * fade).toNumber();
        return (red << 16) | (green << 8) | blue;
    }
    private function tint(color as Number, fraction as Float) as Number {
        return (Math.round(((color >> 16) & 255) * fraction).toNumber() << 16) |
            (Math.round(((color >> 8) & 255) * fraction).toNumber() << 8) |
            Math.round((color & 255) * fraction).toNumber();
    }
    private function segment(dc as Graphics.Dc, cfg as LocusSettings, x1 as Numeric, y1 as Numeric, t1 as Numeric,
        x2 as Numeric, y2 as Numeric, t2 as Numeric, stamp as Number) as Void {
        var dx = x2 - x1; var dy = y2 - y1;
        var steps = Math.ceil(Math.sqrt(dx * dx + dy * dy) / 6.0).toNumber();
        if (steps < 1) { steps = 1; }
        var lastX = x1; var lastY = y1;
        // Interpolate age within a stroke, never switch between color buckets.
        for (var j = 1; j <= steps; j += 1) {
            var part = j / steps.toFloat();
            var x = x1 + dx * part; var y = y1 + dy * part;
            var age = stamp - (t1 + (t2 - t1) * part);
            var color = trailColor(cfg, age);
            // A uniform fine stroke reads as measured data, rather than a comet.
            canvas.line(dc, lastX, lastY, x, y, color, 1.5);
            lastX = x; lastY = y;
        }
    }
    private function trail(dc as Graphics.Dc, s as AthleteSnapshot, cfg as LocusSettings, xmax as Numeric, ymax as Numeric) as Void {
        var prevX = 0.0; var prevY = 0.0; var prevTime = 0;
        var markedTime = 0; var markedX = 0.0; var markedY = 0.0;
        var nowX = ChartAxes.value(cfg.fields[1], s, cfg.miles);
        var nowY = ChartAxes.value(cfg.fields[2], s, cfg.miles);
        var markerX = nowX == null ? -100 : 61 + 264 * nowX / xmax;
        var markerY = nowY == null ? -100 : 281 - 147 * nowY / ymax;
        var clearance = (cfg.fields[0] == 1 ? NativeIcons.heartSize(s.get(1)) / 2.0 : 10) + 6;
        for (var i = 0; i < s.trail.size(); i += 1) {
            var row = s.trail[i];
            var x = 61 + 264 * ChartAxes.convert(cfg.fields[1], row[1], cfg.miles) / xmax;
            var y = 281 - 147 * ChartAxes.convert(cfg.fields[2], row[2], cfg.miles) / ymax;
            var age = s.stamp - row[0];
            if (i > 0 && row[0] - prevTime <= HistoryPolicy.MAX_GAP) { segment(dc, cfg, prevX, prevY, prevTime, x, y, row[0], s.stamp); }
            // Sparse open observation marks, not a dot at every five-minute row.
            var awayFromPoint = (x - markerX) * (x - markerX) + (y - markerY) * (y - markerY) > clearance * clearance;
            if (awayFromPoint && (i == 0 || row[0] - prevTime > HistoryPolicy.MAX_GAP ||
                (row[0] - markedTime >= 90 && (x - markedX) * (x - markedX) + (y - markedY) * (y - markedY) >= 144))) {
                canvas.ring(dc, x, y, 1.6, trailColor(cfg, age));
                markedTime = row[0].toNumber(); markedX = x; markedY = y;
            }
            prevX = x; prevY = y; prevTime = row[0].toNumber();
        }
        if (s.trail.size() > 0 && cfg.fields[1] != 0 && cfg.fields[2] != 0 && s.stamp - prevTime <= HistoryPolicy.MAX_GAP) {
            var x = ChartAxes.value(cfg.fields[1], s, cfg.miles); var y = ChartAxes.value(cfg.fields[2], s, cfg.miles);
            if (x != null && y != null) { segment(dc, cfg, prevX, prevY, prevTime, 61 + 264 * x / xmax, 281 - 147 * y / ymax, s.stamp, s.stamp); }
        }
        if (s.trail.size() > 1) {
            var first = s.trail[0];
            var fx = 61 + 264 * ChartAxes.convert(cfg.fields[1], first[1], cfg.miles) / xmax;
            var fy = 281 - 147 * ChartAxes.convert(cfg.fields[2], first[2], cfg.miles) / ymax;
            var currentX = ChartAxes.value(cfg.fields[1], s, cfg.miles);
            var currentY = ChartAxes.value(cfg.fields[2], s, cfg.miles);
            var cx = currentX == null ? fx : 61 + 264 * currentX / xmax;
            var cy = currentY == null ? fy : 281 - 147 * currentY / ymax;
            if ((fx - cx) * (fx - cx) + (fy - cy) * (fy - cy) > 324) {
                var age = s.stamp - first[0];
                var offset = age >= 60 ? ChartAxes.format(age / 60.0) + "h" : ChartAxes.format(age) + "m";
                canvas.text(dc, ChartAxes.max(104, ChartAxes.min(292, fx + 22)),
                    ChartAxes.max(154, ChartAxes.min(259, fy + 13)), 12, "t-" + offset, Palette.MUTED, 55);
            }
            canvas.text(dc, 286, (cx > 235 && cy < 168) ? 255 : 146, 12,
                "6h  n=" + s.trail.size(), Palette.MUTED, 86);
        }
    }
    private function footer(dc as Graphics.Dc, s as AthleteSnapshot, cfg as LocusSettings, slot as Number, x as Number) as Void {
        var id = cfg.fields[slot]; if (id == 0) { return; }
        _icons.draw(canvas, dc, id, x, 326, cfg.color(), 34);
        var value = Fields.format(id, s, cfg.miles);
        var unit = value.equals("--") ? "" : Fields.unit(id, cfg.miles);
        if (unit.length() > 0) { canvas.valueUnit(dc, x, 360, value, unit, 30, 16, 72); }
        else { canvas.text(dc, x, 360, 30, value, Palette.INK, 72); }
    }
}
