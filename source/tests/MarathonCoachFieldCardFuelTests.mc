using Toybox.Test;

const TEST_CARD_MODE_ACTION = 0;
const TEST_CARD_MODE_FUEL = 1;
const TEST_CARD_MODE_FUEL_OVERDUE = 2;
const TEST_CARD_MODE_HR_OVER = 3;
const TEST_CARD_MODE_DRIFT = 4;
const TEST_CARD_MODE_DISTANCE = 5;

const TEST_CARD_VARIANT_FUEL_SOON = 4;
const TEST_CARD_VARIANT_FUEL_NOW = 5;
const TEST_CARD_VARIANT_RECOVERY = 6;
const TEST_CARD_VARIANT_HR_WARNING = 7;

const TEST_FUEL_METER_STATE_NORMAL = 0;
const TEST_FUEL_METER_STATE_CAUTION = 1;
const TEST_FUEL_METER_STATE_WARNING = 2;

const TEST_FUEL_DISPLAY_COUNTDOWN = 0;
const TEST_FUEL_DISPLAY_DUE = 1;
const TEST_FUEL_DISPLAY_DONE_FLASH = 2;
const TEST_FUEL_DISPLAY_NO_PLAN = 3;
const TEST_FUEL_DISPLAY_DISABLED = 4;
const TEST_DISTANCE_NOTIFY_EVENT_NONE = 0;

class MarathonCoachFieldCardFuelTestDouble extends MarathonCoachField {
    var _testElapsedSec = null;
    var _testElapsedDistanceKm = null;
    var _testHrOver = false;
    var _testDriftOn = false;
    var _testDistanceNotifyEvent = TEST_DISTANCE_NOTIFY_EVENT_NONE;
    var _testApplyDistanceNotifyCard = false;
    var _testActionCardCalledCount = 0;

    function initialize() {
        MarathonCoachField.initialize();
    }

    function resetTestState() {
        _testElapsedSec = null;
        _testElapsedDistanceKm = null;
        _testHrOver = false;
        _testDriftOn = false;
        _testDistanceNotifyEvent = TEST_DISTANCE_NOTIFY_EVENT_NONE;
        _testApplyDistanceNotifyCard = false;
        _testActionCardCalledCount = 0;

        _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
        _customMode = CUSTOM_MODE_CORE;
        _customCodeValid = false;
        _customFuelMode = CUSTOM_FUEL_MODE_TIME;
        _customFirstFuelAfterMin = CustomModeUtils.DEFAULT_FIRST_FUEL_AFTER_MIN;
        _customFuelIntervalMin = CustomModeUtils.DEFAULT_FUEL_INTERVAL_MIN;
        _customFuelAlertLeadMin = CustomModeUtils.DEFAULT_FUEL_ALERT_LEAD_MIN;
        _customPhaseAggressiveness = CustomModeUtils.DEFAULT_PHASE_AGGRESSIVENESS;
        _customHrCapBiasBpm = CustomModeUtils.DEFAULT_HR_CAP_BIAS_BPM;
        _customDriftSensitivity = CustomModeUtils.DEFAULT_DRIFT_SENSITIVITY;
        _fuelPlanSignature = null;
        _halfFuelNextPointIndex = 0;
        _halfFuelDoneFlashUntilSec = null;
        _fuelDueTimeSec = null;
        _fuelRemainingSec = null;
        _fuelRemainingText = "--:--";
        _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        _paceNowSecPerKm = 300;
        _targetPaceSecPerKm = 300;
        _lastFuelTimeSec = 0;
        _lastLapResetSec = null;

        _cardMode = CARD_MODE_ACTION;
        _cardVariant = CARD_VARIANT_ACTION_HOLD;
        _cardLine1 = "";
        _cardLine2 = "";
        _cardLine3 = "";
    }

    function _extractElapsedSec(info) {
        return _testElapsedSec;
    }

    function _extractElapsedDistanceKm(info) {
        return _testElapsedDistanceKm;
    }

    function _isHeartRateOverCap() {
        return _testHrOver;
    }

    function _isDriftOn(info) {
        return _testDriftOn;
    }

    function _updateDistanceNotifyState(info, elapsedSec, suppressDisplay) {
        return _testDistanceNotifyEvent;
    }

