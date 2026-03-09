using Toybox.Test;

class MarathonCoachFieldUtilsHarness extends MarathonCoachField {
    function initialize() {
        MarathonCoachField.initialize();
    }
}

function _newUtilsSut() {
    return new MarathonCoachFieldUtilsHarness();
}

function _assertFloatNear(sut, actual, expected, epsilon, message) {
    if (actual == null or expected == null) {
        Test.assertMessage(actual == expected, message);
        return;
    }
    Test.assertMessage(sut._abs(actual - expected) <= epsilon, message);
}

(:test)
function testFormatHourMinuteSecond_basic(logger) {
    var sut = _newUtilsSut();
    Test.assertEqual("05:07:00", sut._formatHourMinuteSecond(5, 7));
    return true;
}

(:test)
function testMapRaceDistanceIndexToKm_knownValues(logger) {
    var sut = _newUtilsSut();
    _assertFloatNear(sut, sut._mapRaceDistanceIndexToKm(0), 42.195, 0.0001, "index 0 should be full marathon");
    _assertFloatNear(sut, sut._mapRaceDistanceIndexToKm(1), 21.0975, 0.0001, "index 1 should be half marathon");
    _assertFloatNear(sut, sut._mapRaceDistanceIndexToKm(2), 10.0, 0.0001, "index 2 should be 10km");
    _assertFloatNear(sut, sut._mapRaceDistanceIndexToKm(3), 5.0, 0.0001, "index 3 should be 5km");
    Test.assertMessage(sut._mapRaceDistanceIndexToKm(4) == null, "unknown index should map to null");
    return true;
}

(:test)
function testContainsNonAscii(logger) {
    var sut = _newUtilsSut();
    Test.assertEqual(false, sut._containsNonAscii(null));
    Test.assertEqual(false, sut._containsNonAscii("abc123"));
    Test.assertEqual(true, sut._containsNonAscii("ペース"));
    return true;
}

(:test)
function testSplitWords_collapsesSpaces(logger) {
    var sut = _newUtilsSut();
    var words = sut._splitWords("  Hold   pace   now  ");
    Test.assertEqual(3, words.size());
    Test.assertEqual("Hold", words[0]);
    Test.assertEqual("pace", words[1]);
    Test.assertEqual("now", words[2]);
    return true;
}

(:test)
function testRandomMessageIndex_constraints(logger) {
    var sut = _newUtilsSut();
    Test.assertEqual(0, sut._randomMessageIndex(0, -1, -1));
    Test.assertEqual(0, sut._randomMessageIndex(1, 0, 0));

    for (var i = 0; i < 30; i += 1) {
        var idx = sut._randomMessageIndex(5, 1, 2);
        Test.assertMessage(idx >= 0 and idx < 5, "index should stay in range");
        Test.assertMessage(idx != 1 and idx != 2, "index should avoid blocked values");
    }
    return true;
}

(:test)
function testParsePositiveInt(logger) {
    var sut = _newUtilsSut();
    _assertFloatNear(sut, sut._parsePositiveInt("123"), 123, 0.0001, "ascii int parse");
    _assertFloatNear(sut, sut._parsePositiveInt("  １２３  "), 123, 0.0001, "full width int parse");
    Test.assertMessage(sut._parsePositiveInt("12a") == null, "non-digit should fail");
    Test.assertMessage(sut._parsePositiveInt("") == null, "empty string should fail");
    return true;
}

(:test)
function testParsePositiveDecimal(logger) {
    var sut = _newUtilsSut();
    _assertFloatNear(sut, sut._parsePositiveDecimal("12.34"), 12.34, 0.0001, "ascii decimal parse");
    _assertFloatNear(sut, sut._parsePositiveDecimal("１２．５"), 12.5, 0.0001, "full width decimal parse");
    Test.assertMessage(sut._parsePositiveDecimal("12..3") == null, "double dot should fail");
    Test.assertMessage(sut._parsePositiveDecimal("abc") == null, "non-digit decimal should fail");
    return true;
}

(:test)
function testParseTimeToSec(logger) {
    var sut = _newUtilsSut();
    _assertFloatNear(sut, sut._parseTimeToSec("1:02:03"), 3723, 0.0001, "hh:mm:ss parse");
    _assertFloatNear(sut, sut._parseTimeToSec("1:02"), 3720, 0.0001, "hh:mm parse");
    _assertFloatNear(sut, sut._parseTimeToSec(" １：０２ "), 3720, 0.0001, "full width colon parse");
    Test.assertMessage(sut._parseTimeToSec("1:60:00") == null, "invalid minute should fail");
    Test.assertMessage(sut._parseTimeToSec("abc") == null, "non-time text should fail");
    return true;
}

(:test)
function testFormatPaceAndTime(logger) {
    var sut = _newUtilsSut();
    Test.assertEqual("5:00", sut._formatPaceSecPerKm(299.6));
    Test.assertEqual("2:10", sut._formatMinSec(129.7));
    Test.assertEqual("0:00:00", sut._formatElapsedTime(-5));
    Test.assertEqual("1:01:01", sut._formatElapsedTime(3661));
    return true;
}

(:test)
function testFormatDistanceAndHourMin(logger) {
    var sut = _newUtilsSut();
    Test.assertEqual("12.3 km", sut._formatDistanceKm(12.25));
    Test.assertEqual("0.0 km", sut._formatDistanceKm(-1));
    Test.assertEqual("--:--", sut._formatHourMin(null));
    Test.assertEqual("1:00", sut._formatHourMin(3590));
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
