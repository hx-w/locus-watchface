import Toybox.Lang;
import Toybox.Math;

// Natural cubic B-spline interpolation, parameterized by observation order.
// Curve vertices are drawing geometry, never new athlete observations.
class TrailCurve {
    var points as Array<Array<Numeric>> = [];
    private var _rows as Array<Array<Numeric>> = [];
    private var _x as Array<Numeric> = [];
    private var _y as Array<Numeric> = [];
    function initialize(rows as Array<Array<Numeric>>) {
        for (var r = 0; r < rows.size(); r += 1) {
            var row = rows[r];
            // A stationary interval needs one knot, not a small artificial loop.
            if (_rows.size() > 0 && TrailTopology.distance(_rows[_rows.size() - 1], row) < 0.0001) {
                _rows[_rows.size() - 1] = row;
            } else { _rows.add(row); }
        }
        var count = _rows.size();
        if (count == 0) { return; }
        points.add(_rows[0]);
        if (count == 1) { return; }
        var upper = [] as Array<Numeric>;
        for (var i = 0; i < count; i += 1) {
            _x.add(_rows[i][0]); _y.add(_rows[i][1]); upper.add(0.0);
        }
        // Interior interpolation: P[i-1] + 4 P[i] + P[i+1] = 6 D[i].
        // Fixed end controls plus linear ghost controls give zero end curvature.
        for (var k = 1; k < count - 1; k += 1) {
            var diagonal = 4.0 - upper[k - 1];
            upper[k] = 1.0 / diagonal;
            _x[k] = (6.0 * _rows[k][0] - _x[k - 1]) / diagonal;
            _y[k] = (6.0 * _rows[k][1] - _y[k - 1]) / diagonal;
        }
        for (var b = count - 2; b > 0; b -= 1) {
            _x[b] -= upper[b] * _x[b + 1]; _y[b] -= upper[b] * _y[b + 1];
        }
        for (var edge = 0; edge < count - 1; edge += 1) {
            var length = Math.sqrt(TrailTopology.distance(_rows[edge], _rows[edge + 1]));
            var steps = Math.ceil(length / 6.0).toNumber();
            if (steps < 3) { steps = 3; }
            if (steps > 8) { steps = 8; }
            for (var sample = 1; sample <= steps; sample += 1) {
                // Keep every measured knot and the current endpoint exact.
                points.add(sample == steps ? _rows[edge + 1] : at(edge, sample / steps.toFloat()));
            }
        }
    }
    private function control(values as Array<Numeric>, index as Number) as Numeric {
        if (index < 0) { return 2 * values[0] - values[1]; }
        if (index >= values.size()) { return 2 * values[values.size() - 1] - values[values.size() - 2]; }
        return values[index];
    }
    function at(edge as Number, t as Numeric) as Array<Numeric> {
        var t2 = t * t; var t3 = t2 * t; var u = 1 - t;
        var weights = [u * u * u / 6.0, (3 * t3 - 6 * t2 + 4) / 6.0,
            (-3 * t3 + 3 * t2 + 3 * t + 1) / 6.0, t3 / 6.0];
        var x = 0.0; var y = 0.0;
        for (var j = 0; j < 4; j += 1) {
            x += weights[j] * control(_x, edge + j - 1);
            y += weights[j] * control(_y, edge + j - 1);
        }
        return [x, y, _rows[edge][2] + (_rows[edge + 1][2] - _rows[edge][2]) * t];
    }
}