    function _updateBeepNotifications(elapsedSec, fuelOverdue, hrOver, driftOn, distanceNotifyEvent) {
        // No-op in tests.
    }

    function _applyDistanceNotifyCard(elapsedSec) {
        if (!_testApplyDistanceNotifyCard) {
            return false;
        }

        _setCardFixedLines(
            CARD_MODE_DISTANCE,
            CARD_VARIANT_ACTION_HOLD,
            "DIST",
            "notify",
            "card"
        );
        return true;
    }

    function _setActionCardByBaseline(elapsedSec) {
        _testActionCardCalledCount += 1;
        _cardMode = CARD_MODE_ACTION;
        _cardVariant = CARD_VARIANT_ACTION_HOLD;
        _setCardLinesFromMessage(_actionHoldText);
    }
}

function _newCardFuelSut() {
    var sut = new MarathonCoachFieldCardFuelTestDouble();
    sut.resetTestState();
    return sut;
}

function _assertNear(actual, expected, epsilon, message) {
    Test.assertMessage(actual != null, message + " (actual is null)");
    Test.assertMessage(expected != null, message + " (expected is null)");
    Test.assertMessage(_testAbs(actual - expected) <= epsilon, message);
}

function _testAbs(value) {
    if (value < 0) {
        return -value;
    }
    return value;
}

(:test)
function testCardDisplay_priorityFuelOverdueWins(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 300;
    sut._fuelRemainingSec = 0;
    sut._testHrOver = true;
    sut._testDriftOn = true;

    sut._updateCardDisplay(null);

    Test.assertEqual(TEST_CARD_MODE_FUEL_OVERDUE, sut._cardMode);
    Test.assertEqual(TEST_CARD_VARIANT_FUEL_NOW, sut._cardVariant);
    Test.assertEqual(sut._fuelNowLine2Text, sut._cardLine1);
    Test.assertEqual(sut._fuelLabelText + sut._fuelNowLine3Text, sut._cardLine2);
    return true;
}

(:test)
function testCardDisplay_priorityHrOverWinsWhenNotFuelOverdue(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 300;
    sut._fuelRemainingSec = 1;
    sut._testHrOver = true;
    sut._testDriftOn = true;

    sut._updateCardDisplay(null);

    Test.assertEqual(TEST_CARD_MODE_HR_OVER, sut._cardMode);
    Test.assertEqual(TEST_CARD_VARIANT_HR_WARNING, sut._cardVariant);
    return true;
}

(:test)
function testCardDisplay_priorityDriftWinsAfterHrAndFuel(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 300;
    sut._fuelRemainingSec = 1;
    sut._testHrOver = false;
    sut._testDriftOn = true;

    sut._updateCardDisplay(null);

    Test.assertEqual(TEST_CARD_MODE_DRIFT, sut._cardMode);
    Test.assertEqual(TEST_CARD_VARIANT_RECOVERY, sut._cardVariant);
    return true;
}

(:test)
function testCardDisplay_fallsBackToActionWhenElapsedIsNull(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = null;
    sut._fuelRemainingSec = 50;

    sut._updateCardDisplay(null);

    Test.assertEqual(1, sut._testActionCardCalledCount);
    Test.assertEqual(TEST_CARD_MODE_ACTION, sut._cardMode);
    return true;
}

(:test)
function testCardDisplay_distanceNotifySkipsAction(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 300;
    sut._fuelRemainingSec = 300;
    sut._testApplyDistanceNotifyCard = true;

    sut._updateCardDisplay(null);

    Test.assertEqual(TEST_CARD_MODE_DISTANCE, sut._cardMode);
    Test.assertEqual(0, sut._testActionCardCalledCount);
    return true;
}

(:test)
function testCardDisplay_fuelToggleShowsFuelOnOddSlot(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 3; // slot 1 => fuel card
    sut._fuelRemainingSec = 119;

    sut._updateCardDisplay(null);

    Test.assertEqual(TEST_CARD_MODE_FUEL, sut._cardMode);
    Test.assertEqual(TEST_CARD_VARIANT_FUEL_SOON, sut._cardVariant);
    return true;
}

(:test)
function testCardDisplay_fuelToggleShowsActionOnEvenSlot(logger) {
    var sut = _newCardFuelSut();
    sut._testElapsedSec = 0; // slot 0 => action card
    sut._fuelRemainingSec = 119;

    sut._updateCardDisplay(null);

    Test.assertEqual(TEST_CARD_MODE_ACTION, sut._cardMode);
    Test.assertEqual(1, sut._testActionCardCalledCount);
    return true;
}

