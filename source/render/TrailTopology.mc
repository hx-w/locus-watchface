import Toybox.Lang;

// Geometry only: run on the same interpolated path used for the visible stroke.
class TrailTopology {
    var loops as Array<Array<Array<Numeric>>> = [];
    var crossings as Array<Array<Numeric>> = [];
    function initialize(rows as Array<Array<Numeric>>) {
        if (rows.size() == 0) { return; }
        var path = [[rows[0][0], rows[0][1]]] as Array<Array<Numeric>>;
        for (var i = 1; i < rows.size(); i += 1) {
            var row = rows[i]; var target = [row[0], row[1]];
            if (distance(path[path.size() - 1], target) > 0.0001) {
                // Erase completed loops from the working path, giving simple faces.
                var finished = false;
                while (!finished && crossings.size() < 12) {
                    var start = path[path.size() - 1];
                    var left = start[0] < target[0] ? start[0] : target[0];
                    var right = start[0] > target[0] ? start[0] : target[0];
                    var top = start[1] < target[1] ? start[1] : target[1];
                    var bottom = start[1] > target[1] ? start[1] : target[1];
                    var nearest = null; var edge = -1; var part = 2.0;
                    for (var j = 0; j < path.size() - 2; j += 1) {
                        var a = path[j]; var b = path[j + 1];
                        // Exact bounding-box rejection avoids most divisions and calls.
                        if ((a[0] < left && b[0] < left) || (a[0] > right && b[0] > right) ||
                            (a[1] < top && b[1] < top) || (a[1] > bottom && b[1] > bottom)) { continue; }
                        var hit = intersection(start, target, path[j], path[j + 1]);
                        if (hit != null && hit[2] > 0.000001 && hit[2] < part) {
                            nearest = hit; part = hit[2]; edge = j;
                        }
                    }
                    if (nearest == null) { finished = true; }
                    else {
                        var point = [nearest[0], nearest[1]];
                        var face = [point];
                        for (var k = edge + 1; k < path.size(); k += 1) { face.add(path[k]); }
                        if (area(face) >= 16 && loops.size() < 6) { loops.add(face); }
                        var unique = true;
                        for (var c = 0; c < crossings.size(); c += 1) {
                            if (distance(crossings[c], point) < 9) { unique = false; }
                        }
                        if (unique) { crossings.add(point); }
                        var trimmed = [] as Array<Array<Numeric>>;
                        for (var p = 0; p <= edge; p += 1) { trimmed.add(path[p]); }
                        if (distance(trimmed[trimmed.size() - 1], point) > 0.0001) { trimmed.add(point); }
                        path = trimmed;
                        if (distance(point, target) <= 0.0001) { finished = true; }
                    }
                }
                if (distance(path[path.size() - 1], target) > 0.0001) { path.add(target); }
            }
        }
    }
    static function distance(a as Array<Numeric>, b as Array<Numeric>) as Numeric {
        return (a[0] - b[0]) * (a[0] - b[0]) + (a[1] - b[1]) * (a[1] - b[1]);
    }
    static function area(points as Array<Array<Numeric>>) as Numeric {
        var sum = 0.0;
        for (var i = 0; i < points.size(); i += 1) {
            var next = (i + 1) % points.size();
            sum += points[i][0] * points[next][1] - points[next][0] * points[i][1];
        }
        return sum.abs() / 2;
    }
    static function intersection(a as Array<Numeric>, b as Array<Numeric>, c as Array<Numeric>, d as Array<Numeric>) as Array<Numeric>? {
        var rx = b[0] - a[0]; var ry = b[1] - a[1];
        var sx = d[0] - c[0]; var sy = d[1] - c[1];
        var denominator = (rx * sy - ry * sx).toFloat();
        if (denominator.abs() < 0.000001) { return null; }
        var dx = c[0] - a[0]; var dy = c[1] - a[1];
        var t = (dx * sy - dy * sx) / denominator;
        var u = (dx * ry - dy * rx) / denominator;
        if (t < -0.000001 || t > 1.000001 || u < -0.000001 || u > 1.000001) { return null; }
        return [a[0] + t * rx, a[1] + t * ry, t];
    }
}
