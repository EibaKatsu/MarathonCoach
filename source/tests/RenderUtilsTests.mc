using Toybox.Graphics as Gfx;
using Toybox.Test;

const RU_VARIANT_WARMUP = 0;
const RU_VARIANT_ACTION_PUSH = 1;
const RU_VARIANT_ACTION_HOLD = 2;
const RU_VARIANT_ACTION_EASE = 3;
const RU_VARIANT_FUEL_SOON = 4;
const RU_VARIANT_FUEL_NOW = 5;
const RU_VARIANT_RECOVERY = 6;
const RU_VARIANT_HR_WARNING = 7;

function _ruAssertNear(actual, expected, epsilon, message) {
    Test.assertMessage((actual - expected) <= epsilon and (expected - actual) <= epsilon, message);
}

(:test)
function testRenderUtilsGetSizeClass(logger) {
    Test.assertEqual(2, RenderUtils.getSizeClass(261, 261, 218));
    Test.assertEqual(1, RenderUtils.getSizeClass(260, 261, 218));
    Test.assertEqual(0, RenderUtils.getSizeClass(218, 261, 218));
    return true;
}

(:test)
function testRenderUtilsCardBitmapSelection(logger) {
    var bgWarmup = "w";
    var bgPush = "p";
    var bgHold = "h";
    var bgSoon = "s";
    var bgNow = "n";
    var bgHr = "r";

    Test.assertEqual(
        bgWarmup,
        RenderUtils.getCardBgBitmapSmall(
            RU_VARIANT_WARMUP,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_HOLD,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING,
            bgWarmup,
            bgPush,
            bgHold,
            bgSoon,
            bgNow,
            bgHr
        )
    );
    Test.assertEqual(
        bgSoon,
        RenderUtils.getCardBgBitmapSmall(
            RU_VARIANT_RECOVERY,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_HOLD,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING,
            bgWarmup,
            bgPush,
            bgHold,
            bgSoon,
            bgNow,
            bgHr
        )
    );
    Test.assertEqual(
        bgHold,
        RenderUtils.getCardBgBitmapSmall(
            999,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_HOLD,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING,
            bgWarmup,
            bgPush,
            bgHold,
            bgSoon,
            bgNow,
            bgHr
        )
    );
    return true;
}

(:test)
function testRenderUtilsCardColorPalette(logger) {
    Test.assertEqual(
        0x56728F,
        RenderUtils.getCardBorderColor(
            RU_VARIANT_WARMUP,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING
        )
    );
    Test.assertEqual(
        0x883744,
        RenderUtils.getCardGradientTopColor(
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING
        )
    );
    Test.assertEqual(
        0x22415F,
        RenderUtils.getCardGradientMidColor(
            999,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING
        )
    );
    Test.assertEqual(
        0x401B18,
        RenderUtils.getCardGradientBottomColor(
            RU_VARIANT_HR_WARNING,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING
        )
    );
    Test.assertEqual(
        0x79AAB9,
        RenderUtils.getCardSheenColor(
            RU_VARIANT_RECOVERY,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING
        )
    );
    Test.assertEqual(
        0xD7AA76,
        RenderUtils.getCardTopBandColor(
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING
        )
    );
    Test.assertEqual(
        0xFFB99B,
        RenderUtils.getCardAccentColor(
            RU_VARIANT_HR_WARNING,
            RU_VARIANT_WARMUP,
            RU_VARIANT_ACTION_PUSH,
            RU_VARIANT_ACTION_EASE,
            RU_VARIANT_FUEL_SOON,
            RU_VARIANT_FUEL_NOW,
            RU_VARIANT_RECOVERY,
            RU_VARIANT_HR_WARNING
        )
    );
    Test.assertEqual(Gfx.COLOR_WHITE, RenderUtils.getCardTextColor(RU_VARIANT_ACTION_PUSH));
    return true;
}

(:test)
function testRenderUtilsCardFontRules(logger) {
    Test.assertEqual(Gfx.FONT_SMALL, RenderUtils.resolveCardFont(0, 1));
    Test.assertEqual(Gfx.FONT_TINY, RenderUtils.resolveCardFont(0, 2));
    Test.assertEqual(Gfx.FONT_XTINY, RenderUtils.resolveCardFont(0, 3));
    Test.assertEqual(Gfx.FONT_SMALL, RenderUtils.resolveCardFont(2, 2));
    Test.assertEqual(Gfx.FONT_TINY, RenderUtils.resolveCardFont(2, 3));
    Test.assertEqual(Gfx.FONT_SMALL, RenderUtils.resolveCardFont(1, 1));
    Test.assertEqual(Gfx.FONT_TINY, RenderUtils.resolveCardFont(1, 3));

    Test.assertEqual(Gfx.FONT_SMALL, RenderUtils.shrinkCardFont(Gfx.FONT_MEDIUM));
    Test.assertEqual(Gfx.FONT_TINY, RenderUtils.shrinkCardFont(Gfx.FONT_SMALL));
    Test.assertEqual(Gfx.FONT_XTINY, RenderUtils.shrinkCardFont(Gfx.FONT_TINY));
    return true;
}

(:test)
function testRenderUtilsAdjustSingleLineFont(logger) {
    var oneAscii = ["abcdefg"]; // 7 chars => shrink
    var oneCjk = ["補給now"]; // contains non-ascii and >= 4 chars => shrink
    var shortAscii = ["abc"];

    Test.assertEqual(
        Gfx.FONT_TINY,
        RenderUtils.adjustCardFontForSingleLineLimit(Gfx.FONT_SMALL, 1, oneAscii)
    );
    Test.assertEqual(
        Gfx.FONT_TINY,
        RenderUtils.adjustCardFontForSingleLineLimit(Gfx.FONT_SMALL, 1, oneCjk)
    );
    Test.assertEqual(
        Gfx.FONT_SMALL,
        RenderUtils.adjustCardFontForSingleLineLimit(Gfx.FONT_SMALL, 1, shortAscii)
    );
    Test.assertEqual(
        Gfx.FONT_SMALL,
        RenderUtils.adjustCardFontForSingleLineLimit(Gfx.FONT_SMALL, 2, oneAscii)
    );
    return true;
}

(:test)
function testRenderUtilsLineGapAndHeartRateHelpers(logger) {
    Test.assertEqual(0, RenderUtils.resolveCardLineGap(1, 12, 100));
    _ruAssertNear(RenderUtils.resolveCardLineGap(2, 12, 100), 4, 0.001, "gap for 2 lines");
    _ruAssertNear(RenderUtils.resolveCardLineGap(3, 12, 40), 2, 0.001, "gap for 3 lines");

    Test.assertEqual(11, RenderUtils.getHeartRateZoneGaugeColor(1, 11, 22, 33, 44, 55));
    Test.assertEqual(44, RenderUtils.getHeartRateZoneGaugeColor(4, 11, 22, 33, 44, 55));
    Test.assertEqual(55, RenderUtils.getHeartRateZoneGaugeColor(9, 11, 22, 33, 44, 55));

    _ruAssertNear(RenderUtils.resolveHeartRateGaugeRatioFallback(null, 80, 200), 0.5, 0.0001, "null hr");
    _ruAssertNear(RenderUtils.resolveHeartRateGaugeRatioFallback(60, 80, 200), 0.0, 0.0001, "low clamp");
    _ruAssertNear(RenderUtils.resolveHeartRateGaugeRatioFallback(200, 80, 200), 1.0, 0.0001, "upper bound");
    _ruAssertNear(RenderUtils.resolveHeartRateGaugeRatioFallback(140, 80, 200), 0.5, 0.0001, "mid ratio");
    return true;
}
