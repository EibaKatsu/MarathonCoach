using Toybox.Application.Properties as Props;
using Toybox.Activity;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.UserProfile;
using Toybox.WatchUi as Ui;

class MarathonCoachField extends Ui.DataField {
    const KEY_RACE_DISTANCE_KM = "race_distance_km";
    const KEY_TARGET_TIME_HMS = "target_time_hms";
    const LAYOUT_DEBUG_OVERLAY = false;
    const FUEL_INTERVAL_SEC = 35 * 60;
    const LAP_DEBOUNCE_SEC = 20;
    const CARD_TOGGLE_SEC = 3;
    const FUEL_TOGGLE_LEAD_SEC = 2 * 60;
    const HR_OVER_TRIGGER_SEC = 12;
    const HR_OVER_RELEASE_SEC = 5;
    const CAP_RESOLVE_RETRY_SEC = 30;
    const WARMUP_MESSAGE_ROTATE_SEC = 5;
    const DRIFT_BASELINE_START_SEC = 20 * 60;
    const DRIFT_BASELINE_MIN_DISTANCE_KM = 3.0;
    const DRIFT_WINDOW_SEC = 10 * 60;
    const DRIFT_PACE_STABLE_THRESHOLD_SEC = 5;
    const DRIFT_HR_ON_DELTA = 10;
    const DRIFT_HR_OFF_DELTA = 6;
    const DRIFT_OFF_CONFIRM_SEC = 60;
    const MIN_DISTANCE_FOR_PREDICTION_KM = 0.5;
    const ACTION_PUSH_PACE_DELTA_SEC = 8;
    const ACTION_EASE_PACE_DELTA_SEC = -8;
    const ACTION_PUSH_MIN_CAP_MARGIN_BPM = 6;
    const ACTION_EASE_CAP_MARGIN_BPM = 3;
    const ACTION_EASE_BASELINE_HR_DELTA_BPM = 6;
    const FIT_FACT_LOG = true;
    const DIST_PROBE_LOG = true;

    const CARD_MODE_ACTION = 0;
    const CARD_MODE_FUEL = 1;
    const CARD_MODE_FUEL_OVERDUE = 2;
    const CARD_MODE_HR_OVER = 3;
    const CARD_MODE_DRIFT = 4;

    const DEFAULT_RACE_DISTANCE_KM = 42.195;
    const DEFAULT_TARGET_TIME_HMS = "05:00:00";

    var _statusText = "STEP3 LAYOUT";
    var _fuelLabelText = "FUEL";
    var _goalTimeLabelText = "TGT";
    var _goalDeltaText = "TGT 05:00";
    var _actionPushText = "Push a bit";
    var _actionHoldText = "Hold pace";
    var _actionEaseText = "Ease down";
    var _hrOverLine1Text = "HR";
    var _hrOverLine2Text = "OVER";
    var _hrOverLine3Text = "CAP";
    var _driftLine1Text = "WATER";
    var _driftLine2Text = "+";
    var _driftLine3Text = "FUEL";
    var _fuelSoonLine2Text = "IN";
    var _fuelNowLine2Text = "NOW";
    var _fuelNowLine3Text = "!";
    var _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
    var _targetTimeHms = DEFAULT_TARGET_TIME_HMS;
    var _targetTimeSec = null;
    var _targetPaceSecPerKm = null;
    var _distanceTimeText = "--.- km  --:--:--";
    var _paceNowSecPerKm = null;
    var _paceNowText = "--:--";
    var _paceRingSecPerKm as Lang.Array = [];
    var _paceRingWriteIndex = 0;
    var _paceRingCount = 0;
    var _paceRingSum = 0.0;
    var _lastPaceSampleElapsedSec = null;
    var _paceFallbackLastElapsedSec = null;
    var _paceFallbackLastDistanceKm = null;
    var _lastFuelTimeSec = null;
    var _fuelDueTimeSec = null;
    var _fuelRemainingSec = null;
    var _fuelRemainingText = "--:--";
    var _timerRunning = false;
    var _lastElapsedSec = null;
    var _lastLapResetSec = null;
    var _currentHeartRate = null;
    var _baseCapHeartRate = null;
    var _capHeartRate = null;
    var _hrCapText = "-- / --:--";
    var _nextCapResolveRetrySec = 0;
    var _hrOverActive = false;
    var _hrOverStartSec = null;
    var _hrRecoverStartSec = null;
    var _driftBaselineStartSec = null;
    var _driftBaselineHrSum = 0.0;
    var _driftBaselinePaceSum = 0.0;
    var _driftBaselineCount = 0;
    var _driftBaseHr = null;
    var _driftBasePace = null;
    var _driftRingHr as Lang.Array = [];
    var _driftRingPace as Lang.Array = [];
    var _driftRingWriteIndex = 0;
    var _driftRingCount = 0;
    var _driftRingHrSum = 0.0;
    var _driftRingPaceSum = 0.0;
    var _driftLastSampleElapsedSec = null;
    var _driftActive = false;
    var _driftOffStartSec = null;
    var _fitElapsedBaseSec = 0.0;
    var _fitLastRawElapsedSec = null;
    var _fitDistanceBaseM = null;
    var _fitLastRawDistanceM = null;
    var _distanceFromLocationM = 0.0;
    var _distanceLastLocation = null;
    var _distanceLastLocationElapsedSec = null;
    var _distanceFromSpeedM = 0.0;
    var _distanceLastElapsedSec = null;
    var _fallbackActivityInfo = null;
    var _sampleElapsedRaw = null;
    var _sampleTimerRaw = null;
    var _sampleDistanceRawM = null;
    var _sampleCurrentSpeedRaw = null;
    var _sampleAverageSpeedRaw = null;
    var _sampleCurrentLocation = null;
    var _sampleSpeedMps = null;
    var _sampleHeartRate = null;
    var _sampleElapsedSource = "null";
    var _sampleTimerSource = "null";
    var _sampleDistanceSource = "null";
    var _sampleCurrentSpeedSource = "null";
    var _sampleAverageSpeedSource = "null";
    var _sampleSpeedSource = "null";
    var _sampleHeartRateSource = "null";
    var _sampleCurrentLocationSource = "null";
    var _lastFactLogLine = null;
    var _probeLocDistanceM = 0.0;
    var _probeLocLastLocation = null;
    var _probeLocLastElapsedSec = null;
    var _probeSpeedDistanceM = 0.0;
    var _probeSpeedLastElapsedSec = null;
    var _lastDistanceProbeLogLine = null;
    var _warmupMessages as Lang.Array = [];
    var _warmupMessageSlot = -1;
    var _cardMode = CARD_MODE_ACTION;
    var _cardLine1 = "EASE";
    var _cardLine2 = "DOWN";
    var _cardLine3 = "v -10s";

    function initialize() {
        DataField.initialize();
        _loadLocalizedTexts();
        _loadSettings();
    }

