using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.Test;

const TEST_CARD_MODE_ACTION = 0;
const TEST_CARD_MODE_FUEL = 1;
const TEST_CARD_MODE_FUEL_OVERDUE = 2;
const TEST_CARD_VARIANT_ACTION_PUSH = 1;
const TEST_CARD_VARIANT_ACTION_HOLD = 2;
const TEST_CARD_VARIANT_ACTION_EASE = 3;
const TEST_CARD_VARIANT_FUEL_SOON = 4;
const TEST_CARD_VARIANT_FUEL_NOW = 5;
const TEST_ACTION_EASE_REASON_NONE = 0;
const TEST_ACTION_EASE_REASON_PACE = 1;
const TEST_ACTION_EASE_REASON_HR = 2;
const TEST_ACTION_EASE_REASON_BOTH = 3;
const TEST_FUEL_DISPLAY_COUNTDOWN = 0;
const TEST_FUEL_DISPLAY_DUE = 1;
const TEST_FUEL_DISPLAY_DISABLED = 4;

class MarathonCoachFieldCardFuelTestDouble extends MarathonCoachField {
    var _testElapsedSec = null;
    var _testElapsedDistanceKm = 10.0;
    var _testActionVariant = TEST_CARD_VARIANT_ACTION_HOLD;
    var _testActionEaseReason = TEST_ACTION_EASE_REASON_NONE;
    var _testSystemLanguage = Sys.LANGUAGE_JPN;
    var _testCoachMessageCategory = null;

    function initialize() {
        MarathonCoachField.initialize();
    }

    function resetTestState() {
        _testElapsedSec = null;
        _testElapsedDistanceKm = 10.0;
        _testActionVariant = TEST_CARD_VARIANT_ACTION_HOLD;
        _testActionEaseReason = TEST_ACTION_EASE_REASON_NONE;
        _testSystemLanguage = Sys.LANGUAGE_JPN;
        _testCoachMessageCategory = CoachMessageUtils.defaultCategory();

        _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
        _customMode = CUSTOM_MODE_CORE;
        _customCodeValid = false;
        _customFuelMode = CUSTOM_FUEL_MODE_TIME;
        _customFirstFuelAfterMin = CustomModeUtils.DEFAULT_FIRST_FUEL_AFTER_MIN;
        _customFuelIntervalMin = CustomModeUtils.DEFAULT_FUEL_INTERVAL_MIN;
        _customFuelAlertLeadMin = CustomModeUtils.DEFAULT_FUEL_ALERT_LEAD_MIN;
        _customPhaseAggressiveness = CustomModeUtils.DEFAULT_PHASE_AGGRESSIVENESS;
        _customHrCapBiasBpm = CustomModeUtils.DEFAULT_HR_CAP_BIAS_BPM;
        _fuelPlanSignature = null;
        _fuelDueTimeSec = null;
        _fuelRemainingSec = null;
        _fuelRemainingText = "--:--";
        _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        _paceNowSecPerKm = 300;
        _targetPaceSecPerKm = 300;
        _lastFuelTimeSec = 0;
        _lastLapResetSec = null;
        _allowedMaxHeartRate = 150;
        _currentHeartRate = 140;
        _hrOverActive = false;
        _slopeState = "FL";
        _cardMode = CARD_MODE_ACTION;
        _cardVariant = TEST_CARD_VARIANT_ACTION_HOLD;
        _coachMessageCategory = CoachMessageUtils.defaultCategory();
        _resetCoachMessageState();
        _setCardLabelAndMessage(_actionHoldText, _actionHoldText);
    }

    function _extractElapsedSec(info) {
        return _testElapsedSec;
    }

    function _extractElapsedDistanceKm(info) {
        return _testElapsedDistanceKm;
    }

    function _resolvePredictionSystemLanguage() {
        return _testSystemLanguage;
    }

    function _resolveActionVariant() {
        return _testActionVariant;
    }

    function _getActionEaseReason() {
        return _testActionEaseReason;
    }

    function _resolveCoachMessageCategory(language, fuelState, stateKey) {
        if (_testCoachMessageCategory != null) {
            return _testCoachMessageCategory;
        }
        return MarathonCoachField._resolveCoachMessageCategory(language, fuelState, stateKey);
    }

    function _updateBeepNotifications(elapsedSec, fuelOverdue, hrOver) {
        // No-op in tests.
    }
}

