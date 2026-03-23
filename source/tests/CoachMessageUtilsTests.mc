using Toybox.System as Sys;
using Toybox.Test;

(:test)
function testCoachMessageUtilsResolveLanguage(logger) {
    Test.assertEqual("en", CoachMessageUtils.resolveLanguage(Sys.LANGUAGE_ENG));
    Test.assertEqual("ja", CoachMessageUtils.resolveLanguage(Sys.LANGUAGE_JPN));
    Test.assertEqual("en", CoachMessageUtils.resolveLanguage(Sys.LANGUAGE_FRE));
    Test.assertEqual("en", CoachMessageUtils.resolveLanguage(null));
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
function testCoachMessageUtilsDisplayCategoriesExcludeDist(logger) {
    var categories = CoachMessageUtils.displayCategories();

    Test.assertEqual(6, categories.size());
    Test.assertEqual(CoachMessageUtils.CATEGORY_FIXED, categories[0]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_FUNNY, categories[1]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_SALT, categories[2]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_ALCOHOL, categories[3]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_TOXIC, categories[4]);
    Test.assertEqual(CoachMessageUtils.CATEGORY_PRAISE, categories[5]);
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
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "FL_EASE_PACE").size() > 0,
        "ja FL_EASE_PACE should exist"
    );
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("en", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "FL_EASE_BOTH").size() > 0,
        "en FL_EASE_BOTH should exist"
    );
    return true;
}

(:test)
function testCoachMessageUtilsFixedPoolsHaveTenVariants(logger) {
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "FL_PUSH").size() == 10,
        "ja fixed FL_PUSH should have 10"
    );
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("en", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "FL_HOLD").size() == 10,
        "en fixed FL_HOLD should have 10"
    );
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "FL_EASE_PACE").size() == 10,
        "ja fixed FL_EASE_PACE should have 10"
    );
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("en", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "DN_EASE_BOTH").size() == 10,
        "en fixed DN_EASE_BOTH should have 10"
    );
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_PREP, "FL_HOLD").size() == 10,
        "ja fixed fuel prep should have 10"
    );
    Test.assertMessage(
        CoachMessageUtils.getMessagePool("en", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NOW, "FL_HOLD").size() == 10,
        "en fixed fuel now should have 10"
    );
    return true;
}

(:test)
function testCoachMessageUtilsFunnySaltPraisePoolsHaveTenVariants(logger) {
    var categories = [
        CoachMessageUtils.CATEGORY_FUNNY,
        CoachMessageUtils.CATEGORY_SALT,
        CoachMessageUtils.CATEGORY_PRAISE
    ];

    for (var i = 0; i < categories.size(); i += 1) {
        var category = categories[i];
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("ja", category, CoachMessageUtils.FUEL_STATE_NONE, "FL_PUSH").size() == 10,
            "ja normal should have 10 for " + category
        );
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("en", category, CoachMessageUtils.FUEL_STATE_NONE, "FL_HOLD").size() == 10,
            "en normal should have 10 for " + category
        );
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("ja", category, CoachMessageUtils.FUEL_STATE_NONE, "FL_EASE_PACE").size() == 10,
            "ja pace ease should have 10 for " + category
        );
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("en", category, CoachMessageUtils.FUEL_STATE_NONE, "DN_EASE_BOTH").size() == 10,
            "en both ease should have 10 for " + category
        );
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("ja", category, CoachMessageUtils.FUEL_STATE_PREP, "FL_HOLD").size() == 10,
            "ja fuel prep should have 10 for " + category
        );
        Test.assertMessage(
            CoachMessageUtils.getMessagePool("en", category, CoachMessageUtils.FUEL_STATE_NOW, "FL_HOLD").size() == 10,
            "en fuel now should have 10 for " + category
        );
    }
    return true;
}

(:test)
function testCoachMessageUtilsAllDisplayPoolsHaveTenVariants(logger) {
    var categories = CoachMessageUtils.displayCategories();
    var languages = ["ja", "en"];
    var stateKeys = [
        "UP_PUSH",
        "UP_HOLD",
        "UP_EASE",
        "FL_PUSH",
        "FL_HOLD",
        "FL_EASE",
        "DN_PUSH",
        "DN_HOLD",
        "DN_EASE",
        "UP_EASE_PACE",
        "FL_EASE_PACE",
        "DN_EASE_PACE",
        "UP_EASE_BOTH",
        "FL_EASE_BOTH",
        "DN_EASE_BOTH"
    ];

    for (var i = 0; i < languages.size(); i += 1) {
        var language = languages[i];
        for (var j = 0; j < categories.size(); j += 1) {
            var category = categories[j];
            for (var k = 0; k < stateKeys.size(); k += 1) {
                var normalPool = CoachMessageUtils.getMessagePool(language, category, CoachMessageUtils.FUEL_STATE_NONE, stateKeys[k]);
                Test.assertMessage(normalPool.size() == 10, language + " normal should have 10 for " + category + " " + stateKeys[k]);
            }

            var prepPool = CoachMessageUtils.getMessagePool(language, category, CoachMessageUtils.FUEL_STATE_PREP, "FL_HOLD");
            Test.assertMessage(prepPool.size() == 10, language + " fuel prep should have 10 for " + category);

            var nowPool = CoachMessageUtils.getMessagePool(language, category, CoachMessageUtils.FUEL_STATE_NOW, "FL_HOLD");
            Test.assertMessage(nowPool.size() == 10, language + " fuel now should have 10 for " + category);
        }
    }
    return true;
}

