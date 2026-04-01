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
using FuelMeterUtils;
using RaceStrategyUtils;
using RenderUtils;
using SettingsLoader;

class MarathonCoachField extends Ui.DataField {
    const KEY_RACE_DISTANCE_KM = "race_distance_km";
    const KEY_TARGET_TIME_HOUR = "target_time_hour";
    const KEY_TARGET_TIME_MINUTE = "target_time_minute";
    const KEY_CUSTOM_MODE_CODE = "custom_mode_code";
    const FUEL_INTERVAL_SEC = 35 * 60;
    const LAP_DEBOUNCE_SEC = 20;
    const FUEL_TOGGLE_LEAD_SEC = 2 * 60;
    const FUEL_METER_WARNING_LEAD_SEC = 0;
    const FUEL_METER_LABEL_TOGGLE_SEC = 2;
    const LAP_DIAG_LOG = false;
    const FINISH_DIAG_LOG = true;
    const FINISH_DIAG_MARGIN_KM = 1.0;
    const FUEL_PLAN_DIAG_LOG = false;
    const HR_OVER_TRIGGER_MARGIN_BPM = 1;
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
    const HEART_RATE_EMA_WINDOW_SEC = 12;
    const HEART_RATE_EMA_ALPHA = 2.0 / (HEART_RATE_EMA_WINDOW_SEC + 1.0);
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
    const FIVE_DISTANCE_KM = 5.0;
    const SETTINGS_LOG = false;
    const FIT_FACT_LOG = false;
    const DIST_PROBE_LOG = false;
    const SMALL_TOP_ROW_DIAG_LOG = false;
    const MEDIUM_HR_LAYOUT_DIAG_LOG = false;
    const LARGE_TOP_ROW_DIAG_LOG = false;
    const CRASH_DIAG_LOG = false;
    const FUEL_METER_STATE_NORMAL = FuelMeterUtils.STATE_NORMAL;
    const FUEL_METER_STATE_CAUTION = FuelMeterUtils.STATE_CAUTION;
    const FUEL_METER_STATE_WARNING = FuelMeterUtils.STATE_WARNING;
    const FUEL_DISPLAY_COUNTDOWN = FuelMeterUtils.DISPLAY_COUNTDOWN;
    const FUEL_DISPLAY_DUE = FuelMeterUtils.DISPLAY_DUE;
    const FUEL_DISPLAY_DONE_FLASH = FuelMeterUtils.DISPLAY_DONE_FLASH;
    const FUEL_DISPLAY_NO_PLAN = FuelMeterUtils.DISPLAY_NO_PLAN;
    const FUEL_DISPLAY_DISABLED = FuelMeterUtils.DISPLAY_DISABLED;
    const BEEP_HR_SUPPRESS_SEC = 75;
    const BEEP_FUEL_NOW_REPEAT_FIRST_SEC = 30;
    const BEEP_FUEL_NOW_REPEAT_INTERVAL_SEC = 60;
    const HR_ARC_START_DEG = 180;
    const HR_ARC_CAP_DEG = 255;
    const HR_ARC_MAX_DEG = 270;
    const HR_ARC_MAX_RATIO = 1.1;
    const HR_ARC_SAFE_RATIO = 0.90;
    const HR_ARC_CAUTION_RATIO = 0.97;
    const HR_ARC_BASE_COLOR = 0x3A4146;
    const HR_ARC_SAFE_COLOR = 0x63C84A;
    const HR_ARC_CAUTION_COLOR = 0xE0C24A;
    const HR_ARC_WARNING_COLOR = 0xF29F67;
    const HR_ARC_DANGER_COLOR = 0xF01818;
    const PACE_INDICATOR_FAST_COLOR = 0x4CC3FF;
    const PACE_INDICATOR_ON_COLOR = 0x63C84A;
    const PACE_INDICATOR_SLOW_COLOR = 0xF6B547;
    const GOAL_RUNNER_GAUGE_TRACK_COLOR = 0xFFD84A;
    const GOAL_RUNNER_GAUGE_MARKER_COLOR = 0xFFD84A;
    const GOAL_RUNNER_GAUGE_RUNNER_COLOR = 0xFFD84A;
    const GOAL_RUNNER_GAUGE_FLAG_COLOR = 0xFFD84A;
    const GOAL_RUNNER_GAUGE_RANGE_SEC = 10 * 60;
    const GOAL_RUNNER_GAUGE_DEADZONE_SEC = PREDICTION_ON_PACE_THRESHOLD_SEC;