function _newCardFuelSut() {
    var sut = new MarathonCoachFieldCardFuelTestDouble();
    sut.resetTestState();
    return sut;
}

function _cardMessageText(sut) {
    var text = "";
    if (sut._cardLine2 != null) {
        text = sut._cardLine2;
    }
    if (sut._cardLine3 != null and sut._cardLine3.length() > 0) {
        if (text.length() > 0) {
            text += " ";
        }
        text += sut._cardLine3;
    }
    return text;
}

function _assertMessageInPool(actual, pool as Lang.Array, message) {
    for (var i = 0; i < pool.size(); i += 1) {
        var candidate = pool[i];
        if ((candidate != null and candidate.equals(actual)) or candidate == actual) {
            Test.assertMessage(true, message);
            return;
        }
    }
    Test.assertMessage(false, message + ": " + actual);
}

(:test)
function testCardDisplay_priorityFuelNowWins(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 300;
    sut._fuelRemainingSec = 0;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_PUSH;
    sut._slopeState = "UP";

    sut._updateCardDisplay(null);

    Test.assertMessage(sut._cardMode == TEST_CARD_MODE_FUEL_OVERDUE, "cardMode=" + sut._cardMode);
    Test.assertMessage(sut._cardVariant == TEST_CARD_VARIANT_FUEL_NOW, "cardVariant=" + sut._cardVariant);
    Test.assertMessage(sut._cardLine1.equals(sut._fuelNowLabelText), "label=" + sut._cardLine1);
    return true;
}

(:test)
function testCardDisplay_priorityFuelPrepWinsOverAction(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 300;
    sut._fuelRemainingSec = 110;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_EASE;
    sut._slopeState = "DN";

    sut._updateCardDisplay(null);

    Test.assertMessage(sut._cardMode == TEST_CARD_MODE_FUEL, "cardMode=" + sut._cardMode);
    Test.assertMessage(sut._cardVariant == TEST_CARD_VARIANT_FUEL_SOON, "cardVariant=" + sut._cardVariant);
    Test.assertMessage(sut._cardLine1.equals(sut._fuelPrepLabelText), "label=" + sut._cardLine1);
    return true;
}

(:test)
function testCardDisplay_usesSlopeAndActionStateKey(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 300;
    sut._fuelRemainingSec = 300;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_PUSH;
    sut._slopeState = "UP";

    sut._updateCardDisplay(null);

    Test.assertEqual(sut._actionPushText, sut._cardLine1);
    _assertMessageInPool(
        _cardMessageText(sut),
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "UP_PUSH"),
        "message should come from UP_PUSH pool"
    );
    return true;
}

(:test)
function testCardDisplay_usesEnglishLanguagePool(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 300;
    sut._fuelRemainingSec = 300;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_HOLD;
    sut._slopeState = "FL";
    sut._testSystemLanguage = Sys.LANGUAGE_ENG;

    sut._updateCardDisplay(null);

    Test.assertEqual(sut._actionHoldText, sut._cardLine1);
    _assertMessageInPool(
        _cardMessageText(sut),
        CoachMessageUtils.getMessagePool("en", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "FL_HOLD"),
        "message should come from EN pool"
    );
    return true;
}

(:test)
function testSetCardLabelAndMessage_keepsSentenceOnSingleLine(logger) {
    var sut = _newCardFuelSut();

    sut._setCardLabelAndMessage("Hold pace", "Keep the roll pretty");

    Test.assertEqual("Hold pace", sut._cardLine1);
    Test.assertEqual("Keep the roll pretty", sut._cardLine2);
    Test.assertEqual("", sut._cardLine3);
    return true;
}

(:test)
function testCardDisplay_sameStateDoesNotRotateEverySecond(logger) {
    var sut = _newCardFuelSut();
    sut._fuelRemainingSec = 300;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_HOLD;
    sut._slopeState = "FL";

    sut._testElapsedSec = 100;
    sut._updateCardDisplay(null);
    var firstMessage = _cardMessageText(sut);

    sut._testElapsedSec = 101;
    sut._updateCardDisplay(null);
    Test.assertMessage(firstMessage.equals(_cardMessageText(sut)), "message changed");
    return true;
}

