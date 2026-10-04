import Toybox.Activity;
import Toybox.Complications;
import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:test)
function monthlySportAndCalendar(logger as Test.Logger) as Boolean {
    var now = Time.today().add(new Time.Duration(43200));
    var totals = new MonthlyDistances(now);
    totals.add(now, Activity.SPORT_RUNNING, 5000);
    totals.add(now, Activity.SPORT_CYCLING, 25000);
    totals.add(now, Activity.SPORT_RUNNING, 1200.5);
    totals.add(now, Activity.SPORT_WALKING, 9000);
    totals.add(now.subtract(new Time.Duration(35 * 86400)) as Time.Moment, Activity.SPORT_RUNNING, 100000);
    totals.add(now.add(new Time.Duration(86400)), Activity.SPORT_CYCLING, 100000);
    Test.assertEqual(totals.run as Numeric, 6200.5);
    Test.assertEqual(totals.bike as Numeric, 25000.0);
    // Empty month is a real zero; an invalid matching distance is unavailable.
    var empty = new MonthlyDistances(now);
    Test.assertEqual(empty.run as Numeric, 0.0); Test.assertEqual(empty.bike as Numeric, 0.0);
    totals.add(now, Activity.SPORT_RUNNING, null);
    totals.add(now, Activity.SPORT_RUNNING, 500);
    Test.assert(totals.run == null); Test.assertEqual(totals.bike as Numeric, 25000.0);
    totals.add(now, Activity.SPORT_CYCLING, -1);
    Test.assert(totals.bike == null);
    Test.assertEqual(Fields.type(4), Complications.COMPLICATION_TYPE_INVALID);
    Test.assertEqual(Fields.type(5), Complications.COMPLICATION_TYPE_INVALID);
    Test.assertEqual(Fields.type(6), Complications.COMPLICATION_TYPE_STEPS);
    return true;
}

(:test)
function monthlyLocalBoundary(logger as Test.Logger) as Boolean {
    var now = Time.now();
    var date = Gregorian.info(now, Time.FORMAT_SHORT);
    // Convert the first local day to epoch time using the current local offset.
    var utc = Gregorian.moment({:year => date.year, :month => (date.month as Number), :day => date.day,
        :hour => date.hour, :minute => date.min, :second => date.sec});
    var first = Gregorian.moment({:year => date.year, :month => (date.month as Number), :day => 1,
        :hour => 0, :minute => 0, :second => 0}).subtract(new Time.Duration(utc.value() - now.value())) as Time.Moment;
    var totals = new MonthlyDistances(first.add(new Time.Duration(1)));
    totals.add(first.subtract(new Time.Duration(1)) as Time.Moment, Activity.SPORT_RUNNING, 9000);
    totals.add(first, Activity.SPORT_RUNNING, 1000);
    Test.assertEqual(totals.run as Numeric, 1000.0);
    Test.assertEqual(MonthlyActivity.monthKey(now), date.year * 100 + (date.month as Number));
    return true;
}