    const DEFAULT_RACE_DISTANCE_KM = 42.195;
    const CUSTOM_MODE_CORE = CustomModeUtils.MODE_CORE;
    const CUSTOM_MODE_CUSTOM = CustomModeUtils.MODE_CUSTOM;
    const CUSTOM_FUEL_MODE_OFF = CustomModeUtils.FUEL_MODE_OFF;
    const CUSTOM_FUEL_MODE_TIME = CustomModeUtils.FUEL_MODE_TIME;
    const HR_GAUGE_ZONE_COUNT = 5;
    const HR_ZONE_COLOR_1 = 0x9E9E9E; // gray
    const HR_ZONE_COLOR_2 = 0x52B7E8; // light blue
    const HR_ZONE_COLOR_3 = 0x63C84A; // yellow-green
    const HR_ZONE_COLOR_4 = 0xF29F67; // orange
    const HR_ZONE_COLOR_5 = 0xF01818; // red
    const HR_CAP_STATE_SAFE = 0;
    const HR_CAP_STATE_CAUTION = 1;
    const HR_CAP_STATE_OVER = 2;
    const HR_CAP_CAUTION_MARGIN_BPM = 2;

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
    var _customFuelMode = CUSTOM_FUEL_MODE_TIME;
    var _customFirstFuelAfterMin = CustomModeUtils.DEFAULT_FIRST_FUEL_AFTER_MIN;
    var _customFuelIntervalMin = CustomModeUtils.DEFAULT_FUEL_INTERVAL_MIN;
    var _customFuelAlertLeadMin = CustomModeUtils.DEFAULT_FUEL_ALERT_LEAD_MIN;
    var _customPhaseAggressiveness = CustomModeUtils.DEFAULT_PHASE_AGGRESSIVENESS;
    var _customHrCapBiasBpm = CustomModeUtils.DEFAULT_HR_CAP_BIAS_BPM;
    var _fuelPlanSignature = null;
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
    var _lastFuelTimeSec = null;
    var _fuelDueTimeSec = null;
    var _fuelRemainingSec = null;
    var _fuelRemainingText = "--:--";
    var _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
    var _timerRunning = false;
    var _lastElapsedSec = null;
    var _lastLapResetSec = null;
    var _currentHeartRate = null;
    var _activeHeartRateZones as Lang.Array<Lang.Number> = [];
    var _currentHeartRateZone = null;
    var _currentHeartRateZoneUpper = null;
    var _currentHeartRateZoneLower = null;
    var _currentHeartRateGaugeRatio = null;
    var _allowedMaxHeartRate = null;
    var _allowedMaxHeartRateZone = null;
    var _allowedMaxHeartRateZoneUpper = null;
    var _allowedMaxHeartRateZoneLower = null;
    var _allowedMaxHeartRateGaugeRatio = null;
    var _hrZoneText = "-- / cap --";
    var _hrOverActive = false;
    var _hrOverStartSec = null;
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
    var _slopeState = "FL";
    var _slopeAnchorAltitude = null;
    var _slopeAnchorDistanceM = null;
    var _beepStateInitialized = false;
    var _beepPrevFuelMeterState = FUEL_METER_STATE_NORMAL;
    var _beepPrevHrOver = false;
    var _beepFuelNowActive = false;
    var _beepFuelNowNextRepeatSec = null;
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
            _updateFuelTimer(info);
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
        _lastLapResetSec = null;
        _lastFuelTimeSec = null;
        _fuelDueTimeSec = null;
        _fuelRemainingSec = null;
        _fuelRemainingText = "--:--";
        _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
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
        _activeHeartRateZones = [];
        _currentHeartRateZone = null;
        _currentHeartRateZoneUpper = null;
        _currentHeartRateZoneLower = null;
        _currentHeartRateGaugeRatio = null;
        _allowedMaxHeartRate = null;
        _allowedMaxHeartRateZone = null;
        _allowedMaxHeartRateZoneUpper = null;
        _allowedMaxHeartRateZoneLower = null;
        _allowedMaxHeartRateGaugeRatio = null;
        _hrZoneText = "-- / cap --";
        _hrOverActive = false;
        _hrOverStartSec = null;
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
        _logLapDiag("enter", "onTimerLap", _lastElapsedSec, null);
        if (_lastElapsedSec == null) {
            _logLapDiag("reject", "elapsed_null", null, null);
            return;
        }

        if (_lastLapResetSec != null and (_lastElapsedSec - _lastLapResetSec) < LAP_DEBOUNCE_SEC) {
            _logLapDiag("reject", "debounce", _lastElapsedSec, null);
            return;
        }

