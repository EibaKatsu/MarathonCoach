using Toybox.Activity;
using Toybox.Attention;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.UserProfile;
using Toybox.WatchUi as Ui;
using BeepUtils;
using CoachUtils;
using CustomModeUtils;
using RaceStrategyUtils;
using RenderUtils;
using SettingsLoader;

class MarathonCoachField extends Ui.DataField {
    const KEY_RACE_DISTANCE_KM = "race_distance_km";
    const KEY_TARGET_TIME_HOUR = "target_time_hour";
    const KEY_TARGET_TIME_MINUTE = "target_time_minute";
    const KEY_CUSTOM_MODE_CODE = "custom_mode_code";
    const LAP_DIAG_LOG = true;
    const FINISH_DIAG_LOG = false;
    const FINISH_DIAG_MARGIN_KM = 1.0;
    const MIN_DISTANCE_FOR_PREDICTION_KM = 0.05;
    const PREDICTION_ON_PACE_THRESHOLD_SEC = 60;
    const SLOPE_UP_THRESHOLD = 0.03;
    const SLOPE_DOWN_THRESHOLD = -0.03;
    const SLOPE_MIN_DISTANCE_DELTA_M = 20.0;
    const ACTION_EASE_PACE_DELTA_SEC = -8;
    const ACTION_PUSH_TRIGGER_SEC = 6;
    const ACTION_PUSH_RELEASE_SEC = 5;
    const ACTION_PUSH_RELEASE_PACE_HYSTERESIS_SEC = 2;
    const ACTION_PUSH_RELEASE_HR_HYSTERESIS_BPM = 1;
    const LAST_SPURT_MAX_DISTANCE_KM = 1.0;
    const ACTION_EASE_MIN_HEADROOM_BPM = 3;
    const ACTION_EASE_BASELINE_HR_DELTA_BPM = 6;
    const DANGER_PACE_EXTRA_SEC = 4;
    const HEART_RATE_DISPLAY_EMA_WINDOW_SEC = 12;
    const HEART_RATE_DISPLAY_EMA_ALPHA = 2.0 / (HEART_RATE_DISPLAY_EMA_WINDOW_SEC + 1.0);
    const HEART_RATE_JUDGE_EMA_WINDOW_SEC = 4;
    const HEART_RATE_JUDGE_EMA_ALPHA = 2.0 / (HEART_RATE_JUDGE_EMA_WINDOW_SEC + 1.0);
    const PACE_EMA_WINDOW_SEC = 18;
    const PACE_EMA_ALPHA = 2.0 / (PACE_EMA_WINDOW_SEC + 1.0);
    const RACE_PROFILE_FULL = 0;
    const RACE_PROFILE_HALF = 1;
    const RACE_PROFILE_SHORT = 2;
    const RACE_PHASE_1 = 0;
    const RACE_PHASE_2 = 1;
    const RACE_PHASE_3 = 2;
    const RACE_PHASE_4 = 3;
    const RACE_PHASE_5 = 4;
    const RACE_PHASE_1_END_PROGRESS = 0.24;
    const RACE_PHASE_2_END_PROGRESS = 0.59;
    const RACE_PHASE_3_END_PROGRESS = 0.83;
    const RACE_PHASE_4_END_PROGRESS = 0.95;
    const SHORT_DISTANCE_MAX_KM = 10.5;
    const HALF_DISTANCE_KM = 21.0975;
    const HALF_DISTANCE_TOLERANCE_KM = 0.25;
    const TEN_DISTANCE_KM = 10.0;
    const SETTINGS_LOG = false;
    const FIT_FACT_LOG = false;
    const DIST_PROBE_LOG = false;
    const TOP_ROW_DIAG_LOG = false;
    const SMALL_TOP_ROW_DIAG_LOG = false;
    const MEDIUM_HR_LAYOUT_DIAG_LOG = false;
    const LARGE_TOP_ROW_DIAG_LOG = false;
    const CRASH_DIAG_LOG = true;
    const MEDIUM_DRAW_BLOCK_DIAG_LOG = false;
    const BEEP_HR_SUPPRESS_SEC = 75;
    const HR_ARC_START_DEG = 180;
    const HR_ARC_CAP_DEG = 255;
    const HR_ARC_MAX_DEG = 270;
    const HR_ARC_STEP_DEG = 3;
    const HR_ARC_OVERFLOW_BPM = 10;
    const HR_ARC_BASE_COLOR = 0x3A4146;
    const HR_ARC_SAFE_COLOR = 0x63C84A;
    const HR_ARC_CAUTION_COLOR = 0xE0C24A;
    const HR_ARC_WARNING_COLOR = 0xF29F67;
    const HR_ARC_DANGER_COLOR = 0xF01818;
    const PACE_INDICATOR_FAST_COLOR = 0x4CC3FF;
    const PACE_INDICATOR_ON_COLOR = 0x63C84A;
    const PACE_INDICATOR_SLOW_COLOR = 0xF6B547;
    const GOAL_RUNNER_GAUGE_TRACK_COLOR = 0xFFD84A;
    const GOAL_RUNNER_GAUGE_RUNNER_COLOR = 0xFFD84A;
    const GOAL_RUNNER_GAUGE_TARGET_COLOR = 0xC9D2D8;
    const GOAL_RUNNER_GAUGE_FLAG_COLOR = 0xFFD84A;
    const GOAL_RUNNER_GAUGE_RANGE_SEC = 10 * 60;
    const GOAL_RUNNER_GAUGE_DEADZONE_SEC = PREDICTION_ON_PACE_THRESHOLD_SEC;

    const DEFAULT_RACE_DISTANCE_KM = 42.195;
    const CUSTOM_MODE_CORE = CustomModeUtils.MODE_CORE;
    const CUSTOM_MODE_CUSTOM = CustomModeUtils.MODE_CUSTOM;
    const HR_GAUGE_ZONE_COUNT = 5;
    const HR_ZONE_COLOR_1 = 0x9E9E9E; // gray
    const HR_ZONE_COLOR_2 = 0x52B7E8; // light blue
    const HR_ZONE_COLOR_3 = 0x63C84A; // yellow-green
    const HR_ZONE_COLOR_4 = 0xF29F67; // orange
    const HR_ZONE_COLOR_5 = 0xF01818; // red
    const HR_CAP_STATE_SAFE = 0;
    const HR_CAP_STATE_CAUTION = 1;
    const HR_CAP_STATE_OVER = 2;

    var _goalPredictionLabelText = "Pred.";
    var _goalPredictionLabelVisible = true;
    var _goalPredictionTimeText = "--:--";
    var _goalPredictionDiffText = "waiting";
    var _goalDiffSecondsText = "--m";
    var _goalDeltaText = "--:--(waiting)";
    var _goalPredictionDeltaSec = null;
    var _predictionWaitingText = "waiting";
    var _predictionOnPaceText = "on pace";
    var _predictionOverText = "Over";
    var _predictionAheadSuffixText = "min.";
    var _predictionBehindSuffixText = "min.";
    var _predictionSystemLanguage = null;
    var _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
    var _customMode = CUSTOM_MODE_CORE;
    var _customCodeValid = false;
    var _customPhaseAggressiveness = CustomModeUtils.DEFAULT_PHASE_AGGRESSIVENESS;
    var _customHrCapBiasBpm = CustomModeUtils.DEFAULT_HR_CAP_BIAS_BPM;
    var _targetTimeHms = null;
    var _targetTimeSec = null;
    var _targetPaceSecPerKm = null;
    var _distanceText = "--.- km";
    var _elapsedTimeText = "--:--:--";
    var _distanceTimeText = "--.- km  --:--:--";
    var _paceNowSecPerKm = null;
    var _paceNowText = "--:--";
    var _lastPaceSampleElapsedSec = null;
    var _paceFallbackLastElapsedSec = null;
    var _paceFallbackLastDistanceKm = null;
    var _timerRunning = false;
    var _lastElapsedSec = null;
    var _currentHeartRate = null;
    var _judgeHeartRate = null;
    var _activeHeartRateZones as Lang.Array<Lang.Number> = [];
    var _currentHeartRateZone = null;
    var _currentHeartRateZoneUpper = null;
    var _currentHeartRateZoneLower = null;
    var _currentHeartRateGaugeRatio = null;
    var _allowedMaxHeartRate = null;
    var _capHeartRateSource = RaceStrategyUtils.CAP_SOURCE_NONE;
    var _capLactateThresholdHeartRate = null;
    var _capProfileMaxHeartRate = null;
    var _capRestingHeartRate = null;
    var _allowedMaxHeartRateZone = null;
    var _allowedMaxHeartRateZoneUpper = null;
    var _allowedMaxHeartRateZoneLower = null;
    var _allowedMaxHeartRateGaugeRatio = null;
    var _hrZoneText = "-- / cap --";
    var _hrOverActive = false;
    var _hrOverStartSec = null;
    var _hrStrongOverStartSec = null;
    var _hrRecoverStartSec = null;
    var _pushActive = false;
    var _pushStartSec = null;
    var _pushRecoverStartSec = null;
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
    var _sampleAltitudeRaw = null;
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
    var _lastSettingsLogLine = null;
    var _lastMediumHrLayoutDiagLine = null;
    var _lastHeartRateTopRowDiagLine = null;
    var _lastPredictionTopRowDiagLine = null;
    var _lastLargeTopRowDiagLine = null;
    var _largeTopRowDiagPrinted = false;
    var _pendingLargeTopHrDiagLine = null;
    var _pendingLargeTopPaceDiagLine = null;
    var _probeLocDistanceM = 0.0;
    var _probeLocLastLocation = null;
    var _probeLocLastElapsedSec = null;
    var _probeSpeedDistanceM = 0.0;
    var _probeSpeedLastElapsedSec = null;
    var _lastDistanceProbeLogLine = null;
    var _lastFinishDiagLine = null;
    var _lastMediumDrawBlockDiagLine = null;
    var _drawStage = "idle";
    var _lastResolvedHeartRateTopRowNumberFont = null;
    var _slopeState = "FL";
    var _slopeAnchorAltitude = null;
    var _slopeAnchorDistanceM = null;
    var _beepStateInitialized = false;
    var _beepPrevHrOver = false;
    var _beepLastHrAlertSec = null;
    var _beepLastElapsedSec = null;

    function initialize() {
        DataField.initialize();
        _loadLocalizedTexts();
        _loadSettings();
    }

    function _loadLocalizedTexts() {
        _goalPredictionLabelText = Ui.loadResource(Rez.Strings.GoalPredictionLabel);
        _goalPredictionLabelVisible = true;
        _predictionWaitingText = Ui.loadResource(Rez.Strings.PredictionWaiting);
        _predictionOnPaceText = Ui.loadResource(Rez.Strings.PredictionOnPace);
        _predictionOverText = Ui.loadResource(Rez.Strings.PredictionOver);
        _predictionAheadSuffixText = Ui.loadResource(Rez.Strings.PredictionAheadSuffix);
        _predictionBehindSuffixText = Ui.loadResource(Rez.Strings.PredictionBehindSuffix);
        _goalPredictionTimeText = _buildGoalPredictionTimeText(null);
        _goalPredictionDiffText = _buildGoalPredictionDiffText(null);
        _goalDiffSecondsText = _buildGoalDiffSecondsText(null);
        _goalDeltaText = _buildGoalDeltaText(null);
        _goalPredictionDeltaSec = null;
    }

    function compute(info) {
        try {
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
            _updateSlopeState(info);
            _updatePushState(info);
            _updateCardDisplay(info);
        } catch (e) {
            _logCrashDiag("compute", e);
            throw e;
        }
        return;
    }

    function onTimerStart() {
        _timerRunning = true;
        _logFinishDiag("timer_start", _lastElapsedSec, _resolveFinishDiagDistanceKm(), false);
    }

    function onTimerResume() {
        _timerRunning = true;
        _logFinishDiag("timer_resume", _lastElapsedSec, _resolveFinishDiagDistanceKm(), false);
    }

    function onTimerPause() {
        _timerRunning = false;
        _logFinishDiag("timer_pause", _lastElapsedSec, _resolveFinishDiagDistanceKm(), false);
    }

    function onTimerStop() {
        _timerRunning = false;
        _logFinishDiag("timer_stop", _lastElapsedSec, _resolveFinishDiagDistanceKm(), false);
    }

    function onTimerReset() {
        _timerRunning = false;
        _lastElapsedSec = null;
        _resetPaceWindow();
        _paceNowSecPerKm = null;
        _paceNowText = "--:--";
        _distanceText = "--.- km";
        _elapsedTimeText = "--:--:--";
        _distanceTimeText = "--.- km  --:--:--";
        _goalPredictionTimeText = _buildGoalPredictionTimeText(null);
        _goalPredictionDiffText = _buildGoalPredictionDiffText(null);
        _goalDiffSecondsText = _buildGoalDiffSecondsText(null);
        _goalDeltaText = _buildGoalDeltaText(null);
        _goalPredictionDeltaSec = null;
        _goalPredictionLabelVisible = true;
        _currentHeartRate = null;
        _judgeHeartRate = null;
        _activeHeartRateZones = [];
        _currentHeartRateZone = null;
        _currentHeartRateZoneUpper = null;
        _currentHeartRateZoneLower = null;
        _currentHeartRateGaugeRatio = null;
        _allowedMaxHeartRate = null;
        _capHeartRateSource = RaceStrategyUtils.CAP_SOURCE_NONE;
        _capLactateThresholdHeartRate = null;
        _capProfileMaxHeartRate = null;
        _capRestingHeartRate = null;
        _allowedMaxHeartRateZone = null;
        _allowedMaxHeartRateZoneUpper = null;
        _allowedMaxHeartRateZoneLower = null;
        _allowedMaxHeartRateGaugeRatio = null;
        _hrZoneText = "-- / cap --";
        _hrOverActive = false;
        _hrOverStartSec = null;
        _hrStrongOverStartSec = null;
        _hrRecoverStartSec = null;
        _pushActive = false;
        _pushStartSec = null;
        _pushRecoverStartSec = null;
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
        _sampleAltitudeRaw = null;
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
        _lastFinishDiagLine = null;
        _probeLocDistanceM = 0.0;
        _probeLocLastLocation = null;
        _probeLocLastElapsedSec = null;
        _probeSpeedDistanceM = 0.0;
        _probeSpeedLastElapsedSec = null;
        _lastDistanceProbeLogLine = null;
        _resetSlopeState();
        _resetBeepState();
    }

