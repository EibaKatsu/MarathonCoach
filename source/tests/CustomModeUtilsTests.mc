using Toybox.Test;

(:test)
function testCustomModeUtilsDecodeDefaultOnEmpty(logger) {
    var cfg = CustomModeUtils.decodeCustomCode(null);
    Test.assertEqual(CustomModeUtils.MODE_CORE, CustomModeUtils.getMode(cfg));
    Test.assertEqual(false, CustomModeUtils.isCodeValid(cfg));
    Test.assertEqual(CustomModeUtils.FUEL_MODE_TIME, CustomModeUtils.getFuelMode(cfg));
    Test.assertEqual(CustomModeUtils.DEFAULT_FUEL_INTERVAL_MIN, CustomModeUtils.getFuelIntervalMin(cfg));
    return true;
}

(:test)
function testCustomModeUtilsEncodeDecodeRoundTrip(logger) {
    var code = CustomModeUtils.encodeCustomCode(
        CustomModeUtils.FUEL_MODE_TIME,
        18,
        27,
        3,
        14,
        -3,
        6
    );
    Test.assertMessage(code != null, "code should be generated");

    var cfg = CustomModeUtils.decodeCustomCode(code);
    Test.assertEqual(true, CustomModeUtils.isCustomMode(cfg));
    Test.assertEqual(true, CustomModeUtils.isCodeValid(cfg));
    Test.assertEqual(CustomModeUtils.FUEL_MODE_TIME, CustomModeUtils.getFuelMode(cfg));
    Test.assertEqual(18, CustomModeUtils.getFirstFuelAfterMin(cfg));
    Test.assertEqual(27, CustomModeUtils.getFuelIntervalMin(cfg));
    Test.assertEqual(3, CustomModeUtils.getFuelAlertLeadMin(cfg));
    Test.assertEqual(14, CustomModeUtils.getPhaseAggressiveness(cfg));
    Test.assertEqual(-3, CustomModeUtils.getHrCapBiasBpm(cfg));
    Test.assertEqual(6, CustomModeUtils.getDriftSensitivity(cfg));
    return true;
}

(:test)
function testCustomModeUtilsDecodeRejectsBrokenChecksum(logger) {
    var validCode = CustomModeUtils.encodeCustomCode(
        CustomModeUtils.FUEL_MODE_OFF,
        20,
        35,
        2,
        10,
        0,
        3
    );
    Test.assertMessage(validCode != null, "valid code should be generated");

    var brokenCode = validCode.substring(0, validCode.length() - 1) + "Z";
    var cfg = CustomModeUtils.decodeCustomCode(brokenCode);
    Test.assertEqual(false, CustomModeUtils.isCustomMode(cfg));
    Test.assertEqual(false, CustomModeUtils.isCodeValid(cfg));
    Test.assertEqual(CustomModeUtils.DEFAULT_PHASE_AGGRESSIVENESS, CustomModeUtils.getPhaseAggressiveness(cfg));
    return true;
}