        if (_isCustomModeEnabled()) {
            if (_customFuelMode == CUSTOM_FUEL_MODE_OFF) {
                _logLapDiag("reject", "custom_fuel_off", _lastElapsedSec, null);
                return;
            }
            var customIntervalSec = _resolveFuelIntervalSec();
            if (!_shouldAcceptFuelLapReset(_lastElapsedSec, customIntervalSec)) {
                _logLapDiag("reject", "custom_too_early", _lastElapsedSec, customIntervalSec);
                return;
            }
            _lastFuelTimeSec = _lastElapsedSec;
            _fuelDueTimeSec = _lastFuelTimeSec + customIntervalSec;
            _fuelRemainingSec = customIntervalSec;
            _fuelRemainingText = CoachUtils.formatMinSec(_fuelRemainingSec);
            _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
            _lastLapResetSec = _lastElapsedSec;
            _logLapDiag("apply", "custom_reset", _lastElapsedSec, customIntervalSec);
            return;
        }

        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            _logLapDiag("reject", "short_profile", _lastElapsedSec, null);
            return;
        }

        var coreIntervalSec = _resolveFuelIntervalSec();
        if (!_shouldAcceptFuelLapReset(_lastElapsedSec, coreIntervalSec)) {
            _logLapDiag("reject", "core_too_early", _lastElapsedSec, coreIntervalSec);
            return;
        }
        _lastFuelTimeSec = _lastElapsedSec;
        _fuelDueTimeSec = _lastFuelTimeSec + coreIntervalSec;
        _fuelRemainingSec = coreIntervalSec;
        _fuelRemainingText = CoachUtils.formatMinSec(_fuelRemainingSec);
        _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        _lastLapResetSec = _lastElapsedSec;
        _logLapDiag("apply", "core_reset", _lastElapsedSec, coreIntervalSec);
    }

    function _logLapDiag(stage, reason, elapsedSec, intervalSec) {
        if (!LAP_DIAG_LOG) {
            return;
        }
        var line =
            "[LAP_DIAG] stage=" + _factValue(stage) +
            " reason=" + _factValue(reason) +
            " elapsed=" + _factValue(elapsedSec) +
            " lastElapsed=" + _factValue(_lastElapsedSec) +
            " lastLapReset=" + _factValue(_lastLapResetSec) +
            " mode=" + _factValue(_customMode) +
            " fuelMode=" + _factValue(_customFuelMode) +
            " intervalSec=" + _factValue(intervalSec) +
            " fuelDue=" + _factValue(_fuelDueTimeSec) +
            " fuelRem=" + _factValue(_fuelRemainingSec) +
            " fuelDisp=" + _factValue(_fuelDisplayMode) +
            " fuelText=" + _factValue(_fuelRemainingText);
        Sys.println(line);
    }

    function _shouldAcceptFuelLapReset(elapsedSec, intervalSec) {
        if (elapsedSec == null or intervalSec == null or intervalSec <= 0) {
            return false;
        }
        return true;
    }

    function onUpdate(dc as Gfx.Dc) {
        try {
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
            _drawStep3Layout(dc);
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
        _syncFuelPlanStateWithSettings();
        _logSettingsState(targetHour, targetMinute);
    }

    function _applyCustomModeConfig(rawCustomCode) {
        var customConfig = CustomModeUtils.decodeCustomCode(rawCustomCode);
        _customMode = CustomModeUtils.getMode(customConfig);
        _customCodeValid = CustomModeUtils.isCodeValid(customConfig);
        _customFuelMode = CustomModeUtils.getFuelMode(customConfig);
        _customFirstFuelAfterMin = CustomModeUtils.getFirstFuelAfterMin(customConfig);
        _customFuelIntervalMin = CustomModeUtils.getFuelIntervalMin(customConfig);
        _customFuelAlertLeadMin = CustomModeUtils.getFuelAlertLeadMin(customConfig);
        _customPhaseAggressiveness = CustomModeUtils.getPhaseAggressiveness(customConfig);
        _customHrCapBiasBpm = CustomModeUtils.getHrCapBiasBpm(customConfig);
    }

    function _isCustomModeEnabled() {
        return _customMode == CUSTOM_MODE_CUSTOM;
    }

    function _syncFuelPlanStateWithSettings() {
        var signature = _buildFuelPlanSignature();
        if (_isSameText(signature, _fuelPlanSignature)) {
            return;
        }
        if (FUEL_PLAN_DIAG_LOG) {
            Sys.println(
                "[FUEL_PLAN_DIAG] changed prev=" + _factValue(_fuelPlanSignature) +
                " next=" + _factValue(signature) +
                " mode=" + _factValue(_customMode) +
                " fuelMode=" + _factValue(_customFuelMode) +
                " first=" + _factValue(_customFirstFuelAfterMin) +
                " interval=" + _factValue(_customFuelIntervalMin) +
                " lead=" + _factValue(_customFuelAlertLeadMin)
            );
        }

        _fuelPlanSignature = signature;
        _lastFuelTimeSec = null;
        _fuelDueTimeSec = null;
        _fuelRemainingSec = null;
        _fuelRemainingText = "--:--";
        _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        _lastLapResetSec = null;
    }

    function _isSameText(left, right) {
        if (left == null or right == null) {
            return left == right;
        }
        var leftChars = left.toCharArray();
        var rightChars = right.toCharArray();
        if (!(leftChars instanceof Lang.Array) or !(rightChars instanceof Lang.Array)) {
            return false;
        }
        if (leftChars.size() != rightChars.size()) {
            return false;
        }
        for (var i = 0; i < leftChars.size(); i += 1) {
            var leftCh = leftChars[i];
            var rightCh = rightChars[i];
            if (leftCh == null or rightCh == null) {
                if (leftCh != rightCh) {
                    return false;
                }
                continue;
            }
            if (leftCh.toNumber() != rightCh.toNumber()) {
                return false;
            }
        }
        return true;
    }

    function _buildFuelPlanSignature() {
        if (_isCustomModeEnabled()) {
            var signature =
                "custom:" + _customFuelMode.toString() +
                ":" + _customFirstFuelAfterMin.toString() +
                ":" + _customFuelIntervalMin.toString() +
                ":" + _customFuelAlertLeadMin.toString();
            return signature;
        }
        var raceDistanceMilli = Math.floor((_raceDistanceKm * 1000.0) + 0.5);
        return "core:" + _resolveRaceProfile().toString() + ":" + raceDistanceMilli.toString();
    }

    function _resolveFuelIntervalSec() {
        if (_isCustomModeEnabled() and _customFuelMode == CUSTOM_FUEL_MODE_TIME) {
            return _clamp(
                _customFuelIntervalMin * 60,
                CustomModeUtils.MIN_FUEL_INTERVAL_MIN * 60,
                CustomModeUtils.MAX_FUEL_INTERVAL_MIN * 60
            );
        }
        return FUEL_INTERVAL_SEC;
    }

    function _resolveFuelFirstDueSec() {
        if (_isCustomModeEnabled() and _customFuelMode == CUSTOM_FUEL_MODE_TIME) {
            return _clamp(
                _customFirstFuelAfterMin * 60,
                CustomModeUtils.MIN_FIRST_FUEL_AFTER_MIN * 60,
                CustomModeUtils.MAX_FIRST_FUEL_AFTER_MIN * 60
            );
        }
        return _resolveFuelIntervalSec();
    }

    function _resolveFuelToggleLeadSec() {
        if (_isCustomModeEnabled() and _customFuelMode == CUSTOM_FUEL_MODE_TIME) {
            return _clamp(_customFuelAlertLeadMin * 60, 0, 10 * 60);
        }
        return FUEL_TOGGLE_LEAD_SEC;
    }

    function _resolveFuelInitialAnchorSec(intervalSec) {
        var firstDueSec = _resolveFuelFirstDueSec();
        return firstDueSec - intervalSec;
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

        _drawHeartRateDashboard(dc, left + 2, top + 10, centerX - left - 6, topBandH - 14, sizeClass);
        _drawPredictionDashboard(dc, centerX + 2, top + 10, (left + squareSize) - centerX - 4, topBandH - 14, sizeClass);

        _drawCenterPaceDashboard(dc, left, centerY, squareSize, centerH, sizeClass);
        _drawBottomDashboard(dc, left, bottomY, squareSize, bottomBandH, sizeClass);
    }

    function _drawPredictionDashboard(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var diffFont = Gfx.FONT_LARGE;
        var predictionFont = Gfx.FONT_MEDIUM;
        var rowGap = 6;
        var blockOffsetY = 6;
        if (sizeClass == 0) {
            diffFont = Gfx.FONT_MEDIUM;
            predictionFont = Gfx.FONT_SMALL;
            rowGap = 4;
            blockOffsetY = 4;
        } else if (sizeClass == 1) {
            blockOffsetY = 10;
        } else if (sizeClass == 2) {
            rowGap = 8;
            blockOffsetY = 12;
        }

        var predictionText = _goalPredictionTimeText;
        var deltaText = _goalDiffSecondsText;
        if (dc.getTextWidthInPixels(deltaText, diffFont) > (areaW - 8) and diffFont == Gfx.FONT_LARGE) {
            diffFont = Gfx.FONT_MEDIUM;
        }
        if (dc.getTextWidthInPixels(predictionText, predictionFont) > (areaW - 8) and predictionFont == Gfx.FONT_MEDIUM) {
            predictionFont = Gfx.FONT_SMALL;
        }

        var centerX = areaX + Math.floor(areaW / 2);
        var totalH = dc.getFontHeight(predictionFont) + rowGap + dc.getFontHeight(diffFont);
        var predictionY = areaY + Math.floor((areaH - totalH) / 2) + blockOffsetY;
        var deltaY = predictionY + dc.getFontHeight(predictionFont) + rowGap;

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX, predictionY, predictionFont, predictionText, Gfx.TEXT_JUSTIFY_CENTER);
        _drawBoldText(dc, centerX, deltaY, diffFont, deltaText, Gfx.TEXT_JUSTIFY_CENTER, Gfx.COLOR_WHITE);
    }

    function _drawCenterPaceDashboard(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var paceFont = Gfx.FONT_LARGE;
        var unitFont = Gfx.FONT_XTINY;
        var contentInset = 14;
        var gaugeGap = 8;
        var gaugeH = 24;
        var gaugeOverlap = 8;
        if (sizeClass == 0) {
            contentInset = 10;
            gaugeGap = 6;
            gaugeH = 20;
            gaugeOverlap = 6;
        } else if (sizeClass == 1) {
            unitFont = Gfx.FONT_TINY;
            gaugeGap = 10;
        } else if (sizeClass == 2) {
            paceFont = Gfx.FONT_LARGE;
            unitFont = Gfx.FONT_TINY;
            contentInset = 18;
            gaugeGap = 12;
            gaugeH = 28;
            gaugeOverlap = 10;
            unitFont = Gfx.FONT_SMALL;
        }

        var centerX = areaX + Math.floor(areaW / 2);
        var totalH = dc.getFontHeight(paceFont) + gaugeGap + gaugeH - gaugeOverlap;
        var paceY = areaY + Math.floor((areaH - totalH) / 2);
        var laneW = areaW - (contentInset * 2);
        var laneX = areaX + contentInset;
        var laneY = paceY + dc.getFontHeight(paceFont) + gaugeGap - gaugeOverlap;
        _drawGoalRunnerGauge(dc, laneX, laneY, laneW, gaugeH, sizeClass);

        _drawValueWithTrailingUnitCentered(
            dc,
            centerX,
            paceY,
            paceFont,
            _paceNowText,
            unitFont,
            "/km",
            3,
            Gfx.COLOR_WHITE
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

    function _drawHeartRateDashboard(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var currentFont = Gfx.FONT_LARGE;
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
            capValueFont = Gfx.FONT_SMALL;
            outerInset = 12;
            bandThickness = 9;
        } else if (sizeClass == 1) {
            outerInset = 10;
            bandThickness = 10;
        } else if (sizeClass == 2) {
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
        var textCenterX = areaX + Math.floor(areaW / 2);
        if (sizeClass == 0) {
            textCenterX += 6;
        } else if (sizeClass == 1) {
            textCenterX += 10;
        } else {
            textCenterX += 12;
        }
        var capLineH = dc.getFontHeight(capValueFont);
        var currentLineH = dc.getFontHeight(currentFont);
        var totalTextH = capLineH + 6 + currentLineH;
        var topOffsetY = 6;
        if (sizeClass == 0) {
            topOffsetY = 4;
        } else if (sizeClass == 1) {
            topOffsetY = 10;
        } else if (sizeClass == 2) {
            topOffsetY = 12;
        }
        var capValueY = areaY + Math.floor((areaH - totalTextH) / 2) + topOffsetY;
        var currentY = capValueY + capLineH + 6;

        _drawBoldText(dc, textCenterX, currentY, currentFont, currentText, Gfx.TEXT_JUSTIFY_CENTER, Gfx.COLOR_WHITE);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(textCenterX, capValueY, capValueFont, capValueText, Gfx.TEXT_JUSTIFY_CENTER);
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

        var unitY = valueY + dc.getFontHeight(valueFont) - dc.getFontHeight(unitFont) - 1;
        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawX + valueW + unitGap, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawGoalRunnerGauge(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        if (areaW <= 0 or areaH <= 0) {
            return;
        }

        var sideInset = 4;
        var runnerHalfW = 10;
        var runnerLead = 10;
        var flagGap = 12;
        var markerHalfH = 9;
        if (sizeClass == 0) {
            sideInset = 2;
            runnerHalfW = 8;
            runnerLead = 8;
            flagGap = 10;
            markerHalfH = 8;
        } else if (sizeClass == 2) {
            sideInset = 5;
            runnerHalfW = 12;
            runnerLead = 12;
            flagGap = 14;
            markerHalfH = 10;
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

        dc.setColor(GOAL_RUNNER_GAUGE_MARKER_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(centerX, trackY - markerHalfH, centerX, trackY + markerHalfH);
        dc.drawLine(centerX + 1, trackY - markerHalfH, centerX + 1, trackY + markerHalfH);

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

        _drawGoalRunnerIcon(dc, runnerX, trackY, sizeClass);
        _drawGoalFlagIcon(dc, trackEndX + flagGap, trackY, sizeClass);
    }

    function _drawGoalRunnerIcon(dc as Gfx.Dc, centerX, footY, sizeClass) {
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
        dc.setColor(GOAL_RUNNER_GAUGE_RUNNER_COLOR, GOAL_RUNNER_GAUGE_RUNNER_COLOR);
        dc.fillRectangle(
            centerX - (headRadius - 1),
            headCenterY - (headRadius - 1),
            ((headRadius - 1) * 2) + 1,
            ((headRadius - 1) * 2) + 1
        );
        dc.setColor(GOAL_RUNNER_GAUGE_RUNNER_COLOR, Gfx.COLOR_TRANSPARENT);
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
            for (var deg = startDeg + 3; deg <= endDeg; deg += 3) {
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
        if (_currentHeartRate == null or _allowedMaxHeartRate == null) {
            return null;
        }
        if (_currentHeartRate >= (_allowedMaxHeartRate + 1)) {
            return HR_CAP_STATE_OVER;
        }
        if (_currentHeartRate >= (_allowedMaxHeartRate - HR_CAP_CAUTION_MARGIN_BPM)) {
            return HR_CAP_STATE_CAUTION;
        }
        return HR_CAP_STATE_SAFE;
    }

    function _resolveHeartRateArcRatio() {
        if (_currentHeartRate == null) {
            return 0.0;
        }
        if (_allowedMaxHeartRate != null and _allowedMaxHeartRate > 0) {
            return _clamp((_currentHeartRate * 1.0) / (_allowedMaxHeartRate * 1.0), 0.0, HR_ARC_MAX_RATIO);
        }
        return _clamp(_resolveHeartRateGaugeRatio(), 0.0, 1.0);
    }

    function _resolveHeartRateArcEndDeg() {
        var ratio = _resolveHeartRateArcRatio();
        if (ratio <= 0) {
            return HR_ARC_START_DEG;
        }
        if (ratio <= 1.0) {
            return HR_ARC_START_DEG + Math.floor(((HR_ARC_CAP_DEG - HR_ARC_START_DEG) * ratio) + 0.5);
        }
        var overRatio = _clamp((ratio - 1.0) / (HR_ARC_MAX_RATIO - 1.0), 0.0, 1.0);
        return HR_ARC_CAP_DEG + Math.floor(((HR_ARC_MAX_DEG - HR_ARC_CAP_DEG) * overRatio) + 0.5);
    }

    function _resolveHeartRateArcColor() {
        var ratio = _resolveHeartRateArcRatio();
        if (ratio >= 1.0) {
            return HR_ARC_DANGER_COLOR;
        }
        if (ratio >= HR_ARC_CAUTION_RATIO) {
            return HR_ARC_WARNING_COLOR;
        }
        if (ratio >= HR_ARC_SAFE_RATIO) {
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
            _currentHeartRate = _applyEmaSample(_currentHeartRate, heartRate, HEART_RATE_EMA_ALPHA);
        } else {
            _currentHeartRate = null;
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
        if (zones == null or zones.size() == 0) {
            return null;
        }

        var distanceKm = _extractElapsedDistanceKm(info);
        var allowedZoneNumber = _getAllowedZoneNumber(distanceKm);
        var zoneUpper = _getZoneUpperHeartRate(zones, allowedZoneNumber);
        if (zoneUpper == null) {
            return null;
        }

        var allowed = zoneUpper + _getAllowedZoneOffsetBpm(distanceKm) + _resolveHrCapBiasBpm();
        if (allowed < 1) {
            allowed = 1;
        }
        return allowed;
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
            " fuelMode=" + _factValue(_customFuelMode) +
            " firstFuelMin=" + _factValue(_customFirstFuelAfterMin) +
            " fuelIntervalMin=" + _factValue(_customFuelIntervalMin) +
            " fuelLeadMin=" + _factValue(_customFuelAlertLeadMin) +
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
            " cap=" + _factValue(_allowedMaxHeartRate) +
            " state=" + _factValue(_resolveHeartRateGaugeState()) +
            " hrText=" + _factValue(hrText) +
            " capText=" + _factValue(capText) +
            " zone=" + _factValue(_currentHeartRateZone) +
            " zoneUpper=" + _factValue(_currentHeartRateZoneUpper) +
            " zoneLower=" + _factValue(_currentHeartRateZoneLower) +
            " capZone=" + _factValue(_allowedMaxHeartRateZone) +
            " capZoneUpper=" + _factValue(_allowedMaxHeartRateZoneUpper) +
            " capZoneLower=" + _factValue(_allowedMaxHeartRateZoneLower);
        if (_isSameText(_lastMediumHrLayoutDiagLine, line)) {
            return;
        }
        _lastMediumHrLayoutDiagLine = line;
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
        return RaceStrategyUtils.getHrOverTriggerSec(
            distanceKm,
            _raceDistanceKm,
            RACE_PHASE_1_END_PROGRESS,
            RACE_PHASE_2_END_PROGRESS,
            RACE_PHASE_3_END_PROGRESS,
            RACE_PHASE_4_END_PROGRESS
        );
    }

    function _getHrOverReleaseSec(distanceKm) {
        return RaceStrategyUtils.getHrOverReleaseSec(distanceKm);
    }

    function _getHrOverReleaseOffsetBpm(distanceKm) {
        return RaceStrategyUtils.getHrOverReleaseOffsetBpm(
            distanceKm,
            _raceDistanceKm,
            RACE_PHASE_1_END_PROGRESS,
            RACE_PHASE_2_END_PROGRESS,
            RACE_PHASE_3_END_PROGRESS,
            RACE_PHASE_4_END_PROGRESS
        );
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

    function _updateFuelTimer(info) {
        var elapsedSec = _extractElapsedSec(info);

        if (_isCustomModeEnabled()) {
            _updateCustomFuelTimer(elapsedSec);
            return;
        }

        var raceProfile = _resolveRaceProfile();

        if (raceProfile == RACE_PROFILE_SHORT) {
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            _fuelDisplayMode = FUEL_DISPLAY_DISABLED;
            return;
        }

        if (elapsedSec == null) {
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
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
        var intervalSec = _resolveFuelIntervalSec();
        _fuelDueTimeSec = _lastFuelTimeSec + intervalSec;
        _fuelRemainingSec = _fuelDueTimeSec - elapsedSec;
        if (_fuelRemainingSec < 0) {
            _fuelRemainingSec = 0;
        }
        _fuelRemainingText = CoachUtils.formatMinSec(_fuelRemainingSec);
        if (_fuelRemainingSec <= 0) {
            _fuelDisplayMode = FUEL_DISPLAY_DUE;
        } else {
            _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        }
    }

    function _updateCustomFuelTimer(elapsedSec) {
        if (_customFuelMode == CUSTOM_FUEL_MODE_OFF) {
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            _fuelDisplayMode = FUEL_DISPLAY_DISABLED;
            return;
        }

        if (elapsedSec == null) {
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
            return;
        }

        var intervalSec = _resolveFuelIntervalSec();
        if (_lastFuelTimeSec == null) {
            // First custom cue is based on firstFuelAfterMin.
            _lastFuelTimeSec = _resolveFuelInitialAnchorSec(intervalSec);
        } else if (elapsedSec < _lastFuelTimeSec) {
            _lastFuelTimeSec = _resolveFuelInitialAnchorSec(intervalSec);
            _lastLapResetSec = null;
        }

        _fuelDueTimeSec = _lastFuelTimeSec + intervalSec;
        _fuelRemainingSec = _fuelDueTimeSec - elapsedSec;
        if (_fuelRemainingSec < 0) {
            _fuelRemainingSec = 0;
        }
        _fuelRemainingText = CoachUtils.formatMinSec(_fuelRemainingSec);
        if (_fuelRemainingSec <= 0) {
            _fuelDisplayMode = FUEL_DISPLAY_DUE;
        } else {
            _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        }
    }

    function _isFuelCardEnabled() {
        if (_isCustomModeEnabled()) {
            return _customFuelMode == CUSTOM_FUEL_MODE_TIME;
        }

        var raceProfile = _resolveRaceProfile();
        if (raceProfile == RACE_PROFILE_SHORT) {
            return false;
        }
        return true;
    }

    function _updateCardDisplay(info) {
        var elapsedSec = _extractElapsedSec(info);
        var fuelOverdue = _isFuelOverdue();
        var hrOver = _isHeartRateOverCap();
        _updateBeepNotifications(elapsedSec, fuelOverdue, hrOver);
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

    function _updateBeepNotifications(elapsedSec, fuelOverdue, hrOver) {
        if (elapsedSec == null) {
            _resetBeepState();
            return;
        }
        if (_beepLastElapsedSec != null and elapsedSec < _beepLastElapsedSec) {
            _resetBeepState();
        }
        _beepLastElapsedSec = elapsedSec;

        var fuelToggleLeadSec = _resolveFuelToggleLeadSec();
        var fuelMeterState = FuelMeterUtils.resolveMeterState(
            _fuelDisplayMode,
            _fuelRemainingSec,
            fuelToggleLeadSec
        );
        if (!_beepStateInitialized) {
            _beepPrevFuelMeterState = fuelMeterState;
            _beepPrevHrOver = hrOver;
            _beepFuelNowActive = fuelOverdue;
            if (fuelOverdue) {
                _beepFuelNowNextRepeatSec = elapsedSec + BEEP_FUEL_NOW_REPEAT_FIRST_SEC;
            } else {
                _beepFuelNowNextRepeatSec = null;
            }
            _beepStateInitialized = true;
            return;
        }

        var beepEvent = BeepUtils.EVENT_NONE;

        if (fuelOverdue) {
            if (!_beepFuelNowActive) {
                beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_FUEL_NOW);
                _beepFuelNowActive = true;
                _beepFuelNowNextRepeatSec = elapsedSec + BEEP_FUEL_NOW_REPEAT_FIRST_SEC;
            } else if (_beepFuelNowNextRepeatSec != null and elapsedSec >= _beepFuelNowNextRepeatSec) {
                beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_FUEL_NOW);
                _beepFuelNowNextRepeatSec = elapsedSec + BEEP_FUEL_NOW_REPEAT_INTERVAL_SEC;
            }
        } else {
            _beepFuelNowActive = false;
            _beepFuelNowNextRepeatSec = null;
        }

        if (!fuelOverdue) {
            if (hrOver and !_beepPrevHrOver) {
                if (_beepLastHrAlertSec == null or (elapsedSec - _beepLastHrAlertSec) >= BEEP_HR_SUPPRESS_SEC) {
                    beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_HR_OVER);
                    _beepLastHrAlertSec = elapsedSec;
                }
            }

            if (
                fuelMeterState == FUEL_METER_STATE_CAUTION and
                _beepPrevFuelMeterState != FUEL_METER_STATE_CAUTION
            ) {
                beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_FUEL_SOON);
            }
        }

        _playBeepEvent(beepEvent);
        _beepPrevFuelMeterState = fuelMeterState;
        _beepPrevHrOver = hrOver;
    }

    function _resetBeepState() {
        _beepStateInitialized = false;
        _beepPrevFuelMeterState = FUEL_METER_STATE_NORMAL;
        _beepPrevHrOver = false;
        _beepFuelNowActive = false;
        _beepFuelNowNextRepeatSec = null;
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

    function _isFuelOverdue() {
        return _isFuelCardEnabled() and _fuelRemainingSec != null and _fuelRemainingSec <= 0;
    }

    function _isHeartRateOverCap() {
        return _hrOverActive;
    }

    function _updateHrOverState(info) {
        if (_currentHeartRate == null or _allowedMaxHeartRate == null) {
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

        var distanceKm = _extractElapsedDistanceKm(info);
        var triggerThreshold = _allowedMaxHeartRate + HR_OVER_TRIGGER_MARGIN_BPM;
        var releaseThreshold = _allowedMaxHeartRate - _getHrOverReleaseOffsetBpm(distanceKm);
        if (releaseThreshold < 1) {
            releaseThreshold = 1;
        }

        if (_currentHeartRate > triggerThreshold) {
            _hrRecoverStartSec = null;
            if (!_hrOverActive) {
                if (_hrOverStartSec == null or elapsedSec < _hrOverStartSec) {
                    _hrOverStartSec = elapsedSec;
                }
                if ((elapsedSec - _hrOverStartSec) >= _getHrOverTriggerSec(distanceKm)) {
                    _hrOverActive = true;
                }
            }
            return;
        }

        _hrOverStartSec = null;
        if (_hrOverActive) {
            if (_currentHeartRate <= releaseThreshold) {
                if (_hrRecoverStartSec == null or elapsedSec < _hrRecoverStartSec) {
                    _hrRecoverStartSec = elapsedSec;
                }
            } else {
                _hrRecoverStartSec = null;
            }
            if (_hrRecoverStartSec != null and (elapsedSec - _hrRecoverStartSec) >= _getHrOverReleaseSec(distanceKm)) {
                _hrOverActive = false;
                _hrRecoverStartSec = null;
            }
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

        if (_isFuelOverdue() or _hrOverActive) {
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

        var scaled = (absAheadSec - GOAL_RUNNER_GAUGE_DEADZONE_SEC) / usableRangeSec;
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
