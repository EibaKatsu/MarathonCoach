using Toybox.System as Sys;
using Toybox.Test;

(:test)
function testCoachMessageUtilsResolveLanguage(logger) {
    Test.assertEqual("en", CoachMessageUtils.resolveLanguage(Sys.LANGUAGE_ENG));
    Test.assertEqual("ja", CoachMessageUtils.resolveLanguage(Sys.LANGUAGE_JPN));
    Test.assertEqual("ja", CoachMessageUtils.resolveLanguage(Sys.LANGUAGE_FRE));
    return true;
}

(:test)
function testCoachMessageUtilsCategoriesContainMessageInGarminSet(logger) {
    var categories = CoachMessageUtils.categories();

    Test.assertEqual(CoachMessageUtils.CATEGORY_FIXED, categories[0]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_FUNNY, categories[1]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_SALT, categories[2]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_ALCOHOL, categories[3]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_TOXIC, categories[4]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_PRAISE, categories[5]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_DIST, categories[6]);
    return true;
}

(:test)
function testCoachMessageUtilsFuelPoolsExistForEachCategory(logger) {
    var categories = CoachMessageUtils.categories();
    for (var i = 0; i < categories.size(); i += 1) {
        var category = categories[i];
        if (category.equals(CoachMessageUtils.CATEGORY_DIST)) {
            continue;
        }

        Test.assertMessage(
            CoachMessageUtils.getMessagePool("ja", category, CoachMessageUtils.FUEL_STATE_PREP, "FL_HOLD").size() > 0,
            "ja fuelPrep should exist for " + category
        );
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("ja", category, CoachMessageUtils.FUEL_STATE_NOW, "FL_HOLD").size() > 0,
            "ja fuelNow should exist for " + category
        );
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("en", category, CoachMessageUtils.FUEL_STATE_PREP, "FL_HOLD").size() > 0,
            "en fuelPrep should exist for " + category
        );
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("en", category, CoachMessageUtils.FUEL_STATE_NOW, "FL_HOLD").size() > 0,
            "en fuelNow should exist for " + category
        );
    }
    return true;
}

(:test)
function testCoachMessageUtilsNormalPoolUsesSlopeAndActionKey(logger) {
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "UP_PUSH").size() > 0,
        "ja UP_PUSH should exist"
    );
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("en", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "DN_EASE").size() > 0,
        "en DN_EASE should exist"
    );
    return true;
}