    function _loadLocalizedTexts() {
        _statusText = Ui.loadResource(Rez.Strings.Step3Status);
        _fuelLabelText = Ui.loadResource(Rez.Strings.FuelLabel);
        _goalTimeLabelText = Ui.loadResource(Rez.Strings.GoalTimeLabel);
        _goalDeltaText = _buildGoalDeltaText(null);
        _actionPushText = Ui.loadResource(Rez.Strings.ActionPushText);
        _actionHoldText = Ui.loadResource(Rez.Strings.ActionHoldText);
        _actionEaseText = Ui.loadResource(Rez.Strings.ActionEaseText);
        _hrOverLine1Text = Ui.loadResource(Rez.Strings.CardHrOverLine1);
        _hrOverLine2Text = Ui.loadResource(Rez.Strings.CardHrOverLine2);
        _hrOverLine3Text = Ui.loadResource(Rez.Strings.CardHrOverLine3);
        _driftLine1Text = Ui.loadResource(Rez.Strings.CardDriftLine1);
        _driftLine2Text = Ui.loadResource(Rez.Strings.CardDriftLine2);
        _driftLine3Text = Ui.loadResource(Rez.Strings.CardDriftLine3);
        _fuelSoonLine2Text = Ui.loadResource(Rez.Strings.CardFuelSoonLine2);
        _fuelNowLine2Text = Ui.loadResource(Rez.Strings.CardFuelNowLine2);
        _fuelNowLine3Text = Ui.loadResource(Rez.Strings.CardFuelNowLine3);

        _warmupMessages = [
            Ui.loadResource(Rez.Strings.WarmupMsg1),
            Ui.loadResource(Rez.Strings.WarmupMsg2),
            Ui.loadResource(Rez.Strings.WarmupMsg3),
            Ui.loadResource(Rez.Strings.WarmupMsg4),
            Ui.loadResource(Rez.Strings.WarmupMsg5),
            Ui.loadResource(Rez.Strings.WarmupMsg6),
            Ui.loadResource(Rez.Strings.WarmupMsg7),
            Ui.loadResource(Rez.Strings.WarmupMsg8),
            Ui.loadResource(Rez.Strings.WarmupMsg9),
            Ui.loadResource(Rez.Strings.WarmupMsg10)
        ];

        _setCardLinesFromMessage(_actionHoldText);
    }

    function compute(info) {
        // Step 2 settings + Step 4 pace window update.
        _fallbackActivityInfo = null;
        _captureInfoSample(info);
        _logFactSample();
        _logDistanceProbe(info);
        _loadSettings();
        _updateHeartRate(info);
        _updateHrOverState(info);
        _updatePaceWindow(info);
        _updateSummaryMetrics(info);
        _updateFuelTimer(info);
        _updateDriftState(info);
        _updateCardDisplay(info);
        return;
    }

    function onTimerStart() {
        _timerRunning = true;
    }

    function onTimerResume() {
        _timerRunning = true;
    }

    function onTimerPause() {
        _timerRunning = false;
    }

    function onTimerStop() {
        _timerRunning = false;
    }

    function onTimerReset() {
        _timerRunning = false;
        _lastElapsedSec = null;
        _lastLapResetSec = null;
        _nextCapResolveRetrySec = 0;
        _lastFuelTimeSec = null;
        _fuelDueTimeSec = null;
        _fuelRemainingSec = null;
        _fuelRemainingText = "--:--";
        _resetPaceWindow();
        _paceNowSecPerKm = null;
        _paceNowText = "--:--";
        _distanceTimeText = "--.- km  --:--:--";
        _goalDeltaText = _buildGoalDeltaText(null);
        _hrOverActive = false;
        _hrOverStartSec = null;
        _hrRecoverStartSec = null;
        _fitElapsedBaseSec = 0.0;
        _fitLastRawElapsedSec = null;
        _fitDistanceBaseM = null;
        _fitLastRawDistanceM = null;
        _distanceFromLocationM = 0.0;
        _distanceLastLocation = null;
        _distanceLastLocationElapsedSec = null;
        _distanceFromSpeedM = 0.0;
        _distanceLastElapsedSec = null;
        _fallbackActivityInfo = null;
        _sampleElapsedRaw = null;
        _sampleTimerRaw = null;
        _sampleDistanceRawM = null;
        _sampleCurrentSpeedRaw = null;
        _sampleAverageSpeedRaw = null;
        _sampleCurrentLocation = null;
        _sampleSpeedMps = null;
        _sampleHeartRate = null;
        _sampleElapsedSource = "null";
        _sampleTimerSource = "null";
        _sampleDistanceSource = "null";
        _sampleCurrentSpeedSource = "null";
        _sampleAverageSpeedSource = "null";
        _sampleSpeedSource = "null";
        _sampleHeartRateSource = "null";
        _sampleCurrentLocationSource = "null";
        _lastFactLogLine = null;
        _probeLocDistanceM = 0.0;
        _probeLocLastLocation = null;
        _probeLocLastElapsedSec = null;
        _probeSpeedDistanceM = 0.0;
        _probeSpeedLastElapsedSec = null;
        _lastDistanceProbeLogLine = null;
        _resetDriftState();
        _warmupMessageSlot = -1;
        _setActionCardByBaseline(null);
    }

    function onTimerLap() {
        if (_lastElapsedSec == null) {
            return;
        }

        if (_lastLapResetSec != null and (_lastElapsedSec - _lastLapResetSec) < LAP_DEBOUNCE_SEC) {
            return;
        }

        _lastFuelTimeSec = _lastElapsedSec;
        _fuelDueTimeSec = _lastFuelTimeSec + FUEL_INTERVAL_SEC;
        _fuelRemainingSec = FUEL_INTERVAL_SEC;
        _fuelRemainingText = _formatMinSec(_fuelRemainingSec);
        _lastLapResetSec = _lastElapsedSec;
    }

    function onUpdate(dc as Gfx.Dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        _drawStep3Layout(dc);
    }

    function _loadSettings() {
        _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
        _targetTimeHms = DEFAULT_TARGET_TIME_HMS;
        _targetTimeSec = null;
        _targetPaceSecPerKm = null;

        var raceDistance = Props.getValue(KEY_RACE_DISTANCE_KM);
        if (raceDistance != null and raceDistance instanceof Number and raceDistance > 0) {
            _raceDistanceKm = raceDistance;
        }

        var targetTime = Props.getValue(KEY_TARGET_TIME_HMS);
        if (targetTime != null) {
            var targetTimeText = _normalizeTimeText(targetTime.toString());
            if (targetTimeText.length() > 0) {
                _targetTimeHms = targetTimeText;
            }
        }

        _targetTimeSec = _parseTimeToSec(_targetTimeHms);
        if (_targetTimeSec == null or _targetTimeSec <= 0) {
            _targetTimeHms = DEFAULT_TARGET_TIME_HMS;
            _targetTimeSec = _parseTimeToSec(DEFAULT_TARGET_TIME_HMS);
        }
        if (_targetTimeSec == null or _targetTimeSec <= 0) {
            _targetTimeSec = 5 * 3600;
            _targetTimeHms = DEFAULT_TARGET_TIME_HMS;
        }
        if (_targetTimeSec != null and _targetTimeSec > 0 and _raceDistanceKm > 0) {
            _targetPaceSecPerKm = _targetTimeSec / _raceDistanceKm;
        }
    }