    function onTimerLap() {
        _logLapDiag("ignore", "lap_noop", _lastElapsedSec);
    }

    function _logLapDiag(stage, reason, elapsedSec) {
        if (!LAP_DIAG_LOG) {
            return;
        }
        var line =
            "[LAP_DIAG] stage=" + _factValue(stage) +
            " reason=" + _factValue(reason) +
            " elapsed=" + _factValue(elapsedSec) +
            " lastElapsed=" + _factValue(_lastElapsedSec) +
            " mode=" + _factValue(_customMode);
        Sys.println(line);
    }

    function onUpdate(dc as Gfx.Dc) {
        try {
            _drawStage = "onUpdate:start";
            if (LARGE_TOP_ROW_DIAG_LOG and !_largeTopRowDiagPrinted) {
                if (_pendingLargeTopHrDiagLine != null) {
                    Sys.println(_pendingLargeTopHrDiagLine);
                }
                if (_pendingLargeTopPaceDiagLine != null) {
                    Sys.println(_pendingLargeTopPaceDiagLine);
                }
                if (_pendingLargeTopHrDiagLine != null or _pendingLargeTopPaceDiagLine != null) {
                    _largeTopRowDiagPrinted = true;
                }
            }
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
            dc.clear();
            _drawStage = "onUpdate:step3";
            _drawStep3Layout(dc);
            _drawStage = "onUpdate:done";
        } catch (e) {
            _logCrashDiag("onUpdate", e);
            throw e;
        }
    }

    function _loadSettings() {
        _raceDistanceKm = SettingsLoader.loadRaceDistanceKm(
            DEFAULT_RACE_DISTANCE_KM,
            KEY_RACE_DISTANCE_KM
        );
        _targetTimeHms = null;
        _targetTimeSec = null;
        _targetPaceSecPerKm = null;
        _applyCustomModeConfig(SettingsLoader.getPropertyValue(KEY_CUSTOM_MODE_CODE));

        var targetHour = SettingsLoader.loadTargetTimeHour(KEY_TARGET_TIME_HOUR);
        var targetMinute = SettingsLoader.loadTargetTimeMinute(KEY_TARGET_TIME_MINUTE);
        if (targetHour != null and targetMinute != null) {
            var hourInt = Math.floor(targetHour + 0.5);
            var minuteInt = Math.floor(targetMinute + 0.5);
            _targetTimeHms = CoachUtils.formatHourMinuteSecond(hourInt, minuteInt);
            _targetTimeSec = (hourInt * 3600) + (minuteInt * 60);
        }
        if (_targetTimeSec != null and _targetTimeSec > 0 and _raceDistanceKm > 0) {
            _targetPaceSecPerKm = _targetTimeSec / _raceDistanceKm;
        }
        _logSettingsState(targetHour, targetMinute);
    }

    function _applyCustomModeConfig(rawCustomCode) {
        var customConfig = CustomModeUtils.decodeCustomCode(rawCustomCode);
        _customMode = CustomModeUtils.getMode(customConfig);
        _customCodeValid = CustomModeUtils.isCodeValid(customConfig);
        _customPhaseAggressiveness = CustomModeUtils.getPhaseAggressiveness(customConfig);
        _customHrCapBiasBpm = CustomModeUtils.getHrCapBiasBpm(customConfig);
    }

    function _isCustomModeEnabled() {
        return _customMode == CUSTOM_MODE_CUSTOM;
    }

    function _isSameText(left, right) {
        if (left == null or right == null) {
            return left == right;
        }
        try {
            return left == right;
        } catch (e) {
        }
        try {
            return left.toString() == right.toString();
        } catch (e2) {
        }
        return false;
    }

    function _resolvePhaseAggressivenessShift() {
        if (!_isCustomModeEnabled()) {
            return 0;
        }
        return _customPhaseAggressiveness - CustomModeUtils.DEFAULT_PHASE_AGGRESSIVENESS;
    }

    function _resolveHrCapBiasBpm() {
        if (!_isCustomModeEnabled()) {
            return 0;
        }
        return _customHrCapBiasBpm;
    }

    function _signedDivRounded(value, divisor) {
        if (divisor == null or divisor <= 0) {
            return 0;
        }
        if (value >= 0) {
            return Math.floor((value + (divisor / 2)) / divisor);
        }
        return -Math.floor(((-value) + (divisor / 2)) / divisor);
    }

    function _adjustPushPaceThresholdSec(baseThreshold) {
        var shift = _resolvePhaseAggressivenessShift();
        var paceBias = _signedDivRounded(shift, 2);
        return _clamp(baseThreshold - paceBias, 1, 30);
    }

    function _adjustPushHeadroomThresholdBpm(baseThreshold) {
        var shift = _resolvePhaseAggressivenessShift();
        var hrBias = _signedDivRounded(shift, 3);
        return _clamp(baseThreshold - hrBias, 0, 20);
    }

    function _adjustEasePaceThresholdSec(baseThreshold) {
        var shift = _resolvePhaseAggressivenessShift();
        var paceBias = _signedDivRounded(shift, 2);
        return _clamp(baseThreshold - paceBias, -20, -1);
    }

    function _adjustEaseHeadroomThresholdBpm(baseThreshold) {
        var shift = _resolvePhaseAggressivenessShift();
        var hrBias = _signedDivRounded(shift, 3);
        return _clamp(baseThreshold - hrBias, 0, 20);
    }

    function _drawStep3Layout(dc as Gfx.Dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var minDim = _min(width, height);
        var sizeClass = _getSizeClass(minDim);
        if (sizeClass == 0) {
            _drawStep3LayoutSmall(dc, width, height, minDim);
            return;
        }
        if (sizeClass == 1) {
            _drawStep3LayoutMedium(dc, width, height, minDim);
            return;
        }
        _drawStep3LayoutLarge(dc, width, height, minDim);
    }

    function _drawStep3LayoutSmall(dc as Gfx.Dc, width, height, minDim) {
        var insetPct = 4;
        var squareSize = Math.floor(_clamp((minDim * (100 - (insetPct * 2))) / 100, (minDim * 78) / 100, minDim));
        var left = Math.floor((width - squareSize) / 2);
        var top = Math.floor((height - squareSize) / 2);
        _drawDashboardLayout(dc, left, top, squareSize, 0);
    }

    function _drawStep3LayoutMedium(dc as Gfx.Dc, width, height, minDim) {
        var insetPct = 7;
        var squareSize = Math.floor(_clamp((minDim * (100 - (insetPct * 2))) / 100, (minDim * 70) / 100, minDim));
        var left = Math.floor((width - squareSize) / 2);
        var top = Math.floor((height - squareSize) / 2);
        _drawDashboardLayout(dc, left, top, squareSize, 1);
    }

    function _drawStep3LayoutLarge(dc as Gfx.Dc, width, height, minDim) {
        var insetPct = 9;
        var squareSize = Math.floor(_clamp((minDim * (100 - (insetPct * 2))) / 100, (minDim * 72) / 100, minDim));
        var left = Math.floor((width - squareSize) / 2);
        var top = Math.floor((height - squareSize) / 2);
        _drawDashboardLayout(dc, left, top, squareSize, 2);
    }

    function _drawDashboardLayout(dc as Gfx.Dc, left, top, squareSize, sizeClass) {
        var centerX = Math.floor(left + (squareSize / 2));
        var topBandPct = 46;
        var bottomBandPct = 18;
        if (sizeClass == 0) {
            topBandPct = 45;
            bottomBandPct = 19;
        } else if (sizeClass == 2) {
            topBandPct = 45;
            bottomBandPct = 17;
        }

        var topBandH = Math.floor((squareSize * topBandPct) / 100);
        var bottomBandH = Math.floor((squareSize * bottomBandPct) / 100);
        var centerY = top + topBandH;
        var bottomY = top + squareSize - bottomBandH;
        var centerH = bottomY - centerY;
        var heartRateAreaX = left + 2;
        var heartRateAreaY = top + 10;
        var heartRateAreaW = centerX - left - 6;
        var heartRateAreaH = topBandH - 14;
        _drawStage = "layout:heart_rate";
        _logMediumDrawBlockDiag(sizeClass, "heart_rate:start");
        _drawHeartRateDashboard(dc, heartRateAreaX, heartRateAreaY, heartRateAreaW, heartRateAreaH, sizeClass);
        _drawHeartRateCapSourceOverlay(dc, heartRateAreaX, heartRateAreaY, heartRateAreaW, heartRateAreaH, sizeClass);
        _logMediumDrawBlockDiag(sizeClass, "heart_rate:done");
        _drawStage = "layout:prediction";
        _logMediumDrawBlockDiag(sizeClass, "prediction:start");
        _drawPredictionDashboard(dc, centerX + 2, top + 10, (left + squareSize) - centerX - 4, topBandH - 14, sizeClass);
        _logMediumDrawBlockDiag(sizeClass, "prediction:done");

        _drawStage = "layout:bottom_top_y";
        _logMediumDrawBlockDiag(sizeClass, "bottom_top_y:start");
        var bottomTextTopY = _resolveBottomDashboardTextTopY(dc, left, bottomY, squareSize, bottomBandH, sizeClass);
        _logMediumDrawBlockDiag(sizeClass, "bottom_top_y:done");
        _drawStage = "layout:center_pace";
        _logMediumDrawBlockDiag(sizeClass, "center_pace:start");
        _drawCenterPaceDashboard(dc, left, centerY, squareSize, centerH, sizeClass, bottomTextTopY);
        _logMediumDrawBlockDiag(sizeClass, "center_pace:done");
        _drawStage = "layout:bottom";
        _logMediumDrawBlockDiag(sizeClass, "bottom:start");
        _drawBottomDashboard(dc, left, bottomY, squareSize, bottomBandH, sizeClass);
        _logMediumDrawBlockDiag(sizeClass, "bottom:done");
        _drawStage = "layout:done";
    }

