using Toybox.Test;

function _fuelMeterAssertNear(actual, expected, epsilon, message) {
    Test.assertMessage((actual - expected) <= epsilon and (expected - actual) <= epsilon, message);
}

(:test)
function testFuelMeterUtilsResolveMeterState(logger) {
    Test.assertEqual(
        FuelMeterUtils.STATE_WARNING,
        FuelMeterUtils.resolveMeterState(FuelMeterUtils.DISPLAY_DUE, 0, 120)
    );
    Test.assertEqual(
        FuelMeterUtils.STATE_CAUTION,
        FuelMeterUtils.resolveMeterState(FuelMeterUtils.DISPLAY_COUNTDOWN, 120, 120)
    );
    Test.assertEqual(
        FuelMeterUtils.STATE_NORMAL,
        FuelMeterUtils.resolveMeterState(FuelMeterUtils.DISPLAY_COUNTDOWN, 121, 120)
    );
    Test.assertEqual(
        FuelMeterUtils.STATE_NORMAL,
        FuelMeterUtils.resolveMeterState(FuelMeterUtils.DISPLAY_DISABLED, null, 120)
    );
    return true;
}

(:test)
function testFuelMeterUtilsColorResolution(logger) {
    Test.assertEqual(111, FuelMeterUtils.resolveTrackColor(FuelMeterUtils.STATE_NORMAL, 111, 222, 333));
    Test.assertEqual(222, FuelMeterUtils.resolveTrackColor(FuelMeterUtils.STATE_CAUTION, 111, 222, 333));
    Test.assertEqual(333, FuelMeterUtils.resolveTrackColor(FuelMeterUtils.STATE_WARNING, 111, 222, 333));
    Test.assertEqual(444, FuelMeterUtils.resolveFillColor(FuelMeterUtils.STATE_NORMAL, 444, 555, 666));
    Test.assertEqual(555, FuelMeterUtils.resolveFillColor(FuelMeterUtils.STATE_CAUTION, 444, 555, 666));
    Test.assertEqual(666, FuelMeterUtils.resolveFillColor(FuelMeterUtils.STATE_WARNING, 444, 555, 666));
    return true;
}

(:test)
function testFuelMeterUtilsProgressAndRemainingMin(logger) {
    _fuelMeterAssertNear(
        FuelMeterUtils.resolveProgressRatio(FuelMeterUtils.DISPLAY_DISABLED, FuelMeterUtils.STATE_NORMAL, 10, 2100),
        0.0,
        0.0001,
        "disabled ratio"
    );
    _fuelMeterAssertNear(
        FuelMeterUtils.resolveProgressRatio(FuelMeterUtils.DISPLAY_DUE, FuelMeterUtils.STATE_WARNING, 0, 2100),
        1.0,
        0.0001,
        "due ratio"
    );
    _fuelMeterAssertNear(
        FuelMeterUtils.resolveProgressRatio(FuelMeterUtils.DISPLAY_COUNTDOWN, FuelMeterUtils.STATE_NORMAL, 1050, 2100),
        0.5,
        0.0001,
        "half ratio"
    );
    Test.assertEqual(2, FuelMeterUtils.resolveRemainingMin(61));
    Test.assertEqual(0, FuelMeterUtils.resolveRemainingMin(-1));
    Test.assertMessage(FuelMeterUtils.resolveRemainingMin(null) == null, "null remaining min");
    return true;
}

(:test)
function testFuelMeterUtilsTextResolution(logger) {
    Test.assertMessage(
        FuelMeterUtils.resolveCenterText(
            FuelMeterUtils.DISPLAY_DISABLED,
            FuelMeterUtils.STATE_NORMAL,
            null,
            "m",
            "Done",
            "NoPlan",
            "Warn"
        ) == null,
        "disabled center"
    );
    Test.assertEqual(
        "Done",
        FuelMeterUtils.resolveCenterText(
            FuelMeterUtils.DISPLAY_DONE_FLASH,
            FuelMeterUtils.STATE_NORMAL,
            null,
            "m",
            "Done",
            "NoPlan",
            "Warn"
        )
    );
    Test.assertEqual(
        "Warn",
        FuelMeterUtils.resolveCenterText(
            FuelMeterUtils.DISPLAY_DUE,
            FuelMeterUtils.STATE_WARNING,
            0,
            "m",
            "Done",
            "NoPlan",
            "Warn"
        )
    );
    Test.assertEqual(
        "2m",
        FuelMeterUtils.resolveCenterText(
            FuelMeterUtils.DISPLAY_COUNTDOWN,
            FuelMeterUtils.STATE_CAUTION,
            61,
            "m",
            "Done",
            "NoPlan",
            "Warn"
        )
    );
    Test.assertEqual(
        "sub",
        FuelMeterUtils.resolveWarningSubText(
            FuelMeterUtils.DISPLAY_DUE,
            FuelMeterUtils.STATE_WARNING,
            "sub"
        )
    );
    Test.assertMessage(
        FuelMeterUtils.resolveWarningSubText(
            FuelMeterUtils.DISPLAY_COUNTDOWN,
            FuelMeterUtils.STATE_CAUTION,
            "sub"
        ) == null,
        "warning sub only in due"
    );
    return true;
}