    function _drawStep3Layout(dc as Gfx.Dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var minDim = _min(width, height);
        var sizeClass = _getSizeClass(minDim);

        var insetPct = 7;
        var hrFont = Gfx.FONT_TINY;
        var cardFont = Gfx.FONT_SMALL;
        var paceFont = Gfx.FONT_LARGE;
        var footerFont = Gfx.FONT_SMALL;
        var paceDeltaFont = Gfx.FONT_XTINY;
        var fuelLabelFont = Gfx.FONT_XTINY;
        var fuelTimeFont = Gfx.FONT_SMALL;
        var fuelRadiusPct = 46;

        if (sizeClass == 2) {
            insetPct = 9;
            hrFont = Gfx.FONT_XTINY;
            cardFont = Gfx.FONT_TINY;
            paceFont = Gfx.FONT_LARGE;
            footerFont = Gfx.FONT_SMALL;
            paceDeltaFont = Gfx.FONT_XTINY;
            fuelLabelFont = Gfx.FONT_TINY;
            fuelTimeFont = Gfx.FONT_MEDIUM;
            fuelRadiusPct = 50;
        } else if (sizeClass == 0) {
            insetPct = 6;
            hrFont = Gfx.FONT_XTINY;
            cardFont = Gfx.FONT_TINY;
            paceFont = Gfx.FONT_MEDIUM;
            footerFont = Gfx.FONT_TINY;
            paceDeltaFont = Gfx.FONT_XTINY;
            fuelRadiusPct = 44;
        }

        // Use an inscribed square area so round displays keep consistent composition.
        var squareSize = _clamp((minDim * (100 - (insetPct * 2))) / 100, (minDim * 70) / 100, minDim);
        var left = (width - squareSize) / 2;
        var top = (height - squareSize) / 2;
        var right = left + squareSize;
        var bottomY = top + squareSize;
        var centerX = left + (squareSize / 2);

        var row1Y = top + (squareSize / 4);
        var row2Y = top + ((squareSize * 2) / 4);
        var row3Y = top + ((squareSize * 3) / 4);

        var leftColX = left;
        var leftColW = centerX - leftColX;
        var rightColX = centerX;
        var rightColW = right - rightColX;
        var rowHeight = squareSize / 4;
        var row12Height = row2Y - top;
        var row4Height = bottomY - row3Y;

        // 1st row left: HR/CAP
        var hrY = _textYByRatio(top, rowHeight, 66, dc.getFontHeight(hrFont));
        dc.drawText(
            leftColX + (leftColW / 2),
            hrY,
            hrFont,
            _hrCapText,
            Gfx.TEXT_JUSTIFY_CENTER
        );

        // Right col row1-2 span: FUEL ring
        var fuelRadius = _clamp(
            _min((rightColW * fuelRadiusPct) / 100, (row12Height * fuelRadiusPct) / 100),
            20,
            (minDim * 28) / 100
        );
        var fuelCenterX = rightColX + fuelRadius - _clamp((squareSize * 1) / 100, 2, 6);
        var maxFuelCenterX = right - fuelRadius - 2;
        if (fuelCenterX > maxFuelCenterX) {
            fuelCenterX = maxFuelCenterX;
        }
        var fuelCenterY = top + (row12Height / 2);
        var fuelLabelY = _textYByRatio(
            fuelCenterY - fuelRadius,
            fuelRadius * 2,
            31,
            dc.getFontHeight(fuelLabelFont)
        );
        var fuelTimeY = _textYByRatio(
            fuelCenterY - fuelRadius,
            fuelRadius * 2,
            60,
            dc.getFontHeight(fuelTimeFont)
        );

        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        dc.fillCircle(fuelCenterX, fuelCenterY, fuelRadius);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLUE);
        dc.drawText(fuelCenterX, fuelLabelY, fuelLabelFont, _fuelLabelText, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(fuelCenterX, fuelTimeY, fuelTimeFont, _fuelRemainingText, Gfx.TEXT_JUSTIFY_CENTER);

        // Left col row2-3 span: coach card
        var cardInset = _clamp((squareSize * 2) / 100, 2, 10);
        var cardX = leftColX + cardInset;
        var cardY = row1Y + cardInset;
        var cardW = leftColW - (cardInset * 2);
        var cardH = (row3Y - row1Y) - (cardInset * 2);
        var cardCorner = _clamp(cardW / 8, 10, 26);
        var cardFontH = dc.getFontHeight(cardFont);
        var cardLines = _getCardDisplayLines();
        var cardLineCount = cardLines.size();
        var cardGap = _max((cardH - (cardFontH * cardLineCount)) / (cardLineCount + 1), 1);
        var cardLineY = cardY + cardGap;

        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        dc.fillRoundedRectangle(cardX, cardY, cardW, cardH, cardCorner);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLUE);
        for (var i = 0; i < cardLineCount; i += 1) {
            dc.drawText(cardX + (cardW / 2), cardLineY, cardFont, cardLines[i], Gfx.TEXT_JUSTIFY_CENTER);
            cardLineY += cardFontH + cardGap;
        }

        // 3rd row right: pace
        var paceY = row2Y;
        var paceUnitY = _textYByRatio(row2Y, rowHeight, 86, dc.getFontHeight(Gfx.FONT_XTINY));
        var paceUnitX = rightColX + rightColW - _clamp((rightColW * 4) / 100, 4, 12);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.drawText(
            rightColX + (rightColW / 2),
            paceY,
            paceFont,
            _paceNowText,
            Gfx.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            paceUnitX,
            paceUnitY,
            Gfx.FONT_XTINY,
            "/km",
            Gfx.TEXT_JUSTIFY_RIGHT
        );

        // 4th row: DIST / TIME + GOAL / prediction delta
        var mergedY = _textYByRatio(row3Y, row4Height, 24, dc.getFontHeight(footerFont));
        var paceDeltaY = _textYByRatio(row3Y, row4Height, 70, dc.getFontHeight(paceDeltaFont));
        dc.drawText(width / 2, mergedY, footerFont, _distanceTimeText, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, paceDeltaY, paceDeltaFont, _goalDeltaText, Gfx.TEXT_JUSTIFY_CENTER);