(:test)
function testCardDisplay_shortRaceDisablesFuelCard(logger) {
    var sut = _newCardFuelSut();
    sut._raceDistanceKm = 5.0;
    sut._testElapsedSec = 3;
    sut._fuelRemainingSec = 119;

    sut._updateCardDisplay(null);

    Test.assertEqual(TEST_CARD_MODE_ACTION, sut._cardMode);
    Test.assertEqual(1, sut._testActionCardCalledCount);
    return true;
}

(:test)
function testFuelMeterState_resolution(logger) {
    var sut = _newCardFuelSut();

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_DUE;
    Test.assertEqual(
        TEST_FUEL_METER_STATE_WARNING,
        FuelMeterUtils.resolveMeterState(sut._fuelDisplayMode, sut._fuelRemainingSec, 120)
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_DONE_FLASH;
    Test.assertEqual(
        TEST_FUEL_METER_STATE_NORMAL,
        FuelMeterUtils.resolveMeterState(sut._fuelDisplayMode, sut._fuelRemainingSec, 120)
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_COUNTDOWN;
    sut._fuelRemainingSec = 120;
    Test.assertEqual(
        TEST_FUEL_METER_STATE_CAUTION,
        FuelMeterUtils.resolveMeterState(sut._fuelDisplayMode, sut._fuelRemainingSec, 120)
    );

    sut._fuelRemainingSec = 121;
    Test.assertEqual(
        TEST_FUEL_METER_STATE_NORMAL,
        FuelMeterUtils.resolveMeterState(sut._fuelDisplayMode, sut._fuelRemainingSec, 120)
    );
    return true;
}

(:test)
function testFuelMeterProgressRatio_resolution(logger) {
    var sut = _newCardFuelSut();

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_DISABLED;
    _assertNear(
        FuelMeterUtils.resolveProgressRatio(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_NORMAL,
            sut._fuelRemainingSec,
            2100
        ),
        0.0,
        0.0001,
        "disabled => 0"
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_DUE;
    _assertNear(
        FuelMeterUtils.resolveProgressRatio(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_WARNING,
            sut._fuelRemainingSec,
            2100
        ),
        1.0,
        0.0001,
        "due => 1"
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_COUNTDOWN;
    sut._fuelRemainingSec = 1050; // 35 min interval => 0.5
    _assertNear(
        FuelMeterUtils.resolveProgressRatio(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_NORMAL,
            sut._fuelRemainingSec,
            2100
        ),
        0.5,
        0.0001,
        "half remaining => 0.5"
    );

    sut._fuelRemainingSec = null;
    _assertNear(
        FuelMeterUtils.resolveProgressRatio(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_NORMAL,
            sut._fuelRemainingSec,
            2100
        ),
        0.0,
        0.0001,
        "countdown/null => 0"
    );
    return true;
}

(:test)
function testFuelMeterText_resolution(logger) {
    var sut = _newCardFuelSut();

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_DISABLED;
    Test.assertMessage(
        FuelMeterUtils.resolveCenterText(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_NORMAL,
            sut._fuelRemainingSec,
            sut._fuelMeterMinuteSuffixText,
            sut._fuelMeterDoneText,
            sut._fuelMeterNoPlanText,
            sut._fuelMeterWarningText
        ) == null,
        "disabled center text should be null"
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_DONE_FLASH;
    Test.assertEqual(
        sut._fuelMeterDoneText,
        FuelMeterUtils.resolveCenterText(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_NORMAL,
            sut._fuelRemainingSec,
            sut._fuelMeterMinuteSuffixText,
            sut._fuelMeterDoneText,
            sut._fuelMeterNoPlanText,
            sut._fuelMeterWarningText
        )
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_NO_PLAN;
    Test.assertEqual(
        sut._fuelMeterNoPlanText,
        FuelMeterUtils.resolveCenterText(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_NORMAL,
            sut._fuelRemainingSec,
            sut._fuelMeterMinuteSuffixText,
            sut._fuelMeterDoneText,
            sut._fuelMeterNoPlanText,
            sut._fuelMeterWarningText
        )
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_DUE;
    Test.assertEqual(
        sut._fuelMeterWarningText,
        FuelMeterUtils.resolveCenterText(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_WARNING,
            sut._fuelRemainingSec,
            sut._fuelMeterMinuteSuffixText,
            sut._fuelMeterDoneText,
            sut._fuelMeterNoPlanText,
            sut._fuelMeterWarningText
        )
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_COUNTDOWN;
    sut._fuelRemainingSec = 61;
    Test.assertEqual(
        "2" + sut._fuelMeterMinuteSuffixText,
        FuelMeterUtils.resolveCenterText(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_CAUTION,
            sut._fuelRemainingSec,
            sut._fuelMeterMinuteSuffixText,
            sut._fuelMeterDoneText,
            sut._fuelMeterNoPlanText,
            sut._fuelMeterWarningText
        )
    );

    sut._fuelRemainingSec = null;
    Test.assertEqual(
        "--",
        FuelMeterUtils.resolveCenterText(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_NORMAL,
            sut._fuelRemainingSec,
            sut._fuelMeterMinuteSuffixText,
            sut._fuelMeterDoneText,
            sut._fuelMeterNoPlanText,
            sut._fuelMeterWarningText
        )
    );
    return true;
}

(:test)
function testFuelMeterWarningSubText_resolution(logger) {
    var sut = _newCardFuelSut();

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_DUE;
    Test.assertEqual(
        sut._fuelMeterWarningSubText,
        FuelMeterUtils.resolveWarningSubText(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_WARNING,
            sut._fuelMeterWarningSubText
        )
    );

    sut._fuelDisplayMode = TEST_FUEL_DISPLAY_COUNTDOWN;
    Test.assertMessage(
        FuelMeterUtils.resolveWarningSubText(
            sut._fuelDisplayMode,
            TEST_FUEL_METER_STATE_CAUTION,
            sut._fuelMeterWarningSubText
        ) == null,
        "countdown should not have warning sub text"
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
function testUpdateFuelTimer_halfRaceUses60MinInterval(logger) {
    var sut = _newCardFuelSut();
    sut._raceDistanceKm = 21.0975;
    sut._lastFuelTimeSec = 0;

    sut._testElapsedSec = 1000;
    sut._updateFuelTimer(null);
    Test.assertEqual(TEST_FUEL_DISPLAY_COUNTDOWN, sut._fuelDisplayMode);
    Test.assertEqual(2600, sut._fuelRemainingSec);

    sut._testElapsedSec = 3600;
    sut._updateFuelTimer(null);
    Test.assertEqual(TEST_FUEL_DISPLAY_DUE, sut._fuelDisplayMode);
    Test.assertEqual(0, sut._fuelRemainingSec);
    return true;
}

(:test)
function testUpdateFuelTimer_customModeFuelOffDisablesFuelMeter(logger) {
    var sut = _newCardFuelSut();
    sut._customMode = CustomModeUtils.MODE_CUSTOM;
    sut._customFuelMode = CustomModeUtils.FUEL_MODE_OFF;
    sut._testElapsedSec = 100;

    sut._updateFuelTimer(null);

    Test.assertEqual(TEST_FUEL_DISPLAY_DISABLED, sut._fuelDisplayMode);
    Test.assertMessage(sut._fuelRemainingSec == null, "custom fuel off remaining should be null");
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

    sut._testElapsedSec = 600; // 10:00
    sut._updateFuelTimer(null);
    Test.assertEqual(TEST_FUEL_DISPLAY_COUNTDOWN, sut._fuelDisplayMode);
    Test.assertEqual(600, sut._fuelRemainingSec); // due at 20:00

    sut._testElapsedSec = 1200; // 20:00
    sut._updateFuelTimer(null);
    Test.assertEqual(TEST_FUEL_DISPLAY_DUE, sut._fuelDisplayMode);
    Test.assertEqual(0, sut._fuelRemainingSec);
    return true;
}

(:test)
function testIsFuelCardEnabled_customModeFuelOff(logger) {
    var sut = _newCardFuelSut();
    sut._customMode = CustomModeUtils.MODE_CUSTOM;
    sut._customFuelMode = CustomModeUtils.FUEL_MODE_OFF;

    Test.assertEqual(false, sut._isFuelCardEnabled());
    return true;
}