    function _drawPredictionDashboard(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var diffFont = Gfx.FONT_LARGE;
        var predictionFont = Gfx.FONT_MEDIUM;
        var diffNumberFont = _resolvePredictionTopRowNumberFont(sizeClass);
        var deltaAffixFont = predictionFont;
        var deltaUnitGap = 1;
        var rowGap = 6;
        var blockOffsetY = 6;
        if (sizeClass == 0) {
            diffFont = Gfx.FONT_MEDIUM;
            predictionFont = Gfx.FONT_SMALL;
            diffNumberFont = _resolvePredictionTopRowNumberFont(sizeClass);
            deltaAffixFont = predictionFont;
            deltaUnitGap = 0;
            rowGap = 4;
            blockOffsetY = 4;
        } else if (sizeClass == 1) {
            diffNumberFont = _resolvePredictionTopRowNumberFont(sizeClass);
            deltaAffixFont = predictionFont;
            deltaUnitGap = 0;
            blockOffsetY = 10;
        } else if (sizeClass == 2) {
            diffNumberFont = _resolvePredictionTopRowNumberFont(sizeClass);
            deltaAffixFont = predictionFont;
            deltaUnitGap = 0;
            rowGap = 8;
            blockOffsetY = 11;
        }

        var predictionText = _goalPredictionTimeText;
        if (predictionText == null or predictionText.length() <= 0) {
            predictionText = "--:--";
        }
        var deltaText = _goalDiffSecondsText;
        if (deltaText == null or deltaText.length() <= 0) {
            deltaText = "--m";
        }
        if (dc.getTextWidthInPixels(deltaText, diffFont) > (areaW - 8) and diffFont == Gfx.FONT_LARGE) {
            diffFont = Gfx.FONT_MEDIUM;
        }
        if (dc.getTextWidthInPixels(predictionText, predictionFont) > (areaW - 8) and predictionFont == Gfx.FONT_MEDIUM) {
            predictionFont = Gfx.FONT_SMALL;
        }

        var centerX = areaX + Math.floor(areaW / 2);
        var deltaParts = _splitNumericValueAndSuffix(deltaText);
        var deltaValueText = deltaParts[0];
        var deltaUnitText = deltaParts[1];
        if (deltaValueText == null) {
            deltaValueText = "";
        }
        if (deltaUnitText == null) {
            deltaUnitText = "";
        }
        var deltaSignParts = _splitLeadingSign(deltaValueText);
        var deltaSignText = deltaSignParts[0];
        var deltaDigitsText = deltaSignParts[1];
        var drawDeltaWithNumberFont = _containsAsciiDigit(deltaDigitsText);
        diffNumberFont = _capPredictionNumberFontToHeartRate(diffNumberFont);
        var predictionLineH = dc.getFontHeight(predictionFont);
        var deltaLineH = dc.getFontHeight(diffFont);
        if (drawDeltaWithNumberFont) {
            deltaLineH = dc.getFontHeight(diffNumberFont);
        }
        var sharedTopLineH = dc.getFontHeight(sizeClass == 0 ? Gfx.FONT_SMALL : Gfx.FONT_MEDIUM);
        var sharedBottomLineH = dc.getFontHeight(sizeClass == 0 ? Gfx.FONT_MEDIUM : Gfx.FONT_LARGE);
        var numberBottomLineH = dc.getFontHeight(_resolveSharedTopRowNumberFont(sizeClass));
        if (numberBottomLineH > sharedBottomLineH) {
            sharedBottomLineH = numberBottomLineH;
        }
        var totalH = sharedTopLineH + rowGap + sharedBottomLineH;
        var anchorY = areaY + Math.floor((areaH - totalH) / 2) + blockOffsetY;
        var predictionY = anchorY + Math.floor((sharedTopLineH - predictionLineH) / 2);
        var deltaY = anchorY + sharedTopLineH + rowGap + Math.floor((sharedBottomLineH - deltaLineH) / 2);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX, predictionY, predictionFont, predictionText, Gfx.TEXT_JUSTIFY_CENTER);
        if (drawDeltaWithNumberFont) {
            _drawPrefixedValueWithTrailingUnitCentered(
                dc,
                centerX,
                deltaY,
                deltaAffixFont,
                deltaSignText,
                diffNumberFont,
                deltaDigitsText,
                deltaAffixFont,
                deltaUnitText,
                deltaUnitGap,
                Gfx.COLOR_WHITE
            );
        } else {
            _drawBoldText(dc, centerX, deltaY, diffFont, deltaText, Gfx.TEXT_JUSTIFY_CENTER, Gfx.COLOR_WHITE);
        }
        _logTopRowLayoutDiag(
            "prediction",
            sizeClass,
            areaX,
            areaY,
            areaW,
            areaH,
            anchorY,
            sharedTopLineH,
            sharedBottomLineH,
            rowGap,
            blockOffsetY,
            predictionLineH,
            deltaLineH,
            predictionY,
            deltaY,
            predictionText,
            deltaText
        );
    }

    function _drawCenterPaceDashboard(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass, bottomTextTopY) {
        var paceFont = Gfx.FONT_LARGE;
        var paceNumberFont = Gfx.FONT_NUMBER_MEDIUM;
        var unitFont = Gfx.FONT_XTINY;
        var contentInset = 14;
        var gaugeGap = 8;
        var gaugeH = 24;
        var gaugeOverlap = 8;
        if (sizeClass == 0) {
            paceNumberFont = Gfx.FONT_NUMBER_MILD;
            contentInset = 10;
            gaugeGap = 6;
            gaugeH = 20;
            gaugeOverlap = 6;
        } else if (sizeClass == 1) {
            paceNumberFont = Gfx.FONT_NUMBER_MEDIUM;
            unitFont = Gfx.FONT_TINY;
            gaugeGap = 10;
        } else if (sizeClass == 2) {
            paceFont = Gfx.FONT_LARGE;
            paceNumberFont = Gfx.FONT_NUMBER_HOT;
            unitFont = Gfx.FONT_TINY;
            contentInset = 18;
            gaugeGap = 12;
            gaugeH = 28;
            gaugeOverlap = 10;
            unitFont = Gfx.FONT_SMALL;
        }

        var centerX = areaX + Math.floor(areaW / 2);
        var laneW = areaW - (contentInset * 2);
        var laneX = areaX + contentInset;
        paceNumberFont = _resolveFittingNumberFontForTrailingUnit(
            dc,
            _paceNowText,
            paceNumberFont,
            "/km",
            unitFont,
            3,
            laneW,
            paceFont
        );
        var paceLineH = dc.getFontHeight(paceNumberFont);
        var totalH = paceLineH + gaugeGap + gaugeH - gaugeOverlap;
        var paceY = areaY + Math.floor((areaH - totalH) / 2);
        var laneY = paceY + paceLineH + gaugeGap - gaugeOverlap;
        if (bottomTextTopY != null) {
            var paceBottomY = paceY + paceLineH;
            if (bottomTextTopY > paceBottomY) {
                var targetTrackY = paceBottomY + Math.floor((bottomTextTopY - paceBottomY) / 2);
                laneY = targetTrackY - gaugeH + 4;
            }
        }
        laneY = _clamp(laneY, areaY, areaY + areaH - gaugeH);
        _drawGoalRunnerGauge(dc, laneX, laneY, laneW, gaugeH, sizeClass);

        _drawValueWithTrailingUnitCenteredAligned(
            dc,
            centerX,
            paceY,
            paceNumberFont,
            _paceNowText,
            unitFont,
            "/km",
            3,
            Gfx.COLOR_WHITE,
            64
        );
    }

    function _drawBottomDashboard(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var distanceFont = Gfx.FONT_MEDIUM;
        var distanceUnitFont = Gfx.FONT_TINY;
        var timeFont = Gfx.FONT_MEDIUM;
        if (sizeClass == 0) {
            distanceFont = Gfx.FONT_MEDIUM;
            distanceUnitFont = Gfx.FONT_XTINY;
            timeFont = Gfx.FONT_MEDIUM;
        } else if (sizeClass == 1) {
            distanceUnitFont = Gfx.FONT_TINY;
        } else if (sizeClass == 2) {
            distanceFont = Gfx.FONT_LARGE;
            timeFont = Gfx.FONT_LARGE;
        }

        var distanceParts = _splitMetricValueAndUnit(_distanceText);
        var distanceValue = distanceParts[0];
        var distanceUnit = distanceParts[1];
        var halfW = Math.floor(areaW / 2);
        var leftCenterX = areaX + Math.floor((halfW * 60) / 100);
        var rightCenterX = areaX + halfW + Math.floor(((areaW - halfW) * 40) / 100);
        var perSideMaxW = Math.floor(halfW * 0.8);

        if (dc.getTextWidthInPixels(_elapsedTimeText, timeFont) > perSideMaxW and timeFont == Gfx.FONT_LARGE) {
            timeFont = Gfx.FONT_MEDIUM;
        }

        var distanceTotalW = dc.getTextWidthInPixels(distanceValue, distanceFont);
        if (distanceUnit.length() > 0) {
            distanceTotalW += 2 + dc.getTextWidthInPixels(distanceUnit, distanceUnitFont);
        }
        if (distanceTotalW > perSideMaxW) {
            if (distanceFont == Gfx.FONT_LARGE) {
                distanceFont = Gfx.FONT_MEDIUM;
            } else {
                distanceFont = Gfx.FONT_SMALL;
            }
            distanceUnitFont = Gfx.FONT_XTINY;
        }

        if (dc.getTextWidthInPixels(_elapsedTimeText, timeFont) > perSideMaxW and timeFont == Gfx.FONT_MEDIUM) {
            timeFont = Gfx.FONT_SMALL;
        }

        var distanceY = areaY + Math.floor((areaH - dc.getFontHeight(distanceFont)) / 2) - 4;
        var timeY = areaY + Math.floor((areaH - dc.getFontHeight(timeFont)) / 2) - 4;

        _drawValueWithTrailingUnitCentered(
            dc,
            leftCenterX,
            distanceY,
            distanceFont,
            distanceValue,
            distanceUnitFont,
            distanceUnit,
            2,
            Gfx.COLOR_WHITE
        );
        _drawBoldText(dc, rightCenterX, timeY, timeFont, _elapsedTimeText, Gfx.TEXT_JUSTIFY_CENTER, Gfx.COLOR_WHITE);
    }

    function _resolveBottomDashboardTextTopY(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var distanceFont = Gfx.FONT_MEDIUM;
        var distanceUnitFont = Gfx.FONT_TINY;
        var timeFont = Gfx.FONT_MEDIUM;
        if (sizeClass == 0) {
            distanceFont = Gfx.FONT_MEDIUM;
            distanceUnitFont = Gfx.FONT_XTINY;
            timeFont = Gfx.FONT_MEDIUM;
        } else if (sizeClass == 1) {
            distanceUnitFont = Gfx.FONT_TINY;
        } else if (sizeClass == 2) {
            distanceFont = Gfx.FONT_LARGE;
            timeFont = Gfx.FONT_LARGE;
        }

        var distanceParts = _splitMetricValueAndUnit(_distanceText);
        var distanceValue = distanceParts[0];
        var distanceUnit = distanceParts[1];
        var halfW = Math.floor(areaW / 2);
        var perSideMaxW = Math.floor(halfW * 0.8);

        if (dc.getTextWidthInPixels(_elapsedTimeText, timeFont) > perSideMaxW and timeFont == Gfx.FONT_LARGE) {
            timeFont = Gfx.FONT_MEDIUM;
        }

        var distanceTotalW = dc.getTextWidthInPixels(distanceValue, distanceFont);
        if (distanceUnit.length() > 0) {
            distanceTotalW += 2 + dc.getTextWidthInPixels(distanceUnit, distanceUnitFont);
        }
        if (distanceTotalW > perSideMaxW) {
            if (distanceFont == Gfx.FONT_LARGE) {
                distanceFont = Gfx.FONT_MEDIUM;
            } else {
                distanceFont = Gfx.FONT_SMALL;
            }
            distanceUnitFont = Gfx.FONT_XTINY;
        }

        if (dc.getTextWidthInPixels(_elapsedTimeText, timeFont) > perSideMaxW and timeFont == Gfx.FONT_MEDIUM) {
            timeFont = Gfx.FONT_SMALL;
        }

        var distanceY = areaY + Math.floor((areaH - dc.getFontHeight(distanceFont)) / 2) - 4;
        var timeY = areaY + Math.floor((areaH - dc.getFontHeight(timeFont)) / 2) - 4;
        return _min(distanceY, timeY);
    }

    function _drawHeartRateDashboard(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var currentFont = Gfx.FONT_LARGE;
        var currentNumberFont = Gfx.FONT_NUMBER_MEDIUM;
        var capValueFont = Gfx.FONT_MEDIUM;
        var displayW = dc.getWidth();
        var displayH = dc.getHeight();
        var minDim = _min(displayW, displayH);
        var screenCenterX = Math.floor(displayW / 2);
        var screenCenterY = Math.floor(displayH / 2);
        var screenRadius = Math.floor(minDim / 2);
        var outerInset = 12;
        var bandThickness = 9;
        if (sizeClass == 0) {
            currentFont = Gfx.FONT_MEDIUM;
            currentNumberFont = Gfx.FONT_NUMBER_MILD;
            capValueFont = Gfx.FONT_SMALL;
            outerInset = 12;
            bandThickness = 9;
        } else if (sizeClass == 1) {
            currentNumberFont = Gfx.FONT_NUMBER_MEDIUM;
            outerInset = 10;
            bandThickness = 10;
        } else if (sizeClass == 2) {
            currentNumberFont = Gfx.FONT_NUMBER_HOT;
            capValueFont = Gfx.FONT_MEDIUM;
            outerInset = 12;
            bandThickness = 12;
        }

        var outerRadius = screenRadius - outerInset;
        if (outerRadius < bandThickness + 2) {
            outerRadius = bandThickness + 2;
        }
        var centerX = areaX + outerRadius + 2;
        var centerY = areaY + outerRadius + 2;
        centerX = screenCenterX;
        centerY = screenCenterY;
        var innerRadius = outerRadius - bandThickness;
        if (innerRadius < 1) {
            innerRadius = 1;
        }
        var fillEndDeg = _resolveHeartRateArcEndDeg();
        var fillColor = _resolveHeartRateArcColor();

        _drawThickArc(dc, centerX, centerY, innerRadius, outerRadius, HR_ARC_START_DEG, HR_ARC_MAX_DEG, HR_ARC_BASE_COLOR);
        if (fillEndDeg > HR_ARC_START_DEG) {
            _drawThickArc(dc, centerX, centerY, innerRadius, outerRadius, HR_ARC_START_DEG, fillEndDeg, fillColor);
        }
        if (_allowedMaxHeartRate != null) {
            _drawRadialTick(dc, centerX, centerY, innerRadius - 2, outerRadius + 2, HR_ARC_CAP_DEG, Gfx.COLOR_WHITE);
        }

        var currentText = _formatHeartRateValueText(_currentHeartRate);
        var capValueText = _resolveHeartRateCapValueText();
        currentNumberFont = _resolveFittingNumberFont(
            dc,
            currentText,
            currentNumberFont,
            areaW - 6,
            currentFont
        );
        _lastResolvedHeartRateTopRowNumberFont = currentNumberFont;
        var textCenterX = areaX + Math.floor(areaW / 2);
        if (sizeClass == 0) {
            textCenterX += 6;
        } else if (sizeClass == 1) {
            textCenterX += 10;
        } else {
            textCenterX += 12;
        }
        var capLineH = dc.getFontHeight(capValueFont);
        var currentLineH = dc.getFontHeight(currentNumberFont);
        var rowGap = 6;
        var blockOffsetY = 6;
        if (sizeClass == 0) {
            blockOffsetY = 4;
        } else if (sizeClass == 1) {
            blockOffsetY = 10;
        } else if (sizeClass == 2) {
            blockOffsetY = 11;
        }
        var sharedTopLineH = dc.getFontHeight(sizeClass == 0 ? Gfx.FONT_SMALL : Gfx.FONT_MEDIUM);
        var sharedBottomLineH = dc.getFontHeight(sizeClass == 0 ? Gfx.FONT_MEDIUM : Gfx.FONT_LARGE);
        var numberBottomLineH = dc.getFontHeight(_resolveSharedTopRowNumberFont(sizeClass));
        if (numberBottomLineH > sharedBottomLineH) {
            sharedBottomLineH = numberBottomLineH;
        }
        var totalTextH = sharedTopLineH + rowGap + sharedBottomLineH;
        var anchorY = areaY + Math.floor((areaH - totalTextH) / 2) + blockOffsetY;
        var capValueY = anchorY + Math.floor((sharedTopLineH - capLineH) / 2);
        var currentY = anchorY + sharedTopLineH + rowGap + Math.floor((sharedBottomLineH - currentLineH) / 2);

        _drawBoldText(dc, textCenterX, currentY, currentNumberFont, currentText, Gfx.TEXT_JUSTIFY_CENTER, Gfx.COLOR_WHITE);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(textCenterX, capValueY, capValueFont, capValueText, Gfx.TEXT_JUSTIFY_CENTER);
        _logTopRowLayoutDiag(
            "heart_rate",
            sizeClass,
            areaX,
            areaY,
            areaW,
            areaH,
            anchorY,
            sharedTopLineH,
            sharedBottomLineH,
            rowGap,
            blockOffsetY,
            capLineH,
            currentLineH,
            capValueY,
            currentY,
            capValueText,
            currentText
        );
    }

    function _drawHeartRateCapSourceOverlay(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var capSourceText = _resolveCapHeartRateSourceBadgeText();
        var capValueText = _resolveHeartRateCapValueText();
        var capValueFont = Gfx.FONT_MEDIUM;
        if (sizeClass == 0) {
            capValueFont = Gfx.FONT_SMALL;
        }
        var capSourceFont = Gfx.FONT_XTINY;
        var capLineH = dc.getFontHeight(capValueFont);
        var capSourceLineH = dc.getFontHeight(capSourceFont);
        var textCenterX = areaX + Math.floor(areaW / 2);
        if (sizeClass == 0) {
            textCenterX += 6;
        } else if (sizeClass == 1) {
            textCenterX += 10;
        } else {
            textCenterX += 12;
        }
        var rowGap = 6;
        var blockOffsetY = 6;
        if (sizeClass == 0) {
            blockOffsetY = 4;
        } else if (sizeClass == 1) {
            blockOffsetY = 10;
        } else if (sizeClass == 2) {
            blockOffsetY = 11;
        }
        var sharedTopLineH = dc.getFontHeight(sizeClass == 0 ? Gfx.FONT_SMALL : Gfx.FONT_MEDIUM);
        var sharedBottomLineH = dc.getFontHeight(sizeClass == 0 ? Gfx.FONT_MEDIUM : Gfx.FONT_LARGE);
        var numberBottomLineH = dc.getFontHeight(_resolveSharedTopRowNumberFont(sizeClass));
        if (numberBottomLineH > sharedBottomLineH) {
            sharedBottomLineH = numberBottomLineH;
        }
        var totalTextH = sharedTopLineH + rowGap + sharedBottomLineH;
        var anchorY = areaY + Math.floor((areaH - totalTextH) / 2) + blockOffsetY;
        var capValueY = anchorY + Math.floor((sharedTopLineH - capLineH) / 2);
        var capSourceY = capValueY + (capLineH - capSourceLineH);
        var capValueW = dc.getTextWidthInPixels(capValueText, capValueFont);
        var capSourceW = dc.getTextWidthInPixels(capSourceText, capSourceFont);
        var capSourceGap = 2;
        var capSourceX = textCenterX - Math.floor(capValueW / 2) - capSourceGap - capSourceW;

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(capSourceX, capSourceY, capSourceFont, capSourceText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawBoldText(dc as Gfx.Dc, drawX, drawY, font, text, justify, textColor) {
        if (text == null or text.length() == 0) {
            return;
        }
        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawX - 1, drawY, font, text, justify);
        dc.drawText(drawX + 1, drawY, font, text, justify);
        dc.drawText(drawX, drawY - 1, font, text, justify);
        dc.drawText(drawX, drawY + 1, font, text, justify);
        dc.drawText(drawX, drawY, font, text, justify);
    }

    function _drawValueWithTrailingUnitCentered(
        dc as Gfx.Dc,
        centerX,
        valueY,
        valueFont,
        valueText,
        unitFont,
        unitText,
        unitGap,
        textColor
    ) {
        _drawValueWithTrailingUnitCenteredWithUnitYOffset(
            dc,
            centerX,
            valueY,
            valueFont,
            valueText,
            unitFont,
            unitText,
            unitGap,
            textColor,
            0
        );
    }

    function _drawValueWithTrailingUnitCenteredAligned(
        dc as Gfx.Dc,
        centerX,
        valueY,
        valueFont,
        valueText,
        unitFont,
        unitText,
        unitGap,
        textColor,
        unitTopRatioPct
    ) {
        if (valueText == null) {
            valueText = "";
        }
        if (unitText == null) {
            unitText = "";
        }

        var valueW = dc.getTextWidthInPixels(valueText, valueFont);
        var unitW = 0;
        if (unitText.length() > 0) {
            unitW = dc.getTextWidthInPixels(unitText, unitFont);
        } else {
            unitGap = 0;
        }
        var totalW = valueW + unitGap + unitW;
        var drawX = centerX - Math.floor(totalW / 2);

        _drawBoldText(dc, drawX, valueY, valueFont, valueText, Gfx.TEXT_JUSTIFY_LEFT, textColor);
        if (unitText.length() <= 0) {
            return;
        }

        var valueFontH = dc.getFontHeight(valueFont);
        var unitFontH = dc.getFontHeight(unitFont);
        var unitY = valueY + Math.floor((valueFontH * unitTopRatioPct) / 100) - Math.floor(unitFontH / 2);
        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawX + valueW + unitGap, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawPrefixedValueWithTrailingUnitCentered(
        dc as Gfx.Dc,
        centerX,
        valueY,
        prefixFont,
        prefixText,
        valueFont,
        valueText,
        unitFont,
        unitText,
        unitGap,
        textColor
    ) {
        if (prefixText == null) {
            prefixText = "";
        }
        if (valueText == null) {
            valueText = "";
        }
        if (unitText == null) {
            unitText = "";
        }

        var prefixW = 0;
        if (prefixText.length() > 0) {
            prefixW = dc.getTextWidthInPixels(prefixText, prefixFont);
        }
        var valueW = dc.getTextWidthInPixels(valueText, valueFont);
        var unitW = 0;
        if (unitText.length() > 0) {
            unitW = dc.getTextWidthInPixels(unitText, unitFont);
        } else {
            unitGap = 0;
        }

        var totalW = prefixW + valueW + unitGap + unitW;
        var drawX = centerX - Math.floor(totalW / 2);
        if (prefixText.length() > 0) {
            _drawBoldText(dc, drawX, valueY, prefixFont, prefixText, Gfx.TEXT_JUSTIFY_LEFT, textColor);
        }
        _drawBoldText(dc, drawX + prefixW, valueY, valueFont, valueText, Gfx.TEXT_JUSTIFY_LEFT, textColor);
        if (unitText.length() <= 0) {
            return;
        }

        var unitY = valueY + dc.getFontHeight(valueFont) - dc.getFontHeight(unitFont) - 1;
        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawX + prefixW + valueW + unitGap, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawValueWithTrailingUnitCenteredWithUnitYOffset(
        dc as Gfx.Dc,
        centerX,
        valueY,
        valueFont,
        valueText,
        unitFont,
        unitText,
        unitGap,
        textColor,
        unitYOffset
    ) {
        if (valueText == null) {
            valueText = "";
        }
        if (unitText == null) {
            unitText = "";
        }

        var valueW = dc.getTextWidthInPixels(valueText, valueFont);
        var unitW = 0;
        if (unitText.length() > 0) {
            unitW = dc.getTextWidthInPixels(unitText, unitFont);
        } else {
            unitGap = 0;
        }
        var totalW = valueW + unitGap + unitW;
        var drawX = centerX - Math.floor(totalW / 2);

        _drawBoldText(dc, drawX, valueY, valueFont, valueText, Gfx.TEXT_JUSTIFY_LEFT, textColor);
        if (unitText.length() <= 0) {
            return;
        }

        var unitY = valueY + dc.getFontHeight(valueFont) - dc.getFontHeight(unitFont) - 1 + unitYOffset;
        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawX + valueW + unitGap, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
    }
    function _resolveFittingNumberFont(dc as Gfx.Dc, text, preferredFont, maxWidth, fallbackFont) {
        if (text == null or text.length() <= 0) {
            return fallbackFont;
        }

        var font = preferredFont;
        while (true) {
            if (dc.getTextWidthInPixels(text, font) <= maxWidth) {
                return font;
            }
            var smallerFont = _shrinkNumberFont(font);
            if (smallerFont == font) {
                break;
            }
            font = smallerFont;
        }
        return fallbackFont;
    }

    function _resolveFittingNumberFontForTrailingUnit(
        dc as Gfx.Dc,
        valueText,
        preferredFont,
        unitText,
        unitFont,
        unitGap,
        maxWidth,
        fallbackFont
    ) {
        if (valueText == null or valueText.length() <= 0) {
            return fallbackFont;
        }

        var font = preferredFont;
        while (true) {
            if (_measureValueWithTrailingUnitWidth(dc, font, valueText, unitFont, unitText, unitGap) <= maxWidth) {
                return font;
            }
            var smallerFont = _shrinkNumberFont(font);
            if (smallerFont == font) {
                break;
            }
            font = smallerFont;
        }
        return fallbackFont;
    }

    function _measureValueWithTrailingUnitWidth(dc as Gfx.Dc, valueFont, valueText, unitFont, unitText, unitGap) {
        var totalW = dc.getTextWidthInPixels(valueText, valueFont);
        if (unitText != null and unitText.length() > 0) {
            totalW += unitGap + dc.getTextWidthInPixels(unitText, unitFont);
        }
        return totalW;
    }

    function _measurePrefixedValueWithTrailingUnitWidth(
        dc as Gfx.Dc,
        prefixFont,
        prefixText,
        valueFont,
        valueText,
        unitFont,
        unitText,
        unitGap
    ) {
        var totalW = _measureValueWithTrailingUnitWidth(dc, valueFont, valueText, unitFont, unitText, unitGap);
        if (prefixText != null and prefixText.length() > 0) {
            totalW += dc.getTextWidthInPixels(prefixText, prefixFont);
        }
        return totalW;
    }

    function _shrinkNumberFont(font) {
        if (font == Gfx.FONT_NUMBER_HOT) {
            return Gfx.FONT_NUMBER_MEDIUM;
        }
        if (font == Gfx.FONT_NUMBER_MEDIUM) {
            return Gfx.FONT_NUMBER_MILD;
        }
        return font;
    }

    function _resolveSharedTopRowNumberFont(sizeClass) {
        if (sizeClass == 0) {
            return Gfx.FONT_NUMBER_MILD;
        }
        if (sizeClass == 1) {
            return Gfx.FONT_NUMBER_MEDIUM;
        }
        return Gfx.FONT_NUMBER_HOT;
    }

    function _resolvePredictionTopRowNumberFont(sizeClass) {
        if (sizeClass == 2) {
            return Gfx.FONT_NUMBER_MEDIUM;
        }
        return _resolveSharedTopRowNumberFont(sizeClass);
    }

    function _capPredictionNumberFontToHeartRate(font) {
        if (_lastResolvedHeartRateTopRowNumberFont == null) {
            return font;
        }
        if (_numberFontRank(_lastResolvedHeartRateTopRowNumberFont) < _numberFontRank(font)) {
            return _lastResolvedHeartRateTopRowNumberFont;
        }
        return font;
    }

    function _numberFontRank(font) {
        if (font == Gfx.FONT_NUMBER_HOT) {
            return 3;
        }
        if (font == Gfx.FONT_NUMBER_MEDIUM) {
            return 2;
        }
        if (font == Gfx.FONT_NUMBER_MILD) {
            return 1;
        }
        return 0;
    }

    function _splitNumericValueAndSuffix(text) as Lang.Array {
        if (text == null or text.length() <= 0 or !_containsAsciiDigit(text)) {
            return [text, ""];
        }

        var splitIndex = text.length();
        while (splitIndex > 0) {
            var ch = text.substring(splitIndex - 1, splitIndex);
            if (_isAsciiAlphabetic(ch)) {
                splitIndex -= 1;
                continue;
            }
            break;
        }

        if (splitIndex >= text.length()) {
            return [text, ""];
        }
        return [text.substring(0, splitIndex), text.substring(splitIndex, text.length())];
    }

    function _splitLeadingSign(text) as Lang.Array {
        if (text == null or text.length() <= 0) {
            return ["", ""];
        }

        var firstChar = text.substring(0, 1);
        if (firstChar == "+" or firstChar == "-") {
            return [firstChar, text.substring(1, text.length())];
        }
        return ["", text];
    }

    function _isNumberFontValueText(text) as Lang.Boolean {
        if (text == null or text.length() <= 0 or !_containsAsciiDigit(text)) {
            return false;
        }

        for (var i = 0; i < text.length(); i += 1) {
            var ch = text.substring(i, i + 1).toString();
            if ("0123456789:.".find(ch) == null) {
                return false;
            }
        }
        return true;
    }

    function _containsAsciiDigit(text) as Lang.Boolean {
        if (text == null) {
            return false;
        }

        for (var i = 0; i < text.length(); i += 1) {
            var ch = text.substring(i, i + 1).toString();
            if ("0123456789".find(ch) != null) {
                return true;
            }
        }
        return false;
    }

    function _isAsciiAlphabetic(ch) as Lang.Boolean {
        if (ch == null or ch.length() <= 0) {
            return false;
        }
        var raw = ch.toString();
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".find(raw) != null;
    }

    function _drawGoalRunnerGauge(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        if (areaW <= 0 or areaH <= 0) {
            return;
        }

        var sideInset = 4;
        var runnerHalfW = 10;
        var runnerLead = 10;
        var flagGap = 12;
        var targetRunnerOffsetY = 3;
        if (sizeClass == 0) {
            sideInset = 2;
            runnerHalfW = 8;
            runnerLead = 8;
            flagGap = 10;
            targetRunnerOffsetY = 2;
        } else if (sizeClass == 2) {
            sideInset = 5;
            runnerHalfW = 12;
            runnerLead = 12;
            flagGap = 14;
            targetRunnerOffsetY = 4;
        }

        var trackStartX = areaX + sideInset;
        var trackEndX = areaX + areaW - sideInset - flagGap;
        if (trackEndX <= trackStartX) {
            return;
        }

        var trackY = areaY + areaH - 4;
        var centerX = trackStartX + Math.floor((trackEndX - trackStartX) / 2);
        dc.setColor(GOAL_RUNNER_GAUGE_TRACK_COLOR, GOAL_RUNNER_GAUGE_TRACK_COLOR);
        dc.fillRectangle(trackStartX, trackY, trackEndX - trackStartX + 1, 2);

        var availableLeft = centerX - (trackStartX + runnerHalfW);
        var availableRight = (trackEndX - runnerLead) - centerX;
        var halfRange = _min(availableLeft, availableRight);
        if (halfRange < 0) {
            halfRange = 0;
        }
        var offsetRatio = _resolveGoalRunnerOffsetRatioForDeltaSec(_goalPredictionDeltaSec);
        var runnerX = centerX + Math.floor((halfRange * offsetRatio) + 0.5);
        if (offsetRatio < 0) {
            runnerX = centerX - Math.floor((halfRange * _abs(offsetRatio)) + 0.5);
        }
        runnerX = _clamp(runnerX, trackStartX + runnerHalfW, trackEndX - runnerLead);

        _drawGoalRunnerIcon(dc, centerX, trackY + targetRunnerOffsetY, sizeClass, GOAL_RUNNER_GAUGE_TARGET_COLOR);
        _drawGoalFlagIcon(dc, trackEndX + flagGap, trackY, sizeClass);
        _drawGoalRunnerIcon(dc, runnerX, trackY, sizeClass, GOAL_RUNNER_GAUGE_RUNNER_COLOR);
    }

    function _drawGoalRunnerIcon(dc as Gfx.Dc, centerX, footY, sizeClass, color) {
        var headRadius = 4;
        var headOffsetY = 17;
        var shoulderOffsetY = 11;
        var hipOffsetY = 6;
        var armBackX = 6;
        var armForwardX = 6;
        var armForwardDrop = 4;
        var legBackX = 6;
        var legBackRise = 4;
        var legForwardX = 8;
        if (sizeClass == 0) {
            headRadius = 3;
            headOffsetY = 13;
            shoulderOffsetY = 9;
            hipOffsetY = 4;
            armBackX = 5;
            armForwardX = 5;
            armForwardDrop = 3;
            legBackX = 5;
            legBackRise = 3;
            legForwardX = 6;
        } else if (sizeClass == 2) {
            headRadius = 4;
            headOffsetY = 19;
            shoulderOffsetY = 12;
            hipOffsetY = 7;
            armBackX = 7;
            armForwardX = 7;
            armForwardDrop = 5;
            legBackX = 7;
            legBackRise = 5;
            legForwardX = 9;
        }

        var headCenterY = footY - headOffsetY;
        var shoulderY = footY - shoulderOffsetY;
        var hipY = footY - hipOffsetY;
        dc.setColor(color, color);
        dc.fillRectangle(
            centerX - (headRadius - 1),
            headCenterY - (headRadius - 1),
            ((headRadius - 1) * 2) + 1,
            ((headRadius - 1) * 2) + 1
        );
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawCircle(centerX, headCenterY, headRadius);
        dc.drawLine(centerX, headCenterY + headRadius + 1, centerX, hipY);
        dc.drawLine(centerX - 1, headCenterY + headRadius + 1, centerX - 1, hipY);
        dc.drawLine(centerX + 1, headCenterY + headRadius + 1, centerX + 1, hipY);
        dc.drawLine(centerX, shoulderY, centerX - armBackX, shoulderY + 2);
        dc.drawLine(centerX, shoulderY + 1, centerX - armBackX, shoulderY + 3);
        dc.drawLine(centerX, shoulderY, centerX + armForwardX, shoulderY + armForwardDrop);
        dc.drawLine(centerX, shoulderY + 1, centerX + armForwardX, shoulderY + armForwardDrop + 1);
        dc.drawLine(centerX, hipY, centerX - legBackX, footY - legBackRise);
        dc.drawLine(centerX, hipY + 1, centerX - legBackX, footY - legBackRise + 1);
        dc.drawLine(centerX, hipY, centerX + legForwardX, footY);
        dc.drawLine(centerX, hipY + 1, centerX + legForwardX, footY + 1);
    }

    function _drawGoalFlagIcon(dc as Gfx.Dc, poleX, footY, sizeClass) {
        var poleH = 17;
        var flagW = 10;
        var flagH = 6;
        if (sizeClass == 0) {
            poleH = 14;
            flagW = 8;
            flagH = 5;
        } else if (sizeClass == 2) {
            poleH = 19;
            flagW = 11;
            flagH = 7;
        }

        var topY = footY - poleH;
        dc.setColor(GOAL_RUNNER_GAUGE_FLAG_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(poleX, topY, poleX, footY + 1);
        dc.drawLine(poleX + 1, topY, poleX + 1, footY + 1);
        _drawGoalFlagFill(dc, poleX, topY, flagW, flagH, GOAL_RUNNER_GAUGE_FLAG_COLOR);
    }

    function _drawGoalFlagFill(dc as Gfx.Dc, poleX, topY, flagW, flagH, color) {
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        for (var row = 0; row < flagH; row += 1) {
            var span = Math.floor((flagW * (flagH - row)) / flagH);
            if (span < 2) {
                span = 2;
            }
            dc.drawLine(poleX, topY + row, poleX + span, topY + row + 1);
        }
    }

    function _drawThickArc(dc as Gfx.Dc, centerX, centerY, innerRadius, outerRadius, startDeg, endDeg, color) {
        if (outerRadius < innerRadius) {
            return;
        }
        if (endDeg < startDeg) {
            var swap = startDeg;
            startDeg = endDeg;
            endDeg = swap;
        }

        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        for (var radius = innerRadius; radius <= outerRadius; radius += 1) {
            var startPoint = _arcPoint(centerX, centerY, radius, startDeg);
            var prevX = startPoint[0];
            var prevY = startPoint[1];
            for (var deg = startDeg + HR_ARC_STEP_DEG; deg <= endDeg; deg += HR_ARC_STEP_DEG) {
                var point = _arcPoint(centerX, centerY, radius, deg);
                dc.drawLine(prevX, prevY, point[0], point[1]);
                prevX = point[0];
                prevY = point[1];
            }
            var endPoint = _arcPoint(centerX, centerY, radius, endDeg);
            dc.drawLine(prevX, prevY, endPoint[0], endPoint[1]);
        }
    }

    function _drawRadialTick(dc as Gfx.Dc, centerX, centerY, innerRadius, outerRadius, angleDeg, color) {
        var innerPoint = _arcPoint(centerX, centerY, innerRadius, angleDeg);
        var outerPoint = _arcPoint(centerX, centerY, outerRadius, angleDeg);
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(innerPoint[0], innerPoint[1], outerPoint[0], outerPoint[1]);
    }

    function _arcPoint(centerX, centerY, radius, angleDeg) as Lang.Array {
        // Screen-space angle basis: 180deg=9 o'clock, 255deg=11:30, 270deg=12 o'clock.
        var rad = (angleDeg * Math.PI) / 180.0;
        var pointX = Math.floor(centerX + (Math.cos(rad) * radius) + 0.5);
        var pointY = Math.floor(centerY + (Math.sin(rad) * radius) + 0.5);
        return [pointX, pointY];
    }

    function _formatHeartRateValueText(heartRate) {
        if (heartRate == null) {
            return "--";
        }
        try {
            return heartRate.format("%d");
        } catch (e) {
        }

        var text = "--";
        try {
            text = heartRate.toString();
        } catch (e2) {
            return "--";
        }
        var decimalIndex = text.find(".");
        if (decimalIndex != null and decimalIndex > 0) {
            return text.substring(0, decimalIndex);
        }
        return text;
    }

    function _resolveHeartRateCapValueText() {
        return _formatHeartRateValueText(_allowedMaxHeartRate);
    }

    function _resolveHeartRateGaugeState() {
        var deltaBpm = _resolveHeartRateDeltaBpm(_currentHeartRate);
        if (deltaBpm == null) {
            return null;
        }
        if (deltaBpm >= RaceStrategyUtils.getHrOverTriggerDeltaBpm()) {
            return HR_CAP_STATE_OVER;
        }
        if (deltaBpm >= -2) {
            return HR_CAP_STATE_CAUTION;
        }
        return HR_CAP_STATE_SAFE;
    }

    function _resolveHeartRateDeltaBpm(heartRate) {
        if (heartRate == null or _allowedMaxHeartRate == null) {
            return null;
        }
        return heartRate - _allowedMaxHeartRate;
    }

    function _resolveHeartRateArcMaxHeartRate() {
        if (_allowedMaxHeartRate == null or _allowedMaxHeartRate <= 0) {
            return null;
        }

        var arcMaxHeartRate = _allowedMaxHeartRate + HR_ARC_OVERFLOW_BPM;
        if (_capProfileMaxHeartRate != null and _capProfileMaxHeartRate > 0 and _capProfileMaxHeartRate < arcMaxHeartRate) {
            arcMaxHeartRate = _capProfileMaxHeartRate;
        }
        if (arcMaxHeartRate < _allowedMaxHeartRate) {
            arcMaxHeartRate = _allowedMaxHeartRate;
        }
        return arcMaxHeartRate;
    }

    function _resolveHeartRateArcEndDeg() {
        if (_currentHeartRate == null) {
            return HR_ARC_START_DEG;
        }

        if (_allowedMaxHeartRate == null or _allowedMaxHeartRate <= 0) {
            var fallbackRatio = _clamp(_resolveHeartRateGaugeRatio(), 0.0, 1.0);
            return HR_ARC_START_DEG + Math.floor(((HR_ARC_MAX_DEG - HR_ARC_START_DEG) * fallbackRatio) + 0.5);
        }

        var clampedCurrentHeartRate = _currentHeartRate;
        if (clampedCurrentHeartRate < 0) {
            clampedCurrentHeartRate = 0;
        }

        if (clampedCurrentHeartRate <= _allowedMaxHeartRate) {
            var capRatio = _clamp((clampedCurrentHeartRate * 1.0) / (_allowedMaxHeartRate * 1.0), 0.0, 1.0);
            return HR_ARC_START_DEG + Math.floor(((HR_ARC_CAP_DEG - HR_ARC_START_DEG) * capRatio) + 0.5);
        }

        var arcMaxHeartRate = _resolveHeartRateArcMaxHeartRate();
        if (arcMaxHeartRate == null or arcMaxHeartRate <= _allowedMaxHeartRate) {
            return HR_ARC_CAP_DEG;
        }

        var overRatio = _clamp(
            ((clampedCurrentHeartRate - _allowedMaxHeartRate) * 1.0) / ((arcMaxHeartRate - _allowedMaxHeartRate) * 1.0),
            0.0,
            1.0
        );
        return HR_ARC_CAP_DEG + Math.floor(((HR_ARC_MAX_DEG - HR_ARC_CAP_DEG) * overRatio) + 0.5);
    }

    function _resolveHeartRateArcColor() {
        var deltaBpm = _resolveHeartRateDeltaBpm(_currentHeartRate);
        if (deltaBpm == null) {
            return HR_ARC_CAUTION_COLOR;
        }
        if (deltaBpm >= RaceStrategyUtils.getHrOverTriggerDeltaBpm()) {
            return HR_ARC_DANGER_COLOR;
        }
        if (deltaBpm >= -2) {
            return HR_ARC_WARNING_COLOR;
        }
        if (deltaBpm >= -5) {
            return HR_ARC_CAUTION_COLOR;
        }
        return HR_ARC_SAFE_COLOR;
    }

    function _resolvePaceDeltaSec() {
        if (_paceNowSecPerKm == null or _targetPaceSecPerKm == null) {
            return null;
        }
        return _paceNowSecPerKm - _targetPaceSecPerKm;
    }

    function _resolvePaceIndicatorIndex() {
        var paceDeltaSec = _resolvePaceDeltaSec();
        if (paceDeltaSec == null) {
            return 2;
        }
        if (paceDeltaSec <= -12) {
            return 0;
        }
        if (paceDeltaSec <= -4) {
            return 1;
        }
        if (paceDeltaSec < 4) {
            return 2;
        }
        if (paceDeltaSec < 12) {
            return 3;
        }
        return 4;
    }

    function _resolvePaceIndicatorColor(indicatorIndex) {
        if (indicatorIndex <= 1) {
            return PACE_INDICATOR_FAST_COLOR;
        }
        if (indicatorIndex == 2) {
            return PACE_INDICATOR_ON_COLOR;
        }
        return PACE_INDICATOR_SLOW_COLOR;
    }

    function _isDangerousPaceDeviation() {
        var paceDeltaSec = _resolvePaceDeltaSec();
        if (paceDeltaSec == null) {
            return false;
        }
        var easePaceDeltaThreshold = _adjustEasePaceThresholdSec(ACTION_EASE_PACE_DELTA_SEC);
        return paceDeltaSec <= (easePaceDeltaThreshold - DANGER_PACE_EXTRA_SEC);
    }

    function _resolveHeartRateGaugeRatio() {
        if (_currentHeartRateGaugeRatio != null) {
            return _currentHeartRateGaugeRatio;
        }
        var ratio = _resolveHeartRateGaugeRatioForHeartRateAndBounds(
            _currentHeartRate,
            _currentHeartRateZone,
            _currentHeartRateZoneUpper,
            _currentHeartRateZoneLower
        );
        if (ratio == null) {
            return 0.5;
        }
        return ratio;
    }

    function _resolveHeartRateCapGaugeRatio() {
        if (_allowedMaxHeartRateGaugeRatio != null) {
            return _allowedMaxHeartRateGaugeRatio;
        }
        return _resolveHeartRateGaugeRatioForHeartRateAndBounds(
            _allowedMaxHeartRate,
            _allowedMaxHeartRateZone,
            _allowedMaxHeartRateZoneUpper,
            _allowedMaxHeartRateZoneLower
        );
    }

    function _resolveHeartRateGaugeRatioForHeartRate(heartRate) {
        var zoneNumber = _resolveHeartRateGaugeZoneNumber(heartRate);
        return _resolveHeartRateGaugeRatioForHeartRateAndZone(heartRate, zoneNumber);
    }

    function _resolveHeartRateGaugeRatioForHeartRateAndZone(heartRate, zoneNumber) {
        var upper = null;
        var lower = null;
        if (zoneNumber != null) {
            upper = _getZoneUpperHeartRate(_activeHeartRateZones, zoneNumber);
            if (zoneNumber > 1) {
                lower = _getZoneUpperHeartRate(_activeHeartRateZones, zoneNumber - 1);
            }
        }
        return _resolveHeartRateGaugeRatioForHeartRateAndBounds(heartRate, zoneNumber, upper, lower);
    }

    function _resolveHeartRateGaugeRatioForHeartRateAndBounds(heartRate, zoneNumber, upper, lower) {
        if (heartRate == null) {
            return null;
        }
        if (zoneNumber == null) {
            return _resolveHeartRateGaugeRatioFallback(heartRate);
        }

        zoneNumber = _clamp(zoneNumber, 1, HR_GAUGE_ZONE_COUNT);
        if (upper == null) {
            return _resolveHeartRateGaugeRatioFallback(heartRate);
        }

        if (lower == null) {
            lower = upper - 20;
            if (lower < 1) {
                lower = 1;
            }
        }
        if (upper <= lower) {
            upper = lower + 1;
        }

        var progress = _clamp(((heartRate - lower) * 1.0) / ((upper - lower) * 1.0), 0.0, 1.0);
        var ratio = ((zoneNumber - 1) + progress) / HR_GAUGE_ZONE_COUNT;
        return _clamp(ratio, 0.0, 1.0);
    }

    function _resolveHeartRateGaugeZoneNumber(heartRate) {
        if (heartRate == null) {
            return null;
        }

        if (heartRate == _currentHeartRate and _currentHeartRateZone != null) {
            return _currentHeartRateZone;
        }

        if (_activeHeartRateZones == null or _activeHeartRateZones.size() == 0) {
            return null;
        }

        for (var i = 0; i < _activeHeartRateZones.size(); i += 1) {
            var upper = _normalizeHeartRateValue(_activeHeartRateZones[i]);
            if (upper == null) {
                continue;
            }
            if (heartRate <= upper) {
                return i + 1;
            }
        }

        return _activeHeartRateZones.size();
    }

    function _resolveHeartRateGaugeRatioFallback(heartRate) {
        return RenderUtils.resolveHeartRateGaugeRatioFallback(heartRate, 80, 200);
    }

    function _min(a, b) {
        return CoachUtils.min(a, b);
    }

    function _max(a, b) {
        return CoachUtils.max(a, b);
    }

    function _getSizeClass(minDim) {
        return RenderUtils.getSizeClass(minDim, 261, 218);
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
            _paceNowSecPerKm = _applyEmaSample(_paceNowSecPerKm, samplePaceSecPerKm, PACE_EMA_ALPHA);
            _lastPaceSampleElapsedSec = elapsedSec;
        }

        if (_paceNowSecPerKm == null) {
            _paceNowSecPerKm = null;
            _paceNowText = "--:--";
            return;
        }

        _paceNowText = CoachUtils.formatPaceSecPerKm(_paceNowSecPerKm);
    }

    function _resetPaceWindow() {
        _paceNowSecPerKm = null;
        _lastPaceSampleElapsedSec = null;
        _paceFallbackLastElapsedSec = null;
        _paceFallbackLastDistanceKm = null;
    }

    function _updateSummaryMetrics(info) {
        var elapsedSec = _extractElapsedSec(info);
        var distanceKm = _extractElapsedDistanceKm(info);
        var hideGoalPrediction = _isPastRaceDistance(distanceKm);

        var distanceText = "--.- km";
        if (distanceKm != null) {
            distanceText = CoachUtils.formatDistanceKm(distanceKm);
        }

        var elapsedText = "--:--:--";
        if (elapsedSec != null) {
            elapsedText = _buildDashboardElapsedText(elapsedSec);
        }

        _distanceText = distanceText;
        _elapsedTimeText = elapsedText;
        _distanceTimeText = distanceText + "  " + elapsedText;
        var predictedTotalSec = null;
        var displayPaceSecPerKm = null;
        if (_paceNowSecPerKm != null) {
            // Keep delta calculation aligned with the pace value shown on screen.
            displayPaceSecPerKm = Math.floor(_paceNowSecPerKm + 0.5);
        }
        if (
            !hideGoalPrediction and
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
            predictedTotalSec = elapsedSec + (remainingDistanceKm * displayPaceSecPerKm);
        }

        if (hideGoalPrediction) {
            var overDistanceText = _buildGoalPredictionOverDistanceText(distanceKm - _raceDistanceKm);
            _goalPredictionLabelVisible = false;
            _goalPredictionTimeText = overDistanceText;
            _goalPredictionDiffText = _predictionOverText;
            _goalDiffSecondsText = _predictionOverText;
            _goalDeltaText = _predictionOverText + " " + overDistanceText;
            _goalPredictionDeltaSec = null;
            _logFinishDiag("summary", elapsedSec, distanceKm, hideGoalPrediction);
            return;
        }

        _goalPredictionDeltaSec = _resolveGoalPredictionDeltaSec(predictedTotalSec);
        _goalPredictionLabelVisible = true;
        _goalPredictionTimeText = _buildGoalPredictionTimeText(predictedTotalSec);
        _goalPredictionDiffText = _buildGoalPredictionDiffText(predictedTotalSec);
        _goalDiffSecondsText = _buildGoalDiffSecondsText(predictedTotalSec);
        _goalDeltaText = _buildGoalDeltaText(predictedTotalSec);
        _logFinishDiag("summary", elapsedSec, distanceKm, hideGoalPrediction);
    }

    function _updateHeartRate(info) {
        var heartRate = _extractCurrentHeartRate(info);
        if (heartRate != null and heartRate > 0) {
            _currentHeartRate = _applyEmaSample(_currentHeartRate, heartRate, HEART_RATE_DISPLAY_EMA_ALPHA);
            _judgeHeartRate = _applyEmaSample(_judgeHeartRate, heartRate, HEART_RATE_JUDGE_EMA_ALPHA);
        } else {
            _currentHeartRate = null;
            _judgeHeartRate = null;
        }

        _activeHeartRateZones = _resolveActiveHeartRateZones();
        _allowedMaxHeartRate = _resolveAllowedMaxHeartRate(info, _activeHeartRateZones);
        _currentHeartRateZone = _resolveHeartRateZone(_currentHeartRate, _activeHeartRateZones);
        _currentHeartRateZoneUpper = _getZoneUpperHeartRate(_activeHeartRateZones, _currentHeartRateZone);
        _currentHeartRateZoneLower = null;
        if (_currentHeartRateZone != null and _currentHeartRateZone > 1) {
            _currentHeartRateZoneLower = _getZoneUpperHeartRate(_activeHeartRateZones, _currentHeartRateZone - 1);
        }
        _currentHeartRateGaugeRatio = _resolveHeartRateGaugeRatioForHeartRateAndBounds(
            _currentHeartRate,
            _currentHeartRateZone,
            _currentHeartRateZoneUpper,
            _currentHeartRateZoneLower
        );
        _allowedMaxHeartRateZone = _resolveHeartRateZone(_allowedMaxHeartRate, _activeHeartRateZones);
        _allowedMaxHeartRateZoneUpper = _getZoneUpperHeartRate(_activeHeartRateZones, _allowedMaxHeartRateZone);
        _allowedMaxHeartRateZoneLower = null;
        if (_allowedMaxHeartRateZone != null and _allowedMaxHeartRateZone > 1) {
            _allowedMaxHeartRateZoneLower = _getZoneUpperHeartRate(_activeHeartRateZones, _allowedMaxHeartRateZone - 1);
        }
        _allowedMaxHeartRateGaugeRatio = _resolveHeartRateGaugeRatioForHeartRateAndBounds(
            _allowedMaxHeartRate,
            _allowedMaxHeartRateZone,
            _allowedMaxHeartRateZoneUpper,
            _allowedMaxHeartRateZoneLower
        );
        var hrText = _formatHeartRateValueText(_currentHeartRate);

        var capText = "--";
        if (_allowedMaxHeartRate != null) {
            capText = _allowedMaxHeartRate.format("%d");
        }
        _hrZoneText = hrText + " / cap " + capText;
        _logMediumHrLayoutDiagState(hrText, capText);
    }

    function _resolveActiveHeartRateZones() as Lang.Array<Lang.Number> {
        var zones = _resolveUsableHeartRateZoneThresholds(_getHeartRateZonesForCurrentSport());
        if (zones != null and zones.size() > 0) {
            return zones;
        }

        var genericZones = _resolveUsableHeartRateZoneThresholds(_getGenericHeartRateZones());
        if (genericZones != null and genericZones.size() > 0) {
            return genericZones;
        }

        return [];
    }

    function _resolveUsableHeartRateZoneThresholds(rawZones) {
        if (rawZones == null or !(rawZones instanceof Lang.Array)) {
            return null;
        }

        if (rawZones.size() >= 6) {
            var docValues = [];
            for (var i = 0; i < 6; i += 1) {
                var docValue = _normalizeHeartRateValue(rawZones[i]);
                if (docValue == null) {
                    return null;
                }
                docValues.add(docValue);
            }
            if (!_isMonotonicHeartRateZoneValues(docValues)) {
                return null;
            }
            var usableValues = [];
            for (var k = 1; k < 6; k += 1) {
                usableValues.add(docValues[k]);
            }
            return usableValues;
        }

        if (rawZones.size() == 5) {
            var fiveValues = [];
            for (var j = 0; j < 5; j += 1) {
                var fiveValue = _normalizeHeartRateValue(rawZones[j]);
                if (fiveValue == null) {
                    return null;
                }
                fiveValues.add(fiveValue);
            }
            if (!_isMonotonicHeartRateZoneValues(fiveValues)) {
                return null;
            }
            return fiveValues;
        }

        return null;
    }

    function _isMonotonicHeartRateZoneValues(values) {
        if (values == null or !(values instanceof Lang.Array) or values.size() == 0) {
            return false;
        }
        for (var i = 1; i < values.size(); i += 1) {
            if (values[i] <= values[i - 1]) {
                return false;
            }
        }
        return true;
    }

    function _resolveAllowedMaxHeartRate(info, zones as Lang.Array<Lang.Number>) {
        var distanceKm = _extractElapsedDistanceKm(info);
        var phase = _resolveRacePhase(distanceKm);
        var profile = _resolveRaceProfile();
        var anchors = _resolveHeartRateAnchorInfo(info);
        _capHeartRateSource = anchors[0];
        _capLactateThresholdHeartRate = anchors[1];
        _capProfileMaxHeartRate = anchors[2];
        _capRestingHeartRate = anchors[3];

        if (_capHeartRateSource == RaceStrategyUtils.CAP_SOURCE_NONE) {
            return null;
        }

        return RaceStrategyUtils.resolveCapHeartRate(
            _capHeartRateSource,
            profile,
            phase,
            _capLactateThresholdHeartRate,
            _capProfileMaxHeartRate,
            _capRestingHeartRate,
            _resolveHrCapBiasBpm()
        );
    }

    function _resolveHeartRateAnchorInfo(info) as Lang.Array {
        var profile = _getUserHeartRateProfile();
        var lthr = _resolveLactateThresholdHeartRate(profile, info);
        var maxHeartRate = _resolveProfileMaxHeartRate(profile, info);
        var restingHeartRate = _resolveProfileRestingHeartRate(profile);
        var source = RaceStrategyUtils.resolveCapSource(lthr, maxHeartRate, restingHeartRate);
        return [source, lthr, maxHeartRate, restingHeartRate];
    }

    function _getUserHeartRateProfile() {
        try {
            return UserProfile.getProfile();
        } catch (e) {
            return null;
        }
    }

    function _resolveLactateThresholdHeartRate(profile, info) {
        var infoValue = _readInfoLactateThresholdHeartRate(info);
        if (infoValue != null) {
            return infoValue;
        }
        return _readProfileLactateThresholdHeartRate(profile);
    }

    function _readInfoLactateThresholdHeartRate(info) {
        if (info != null and info has :lactateThresholdHeartRate) {
            return _normalizeHeartRateValue(info.lactateThresholdHeartRate);
        }
        if (info != null and info has :runningLactateThresholdHeartRate) {
            return _normalizeHeartRateValue(info.runningLactateThresholdHeartRate);
        }
        if (info != null and info has :thresholdHeartRate) {
            return _normalizeHeartRateValue(info.thresholdHeartRate);
        }
        if (info != null and info has :runningThresholdHeartRate) {
            return _normalizeHeartRateValue(info.runningThresholdHeartRate);
        }
        return null;
    }

    function _readProfileLactateThresholdHeartRate(profile) {
        if (profile != null and profile has :lactateThresholdHeartRate) {
            return _normalizeHeartRateValue(profile.lactateThresholdHeartRate);
        }
        if (profile != null and profile has :runningLactateThresholdHeartRate) {
            return _normalizeHeartRateValue(profile.runningLactateThresholdHeartRate);
        }
        if (profile != null and profile has :thresholdHeartRate) {
            return _normalizeHeartRateValue(profile.thresholdHeartRate);
        }
        if (profile != null and profile has :runningThresholdHeartRate) {
            return _normalizeHeartRateValue(profile.runningThresholdHeartRate);
        }
        return null;
    }

    function _resolveProfileMaxHeartRate(profile, info) {
        if (profile != null and profile has :maxHeartRate) {
            var profileMaxHeartRate = _normalizeHeartRateValue(profile.maxHeartRate);
            if (profileMaxHeartRate != null) {
                return profileMaxHeartRate;
            }
        }

        var infoMaxHeartRate = null;
        if (info != null and info has :maxHeartRate) {
            infoMaxHeartRate = _normalizeHeartRateValue(info.maxHeartRate);
        }
        if (infoMaxHeartRate != null) {
            return infoMaxHeartRate;
        }

        var fallbackInfo = _getFallbackActivityInfo();
        if (fallbackInfo != null and fallbackInfo has :maxHeartRate) {
            return _normalizeHeartRateValue(fallbackInfo.maxHeartRate);
        }
        return null;
    }

    function _resolveProfileRestingHeartRate(profile) {
        if (profile != null and profile has :restingHeartRate) {
            var restingHeartRate = _normalizeHeartRateValue(profile.restingHeartRate);
            if (restingHeartRate != null) {
                return restingHeartRate;
            }
        }
        if (profile != null and profile has :averageRestingHeartRate) {
            return _normalizeHeartRateValue(profile.averageRestingHeartRate);
        }
        return null;
    }

    function _resolveCapHeartRateSourceText() {
        if (_capHeartRateSource == RaceStrategyUtils.CAP_SOURCE_LTHR) {
            return "LTHR";
        }
        if (_capHeartRateSource == RaceStrategyUtils.CAP_SOURCE_HRR) {
            return "HRR";
        }
        if (_capHeartRateSource == RaceStrategyUtils.CAP_SOURCE_MAXHR) {
            return "MAXHR";
        }
        return "NONE";
    }

    function _resolveCapHeartRateSourceBadgeText() {
        if (_capHeartRateSource == RaceStrategyUtils.CAP_SOURCE_MAXHR) {
            return "MHR";
        }
        return _resolveCapHeartRateSourceText();
    }

    function _resolveHeartRateZone(heartRate, zones as Lang.Array<Lang.Number>) {
        if (heartRate == null or zones == null or zones.size() == 0) {
            return null;
        }

        for (var i = 0; i < zones.size(); i += 1) {
            var upper = _normalizeHeartRateValue(zones[i]);
            if (upper == null) {
                continue;
            }
            if (heartRate <= upper) {
                return i + 1;
            }
        }

        return zones.size();
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

    function _getZoneUpperHeartRate(zones as Lang.Array<Lang.Number>, zoneNumber) {
        if (zones == null or zones.size() == 0 or zoneNumber == null or zoneNumber <= 0) {
            return null;
        }

        var idx = zoneNumber - 1;
        if (idx < 0) {
            idx = 0;
        }
        if (idx >= zones.size()) {
            idx = zones.size() - 1;
        }

        for (var i = idx; i >= 0; i -= 1) {
            var backward = _normalizeHeartRateValue(zones[i]);
            if (backward != null) {
                return backward;
            }
        }

        for (var j = idx + 1; j < zones.size(); j += 1) {
            var forward = _normalizeHeartRateValue(zones[j]);
            if (forward != null) {
                return forward;
            }
        }

        return null;
    }

    function _normalizeHeartRateValue(value) {
        if (value == null) {
            return null;
        }
        try {
            if (value != value) {
                return null;
            }
            if (value < 1 or value > 300) {
                return null;
            }
        } catch (e) {
            return null;
        }
        return value;
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
        // Keep elapsed time on Activity.Info stream only.
        if (_sampleElapsedRaw != null) {
            return _sampleElapsedRaw;
        }
        if (_sampleTimerRaw != null) {
            return _sampleTimerRaw;
        }
        return null;
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

        var infoElapsedTime = (info != null) ? info.elapsedTime : null;
        if (_isNumericSample(infoElapsedTime)) {
            _sampleElapsedRaw = infoElapsedTime;
            _sampleElapsedSource = "info";
        } else {
            _sampleElapsedRaw = null;
            _sampleElapsedSource = "none";
        }

        var infoTimerTime = (info != null) ? info.timerTime : null;
        if (_isNumericSample(infoTimerTime)) {
            _sampleTimerRaw = infoTimerTime;
            _sampleTimerSource = "info";
        } else {
            _sampleTimerRaw = null;
            _sampleTimerSource = "none";
        }

        // Keep distance strictly on Activity.Info stream; do not mix with fallback source.
        var infoElapsedDistance = (info != null) ? info.elapsedDistance : null;
        if (_isNumericSample(infoElapsedDistance)) {
            _sampleDistanceRawM = infoElapsedDistance;
            _sampleDistanceSource = "info";
        } else {
            _sampleDistanceRawM = null;
            _sampleDistanceSource = "none";
        }

        var infoCurrentSpeed = (info != null) ? info.currentSpeed : null;
        if (_isNumericSample(infoCurrentSpeed)) {
            _sampleCurrentSpeedRaw = infoCurrentSpeed;
            _sampleCurrentSpeedSource = "info";
        } else {
            _sampleCurrentSpeedRaw = null;
            _sampleCurrentSpeedSource = "none";
        }

        var infoAverageSpeed = (info != null) ? info.averageSpeed : null;
        if (_isNumericSample(infoAverageSpeed)) {
            _sampleAverageSpeedRaw = infoAverageSpeed;
            _sampleAverageSpeedSource = "info";
        } else {
            _sampleAverageSpeedRaw = null;
            _sampleAverageSpeedSource = "none";
        }

        var infoAltitude = null;
        if (info != null and info has :altitude) {
            infoAltitude = info.altitude;
        }
        var fallbackAltitude = null;
        if (fallbackInfo != null and fallbackInfo has :altitude) {
            fallbackAltitude = fallbackInfo.altitude;
        }
        _sampleAltitudeRaw = _pickSampleNumber(infoAltitude, fallbackAltitude, "altitude");

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
            if (
                !(fromRad instanceof Lang.Array) or
                !(toRad instanceof Lang.Array) or
                fromRad.size() < 2 or
                toRad.size() < 2
            ) {
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
        if (_isSameText(_lastFactLogLine, line)) {
            return;
        }
        _lastFactLogLine = line;
        Sys.println(line);
    }

    function _logSettingsState(targetHour, targetMinute) {
        if (!SETTINGS_LOG) {
            return;
        }
        var rawRace = SettingsLoader.getPropertyValue(KEY_RACE_DISTANCE_KM);
        var rawHour = SettingsLoader.getPropertyValue(KEY_TARGET_TIME_HOUR);
        var rawMinute = SettingsLoader.getPropertyValue(KEY_TARGET_TIME_MINUTE);
        var rawCustomCode = SettingsLoader.getPropertyValue(KEY_CUSTOM_MODE_CODE);
        var line =
            "[SETTINGS] raceRaw=" + _factValue(rawRace) +
            " hourRaw=" + _factValue(rawHour) +
            " minuteRaw=" + _factValue(rawMinute) +
            " customRaw=" + _factValue(rawCustomCode) +
            " hourNorm=" + _factValue(targetHour) +
            " minuteNorm=" + _factValue(targetMinute) +
            " raceKm=" + _factValue(_raceDistanceKm) +
            " hms=" + _factValue(_targetTimeHms) +
            " sec=" + _factValue(_targetTimeSec) +
            " paceSecPerKm=" + _factValue(_targetPaceSecPerKm) +
            " mode=" + _factValue(_customMode) +
            " codeValid=" + _factValue(_customCodeValid) +
            " aggr=" + _factValue(_customPhaseAggressiveness) +
            " hrBias=" + _factValue(_customHrCapBiasBpm);
        if (_isSameText(_lastSettingsLogLine, line)) {
            return;
        }
        _lastSettingsLogLine = line;
        Sys.println(line);
    }

    function _logMediumHrLayoutDiagState(hrText, capText) {
        if (!MEDIUM_HR_LAYOUT_DIAG_LOG) {
            return;
        }

        var line =
            "[MEDIUM_HR_DIAG]" +
            " hr=" + _factValue(_currentHeartRate) +
            " judgeHr=" + _factValue(_judgeHeartRate) +
            " cap=" + _factValue(_allowedMaxHeartRate) +
            " capSource=" + _resolveCapHeartRateSourceText() +
            " lthr=" + _factValue(_capLactateThresholdHeartRate) +
            " maxHr=" + _factValue(_capProfileMaxHeartRate) +
            " restingHr=" + _factValue(_capRestingHeartRate) +
            " state=" + _factValue(_resolveHeartRateGaugeState()) +
            " hrText=" + _factValue(hrText) +
            " capText=" + _factValue(capText);
        if (_isSameText(_lastMediumHrLayoutDiagLine, line)) {
            return;
        }
        _lastMediumHrLayoutDiagLine = line;
        Sys.println(line);
    }

    function _logTopRowLayoutDiag(side, sizeClass, areaX, areaY, areaW, areaH, anchorY, topLineH, bottomLineH, rowGap, blockOffsetY, firstLineH, secondLineH, firstY, secondY, firstText, secondText) {
        if (!TOP_ROW_DIAG_LOG) {
            return;
        }

        var line =
            "[TOP_ROW_DIAG]" +
            " side=" + _factValue(side) +
            " sizeClass=" + _factValue(sizeClass) +
            " area=" + _factValue(areaX) + "," + _factValue(areaY) + "," + _factValue(areaW) + "," + _factValue(areaH) +
            " anchorY=" + _factValue(anchorY) +
            " topLineH=" + _factValue(topLineH) +
            " bottomLineH=" + _factValue(bottomLineH) +
            " rowGap=" + _factValue(rowGap) +
            " blockOffsetY=" + _factValue(blockOffsetY) +
            " firstLineH=" + _factValue(firstLineH) +
            " secondLineH=" + _factValue(secondLineH) +
            " firstY=" + _factValue(firstY) +
            " secondY=" + _factValue(secondY) +
            " firstText=" + _factValue(firstText) +
            " secondText=" + _factValue(secondText);
        var lastLine = _lastPredictionTopRowDiagLine;
        if (side == "heart_rate") {
            lastLine = _lastHeartRateTopRowDiagLine;
        }
        if (_isSameText(lastLine, line)) {
            return;
        }
        if (side == "heart_rate") {
            _lastHeartRateTopRowDiagLine = line;
        } else {
            _lastPredictionTopRowDiagLine = line;
        }
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
        if (_isSameText(_lastDistanceProbeLogLine, line)) {
            return;
        }
        _lastDistanceProbeLogLine = line;
        Sys.println(line);
    }

    function _logMediumDrawBlockDiag(sizeClass, stage) {
        if (!MEDIUM_DRAW_BLOCK_DIAG_LOG) {
            return;
        }
        if (sizeClass != 1) {
            return;
        }

        var line = "[MEDIUM_DRAW_BLOCK] stage=" + _factValue(stage) + " drawStage=" + _factValue(_drawStage);
        if (_isSameText(_lastMediumDrawBlockDiagLine, line)) {
            return;
        }
        _lastMediumDrawBlockDiagLine = line;
        Sys.println(line);
    }

    function _factValue(value) {
        if (value == null) {
            return "null";
        }
        return value.toString();
    }

    function _shouldLogFinishDiag(stage, distanceKm) {
        if (!FINISH_DIAG_LOG) {
            return false;
        }
        if (stage != "summary") {
            return true;
        }
        if (distanceKm == null or _raceDistanceKm == null or _raceDistanceKm <= 0) {
            return false;
        }
        return distanceKm >= (_raceDistanceKm - FINISH_DIAG_MARGIN_KM);
    }

    function _logFinishDiag(stage, elapsedSec, distanceKm, hideGoalPrediction) {
        if (!_shouldLogFinishDiag(stage, distanceKm)) {
            return;
        }

        var overDistanceKm = null;
        if (distanceKm != null and _raceDistanceKm != null) {
            overDistanceKm = distanceKm - _raceDistanceKm;
        }

        var line =
            "[FINISH_DIAG]" +
            " stage=" + _factValue(stage) +
            " elapsed=" + _factValue(elapsedSec) +
            " timerRunning=" + _factValue(_timerRunning) +
            " distanceKm=" + _factValue(distanceKm) +
            " raceKm=" + _factValue(_raceDistanceKm) +
            " overKm=" + _factValue(overDistanceKm) +
            " sampleTimerRaw=" + _factValue(_sampleTimerRaw) + "(" + _sampleTimerSource + ")" +
            " sampleDistanceRawM=" + _factValue(_sampleDistanceRawM) + "(" + _sampleDistanceSource + ")" +
            " paceNow=" + _factValue(_paceNowSecPerKm) +
            " hideGoalPrediction=" + _factValue(hideGoalPrediction) +
            " labelVisible=" + _factValue(_goalPredictionLabelVisible) +
            " timeText=" + _factValue(_goalPredictionTimeText) +
            " diffText=" + _factValue(_goalPredictionDiffText) +
            " deltaText=" + _factValue(_goalDeltaText) +
            " distanceText=" + _factValue(_distanceText) +
            " elapsedText=" + _factValue(_elapsedTimeText);
        if (_isSameText(_lastFinishDiagLine, line)) {
            return;
        }
        _lastFinishDiagLine = line;
        Sys.println(line);
    }

    function _logCrashDiag(stage, errorValue) {
        if (!CRASH_DIAG_LOG) {
            return;
        }

        var line =
            "[CRASH_DIAG]" +
            " stage=" + _factValue(stage) +
            " drawStage=" + _factValue(_drawStage) +
            " error=" + _factValue(errorValue) +
            " elapsed=" + _factValue(_lastElapsedSec) +
            " slope=" + _factValue(_slopeState) +
            " hr=" + _factValue(_currentHeartRate) +
            " cap=" + _factValue(_allowedMaxHeartRate) +
            " paceNow=" + _factValue(_paceNowSecPerKm) +
            " paceText=" + _factValue(_paceNowText);
        Sys.println(line);
    }

    function _resolveRaceProfile() {
        return RaceStrategyUtils.resolveRaceProfile(
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM
        );
    }

    function _resolveRaceProgress(distanceKm) {
        return RaceStrategyUtils.resolveRaceProgress(distanceKm, _raceDistanceKm);
    }

    function _resolveRacePhase(distanceKm) {
        return RaceStrategyUtils.resolveRacePhase(
            distanceKm,
            _raceDistanceKm,
            RACE_PHASE_1_END_PROGRESS,
            RACE_PHASE_2_END_PROGRESS,
            RACE_PHASE_3_END_PROGRESS,
            RACE_PHASE_4_END_PROGRESS
        );
    }

    function _getAllowedZoneNumber(distanceKm) {
        return RaceStrategyUtils.getAllowedZoneNumber(
            distanceKm,
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM,
            RACE_PHASE_1_END_PROGRESS,
            RACE_PHASE_2_END_PROGRESS,
            RACE_PHASE_3_END_PROGRESS,
            RACE_PHASE_4_END_PROGRESS
        );
    }

    function _getAllowedZoneOffsetBpm(distanceKm) {
        return RaceStrategyUtils.getAllowedZoneOffsetBpm(
            distanceKm,
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM,
            RACE_PHASE_1_END_PROGRESS,
            RACE_PHASE_2_END_PROGRESS,
            RACE_PHASE_3_END_PROGRESS,
            RACE_PHASE_4_END_PROGRESS
        );
    }

    function _getHrOverTriggerSec(distanceKm) {
        return RaceStrategyUtils.getHrOverTriggerSec(null, null, null, null, null, null);
    }

    function _getHrOverStrongTriggerSec() {
        return RaceStrategyUtils.getHrOverStrongTriggerSec();
    }

    function _getHrOverReleaseSec(distanceKm) {
        return RaceStrategyUtils.getHrOverReleaseSec(null);
    }

    function _getHrOverReleaseOffsetBpm(distanceKm) {
        return RaceStrategyUtils.getHrOverReleaseOffsetBpm(null, null, null, null, null, null);
    }

    function _getPushPaceDeltaThresholdSec(distanceKm) {
        return RaceStrategyUtils.getPushPaceDeltaThresholdSec(
            distanceKm,
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM,
            RACE_PHASE_1_END_PROGRESS,
            RACE_PHASE_2_END_PROGRESS,
            RACE_PHASE_3_END_PROGRESS,
            RACE_PHASE_4_END_PROGRESS
        );
    }

    function _getPushHeadroomThresholdBpm(distanceKm) {
        return RaceStrategyUtils.getPushHeadroomThresholdBpm(
            distanceKm,
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM,
            RACE_PHASE_1_END_PROGRESS,
            RACE_PHASE_2_END_PROGRESS,
            RACE_PHASE_3_END_PROGRESS,
            RACE_PHASE_4_END_PROGRESS
        );
    }

    function _getActionEaseMinHeadroomBpm(distanceKm) {
        return RaceStrategyUtils.getActionEaseMinHeadroomBpm(
            distanceKm,
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM,
            ACTION_EASE_MIN_HEADROOM_BPM
        );
    }

    function _updateSlopeState(info) {
        var altitude = _sampleAltitudeRaw;
        var distanceKm = _extractElapsedDistanceKm(info);
        if (altitude == null or distanceKm == null) {
            return;
        }

        var distanceM = distanceKm * 1000.0;
        if (_slopeAnchorAltitude == null or _slopeAnchorDistanceM == null) {
            _slopeAnchorAltitude = altitude;
            _slopeAnchorDistanceM = distanceM;
            return;
        }

        var deltaDistanceM = distanceM - _slopeAnchorDistanceM;
        if (deltaDistanceM <= 0) {
            _resetSlopeState();
            _slopeAnchorAltitude = altitude;
            _slopeAnchorDistanceM = distanceM;
            return;
        }
        if (deltaDistanceM < SLOPE_MIN_DISTANCE_DELTA_M) {
            return;
        }

        var deltaAltitude = altitude - _slopeAnchorAltitude;
        var grade = deltaAltitude / deltaDistanceM;
        if (grade >= SLOPE_UP_THRESHOLD) {
            _slopeState = "UP";
        } else if (grade <= SLOPE_DOWN_THRESHOLD) {
            _slopeState = "DN";
        } else {
            _slopeState = "FL";
        }

        _slopeAnchorAltitude = altitude;
        _slopeAnchorDistanceM = distanceM;
    }

    function _resetSlopeState() {
        _slopeState = "FL";
        _slopeAnchorAltitude = null;
        _slopeAnchorDistanceM = null;
    }

    function _updateCardDisplay(info) {
        var elapsedSec = _extractElapsedSec(info);
        var hrOver = _isHeartRateOverCap();
        _updateBeepNotifications(elapsedSec, hrOver);
    }

    function _isLastSpurtSegment(info) {
        var distanceKm = _extractElapsedDistanceKm(info);
        if (
            distanceKm == null or
            _raceDistanceKm == null or
            _raceDistanceKm <= 0
        ) {
            return false;
        }

        var remainingDistanceKm = _raceDistanceKm - distanceKm;
        if (remainingDistanceKm < 0) {
            remainingDistanceKm = 0;
        }

        var progressThresholdDistanceKm = _raceDistanceKm * (1.0 - RACE_PHASE_4_END_PROGRESS);
        var triggerRemainingDistanceKm = progressThresholdDistanceKm;
        if (triggerRemainingDistanceKm > LAST_SPURT_MAX_DISTANCE_KM) {
            triggerRemainingDistanceKm = LAST_SPURT_MAX_DISTANCE_KM;
        }

        return remainingDistanceKm <= triggerRemainingDistanceKm;
    }

    function _updateBeepNotifications(elapsedSec, hrOver) {
        if (elapsedSec == null) {
            _resetBeepState();
            return;
        }
        if (_beepLastElapsedSec != null and elapsedSec < _beepLastElapsedSec) {
            _resetBeepState();
        }
        _beepLastElapsedSec = elapsedSec;

        if (!_beepStateInitialized) {
            _beepPrevHrOver = hrOver;
            _beepStateInitialized = true;
            return;
        }

        var beepEvent = BeepUtils.EVENT_NONE;
        if (hrOver and !_beepPrevHrOver) {
            if (_beepLastHrAlertSec == null or (elapsedSec - _beepLastHrAlertSec) >= BEEP_HR_SUPPRESS_SEC) {
                beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_HR_OVER);
                _beepLastHrAlertSec = elapsedSec;
            }
        }

        _playBeepEvent(beepEvent);
        _beepPrevHrOver = hrOver;
    }

    function _resetBeepState() {
        _beepStateInitialized = false;
        _beepPrevHrOver = false;
        _beepLastHrAlertSec = null;
        _beepLastElapsedSec = null;
    }

    function _playBeepEvent(beepEvent) {
        var beepLevel = BeepUtils.resolveBeepLevel(beepEvent);
        if (beepLevel <= 0) {
            return;
        }
        _playBeepPattern(beepLevel);
    }

    function _playBeepPattern(beepCount) {
        if (beepCount <= 0 or !(Attention has :playTone)) {
            return;
        }

        try {
            if (Attention has :ToneProfile) {
                var toneProfile = [];
                for (var i = 0; i < beepCount; i += 1) {
                    toneProfile.add(new Attention.ToneProfile(5200, 80));
                    if (i < (beepCount - 1)) {
                        toneProfile.add(new Attention.ToneProfile(2200, 50));
                    }
                }
                Attention.playTone({:toneProfile => toneProfile});
                return;
            }

            for (var j = 0; j < beepCount; j += 1) {
                Attention.playTone(Attention.TONE_LOUD_BEEP);
            }
        } catch (e) {
        }
    }

    function _isHeartRateOverCap() {
        return _hrOverActive;
    }

    function _updateHrOverState(info) {
        if (_judgeHeartRate == null or _allowedMaxHeartRate == null) {
            _hrOverActive = false;
            _hrOverStartSec = null;
            _hrStrongOverStartSec = null;
            _hrRecoverStartSec = null;
            return;
        }

        var elapsedSec = _extractElapsedSec(info);
        if (elapsedSec == null) {
            _hrOverActive = false;
            _hrOverStartSec = null;
            _hrStrongOverStartSec = null;
            _hrRecoverStartSec = null;
            return;
        }

        if (!_hrOverActive) {
            if (_judgeHeartRate >= (_allowedMaxHeartRate + RaceStrategyUtils.getHrOverTriggerDeltaBpm())) {
                if (_hrOverStartSec == null or elapsedSec < _hrOverStartSec) {
                    _hrOverStartSec = elapsedSec;
                }
            } else {
                _hrOverStartSec = null;
            }

            if (_judgeHeartRate >= (_allowedMaxHeartRate + RaceStrategyUtils.getHrOverStrongTriggerDeltaBpm())) {
                if (_hrStrongOverStartSec == null or elapsedSec < _hrStrongOverStartSec) {
                    _hrStrongOverStartSec = elapsedSec;
                }
            } else {
                _hrStrongOverStartSec = null;
            }

            if (
                _hrStrongOverStartSec != null and
                (elapsedSec - _hrStrongOverStartSec) >= _getHrOverStrongTriggerSec()
            ) {
                _hrOverActive = true;
                _hrRecoverStartSec = null;
                return;
            }

            if (
                _hrOverStartSec != null and
                (elapsedSec - _hrOverStartSec) >= _getHrOverTriggerSec(null)
            ) {
                _hrOverActive = true;
                _hrRecoverStartSec = null;
            }
            return;
        }

        _hrOverStartSec = null;
        _hrStrongOverStartSec = null;
        if (_judgeHeartRate <= (_allowedMaxHeartRate - _getHrOverReleaseOffsetBpm(null))) {
            if (_hrRecoverStartSec == null or elapsedSec < _hrRecoverStartSec) {
                _hrRecoverStartSec = elapsedSec;
            }
        } else {
            _hrRecoverStartSec = null;
        }
        if (_hrRecoverStartSec != null and (elapsedSec - _hrRecoverStartSec) >= _getHrOverReleaseSec(null)) {
            _hrOverActive = false;
            _hrRecoverStartSec = null;
        }
    }

    function _updatePushState(info) {
        var elapsedSec = _extractElapsedSec(info);
        if (elapsedSec == null) {
            _resetPushState();
            return;
        }

        if (_isLastSpurtSegment(info)) {
            _resetPushState();
            return;
        }

        if (_hrOverActive) {
            _resetPushState();
            return;
        }

        if (
            _paceNowSecPerKm == null or
            _targetPaceSecPerKm == null or
            _allowedMaxHeartRate == null or
            _currentHeartRate == null
        ) {
            _resetPushState();
            return;
        }

        var distanceKm = _extractElapsedDistanceKm(info);
        var paceDeltaSec = _paceNowSecPerKm - _targetPaceSecPerKm;
        var headroomBpm = _allowedMaxHeartRate - _currentHeartRate;
        var paceTriggerThreshold = _adjustPushPaceThresholdSec(_getPushPaceDeltaThresholdSec(distanceKm));
        var headroomTriggerThreshold = _adjustPushHeadroomThresholdBpm(_getPushHeadroomThresholdBpm(distanceKm));
        var canTrigger = (
            paceDeltaSec >= paceTriggerThreshold and
            headroomBpm >= headroomTriggerThreshold
        );

        if (!_pushActive) {
            _pushRecoverStartSec = null;
            if (canTrigger) {
                if (_pushStartSec == null or elapsedSec < _pushStartSec) {
                    _pushStartSec = elapsedSec;
                }
                if ((elapsedSec - _pushStartSec) >= ACTION_PUSH_TRIGGER_SEC) {
                    _pushActive = true;
                    _pushStartSec = null;
                }
            } else {
                _pushStartSec = null;
            }
            return;
        }

        _pushStartSec = null;
        var paceReleaseThreshold = paceTriggerThreshold - ACTION_PUSH_RELEASE_PACE_HYSTERESIS_SEC;
        var headroomReleaseThreshold = headroomTriggerThreshold - ACTION_PUSH_RELEASE_HR_HYSTERESIS_BPM;
        if (headroomReleaseThreshold < 0) {
            headroomReleaseThreshold = 0;
        }
        var shouldRelease = (
            paceDeltaSec < paceReleaseThreshold or
            headroomBpm < headroomReleaseThreshold
        );
        if (!shouldRelease) {
            _pushRecoverStartSec = null;
            return;
        }

        if (_pushRecoverStartSec == null or elapsedSec < _pushRecoverStartSec) {
            _pushRecoverStartSec = elapsedSec;
        }
        if ((elapsedSec - _pushRecoverStartSec) >= ACTION_PUSH_RELEASE_SEC) {
            _pushActive = false;
            _pushRecoverStartSec = null;
        }
    }

    function _resetPushState() {
        _pushActive = false;
        _pushStartSec = null;
        _pushRecoverStartSec = null;
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

    function _buildGoalPredictionTimeText(predictedTotalSec) {
        var predictedText = "--:--";
        if (predictedTotalSec != null and predictedTotalSec >= 0) {
            predictedText = CoachUtils.formatHourMin(predictedTotalSec);
        }
        return predictedText;
    }

    function _buildGoalDiffSecondsText(predictedTotalSec) {
        if (
            predictedTotalSec == null or
            _targetTimeSec == null or
            _targetTimeSec <= 0
        ) {
            return "--m";
        }

        var deltaSec = predictedTotalSec - _targetTimeSec;
        if (_abs(deltaSec) < 0.5) {
            return "0m";
        }
        var sign = "+";
        if (deltaSec < 0) {
            sign = "-";
        }
        var deltaMin = Math.floor((_abs(deltaSec) + 30) / 60);
        if (deltaMin <= 0) {
            deltaMin = 1;
        }
        return sign + deltaMin.format("%d") + "m";
    }

    function _resolveGoalPredictionDeltaSec(predictedTotalSec) {
        if (
            predictedTotalSec == null or
            _targetTimeSec == null or
            _targetTimeSec <= 0
        ) {
            return null;
        }
        return predictedTotalSec - _targetTimeSec;
    }

    function _resolveGoalRunnerOffsetRatioForDeltaSec(deltaSec) {
        if (deltaSec == null) {
            return 0.0;
        }

        var signedAheadSec = -deltaSec;
        var absAheadSec = _abs(signedAheadSec);
        if (absAheadSec <= GOAL_RUNNER_GAUGE_DEADZONE_SEC) {
            return 0.0;
        }

        var usableRangeSec = GOAL_RUNNER_GAUGE_RANGE_SEC - GOAL_RUNNER_GAUGE_DEADZONE_SEC;
        if (usableRangeSec <= 0) {
            return 0.0;
        }

        var scaled = ((absAheadSec - GOAL_RUNNER_GAUGE_DEADZONE_SEC) * 1.0) / usableRangeSec;
        if (signedAheadSec < 0) {
            scaled = -scaled;
        }
        return _clamp(scaled, -1.0, 1.0);
    }

    function _buildDashboardElapsedText(elapsedSec) {
        if (elapsedSec == null) {
            return "--:--";
        }
        if (elapsedSec < 3600) {
            return CoachUtils.formatMinSec(elapsedSec);
        }
        return CoachUtils.formatElapsedTime(elapsedSec);
    }

    function _splitMetricValueAndUnit(metricText) as Lang.Array {
        if (metricText == null) {
            return ["", ""];
        }
        var splitIndex = metricText.find(" ");
        if (splitIndex == null) {
            return [metricText, ""];
        }
        return [
            metricText.substring(0, splitIndex),
            metricText.substring(splitIndex + 1, metricText.length())
        ];
    }


    function _resolveFinishDiagDistanceKm() {
        if (!_isNumericSample(_sampleDistanceRawM) or _sampleDistanceRawM < 0) {
            return null;
        }
        return _sampleDistanceRawM / 1000.0;
    }

    function _hasGoalPredictionDisplay() {
        return _goalPredictionTimeText != null and _goalPredictionTimeText.length() > 0;
    }

    function _buildGoalPredictionOverDistanceText(overDistanceKm) {
        if (overDistanceKm == null or overDistanceKm < 0) {
            overDistanceKm = 0;
        }

        var roundedHundredths = Math.floor((overDistanceKm * 100.0) + 0.5);
        var wholeKm = Math.floor(roundedHundredths / 100);
        var fractionKm = roundedHundredths - (wholeKm * 100);
        var fractionText = fractionKm.format("%d");
        if (fractionKm < 10) {
            fractionText = "0" + fractionText;
        }
        return "+" + wholeKm.format("%d") + "." + fractionText + "km";
    }

    function _applyEmaSample(previousValue, sampleValue, alpha) {
        if (sampleValue == null) {
            return previousValue;
        }
        if (previousValue == null) {
            return sampleValue;
        }
        return previousValue + ((sampleValue - previousValue) * alpha);
    }

    function _buildGoalPredictionDiffText(predictedTotalSec) {
        if (
            predictedTotalSec == null or
            _targetTimeSec == null or
            _targetTimeSec <= 0
        ) {
            return _predictionWaitingText;
        }

        var deltaSec = predictedTotalSec - _targetTimeSec;
        if (_abs(deltaSec) <= PREDICTION_ON_PACE_THRESHOLD_SEC) {
            return _predictionOnPaceText;
        }

        var roundedMinuteDelta = Math.floor((_abs(deltaSec) + 30.0) / 60.0);
        if (roundedMinuteDelta < 1) {
            roundedMinuteDelta = 1;
        }
        var systemLanguage = _resolvePredictionSystemLanguage();
        if (systemLanguage == Sys.LANGUAGE_JPN) {
            if (deltaSec < 0) {
                return roundedMinuteDelta.format("%d") + "分早い";
            }
            return roundedMinuteDelta.format("%d") + "分遅れ";
        }

        var deltaSuffixText = _predictionBehindSuffixText;
        if (deltaSec < 0) {
            deltaSuffixText = _predictionAheadSuffixText;
        }
        return roundedMinuteDelta.format("%d") + deltaSuffixText;
    }

    function _buildGoalDeltaText(predictedTotalSec) {
        var predictedText = _buildGoalPredictionTimeText(predictedTotalSec);
        var diffText = _buildGoalPredictionDiffText(predictedTotalSec);
        return predictedText + "(" + diffText + ")";
    }

    function _isPastRaceDistance(distanceKm) {
        return (
            distanceKm != null and
            _raceDistanceKm != null and
            _raceDistanceKm > 0 and
            distanceKm > _raceDistanceKm
        );
    }

    function _resolvePredictionSystemLanguage() {
        var systemLanguage = _predictionSystemLanguage;
        if (systemLanguage == null) {
            var deviceSettings = Sys.getDeviceSettings();
            if (deviceSettings != null) {
                systemLanguage = deviceSettings.systemLanguage;
            }
        }
        return systemLanguage;
    }

    function _clamp(value, minValue, maxValue) {
        return CoachUtils.clamp(value, minValue, maxValue);
    }

    function _abs(value) {
        return CoachUtils.abs(value);
    }
}