        if (LAYOUT_DEBUG_OVERLAY) {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
            dc.drawLine(centerX, top, centerX, bottomY);
            dc.drawLine(left, row1Y, right, row1Y);
            dc.drawLine(left, row2Y, right, row2Y);
            dc.drawLine(left, row3Y, right, row3Y);
        }
    }

    function _min(a, b) {
        if (a < b) {
            return a;
        }
        return b;
    }

    function _max(a, b) {
        if (a > b) {
            return a;
        }
        return b;
    }

    function _getSizeClass(minDim) {
        if (minDim >= 261) {
            return 2; // large
        }
        if (minDim <= 218) {
            return 0; // small
        }
        return 1; // medium
    }

    function _updatePaceWindow(info) {
        var elapsedSec = _extractElapsedSec(info);
        _lastElapsedSec = elapsedSec;
        if (elapsedSec == null) {
            _paceNowSecPerKm = null;
            _paceNowText = "--:--";
            return;
        }

        var samplePaceSecPerKm = _extractPaceSecPerKm(info);
        if (samplePaceSecPerKm == null) {
            samplePaceSecPerKm = _extractPaceFromDistanceDelta(info, elapsedSec);
        }

        if (_lastPaceSampleElapsedSec != null and elapsedSec < _lastPaceSampleElapsedSec) {
            _resetPaceWindow();
        }

        if (
            samplePaceSecPerKm != null and
            (_lastPaceSampleElapsedSec == null or elapsedSec > _lastPaceSampleElapsedSec)
        ) {
            _appendPaceSample(samplePaceSecPerKm);
            _lastPaceSampleElapsedSec = elapsedSec;
        }

        if (_paceRingCount == 0) {
            _paceNowSecPerKm = null;
            _paceNowText = "--:--";
            return;
        }

        _paceNowSecPerKm = _paceRingSum / _paceRingCount;
        _paceNowText = _formatPaceSecPerKm(_paceNowSecPerKm);
    }

    function _resetPaceWindow() {
        _paceRingSecPerKm = [];
        _paceRingWriteIndex = 0;
        _paceRingCount = 0;
        _paceRingSum = 0.0;
        _lastPaceSampleElapsedSec = null;
        _paceFallbackLastElapsedSec = null;
        _paceFallbackLastDistanceKm = null;
    }

    function _appendPaceSample(samplePaceSecPerKm) {
        var maxSamples = 10;
        if (_paceRingCount < maxSamples) {
            _paceRingSecPerKm.add(samplePaceSecPerKm);
            _paceRingSum += samplePaceSecPerKm;
            _paceRingCount += 1;
            if (_paceRingCount == maxSamples) {
                _paceRingWriteIndex = 0;
            }
            return;
        }

        var oldSample = _paceRingSecPerKm[_paceRingWriteIndex];
        _paceRingSum -= oldSample;
        _paceRingSecPerKm[_paceRingWriteIndex] = samplePaceSecPerKm;
        _paceRingSum += samplePaceSecPerKm;
        _paceRingWriteIndex += 1;
        if (_paceRingWriteIndex >= maxSamples) {
            _paceRingWriteIndex = 0;
        }
    }

    function _updateSummaryMetrics(info) {
        var elapsedSec = _extractElapsedSec(info);
        var distanceKm = _extractElapsedDistanceKm(info);

        var distanceText = "--.- km";
        if (distanceKm != null) {
            distanceText = _formatDistanceKm(distanceKm);
        }

        var elapsedText = "--:--:--";
        if (elapsedSec != null) {
            elapsedText = _formatElapsedTime(elapsedSec);
        }

        _distanceTimeText = distanceText + "  " + elapsedText;
        var predictionDeltaText = null;
        var displayPaceSecPerKm = null;
        if (_paceNowSecPerKm != null) {
            // Keep delta calculation aligned with the pace value shown on screen.
            displayPaceSecPerKm = Math.floor(_paceNowSecPerKm + 0.5);
        }
        if (
            _targetTimeSec != null and _targetTimeSec > 0 and
            displayPaceSecPerKm != null and
            elapsedSec != null and
            distanceKm != null and
            _raceDistanceKm > 0 and
            distanceKm >= MIN_DISTANCE_FOR_PREDICTION_KM
        ) {
            var remainingDistanceKm = _raceDistanceKm - distanceKm;
            if (remainingDistanceKm < 0) {
                remainingDistanceKm = 0;
            }
            var predictedTotalSec = elapsedSec + (remainingDistanceKm * displayPaceSecPerKm);
            var deltaSec = predictedTotalSec - _targetTimeSec;
            predictionDeltaText = _formatSignedDeltaMinSec(deltaSec);
        }

        _goalDeltaText = _buildGoalDeltaText(predictionDeltaText);
    }

    function _updateHeartRate(info) {
        _resolveCapHeartRate(info);

        var capText = "--:--";
        if (_capHeartRate != null) {
            capText = _capHeartRate.format("%d");
        }

        var heartRate = _extractCurrentHeartRate(info);
        if (heartRate != null and heartRate > 0) {
            _currentHeartRate = heartRate;
            _hrCapText = _currentHeartRate.format("%d") + " / " + capText;
            return;
        }

        _currentHeartRate = null;
        _hrCapText = "-- / " + capText;
    }

    function _resolveCapHeartRate(info) {
        var elapsedSec = _extractElapsedSec(info);
        if (_baseCapHeartRate == null) {
            // Resolve only after activity elapsed time becomes available to keep source stable.
            var shouldResolveBase = (elapsedSec != null and elapsedSec >= _nextCapResolveRetrySec);
            if (shouldResolveBase) {
                _baseCapHeartRate = _resolveBaseCapHeartRate();
                if (_baseCapHeartRate == null and elapsedSec != null) {
                    _nextCapResolveRetrySec = elapsedSec + CAP_RESOLVE_RETRY_SEC;
                }
            }
        }

        if (_baseCapHeartRate == null) {
            _capHeartRate = null;
            return;
        }

        var distanceKm = _extractElapsedDistanceKm(info);
        var capOffset = _getCapDistanceOffset(distanceKm);
        var adjustedCap = _baseCapHeartRate - capOffset;
        if (adjustedCap < 1) {
            adjustedCap = 1;
        }
        _capHeartRate = adjustedCap;
    }

    function _resolveBaseCapHeartRate() {
        var lthrHeartRate = _getLthrHeartRate();
        if (lthrHeartRate != null and lthrHeartRate > 0) {
            return lthrHeartRate;
        }

        var maxHeartRate = _getConfiguredMaxHeartRate();
        if (maxHeartRate != null and maxHeartRate > 0) {
            return Math.floor((maxHeartRate * 0.86) + 0.5);
        }

        return null;
    }

    function _getLthrHeartRate() {
        // No direct public API for LTHR in current Connect IQ SDK.
        return null;
    }

    function _getConfiguredMaxHeartRate() {
        var zones = _getHeartRateZonesForCurrentSport();
        var maxHeartRate = _extractMaxZoneValue(zones);
        if (maxHeartRate != null) {
            return maxHeartRate;
        }

        var genericZones = _getGenericHeartRateZones();
        maxHeartRate = _extractMaxZoneValue(genericZones);
        if (maxHeartRate != null) {
            return maxHeartRate;
        }

        return null;
    }

    function _getHeartRateZonesForCurrentSport() as Lang.Array<Lang.Number> or Null {
        try {
            var sport = UserProfile.getCurrentSport();
            var zones = UserProfile.getHeartRateZones(sport);
            if (zones != null and zones.size() > 0) {
                return zones;
            }
        } catch (e) {
            return null;
        }

        return null;
    }

    function _getGenericHeartRateZones() as Lang.Array<Lang.Number> or Null {
        try {
            var genericZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
            if (genericZones != null and genericZones.size() > 0) {
                return genericZones;
            }
        } catch (e) {
            return null;
        }

        return null;
    }

    function _extractMaxZoneValue(zones as Lang.Array<Lang.Number> or Null) {
        if (zones == null or zones.size() == 0) {
            return null;
        }

        var maxValue = null;
        for (var i = 0; i < zones.size(); i += 1) {
            var value = zones[i];
            if (value == null or !(value instanceof Number) or value <= 0) {
                continue;
            }
            if (maxValue == null or value > maxValue) {
                maxValue = value;
            }
        }

        if (maxValue == null) {
            return null;
        }

        try {
            return Math.floor(maxValue + 0.5);
        } catch (e) {
            return null;
        }
    }

    function _extractPaceSecPerKm(info) {
        var speedMps = _extractCurrentSpeed(info);
        if (speedMps == null) {
            return null;
        }

        if (speedMps <= 0) {
            return null;
        }

        var paceSecPerKm = 1000.0 / speedMps;
        // Reject clearly invalid GPS/sensor spikes.
        if (paceSecPerKm < 120 or paceSecPerKm > 1200) {
            return null;
        }

        return paceSecPerKm;
    }

    function _extractElapsedDistanceKm(info) {
        // In Activity.Info, elapsedDistance is the FIT-equivalent running total_distance (meters).
        if (!_isNumericSample(_sampleDistanceRawM)) {
            return null;
        }
        if (_sampleDistanceRawM < 0) {
            return null;
        }
        return _sampleDistanceRawM / 1000.0;
    }

    function _extractPaceFromDistanceDelta(info, elapsedSec) {
        var distanceKm = _extractElapsedDistanceKm(info);
        if (distanceKm == null) {
            return null;
        }

        var samplePaceSecPerKm = null;
        if (
            _paceFallbackLastElapsedSec != null and
            _paceFallbackLastDistanceKm != null and
            elapsedSec > _paceFallbackLastElapsedSec
        ) {
            var deltaSec = elapsedSec - _paceFallbackLastElapsedSec;
            var deltaDistanceKm = distanceKm - _paceFallbackLastDistanceKm;
            if (deltaSec > 0 and deltaDistanceKm > 0) {
                var speedMps = (deltaDistanceKm * 1000.0) / deltaSec;
                if (speedMps > 0) {
                    samplePaceSecPerKm = 1000.0 / speedMps;
                    if (samplePaceSecPerKm < 120 or samplePaceSecPerKm > 1200) {
                        samplePaceSecPerKm = null;
                    }
                }
            }
        }

        _paceFallbackLastElapsedSec = elapsedSec;
        _paceFallbackLastDistanceKm = distanceKm;
        return samplePaceSecPerKm;
    }

    function _extractCurrentHeartRate(info) {
        return _sampleHeartRate;
    }

    function _extractCurrentSpeed(info) {
        return _sampleSpeedMps;
    }

    function _getElapsedTimeRaw(info) {
        // Match MessageInGarmin: use timerTime, and fall back to system uptime when unavailable.
        if (_sampleTimerRaw != null) {
            return _sampleTimerRaw;
        }
        return Sys.getTimer();
    }

    function _getFallbackActivityInfo() {
        if (_fallbackActivityInfo != null) {
            return _fallbackActivityInfo;
        }
        try {
            _fallbackActivityInfo = Activity.getActivityInfo();
            return _fallbackActivityInfo;
        } catch (e) {
            return null;
        }
    }

    function _captureInfoSample(info) {
        var fallbackInfo = _getFallbackActivityInfo();

        _sampleElapsedRaw = _pickSampleNumber(
            (info != null) ? info.elapsedTime : null,
            (fallbackInfo != null) ? fallbackInfo.elapsedTime : null,
            "elapsedTime"
        );
        _sampleElapsedSource = _pickSampleSource(
            (info != null) ? info.elapsedTime : null,
            (fallbackInfo != null) ? fallbackInfo.elapsedTime : null
        );

        _sampleTimerRaw = _pickSampleNumber(
            (info != null) ? info.timerTime : null,
            (fallbackInfo != null) ? fallbackInfo.timerTime : null,
            "timerTime"
        );
        _sampleTimerSource = _pickSampleSource(
            (info != null) ? info.timerTime : null,
            (fallbackInfo != null) ? fallbackInfo.timerTime : null
        );

        _sampleDistanceRawM = _pickSampleNumber(
            (info != null) ? info.elapsedDistance : null,
            (fallbackInfo != null) ? fallbackInfo.elapsedDistance : null,
            "elapsedDistance"
        );
        _sampleDistanceSource = _pickSampleSource(
            (info != null) ? info.elapsedDistance : null,
            (fallbackInfo != null) ? fallbackInfo.elapsedDistance : null
        );

        _sampleCurrentSpeedRaw = _pickSampleNumber(
            (info != null) ? info.currentSpeed : null,
            (fallbackInfo != null) ? fallbackInfo.currentSpeed : null,
            "currentSpeed"
        );
        _sampleCurrentSpeedSource = _pickSampleSource(
            (info != null) ? info.currentSpeed : null,
            (fallbackInfo != null) ? fallbackInfo.currentSpeed : null
        );

        _sampleAverageSpeedRaw = _pickSampleNumber(
            (info != null) ? info.averageSpeed : null,
            (fallbackInfo != null) ? fallbackInfo.averageSpeed : null,
            "averageSpeed"
        );
        _sampleAverageSpeedSource = _pickSampleSource(
            (info != null) ? info.averageSpeed : null,
            (fallbackInfo != null) ? fallbackInfo.averageSpeed : null
        );

        _sampleSpeedMps = _sampleCurrentSpeedRaw;
        _sampleSpeedSource = _sampleCurrentSpeedSource;
        if (_sampleSpeedMps == null) {
            _sampleSpeedMps = _sampleAverageSpeedRaw;
            _sampleSpeedSource = _sampleAverageSpeedSource;
        }

        var locPrimary = (info != null) ? info.currentLocation : null;
        var locSecondary = (fallbackInfo != null) ? fallbackInfo.currentLocation : null;
        if (locPrimary != null) {
            _sampleCurrentLocation = locPrimary;
            _sampleCurrentLocationSource = "info";
        } else if (locSecondary != null) {
            _sampleCurrentLocation = locSecondary;
            _sampleCurrentLocationSource = "fallback";
        } else {
            _sampleCurrentLocation = null;
            _sampleCurrentLocationSource = "none";
        }

        _sampleHeartRate = _pickSampleNumber(
            (info != null) ? info.currentHeartRate : null,
            (fallbackInfo != null) ? fallbackInfo.currentHeartRate : null,
            "currentHeartRate"
        );
        _sampleHeartRateSource = _pickSampleSource(
            (info != null) ? info.currentHeartRate : null,
            (fallbackInfo != null) ? fallbackInfo.currentHeartRate : null
        );
    }

    function _pickSampleNumber(primary, secondary, label) {
        if (_isNumericSample(primary)) {
            return primary;
        }
        if (_isNumericSample(secondary)) {
            return secondary;
        }
        return null;
    }

    function _pickSampleSource(primary, secondary) {
        if (_isNumericSample(primary)) {
            return "info";
        }
        if (_isNumericSample(secondary)) {
            return "fallback";
        }
        return "none";
    }

    function _isNumericSample(value) {
        return value != null and (
            value instanceof Number or
            value instanceof Float or
            value instanceof Double or
            value instanceof Long
        );
    }

    function _distanceBetweenLocationsM(fromLocation, toLocation) {
        if (fromLocation == null or toLocation == null) {
            return null;
        }
        try {
            var fromRad = fromLocation.toRadians();
            var toRad = toLocation.toRadians();
            if (fromRad == null or toRad == null or fromRad.size() < 2 or toRad.size() < 2) {
                return null;
            }

            var lat1 = fromRad[0];
            var lon1 = fromRad[1];
            var lat2 = toRad[0];
            var lon2 = toRad[1];

            var dLat = lat2 - lat1;
            var dLon = lon2 - lon1;
            var sinHalfLat = Math.sin(dLat / 2.0);
            var sinHalfLon = Math.sin(dLon / 2.0);
            var a = (sinHalfLat * sinHalfLat) + (Math.cos(lat1) * Math.cos(lat2) * sinHalfLon * sinHalfLon);
            if (a < 0) {
                a = 0;
            } else if (a > 1) {
                a = 1;
            }

            var c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));
            return 6371000.0 * c;
        } catch (e) {
            return null;
        }
    }

    function _logFactSample() {
        if (!FIT_FACT_LOG) {
            return;
        }
        var line =
            "[FACT] et=" + _factValue(_sampleElapsedRaw) + "(" + _sampleElapsedSource + ")" +
            " tt=" + _factValue(_sampleTimerRaw) + "(" + _sampleTimerSource + ")" +
            " dist=" + _factValue(_sampleDistanceRawM) + "(" + _sampleDistanceSource + ")" +
            " currSpd=" + _factValue(_sampleCurrentSpeedRaw) + "(" + _sampleCurrentSpeedSource + ")" +
            " avgSpd=" + _factValue(_sampleAverageSpeedRaw) + "(" + _sampleAverageSpeedSource + ")" +
            " spd=" + _factValue(_sampleSpeedMps) + "(" + _sampleSpeedSource + ")" +
            " hr=" + _factValue(_sampleHeartRate) + "(" + _sampleHeartRateSource + ")" +
            " loc=" + _sampleCurrentLocationSource;
        if (_lastFactLogLine == line) {
            return;
        }
        _lastFactLogLine = line;
        Sys.println(line);
    }

    function _logDistanceProbe(info) {
        if (!DIST_PROBE_LOG) {
            return;
        }

        var fallbackInfo = _getFallbackActivityInfo();
        var elapsedSec = _extractElapsedSec(info);
        var rawElapsed = _getElapsedTimeRaw(info);

        var infoElapsedDistance = null;
        if (info != null and _isNumericSample(info.elapsedDistance)) {
            infoElapsedDistance = info.elapsedDistance;
        }
        var fallbackElapsedDistance = null;
        if (fallbackInfo != null and _isNumericSample(fallbackInfo.elapsedDistance)) {
            fallbackElapsedDistance = fallbackInfo.elapsedDistance;
        }

        var locationDeltaM = null;
        if (elapsedSec != null and _sampleCurrentLocation != null) {
            if (_probeLocLastElapsedSec == null or elapsedSec < _probeLocLastElapsedSec) {
                _probeLocDistanceM = 0.0;
                _probeLocLastLocation = _sampleCurrentLocation;
                _probeLocLastElapsedSec = elapsedSec;
            } else if (elapsedSec > _probeLocLastElapsedSec) {
                if (_probeLocLastLocation != null) {
                    locationDeltaM = _distanceBetweenLocationsM(_probeLocLastLocation, _sampleCurrentLocation);
                    if (locationDeltaM != null and locationDeltaM > 0) {
                        _probeLocDistanceM += locationDeltaM;
                    }
                }
                _probeLocLastLocation = _sampleCurrentLocation;
                _probeLocLastElapsedSec = elapsedSec;
            }
        }

        var speedDeltaM = null;
        if (elapsedSec != null) {
            if (_probeSpeedLastElapsedSec == null or elapsedSec < _probeSpeedLastElapsedSec) {
                _probeSpeedDistanceM = 0.0;
                _probeSpeedLastElapsedSec = elapsedSec;
            } else {
                var deltaSec = elapsedSec - _probeSpeedLastElapsedSec;
                if (deltaSec > 0 and _sampleSpeedMps != null and _sampleSpeedMps > 0) {
                    speedDeltaM = _sampleSpeedMps * deltaSec;
                    _probeSpeedDistanceM += speedDeltaM;
                }
                if (deltaSec > 0) {
                    _probeSpeedLastElapsedSec = elapsedSec;
                }
            }
        }

        var line =
            "[DIST_PROBE] rawT=" + _factValue(rawElapsed) +
            " sec=" + _factValue(elapsedSec) +
            " infoDist=" + _factValue(infoElapsedDistance) +
            " fbDist=" + _factValue(fallbackElapsedDistance) +
            " sampleDist=" + _factValue(_sampleDistanceRawM) + "(" + _sampleDistanceSource + ")" +
            " locSrc=" + _sampleCurrentLocationSource +
            " locDeltaM=" + _factValue(locationDeltaM) +
            " locAccumM=" + _factValue(_probeLocDistanceM) +
            " spd=" + _factValue(_sampleSpeedMps) + "(" + _sampleSpeedSource + ")" +
            " spdDeltaM=" + _factValue(speedDeltaM) +
            " spdAccumM=" + _factValue(_probeSpeedDistanceM);
        if (_lastDistanceProbeLogLine == line) {
            return;
        }
        _lastDistanceProbeLogLine = line;
        Sys.println(line);
    }

    function _factValue(value) {
        if (value == null) {
            return "null";
        }
        return value.toString();
    }

    function _getCapDistanceOffset(distanceKm) {
        if (distanceKm == null or distanceKm < 10.0) {
            return 23;
        }
        if (distanceKm < 25.0) {
            return 18;
        }
        if (distanceKm < 35.0) {
            return 13;
        }
        return 8;
    }

    function _updateDriftState(info) {
        var elapsedSec = _extractElapsedSec(info);
        if (elapsedSec == null) {
            return;
        }

        if (_driftLastSampleElapsedSec != null and elapsedSec < _driftLastSampleElapsedSec) {
            _resetDriftState();
        }

        if (_driftLastSampleElapsedSec != null and elapsedSec == _driftLastSampleElapsedSec) {
            return;
        }
        _driftLastSampleElapsedSec = elapsedSec;

        var sampleHr = _currentHeartRate;
        var samplePace = _extractPaceSecPerKm(info);
        var distanceKm = _extractElapsedDistanceKm(info);

        _updateDriftBaseline(elapsedSec, distanceKm, sampleHr, samplePace);

        if (_driftBaseHr == null or _driftBasePace == null) {
            _driftActive = false;
            _driftOffStartSec = null;
            return;
        }

        if (sampleHr == null or samplePace == null) {
            return;
        }

        _appendDriftRollingSample(sampleHr, samplePace);
        if (_driftRingCount == 0) {
            return;
        }

        var curHr = _driftRingHrSum / _driftRingCount;
        var curPace = _driftRingPaceSum / _driftRingCount;
        var paceDiffAbs = _abs(curPace - _driftBasePace);

        // Evaluate drift only while pace remains near baseline pace.
        if (paceDiffAbs > DRIFT_PACE_STABLE_THRESHOLD_SEC) {
            _driftOffStartSec = null;
            return;
        }

        var hrDelta = curHr - _driftBaseHr;
        if (!_driftActive and hrDelta >= DRIFT_HR_ON_DELTA) {
            _driftActive = true;
            _driftOffStartSec = null;
            return;
        }

        if (_driftActive and hrDelta <= DRIFT_HR_OFF_DELTA) {
            if (_driftOffStartSec == null) {
                _driftOffStartSec = elapsedSec;
                return;
            }
            if ((elapsedSec - _driftOffStartSec) >= DRIFT_OFF_CONFIRM_SEC) {
                _driftActive = false;
                _driftOffStartSec = null;
            }
            return;
        }

        _driftOffStartSec = null;
    }

    function _updateDriftBaseline(elapsedSec, distanceKm, sampleHr, samplePace) {
        if (_driftBaseHr != null and _driftBasePace != null) {
            return;
        }

        if (_driftBaselineStartSec == null) {
            if (
                elapsedSec >= DRIFT_BASELINE_START_SEC and
                distanceKm != null and distanceKm >= DRIFT_BASELINE_MIN_DISTANCE_KM
            ) {
                _driftBaselineStartSec = elapsedSec;
                _driftBaselineHrSum = 0.0;
                _driftBaselinePaceSum = 0.0;
                _driftBaselineCount = 0;
            } else {
                return;
            }
        }

        if ((elapsedSec - _driftBaselineStartSec) < DRIFT_WINDOW_SEC) {
            if (sampleHr != null and samplePace != null) {
                _driftBaselineHrSum += sampleHr;
                _driftBaselinePaceSum += samplePace;
                _driftBaselineCount += 1;
            }
            return;
        }

        if (_driftBaselineCount > 0) {
            _driftBaseHr = _driftBaselineHrSum / _driftBaselineCount;
            _driftBasePace = _driftBaselinePaceSum / _driftBaselineCount;
            _driftRingHr = [];
            _driftRingPace = [];
            _driftRingWriteIndex = 0;
            _driftRingCount = 0;
            _driftRingHrSum = 0.0;
            _driftRingPaceSum = 0.0;
        } else {
            // Re-arm baseline sampling if the initial window had no valid samples.
            _driftBaselineStartSec = null;
        }
    }

    function _appendDriftRollingSample(sampleHr, samplePace) {
        var maxSamples = DRIFT_WINDOW_SEC;
        if (_driftRingCount < maxSamples) {
            _driftRingHr.add(sampleHr);
            _driftRingPace.add(samplePace);
            _driftRingHrSum += sampleHr;
            _driftRingPaceSum += samplePace;
            _driftRingCount += 1;
            if (_driftRingCount == maxSamples) {
                _driftRingWriteIndex = 0;
            }
            return;
        }

        var oldHr = _driftRingHr[_driftRingWriteIndex];
        var oldPace = _driftRingPace[_driftRingWriteIndex];
        _driftRingHrSum -= oldHr;
        _driftRingPaceSum -= oldPace;
        _driftRingHr[_driftRingWriteIndex] = sampleHr;
        _driftRingPace[_driftRingWriteIndex] = samplePace;
        _driftRingHrSum += sampleHr;
        _driftRingPaceSum += samplePace;
        _driftRingWriteIndex += 1;
        if (_driftRingWriteIndex >= maxSamples) {
            _driftRingWriteIndex = 0;
        }
    }

    function _resetDriftState() {
        _driftBaselineStartSec = null;
        _driftBaselineHrSum = 0.0;
        _driftBaselinePaceSum = 0.0;
        _driftBaselineCount = 0;
        _driftBaseHr = null;
        _driftBasePace = null;
        _driftRingHr = [];
        _driftRingPace = [];
        _driftRingWriteIndex = 0;
        _driftRingCount = 0;
        _driftRingHrSum = 0.0;
        _driftRingPaceSum = 0.0;
        _driftLastSampleElapsedSec = null;
        _driftActive = false;
        _driftOffStartSec = null;
    }

    function _updateFuelTimer(info) {
        var elapsedSec = _extractElapsedSec(info);
        if (elapsedSec == null) {
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            return;
        }

        if (_lastFuelTimeSec == null) {
            // Keep fuel schedule aligned to activity elapsed time (FIT playback time).
            _lastFuelTimeSec = 0;
        } else if (elapsedSec < _lastFuelTimeSec) {
            // Recover when activity timer resets or playback jumps backward before last reset point.
            _lastFuelTimeSec = 0;
            _lastLapResetSec = null;
        }

        _fuelDueTimeSec = _lastFuelTimeSec + FUEL_INTERVAL_SEC;
        _fuelRemainingSec = _fuelDueTimeSec - elapsedSec;
        if (_fuelRemainingSec < 0) {
            _fuelRemainingSec = 0;
        }

        _fuelRemainingText = _formatMinSec(_fuelRemainingSec);
    }

    function _updateCardDisplay(info) {
        var elapsedSec = _extractElapsedSec(info);
        var fuelOverdue = _isFuelOverdue();

        if (_isHeartRateOverCap()) {
            _cardMode = CARD_MODE_HR_OVER;
            _cardLine1 = _hrOverLine1Text;
            _cardLine2 = _hrOverLine2Text;
            _cardLine3 = _hrOverLine3Text;
            return;
        }

        if (_isDriftOn(info)) {
            _cardMode = CARD_MODE_DRIFT;
            _cardLine1 = _driftLine1Text;
            _cardLine2 = _driftLine2Text;
            _cardLine3 = _driftLine3Text;
            return;
        }

        if (elapsedSec == null) {
            _setActionCardByBaseline(null);
            return;
        }

        // Toggle starts in the final 2 minutes before fuel due, and continues after overdue.
        var inFuelToggleWindow = (
            fuelOverdue or
            (_fuelRemainingSec != null and _fuelRemainingSec <= FUEL_TOGGLE_LEAD_SEC)
        );
        if (inFuelToggleWindow) {
            var toggleSlot = Math.floor(elapsedSec / CARD_TOGGLE_SEC);
            var showFuelCard = ((toggleSlot % 2) == 1);
            if (showFuelCard) {
                _cardLine1 = _fuelLabelText;
                if (fuelOverdue) {
                    _cardMode = CARD_MODE_FUEL_OVERDUE;
                    _cardLine2 = _fuelNowLine2Text;
                    _cardLine3 = _fuelNowLine3Text;
                } else {
                    _cardMode = CARD_MODE_FUEL;
                    _cardLine2 = _fuelSoonLine2Text;
                    _cardLine3 = _fuelRemainingText;
                }
                return;
            }
        }

        _setActionCardByBaseline(elapsedSec);
    }

    function _isFuelOverdue() {
        return _fuelRemainingSec != null and _fuelRemainingSec <= 0;
    }

    function _isHeartRateOverCap() {
        return _hrOverActive;
    }

    function _updateHrOverState(info) {
        if (_currentHeartRate == null or _capHeartRate == null) {
            _hrOverActive = false;
            _hrOverStartSec = null;
            _hrRecoverStartSec = null;
            return;
        }

        var elapsedSec = _extractElapsedSec(info);
        if (elapsedSec == null) {
            _hrOverActive = false;
            _hrOverStartSec = null;
            _hrRecoverStartSec = null;
            return;
        }

        if (_currentHeartRate > _capHeartRate) {
            _hrRecoverStartSec = null;
            if (!_hrOverActive) {
                if (_hrOverStartSec == null or elapsedSec < _hrOverStartSec) {
                    _hrOverStartSec = elapsedSec;
                }
                if ((elapsedSec - _hrOverStartSec) >= HR_OVER_TRIGGER_SEC) {
                    _hrOverActive = true;
                }
            }
            return;
        }

        _hrOverStartSec = null;
        if (_hrOverActive) {
            if (_hrRecoverStartSec == null or elapsedSec < _hrRecoverStartSec) {
                _hrRecoverStartSec = elapsedSec;
            }
            if ((elapsedSec - _hrRecoverStartSec) >= HR_OVER_RELEASE_SEC) {
                _hrOverActive = false;
                _hrRecoverStartSec = null;
            }
        }
    }

    function _isDriftOn(info) {
        return _driftActive;
    }

    function _isBaselineReady() {
        return _driftBaseHr != null and _driftBasePace != null;
    }

    function _resolveActionMessage() {
        var paceDeltaSec = null;
        if (_paceNowSecPerKm != null and _targetPaceSecPerKm != null) {
            paceDeltaSec = _paceNowSecPerKm - _targetPaceSecPerKm;
        }

        var capMargin = null;
        if (_capHeartRate != null and _currentHeartRate != null) {
            capMargin = _capHeartRate - _currentHeartRate;
        }

        var baselineHrDelta = null;
        if (_driftBaseHr != null and _currentHeartRate != null) {
            baselineHrDelta = _currentHeartRate - _driftBaseHr;
        }

        var shouldEase = false;
        if (paceDeltaSec != null and paceDeltaSec <= ACTION_EASE_PACE_DELTA_SEC) {
            shouldEase = true;
        }
        if (capMargin != null and capMargin <= ACTION_EASE_CAP_MARGIN_BPM) {
            shouldEase = true;
        }
        if (baselineHrDelta != null and baselineHrDelta >= ACTION_EASE_BASELINE_HR_DELTA_BPM) {
            shouldEase = true;
        }
        if (shouldEase) {
            return _actionEaseText;
        }

        var canPushByHr = (capMargin == null or capMargin >= ACTION_PUSH_MIN_CAP_MARGIN_BPM);
        if (paceDeltaSec != null and paceDeltaSec >= ACTION_PUSH_PACE_DELTA_SEC and canPushByHr) {
            return _actionPushText;
        }

        return _actionHoldText;
    }

    function _setActionCardByBaseline(elapsedSec) {
        _cardMode = CARD_MODE_ACTION;
        if (_isBaselineReady()) {
            _setCardLinesFromMessage(_resolveActionMessage());
            return;
        }

        _setWarmupCardMessages(elapsedSec);
    }

    function _setWarmupCardMessages(elapsedSec) {
        var slot = -1;
        if (elapsedSec != null) {
            slot = Math.floor(elapsedSec / WARMUP_MESSAGE_ROTATE_SEC);
        }

        if (slot == _warmupMessageSlot and _cardLine1 != null and _cardLine2 != null and _cardLine3 != null) {
            return;
        }
        _warmupMessageSlot = slot;

        if (_warmupMessages.size() == 0) {
            _setCardLinesFromMessage(_actionHoldText);
            return;
        }

        var idx = _randomMessageIndex(_warmupMessages.size(), -1, -1);
        _setCardLinesFromMessage(_warmupMessages[idx]);
    }

    function _setCardLinesFromMessage(message) {
        _cardLine1 = "";
        _cardLine2 = "";
        _cardLine3 = "";

        if (message == null) {
            return;
        }

        var text = message.toString();
        if (text.length() == 0) {
            return;
        }

        var words = _splitWords(text);
        if (words.size() == 0) {
            return;
        }

        _cardLine1 = words[0];

        if (words.size() >= 2) {
            _cardLine2 = words[1];
        }
        if (words.size() >= 3) {
            _cardLine3 = words[2];
            // Card keeps 3 lines. If extra words exist, append to line 3.
            for (var i = 3; i < words.size(); i += 1) {
                _cardLine3 += " " + words[i];
            }
        }
    }

    function _splitWords(text) as Lang.Array {
        var words = [];
        var remaining = text;

        while (remaining != null and remaining.length() > 0) {
            var spaceIndex = remaining.find(" ");
            if (spaceIndex == null) {
                if (remaining.length() > 0) {
                    words.add(remaining);
                }
                break;
            }

            if (spaceIndex > 0) {
                words.add(remaining.substring(0, spaceIndex));
            }

            if ((spaceIndex + 1) >= remaining.length()) {
                break;
            }
            remaining = remaining.substring(spaceIndex + 1, remaining.length());
            while (remaining.length() > 0 and remaining.substring(0, 1) == " ") {
                if (remaining.length() == 1) {
                    remaining = "";
                    break;
                }
                remaining = remaining.substring(1, remaining.length());
            }
            if (remaining.length() == 0) {
                break;
            } else {
                continue;
            }
        }

        return words;
    }

    function _getCardDisplayLines() as Lang.Array {
        var lines = [];
        if (_cardLine1 != null and _cardLine1.length() > 0) {
            lines.add(_cardLine1);
        }
        if (_cardLine2 != null and _cardLine2.length() > 0) {
            lines.add(_cardLine2);
        }
        if (_cardLine3 != null and _cardLine3.length() > 0) {
            lines.add(_cardLine3);
        }
        if (lines.size() == 0) {
            lines.add("");
        }
        return lines;
    }

    function _randomMessageIndex(size, avoid1, avoid2) {
        if (size <= 0) {
            return 0;
        }

        var idx = 0;
        for (var i = 0; i < 10; i += 1) {
            idx = Math.floor(Math.rand()) % size;
            if (idx < 0) {
                idx += size;
            }
            if (idx != avoid1 and idx != avoid2) {
                return idx;
            }
        }

        // Fallback scan in case random values kept colliding.
        for (var j = 0; j < size; j += 1) {
            if (j != avoid1 and j != avoid2) {
                return j;
            }
        }
        return 0;
    }

    function _parseTimeToSec(text) {
        if (text == null) {
            return null;
        }

        var raw = _normalizeTimeText(text.toString());
        if (raw.length() == 0) {
            return null;
        }

        var p1 = raw.find(":");
        if (p1 == null or p1 < 0) {
            return null;
        }

        var tail = raw.substring(p1 + 1, raw.length());
        var p2rel = tail.find(":");
        var hourText = raw.substring(0, p1);
        var minText = "";
        var secText = "0";
        if (p2rel == null or p2rel < 0) {
            minText = tail;
        } else {
            var p2 = p1 + 1 + p2rel;
            minText = raw.substring(p1 + 1, p2);
            secText = raw.substring(p2 + 1, raw.length());
        }

        var h = _parsePositiveInt(hourText);
        var m = _parsePositiveInt(minText);
        var s = _parsePositiveInt(secText);
        if (h == null or m == null or s == null) {
            return null;
        }
        if (m >= 60 or s >= 60) {
            return null;
        }
        return (h * 3600) + (m * 60) + s;
    }

    function _parsePositiveInt(text) {
        var rawText = _normalizeTimeText(text);
        if (rawText == null or rawText.length() == 0) {
            return null;
        }

        var value = 0;
        for (var i = 0; i < rawText.length(); i += 1) {
            var ch = rawText.substring(i, i + 1);
            var digit = _digitValue(ch);
            if (digit == null) {
                return null;
            }
            value = (value * 10) + digit;
        }
        return value;
    }

    function _normalizeTimeText(text) {
        if (text == null) {
            return "";
        }

        var raw = text.toString();
        var normalized = "";
        for (var i = 0; i < raw.length(); i += 1) {
            var ch = raw.substring(i, i + 1);
            if (ch == "：" or ch == "∶") {
                normalized += ":";
                continue;
            }

            var asciiDigit = _fullWidthDigitToAscii(ch);
            if (asciiDigit != null) {
                normalized += asciiDigit;
                continue;
            }
            normalized += ch;
        }

        var start = 0;
        while (start < normalized.length()) {
            var first = normalized.substring(start, start + 1);
            if (first != " " and first != "\t" and first != "　") {
                break;
            }
            start += 1;
        }

        var endExclusive = normalized.length();
        while (endExclusive > start) {
            var last = normalized.substring(endExclusive - 1, endExclusive);
            if (last != " " and last != "\t" and last != "　") {
                break;
            }
            endExclusive -= 1;
        }

        if (start >= endExclusive) {
            return "";
        }
        return normalized.substring(start, endExclusive);
    }

    function _fullWidthDigitToAscii(ch) {
        if (ch == "０") { return "0"; }
        if (ch == "１") { return "1"; }
        if (ch == "２") { return "2"; }
        if (ch == "３") { return "3"; }
        if (ch == "４") { return "4"; }
        if (ch == "５") { return "5"; }
        if (ch == "６") { return "6"; }
        if (ch == "７") { return "7"; }
        if (ch == "８") { return "8"; }
        if (ch == "９") { return "9"; }
        return null;
    }

    function _digitValue(ch) {
        if (ch == "0") { return 0; }
        if (ch == "1") { return 1; }
        if (ch == "2") { return 2; }
        if (ch == "3") { return 3; }
        if (ch == "4") { return 4; }
        if (ch == "5") { return 5; }
        if (ch == "6") { return 6; }
        if (ch == "7") { return 7; }
        if (ch == "8") { return 8; }
        if (ch == "9") { return 9; }
        return null;
    }

    function _extractElapsedSec(info) {
        // Match MessageInGarmin time semantics: use raw timer milliseconds as the time source.
        var rawElapsed = _getElapsedTimeRaw(info);
        if (rawElapsed == null) {
            return null;
        }
        var elapsedSec = rawElapsed / 1000.0;
        if (elapsedSec < 0) {
            elapsedSec = 0;
        }
        return Math.floor(elapsedSec);
    }

    function _formatPaceSecPerKm(paceSecPerKm) {
        var roundedSec = Math.floor(paceSecPerKm + 0.5);
        var minPart = Math.floor(roundedSec / 60);
        var secPart = roundedSec - (minPart * 60);
        return minPart.format("%d") + ":" + secPart.format("%02d");
    }

    function _formatMinSec(totalSec) {
        var roundedSec = Math.floor(totalSec + 0.5);
        var minPart = Math.floor(roundedSec / 60);
        var secPart = roundedSec - (minPart * 60);
        return minPart.format("%d") + ":" + secPart.format("%02d");
    }

    function _formatElapsedTime(totalSec) {
        var sec = Math.floor(totalSec);
        if (sec < 0) {
            sec = 0;
        }
        var hourPart = Math.floor(sec / 3600);
        var remain = sec - (hourPart * 3600);
        var minPart = Math.floor(remain / 60);
        var secPart = remain - (minPart * 60);
        return hourPart.format("%d") + ":" + minPart.format("%02d") + ":" + secPart.format("%02d");
    }

    function _formatDistanceKm(distanceKm) {
        var roundedTenth = Math.floor((distanceKm * 10.0) + 0.5);
        if (roundedTenth < 0) {
            roundedTenth = 0;
        }
        var kmWhole = Math.floor(roundedTenth / 10);
        var kmDecimal = roundedTenth - (kmWhole * 10);
        return kmWhole.format("%d") + "." + kmDecimal.format("%d") + " km";
    }

    function _buildGoalDeltaText(deltaText) {
        if (deltaText == null or deltaText.length() == 0) {
            return _goalTimeLabelText + " " + _formatTargetTimeHourMin();
        }
        return _goalTimeLabelText + " " + _formatTargetTimeHourMin() + " (" + deltaText + ")";
    }

    function _formatTargetTimeHourMin() {
        var sec = _targetTimeSec;
        if (sec == null or sec < 0) {
            sec = _parseTimeToSec(_targetTimeHms);
        }
        if (sec == null or sec < 0) {
            sec = _parseTimeToSec(DEFAULT_TARGET_TIME_HMS);
        }
        if (sec == null or sec < 0) {
            return "05:00";
        }

        var totalSec = Math.floor(sec);
        var hourPart = Math.floor(totalSec / 3600);
        var minPart = Math.floor((totalSec - (hourPart * 3600)) / 60);
        return hourPart.format("%d") + ":" + minPart.format("%02d");
    }

    function _formatSignedDeltaMinSec(deltaSec) {
        var absSec = _abs(deltaSec);
        var roundedAbsSec = Math.floor((absSec + 2.5) / 5) * 5;
        var sign = "+";
        if (deltaSec < -2.5) {
            sign = "-";
        }
        var minPart = Math.floor(roundedAbsSec / 60);
        var secPart = roundedAbsSec - (minPart * 60);
        return sign + minPart.format("%02d") + "m" + secPart.format("%02d") + "s";
    }

    function _textYByRatio(blockTop, blockHeight, ratioPct, fontHeight) {
        return blockTop + ((blockHeight * ratioPct) / 100) - (fontHeight / 2);
    }

    function _clamp(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }

    function _abs(value) {
        if (value < 0) {
            return -value;
        }
        return value;
    }
}
