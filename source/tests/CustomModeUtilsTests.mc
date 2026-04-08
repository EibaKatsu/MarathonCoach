using Toybox.Test;

(:test)
function testCustomModeUtilsDecodeDefaultOnEmpty(logger) {
    var cfg = CustomModeUtils.decodeCustomCode(null);
    Test.assertEqual(CustomModeUtils.MODE_CORE, CustomModeUtils.getMode(cfg));
    Test.assertEqual(false, CustomModeUtils.isCodeValid(cfg));
    Test.assertEqual(false, CustomModeUtils.isCustomCode(cfg));
    Test.assertMessage(CustomModeUtils.getDirectCapS1(cfg) == null, "direct cap should default to null");
    return true;
}

(:test)
function testCustomModeUtilsEncodeDecodeRoundTrip(logger) {
    var code = CustomModeUtils.encodeCustomCode(
        158,
        162,
        166,
        170,
        174
    );
    Test.assertMessage(code != null, "code should be generated");

    var cfg = CustomModeUtils.decodeCustomCode(code);
    Test.assertEqual(true, CustomModeUtils.isCustomMode(cfg));
    Test.assertEqual(true, CustomModeUtils.isCustomCode(cfg));
    Test.assertEqual(true, CustomModeUtils.isCodeValid(cfg));
    Test.assertMessage(CustomModeUtils.getDirectCapS1(cfg) == 158, "S1 cap should round-trip");
    Test.assertMessage(CustomModeUtils.getDirectCapS2(cfg) == 162, "S2 cap should round-trip");
    Test.assertMessage(CustomModeUtils.getDirectCapS3(cfg) == 166, "S3 cap should round-trip");
    Test.assertMessage(CustomModeUtils.getDirectCapS4(cfg) == 170, "S4 cap should round-trip");
    Test.assertMessage(CustomModeUtils.getDirectCapS5(cfg) == 174, "S5 cap should round-trip");
    Test.assertMessage(CustomModeUtils.getDirectCapHeartRate(cfg, 3) == 170, "phase lookup should use S4");
    return true;
}

(:test)
function testCustomModeUtilsDecodeRejectsBrokenChecksum(logger) {
    var validCode = CustomModeUtils.encodeCustomCode(
        150,
        151,
        152,
        153,
        154
    );
    Test.assertMessage(validCode != null, "valid code should be generated");

    var brokenCode = validCode.substring(0, validCode.length() - 1) + "Z";
    var cfg = CustomModeUtils.decodeCustomCode(brokenCode);
    Test.assertEqual(false, CustomModeUtils.isCustomMode(cfg));
    Test.assertEqual(false, CustomModeUtils.isCodeValid(cfg));
    Test.assertMessage(CustomModeUtils.getDirectCapS1(cfg) == null, "broken code should clear direct caps");
    return true;
}