(:test)
function testCoachMessageUtilsEnglishMessagesFitTwentyFiveChars(logger) {
    var categories = CoachMessageUtils.displayCategories();
    var stateKeys = [
        "UP_PUSH",
        "UP_HOLD",
        "UP_EASE",
        "FL_PUSH",
        "FL_HOLD",
        "FL_EASE",
        "DN_PUSH",
        "DN_HOLD",
        "DN_EASE",
        "UP_EASE_PACE",
        "FL_EASE_PACE",
        "DN_EASE_PACE",
        "UP_EASE_BOTH",
        "FL_EASE_BOTH",
        "DN_EASE_BOTH"
    ];

    for (var i = 0; i < categories.size(); i += 1) {
        var category = categories[i];
        for (var j = 0; j < stateKeys.size(); j += 1) {
            var pool = CoachMessageUtils.getMessagePool("en", category, CoachMessageUtils.FUEL_STATE_NONE, stateKeys[j]);
            for (var k = 0; k < pool.size(); k += 1) {
                Test.assertMessage(pool[k].length() <= 25, "normal pool too long: " + category + " " + stateKeys[j] + " " + pool[k]);
            }
        }

        var prepPool = CoachMessageUtils.getMessagePool("en", category, CoachMessageUtils.FUEL_STATE_PREP, "FL_HOLD");
        for (var m = 0; m < prepPool.size(); m += 1) {
            Test.assertMessage(prepPool[m].length() <= 25, "prep pool too long: " + category + " " + prepPool[m]);
        }

        var nowPool = CoachMessageUtils.getMessagePool("en", category, CoachMessageUtils.FUEL_STATE_NOW, "FL_HOLD");
        for (var n = 0; n < nowPool.size(); n += 1) {
            Test.assertMessage(nowPool[n].length() <= 25, "now pool too long: " + category + " " + nowPool[n]);
        }
    }
    return true;
}

(:test)
function testCoachMessageUtilsJapaneseMessagesFitNineChars(logger) {
    var categories = CoachMessageUtils.displayCategories();
    var stateKeys = [
        "UP_PUSH",
        "UP_HOLD",
        "UP_EASE",
        "FL_PUSH",
        "FL_HOLD",
        "FL_EASE",
        "DN_PUSH",
        "DN_HOLD",
        "DN_EASE",
        "UP_EASE_PACE",
        "FL_EASE_PACE",
        "DN_EASE_PACE",
        "UP_EASE_BOTH",
        "FL_EASE_BOTH",
        "DN_EASE_BOTH"
    ];

    for (var i = 0; i < categories.size(); i += 1) {
        var category = categories[i];
        for (var j = 0; j < stateKeys.size(); j += 1) {
            var pool = CoachMessageUtils.getMessagePool("ja", category, CoachMessageUtils.FUEL_STATE_NONE, stateKeys[j]);
            for (var k = 0; k < pool.size(); k += 1) {
                Test.assertMessage(pool[k].length() <= 9, "normal pool too long: " + category + " " + stateKeys[j] + " " + pool[k]);
            }
        }

        var prepPool = CoachMessageUtils.getMessagePool("ja", category, CoachMessageUtils.FUEL_STATE_PREP, "FL_HOLD");
        for (var m = 0; m < prepPool.size(); m += 1) {
            Test.assertMessage(prepPool[m].length() <= 9, "prep pool too long: " + category + " " + prepPool[m]);
        }

        var nowPool = CoachMessageUtils.getMessagePool("ja", category, CoachMessageUtils.FUEL_STATE_NOW, "FL_HOLD");
        for (var n = 0; n < nowPool.size(); n += 1) {
            Test.assertMessage(nowPool[n].length() <= 9, "now pool too long: " + category + " " + nowPool[n]);
        }
    }
    return true;
}