(:test)
function testCardDisplay_stateChangeRefreshesImmediately(logger) {
    var sut = _newCardFuelSut();
    sut._fuelRemainingSec = 300;
    sut._slopeState = "FL";
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_HOLD;

    sut._testElapsedSec = 100;
    sut._updateCardDisplay(null);

    sut._testElapsedSec = 101;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_EASE;
    sut._updateCardDisplay(null);

    Test.assertEqual(sut._actionEaseText, sut._cardLine1);
    _assertMessageInPool(
        _cardMessageText(sut),
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "FL_EASE"),
        "message should refresh for new state"
    );
    return true;
}

(:test)
function testCardDisplay_lastSpurtOverridesFuelAndAction(logger) {
    var sut = _newCardFuelSut();
    sut._fuelRemainingSec = 0;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_EASE;
    sut._testActionEaseReason = TEST_ACTION_EASE_REASON_BOTH;
    sut._slopeState = "DN";
    sut._testElapsedDistanceKm = sut._raceDistanceKm * 0.95;
    sut._testElapsedSec = 7200;

    sut._updateCardDisplay(null);

    Test.assertEqual(TEST_CARD_MODE_ACTION, sut._cardMode);
    Test.assertEqual(TEST_CARD_VARIANT_ACTION_PUSH, sut._cardVariant);
    Test.assertEqual(sut._lastSpurtLabelText, sut._cardLine1);
    _assertMessageInPool(
        _cardMessageText(sut),
        CoachMessageUtils.getMessagePool(
            "ja",
            CoachMessageUtils.CATEGORY_FIXED,
            CoachMessageUtils.FUEL_STATE_NONE,
            CoachMessageUtils.STATE_KEY_LAST_SPURT
        ),
        "message should come from last spurt pool"
    );
    return true;
}

(:test)
function testCardDisplay_paceOnlyEaseUsesPaceLabelAndPool(logger) {
    var sut = _newCardFuelSut();
    sut._fuelRemainingSec = 300;
    sut._slopeState = "FL";
    sut._testElapsedSec = 100;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_EASE;
    sut._testActionEaseReason = TEST_ACTION_EASE_REASON_PACE;

    sut._updateCardDisplay(null);

    Test.assertEqual(sut._actionEasePaceText, sut._cardLine1);
    _assertMessageInPool(
        _cardMessageText(sut),
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "FL_EASE_PACE"),
        "pace-only ease should use PACE pool"
    );
    return true;
}

(:test)
function testCardDisplay_bothEaseUsesBothPool(logger) {
    var sut = _newCardFuelSut();
    sut._fuelRemainingSec = 300;
    sut._slopeState = "DN";
    sut._testElapsedSec = 100;
    sut._testActionVariant = TEST_CARD_VARIANT_ACTION_EASE;
    sut._testActionEaseReason = TEST_ACTION_EASE_REASON_BOTH;

    sut._updateCardDisplay(null);

    Test.assertEqual(sut._actionEaseText, sut._cardLine1);
    _assertMessageInPool(
        _cardMessageText(sut),
        CoachMessageUtils.getMessagePool("ja", CoachMessageUtils.CATEGORY_FIXED, CoachMessageUtils.FUEL_STATE_NONE, "DN_EASE_BOTH"),
        "both ease should use BOTH pool"
    );
    return true;
}

(:test)
function testUpdateFuelTimer_shortRaceDisablesFuelMeter(logger) {
    var sut = _newCardFuelSut();
    sut._raceDistanceKm = 5.0;
    sut._testElapsedSec = 100;

    sut._updateFuelTimer(null);

    Test.assertEqual(TEST_FUEL_DISPLAY_DISABLED, sut._fuelDisplayMode);
    Test.assertMessage(sut._fuelRemainingSec == null, "short race remaining should be null");
    return true;
}

(:test)
function testUpdateSummaryMetrics_showsOverDistancePastRaceDistance(logger) {
    var sut = _newCardFuelSut();
    sut._targetTimeSec = 12600;
    sut._testElapsedSec = 12630;
    sut._testElapsedDistanceKm = 42.314;

    sut._updateSummaryMetrics(null);

    Test.assertEqual("Over", sut._goalPredictionTimeText);
    Test.assertEqual("+0.12km", sut._goalPredictionDiffText);
    Test.assertEqual("Over +0.12km", sut._goalDeltaText);
    Test.assertEqual(false, sut._goalPredictionLabelVisible);
    return true;
}

