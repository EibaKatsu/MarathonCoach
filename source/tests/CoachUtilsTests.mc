using Toybox.Test;

class MarathonCoachFieldUtilsHarness extends MarathonCoachField {
    function initialize() {
        MarathonCoachField.initialize();
    }
}

function _newUtilsSut() {
    return new MarathonCoachFieldUtilsHarness();
}

function _assertFloatNear(actual, expected, epsilon, message) {
    if (actual == null or expected == null) {
        Test.assertMessage(actual == expected, message);
        return;
    }
    Test.assertMessage(_testAbsUtils(actual - expected) <= epsilon, message);
}

function _testAbsUtils(value) {
    if (value < 0) {
        return -value;
    }
    return value;
}

(:test)
function testFormatHourMinuteSecond_basic(logger) {
    Test.assertEqual("05:07:00", CoachUtils.formatHourMinuteSecond(5, 7));
    return true;
}

(:test)
function testMapRaceDistanceIndexToKm_knownValues(logger) {
    _assertFloatNear(CoachUtils.mapRaceDistanceIndexToKm(0), 42.195, 0.0001, "index 0 should be full marathon");
    _assertFloatNear(CoachUtils.mapRaceDistanceIndexToKm(1), 21.0975, 0.0001, "index 1 should be half marathon");
    _assertFloatNear(CoachUtils.mapRaceDistanceIndexToKm(2), 10.0, 0.0001, "index 2 should be 10km");
    _assertFloatNear(CoachUtils.mapRaceDistanceIndexToKm(3), 5.0, 0.0001, "index 3 should be 5km");
    Test.assertMessage(CoachUtils.mapRaceDistanceIndexToKm(4) == null, "unknown index should map to null");
    return true;
}

(:test)
function testContainsNonAscii(logger) {
    Test.assertEqual(false, CoachUtils.containsNonAscii(null));
    Test.assertEqual(false, CoachUtils.containsNonAscii("abc123"));
    Test.assertEqual(true, CoachUtils.containsNonAscii("ペース"));
    return true;
}

(:test)
function testSplitWords_collapsesSpaces(logger) {
    var words = CoachUtils.splitWords("  Hold   pace   now  ");
    Test.assertEqual(3, words.size());
    Test.assertEqual("Hold", words[0]);
    Test.assertEqual("pace", words[1]);
    Test.assertEqual("now", words[2]);
    return true;
}

(:test)
function testRandomMessageIndex_constraints(logger) {
    Test.assertEqual(0, CoachUtils.randomMessageIndex(0, -1, -1));
    Test.assertEqual(0, CoachUtils.randomMessageIndex(1, 0, 0));

    for (var i = 0; i < 30; i += 1) {
        var idx = CoachUtils.randomMessageIndex(5, 1, 2);
        Test.assertMessage(idx >= 0 and idx < 5, "index should stay in range");
        Test.assertMessage(idx != 1 and idx != 2, "index should avoid blocked values");
    }
    return true;
}

(:test)
function testParsePositiveInt(logger) {
    _assertFloatNear(CoachUtils.parsePositiveInt("123"), 123, 0.0001, "ascii int parse");
    _assertFloatNear(CoachUtils.parsePositiveInt("  １２３  "), 123, 0.0001, "full width int parse");
    Test.assertMessage(CoachUtils.parsePositiveInt("12a") == null, "non-digit should fail");
    Test.assertMessage(CoachUtils.parsePositiveInt("") == null, "empty string should fail");
    return true;
}

(:test)
function testParsePositiveDecimal(logger) {
    _assertFloatNear(CoachUtils.parsePositiveDecimal("12.34"), 12.34, 0.0001, "ascii decimal parse");
    _assertFloatNear(CoachUtils.parsePositiveDecimal("１２．５"), 12.5, 0.0001, "full width decimal parse");
    Test.assertMessage(CoachUtils.parsePositiveDecimal("12..3") == null, "double dot should fail");
    Test.assertMessage(CoachUtils.parsePositiveDecimal("abc") == null, "non-digit decimal should fail");
    return true;
}

(:test)
function testParseTimeToSec(logger) {
    _assertFloatNear(CoachUtils.parseTimeToSec("1:02:03"), 3723, 0.0001, "hh:mm:ss parse");
    _assertFloatNear(CoachUtils.parseTimeToSec("1:02"), 3720, 0.0001, "hh:mm parse");
    _assertFloatNear(CoachUtils.parseTimeToSec(" １：０２ "), 3720, 0.0001, "full width colon parse");
    Test.assertMessage(CoachUtils.parseTimeToSec("1:60:00") == null, "invalid minute should fail");
    Test.assertMessage(CoachUtils.parseTimeToSec("abc") == null, "non-time text should fail");
    return true;
}

(:test)
function testFormatPaceAndTime(logger) {
    Test.assertEqual("5:00", CoachUtils.formatPaceSecPerKm(299.6));
    Test.assertEqual("2:10", CoachUtils.formatMinSec(129.7));
    Test.assertEqual("0:00:00", CoachUtils.formatElapsedTime(-5));
    Test.assertEqual("1:01:01", CoachUtils.formatElapsedTime(3661));
    return true;
}

(:test)
function testFormatDistanceAndHourMin(logger) {
    Test.assertEqual("12.3 km", CoachUtils.formatDistanceKm(12.25));
    Test.assertEqual("0.0 km", CoachUtils.formatDistanceKm(-1));
    Test.assertEqual("--:--", CoachUtils.formatHourMin(null));
    Test.assertEqual("1:00", CoachUtils.formatHourMin(3590));
    return true;
}

(:test)
function testMathHelpers(logger) {
    var sut = _newUtilsSut();
    Test.assertEqual(2, sut._min(2, 3));
    Test.assertEqual(3, sut._max(2, 3));
    Test.assertEqual(5, sut._clamp(10, 0, 5));
    Test.assertEqual(0, sut._clamp(-2, 0, 5));
    Test.assertEqual(3, sut._clamp(3, 0, 5));
    Test.assertEqual(4, sut._abs(-4));
    return true;
}
