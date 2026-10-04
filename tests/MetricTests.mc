import Toybox.Lang;
import Toybox.Test;

(:test)
function missingAndZero(logger as Test.Logger) as Boolean {
    Test.assertEqual(MetricFormat.distance(null, false), "--");
    Test.assertEqual(MetricFormat.distance(0, false), "0.0");
    Test.assertEqual(MetricFormat.percent(null), "--");
    Test.assertEqual(MetricFormat.percent(0), "0");
    Test.assertEqual(MetricFormat.recovery(null), "--");
    Test.assertEqual(MetricFormat.recovery(0), "0h");
    Test.assertEqual(MetricFormat.whole(-1), "--");
    return true;
}
(:test)
function unitsAndRounding(logger as Test.Logger) as Boolean {
    Test.assertEqual(MetricFormat.distance(24800.0, false), "24.8");
    Test.assertEqual(MetricFormat.distance(1609.344, true), "1.0");
    Test.assertEqual(MetricFormat.distance(99950.0, false), "100");
    Test.assertEqual(MetricFormat.distance(10000000.0, false), "9999+");
    Test.assertEqual(MetricFormat.steps(8200), "8.2k");
    Test.assertEqual(MetricFormat.steps(9995), "10k");
    Test.assertEqual(MetricFormat.steps(1000000), "999k+");
    return true;
}
(:test)
function recoveryUnits(logger as Test.Logger) as Boolean {
    Test.assertEqual(MetricFormat.recovery(59), "59m");
    Test.assertEqual(MetricFormat.recovery(60), "1h");
    Test.assertEqual(MetricFormat.recovery(61), "2h");
    Test.assertEqual(MetricFormat.recovery(1080), "18h");
    Test.assertEqual(MetricFormat.recovery(60000), "999h+");
    return true;
}
(:test)
function clockAndBounds(logger as Test.Logger) as Boolean {
    Test.assertEqual(MetricFormat.hour(0, false), "12");
    Test.assertEqual(MetricFormat.hour(12, false), "12");
    Test.assertEqual(MetricFormat.hour(23, false), "11");
    Test.assertEqual(MetricFormat.hour(0, true), "00");
    Test.assertEqual(MetricFormat.percent(101), "--");
    return true;
}