(:test)
function testUpdateFuelTimer_fullRaceCountdownAndDue(logger) {
    var sut = _newCardFuelSut();
    sut._raceDistanceKm = 42.195;
    sut._lastFuelTimeSec = 0;

    sut._testElapsedSec = 100;
    sut._updateFuelTimer(null);
    Test.assertEqual(TEST_FUEL_DISPLAY_COUNTDOWN, sut._fuelDisplayMode);
    Test.assertEqual(2000, sut._fuelRemainingSec);

    sut._testElapsedSec = 2100;
    sut._updateFuelTimer(null);
    Test.assertEqual(TEST_FUEL_DISPLAY_DUE, sut._fuelDisplayMode);
    Test.assertEqual(0, sut._fuelRemainingSec);
    return true;
}

(:test)
function testUpdateFuelTimer_customModeTimeUsesFirstFuelOffset(logger) {
    var sut = _newCardFuelSut();
    sut._customMode = CustomModeUtils.MODE_CUSTOM;
    sut._customFuelMode = CustomModeUtils.FUEL_MODE_TIME;
    sut._customFirstFuelAfterMin = 20;
    sut._customFuelIntervalMin = 30;
    sut._lastFuelTimeSec = null;

    sut._testElapsedSec = 600;
    sut._updateFuelTimer(null);
    Test.assertEqual(TEST_FUEL_DISPLAY_COUNTDOWN, sut._fuelDisplayMode);
    Test.assertEqual(600, sut._fuelRemainingSec);

    sut._testElapsedSec = 1200;
    sut._updateFuelTimer(null);
    Test.assertEqual(TEST_FUEL_DISPLAY_DUE, sut._fuelDisplayMode);
    Test.assertEqual(0, sut._fuelRemainingSec);
    return true;
}

(:test)
function testOnTimerLap_resetsCoreFuelEvenBeforeDue(logger) {
    var sut = _newCardFuelSut();
    sut._raceDistanceKm = 42.195;
    sut._customMode = CustomModeUtils.MODE_CORE;
    sut._lastFuelTimeSec = 0;
    sut._lastElapsedSec = 600;
    sut._fuelDueTimeSec = 2100;
    sut._fuelRemainingSec = 1500;
    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_COUNTDOWN;

    sut.onTimerLap();

    Test.assertEqual(600, sut._lastFuelTimeSec);
    Test.assertEqual(2700, sut._fuelDueTimeSec);
    Test.assertEqual(2100, sut._fuelRemainingSec);
    Test.assertEqual(TEST_FUEL_DISPLAY_COUNTDOWN, sut._fuelDisplayMode);
    return true;
}

(:test)
function testOnTimerLap_resetsCustomFuelEvenBeforeDue(logger) {
    var sut = _newCardFuelSut();
    sut._customMode = CustomModeUtils.MODE_CUSTOM;
    sut._customFuelMode = CustomModeUtils.FUEL_MODE_TIME;
    sut._customFuelIntervalMin = 30;
    sut._lastFuelTimeSec = 0;
    sut._lastElapsedSec = 600;
    sut._fuelDueTimeSec = 1800;
    sut._fuelRemainingSec = 1200;
    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_COUNTDOWN;

    sut.onTimerLap();

    Test.assertEqual(600, sut._lastFuelTimeSec);
    Test.assertEqual(2400, sut._fuelDueTimeSec);
    Test.assertEqual(1800, sut._fuelRemainingSec);
    Test.assertEqual(TEST_FUEL_DISPLAY_COUNTDOWN, sut._fuelDisplayMode);
    return true;
}

(:test)
function testOnTimerLap_stillDebouncesRapidRepeat(logger) {
    var sut = _newCardFuelSut();
    sut._raceDistanceKm = 42.195;
    sut._lastFuelTimeSec = 600;
    sut._lastElapsedSec = 610;
    sut._lastLapResetSec = 600;
    sut._fuelDueTimeSec = 2700;
    sut._fuelRemainingSec = 2090;

    sut.onTimerLap();

    Test.assertEqual(600, sut._lastFuelTimeSec);
    Test.assertEqual(2700, sut._fuelDueTimeSec);
    Test.assertEqual(2090, sut._fuelRemainingSec);
    return true;
}
