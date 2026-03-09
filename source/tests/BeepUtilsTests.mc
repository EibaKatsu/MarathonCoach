using Toybox.Test;

(:test)
function testBeepUtilsSelectHigherPriorityEvent(logger) {
    Test.assertEqual(
        BeepUtils.EVENT_FUEL_NOW,
        BeepUtils.selectHigherPriorityEvent(BeepUtils.EVENT_HR_OVER, BeepUtils.EVENT_FUEL_NOW)
    );
    Test.assertEqual(
        BeepUtils.EVENT_HR_OVER,
        BeepUtils.selectHigherPriorityEvent(BeepUtils.EVENT_HR_OVER, BeepUtils.EVENT_DISTANCE_SPLIT)
    );
    Test.assertEqual(
        BeepUtils.EVENT_NONE,
        BeepUtils.selectHigherPriorityEvent(BeepUtils.EVENT_NONE, BeepUtils.EVENT_NONE)
    );
    return true;
}

(:test)
function testBeepUtilsResolveEventPriority(logger) {
    Test.assertEqual(600, BeepUtils.resolveEventPriority(BeepUtils.EVENT_FUEL_NOW));
    Test.assertEqual(500, BeepUtils.resolveEventPriority(BeepUtils.EVENT_HR_OVER));
    Test.assertEqual(400, BeepUtils.resolveEventPriority(BeepUtils.EVENT_DRIFT_ON));
    Test.assertEqual(350, BeepUtils.resolveEventPriority(BeepUtils.EVENT_FUEL_SOON));
    Test.assertEqual(300, BeepUtils.resolveEventPriority(BeepUtils.EVENT_DISTANCE_MILESTONE));
    Test.assertEqual(200, BeepUtils.resolveEventPriority(BeepUtils.EVENT_DISTANCE_SPLIT));
    Test.assertEqual(0, BeepUtils.resolveEventPriority(BeepUtils.EVENT_NONE));
    return true;
}

(:test)
function testBeepUtilsResolveBeepLevel(logger) {
    Test.assertEqual(BeepUtils.LEVEL_INFO, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_DISTANCE_SPLIT));
    Test.assertEqual(BeepUtils.LEVEL_CAUTION, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_DISTANCE_MILESTONE));
    Test.assertEqual(BeepUtils.LEVEL_CAUTION, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_FUEL_SOON));
    Test.assertEqual(BeepUtils.LEVEL_CAUTION, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_HR_OVER));
    Test.assertEqual(BeepUtils.LEVEL_CAUTION, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_DRIFT_ON));
    Test.assertEqual(BeepUtils.LEVEL_URGENT, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_FUEL_NOW));
    Test.assertEqual(0, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_NONE));
    return true;
}
