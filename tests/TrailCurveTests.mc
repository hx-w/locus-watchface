import Toybox.Lang;
import Toybox.Test;

(:test)
function splineInterpolatesMeasurementsAndActivityGap(logger as Test.Logger) as Boolean {
    var rows = [[0,0,100],[10,10,105],[20,0,200]] as Array<Array<Numeric>>;
    var curve = new TrailCurve(rows);
    // Independent natural-cubic oracle: y(u) = 15u - 5u^3 on the first span.
    Test.assert((curve.at(0, 0.5)[0] - 5).abs() < 0.0001);
    Test.assert((curve.at(0, 0.5)[1] - 6.875).abs() < 0.0001);
    for (var edge = 0; edge < 2; edge += 1) {
        for (var end = 0; end <= 1; end += 1) {
            var point = curve.at(edge, end);
            Test.assert((point[0] - rows[edge + end][0]).abs() < 0.0001);
            Test.assert((point[1] - rows[edge + end][1]).abs() < 0.0001);
            Test.assertEqual(point[2], rows[edge + end][2]);
        }
    }
    var last = curve.points[curve.points.size() - 1];
    Test.assertEqual(last[0], 20); Test.assertEqual(last[1], 0); Test.assertEqual(last[2], 200);
    var before = curve.at(0, 0.999); var after = curve.at(1, 0.001);
    Test.assert(((10 - before[0]) - (after[0] - 10)).abs() < 0.0001);
    Test.assert(((10 - before[1]) - (after[1] - 10)).abs() < 0.0001);
    Test.assertEqual(rows.size(), 3); Test.assertEqual(rows[1][2], 105);
    return true;
}

(:test)
function splineEmptyStationaryAndBoundedGeometry(logger as Test.Logger) as Boolean {
    Test.assertEqual(new TrailCurve([]).points.size(), 0);
    var stationary = new TrailCurve([[2,2,100],[2,2,105],[2,2,200]]);
    Test.assertEqual(stationary.points.size(), 1);
    Test.assertEqual(stationary.points[0][2], 200);
    var pair = new TrailCurve([[0,0,100],[100,100,240]]);
    Test.assert((pair.at(0, 0.5)[0] - 50).abs() < 0.0001);
    Test.assert((pair.at(0, 0.5)[1] - 50).abs() < 0.0001);
    var rows = [] as Array<Array<Numeric>>;
    for (var i = 0; i < 74; i += 1) { rows.add([i % 2 == 0 ? 0 : 264, i % 3 == 0 ? 0 : 147, 640 + 5 * i]); }
    var dense = new TrailCurve(rows);
    Test.assert(dense.points.size() > rows.size());
    Test.assert(dense.points.size() <= 1 + 8 * (rows.size() - 1));
    Test.assertEqual(dense.points[dense.points.size() - 1][2], rows[rows.size() - 1][2]);
    return true;
}
