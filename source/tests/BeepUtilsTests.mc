using Toybox.Test;

(:test)
function testBeepUtilsSelectHigherPriorityEvent(logger) {
    Test.assertEqual(
        BeepUtils.EVENT_HR_OVER,
        BeepUtils.selectHigherPriorityEvent(BeepUtils.EVENT_NONE, BeepUtils.EVENT_HR_OVER)
    );
    Test.assertEqual(
        BeepUtils.EVENT_NONE,
        BeepUtils.selectHigherPriorityEvent(BeepUtils.EVENT_NONE, BeepUtils.EVENT_NONE)
    );
    return true;
}

(:test)
function testBeepUtilsResolveEventPriority(logger) {
    Test.assertEqual(500, BeepUtils.resolveEventPriority(BeepUtils.EVENT_HR_OVER));
    Test.assertEqual(0, BeepUtils.resolveEventPriority(BeepUtils.EVENT_NONE));
    return true;
}

(:test)
function testBeepUtilsResolveBeepLevel(logger) {
    Test.assertEqual(BeepUtils.LEVEL_CAUTION, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_HR_OVER));
    Test.assertEqual(0, BeepUtils.resolveBeepLevel(BeepUtils.EVENT_NONE));
    return true;
}
