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
using CoachMessageUtils;
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
    const FUEL_PLAN_DIAG_LOG = false;
    const HR_OVER_TRIGGER_MARGIN_BPM = 1;
    const MIN_DISTANCE_FOR_PREDICTION_KM = 0.5;
    const PREDICTION_ON_PACE_THRESHOLD_SEC = 60;
    const MESSAGE_ROTATE_SEC = 24;
    const SLOPE_UP_THRESHOLD = 0.03;
    const SLOPE_DOWN_THRESHOLD = -0.03;
    const SLOPE_MIN_DISTANCE_DELTA_M = 20.0;
    const ACTION_EASE_PACE_DELTA_SEC = -8;
    const ACTION_PUSH_TRIGGER_SEC = 6;
    const ACTION_PUSH_RELEASE_SEC = 5;
    const ACTION_PUSH_RELEASE_PACE_HYSTERESIS_SEC = 2;
    const ACTION_PUSH_RELEASE_HR_HYSTERESIS_BPM = 1;
    const ACTION_EASE_MIN_HEADROOM_BPM = 3;
    const ACTION_EASE_BASELINE_HR_DELTA_BPM = 6;
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
    const COACH_MESSAGE_DIAG_LOG = false;
    const CRASH_DIAG_LOG = false;
    const COMPACT_BANNER_DIAG_LOG = false;

    const CARD_MODE_ACTION = 0;
    const CARD_MODE_FUEL = 1;
    const CARD_MODE_FUEL_OVERDUE = 2;
    const CARD_VARIANT_WARMUP = 0;
    const CARD_VARIANT_ACTION_PUSH = 1;
    const CARD_VARIANT_ACTION_HOLD = 2;
    const CARD_VARIANT_ACTION_EASE = 3;
    const CARD_VARIANT_FUEL_SOON = 4;
    const CARD_VARIANT_FUEL_NOW = 5;
    const CARD_VARIANT_RECOVERY = 6;
    const CARD_VARIANT_HR_WARNING = 7;
    const FUEL_METER_STATE_NORMAL = FuelMeterUtils.STATE_NORMAL;
    const FUEL_METER_STATE_CAUTION = FuelMeterUtils.STATE_CAUTION;
    const FUEL_METER_STATE_WARNING = FuelMeterUtils.STATE_WARNING;
    const FUEL_DISPLAY_COUNTDOWN = FuelMeterUtils.DISPLAY_COUNTDOWN;
    const FUEL_DISPLAY_DUE = FuelMeterUtils.DISPLAY_DUE;
    const FUEL_DISPLAY_DONE_FLASH = FuelMeterUtils.DISPLAY_DONE_FLASH;
    const FUEL_DISPLAY_NO_PLAN = FuelMeterUtils.DISPLAY_NO_PLAN;
    const FUEL_DISPLAY_DISABLED = FuelMeterUtils.DISPLAY_DISABLED;
    const ACTION_EASE_REASON_NONE = 0;
    const ACTION_EASE_REASON_PACE = 1;
    const ACTION_EASE_REASON_HR = 2;
    const ACTION_EASE_REASON_BOTH = 3;
    const BEEP_HR_SUPPRESS_SEC = 75;
    const BEEP_FUEL_NOW_REPEAT_FIRST_SEC = 30;
    const BEEP_FUEL_NOW_REPEAT_INTERVAL_SEC = 60;

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
    const HR_CAP_MARKER_SAFE_COLOR = 0x63C84A;
    const HR_CAP_MARKER_CAUTION_COLOR = 0xF29F67;
    const HR_CAP_MARKER_OVER_COLOR = 0xF01818;

    var _goalPredictionLabelText = "Pred.";
    var _goalPredictionTimeText = "--:--";
    var _goalPredictionDiffText = "waiting";
    var _goalDeltaText = "--:--(waiting)";
    var _predictionWaitingText = "waiting";
    var _predictionOnPaceText = "on pace";
    var _predictionAheadSuffixText = "min.";
    var _predictionBehindSuffixText = "min.";
    var _predictionSystemLanguage = null;
    var _actionPushText = "Push a bit";
    var _actionHoldText = "Hold pace";
    var _actionEaseText = "Ease down";
    var _actionEasePaceText = "Ease pace";
    var _lastSpurtLabelText = "Final push";
    var _fuelPrepLabelText = "Fuel prep";
    var _fuelNowLabelText = "Fuel NOW";
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
    var _lastCoachMessageDiagLine = null;
    var _coachMessageLanguage = "ja";
    var _coachMessageCategory = CoachMessageUtils.defaultCategory();
    var _coachMessageStateKey = null;
    var _coachMessageFuelState = CoachMessageUtils.FUEL_STATE_NONE;
    var _coachMessageCurrentText = "";
    var _coachMessagePreviousText = "";
    var _coachMessageLastChangeSec = null;
    var _actionEaseReason = ACTION_EASE_REASON_NONE;
    var _slopeState = "FL";
    var _slopeAnchorAltitude = null;
    var _slopeAnchorDistanceM = null;
    var _cardMode = CARD_MODE_ACTION;
    var _cardVariant = CARD_VARIANT_ACTION_HOLD;
    var _cardLine1 = "Hold pace";
    var _cardLine2 = "Hold";
    var _cardLine3 = "this rhythm";
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
        _predictionWaitingText = Ui.loadResource(Rez.Strings.PredictionWaiting);
        _predictionOnPaceText = Ui.loadResource(Rez.Strings.PredictionOnPace);
        _predictionAheadSuffixText = Ui.loadResource(Rez.Strings.PredictionAheadSuffix);
        _predictionBehindSuffixText = Ui.loadResource(Rez.Strings.PredictionBehindSuffix);
        _goalPredictionTimeText = _buildGoalPredictionTimeText(null);
        _goalPredictionDiffText = _buildGoalPredictionDiffText(null);
        _goalDeltaText = _buildGoalDeltaText(null);
        _actionPushText = Ui.loadResource(Rez.Strings.ActionPushText);
        _actionHoldText = Ui.loadResource(Rez.Strings.ActionHoldText);
        _actionEaseText = Ui.loadResource(Rez.Strings.ActionEaseText);
        _actionEasePaceText = Ui.loadResource(Rez.Strings.ActionEasePaceText);
        _lastSpurtLabelText = Ui.loadResource(Rez.Strings.CardLastSpurtLabel);
        _fuelPrepLabelText = Ui.loadResource(Rez.Strings.CardFuelPrepLabel);
        _fuelNowLabelText = Ui.loadResource(Rez.Strings.CardFuelNowLabel);
        _cardMode = CARD_MODE_ACTION;
        _cardVariant = CARD_VARIANT_ACTION_HOLD;
        _coachMessageLanguage = CoachMessageUtils.resolveLanguage(_resolvePredictionSystemLanguage());
        _setCardLabelAndMessage(_actionHoldText, _actionHoldText);
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
        _goalDeltaText = _buildGoalDeltaText(null);
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
        _probeLocDistanceM = 0.0;
        _probeLocLastLocation = null;
        _probeLocLastElapsedSec = null;
        _probeSpeedDistanceM = 0.0;
        _probeSpeedLastElapsedSec = null;
        _lastDistanceProbeLogLine = null;
        _resetSlopeState();
        _resetCoachMessageState();
        _resetBeepState();
        _setActionCardDisplay(null, CoachMessageUtils.FUEL_STATE_NONE, null, true);
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
        var centerX = Math.floor(left + (squareSize / 2));
        var right = left + squareSize;
        var bottomY = top + squareSize;

        var row1H = Math.floor((squareSize * 29) / 100);
        var row2H = Math.floor((squareSize * 35) / 100);
        var row3H = Math.floor((squareSize * 14) / 100);
        var row4H = bottomY - top - row1H - row2H - row3H;
        var row1Y = top + row1H;
        var row2Y = row1Y + row2H;
        var row3Y = row2Y + row3H;

        var leftColX = left;
        var leftColW = centerX - leftColX;
        var rightColX = centerX;
        var rightColW = right - rightColX;

        _drawHeartRateSummarySmall(dc, leftColX, top, leftColW, row1H);
        _drawPaceSummarySmall(dc, rightColX, top, rightColW, row1H);

        var bannerInsetY = 1;
        var bannerY = row1Y + bannerInsetY + 1;
        var bannerH = row2H - (bannerInsetY * 2);
        var bannerTextInset = 10;
        var bannerTextAreaX = bannerTextInset / 2;
        var bannerTextAreaW = width - bannerTextInset;
        var bannerLabelText = _cardLine1;
        var bannerLabelFont = Gfx.FONT_XTINY;
        var bannerMessageText = _cardLine2;
        var bannerMessageFont = Gfx.FONT_XTINY;
        if (bannerMessageText != null and bannerMessageText.length() > 0 and bannerTextAreaW > 0) {
            _drawMessageBannerFrame(dc, 0, bannerY, width, bannerH, 0);
            bannerMessageText = _truncateCardText(bannerMessageText, 20);
            var bannerCenterX = bannerTextAreaX + (bannerTextAreaW / 2);
            var bannerLabelY = bannerY + 7;
            var bannerMessageY = bannerY + ((bannerH - dc.getFontHeight(bannerMessageFont)) / 2) + 6;
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            if (bannerLabelText != null and bannerLabelText.length() > 0) {
                dc.drawText(bannerTextAreaX + 6, bannerLabelY, bannerLabelFont, bannerLabelText, Gfx.TEXT_JUSTIFY_LEFT);
            }
            dc.drawText(bannerCenterX, bannerMessageY, bannerMessageFont, bannerMessageText, Gfx.TEXT_JUSTIFY_CENTER);
        }

        var metricFont = Gfx.FONT_SMALL;
        var metricFontHeight = dc.getFontHeight(metricFont);
        var metricY = CoachUtils.textYByRatio(row2Y, row3H, 54, metricFontHeight);
        var metricInset = 8;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        _drawDistanceSummaryMedium(dc, leftColX + 22, metricY, _distanceText, metricFont);
        dc.drawText(rightColX + metricInset, metricY, metricFont, _elapsedTimeText, Gfx.TEXT_JUSTIFY_LEFT);

        var footerTimeFont = Gfx.FONT_TINY;
        var footerDiffFont = Gfx.FONT_XTINY;
        var footerLabelFont = Gfx.FONT_XTINY;
        var footerAreaH = row4H;
        var footerTimeY = CoachUtils.textYByRatio(row3Y, footerAreaH, 30, dc.getFontHeight(footerTimeFont));
        var footerDiffY = CoachUtils.textYByRatio(row3Y, footerAreaH, 80, dc.getFontHeight(footerDiffFont));
        _drawGoalPredictionTimeWithLabel(dc, width / 2, footerTimeY, footerTimeFont, footerLabelFont);
        dc.drawText(width / 2, footerDiffY, footerDiffFont, _goalPredictionDiffText, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function _drawStep3LayoutMedium(dc as Gfx.Dc, width, height, minDim) {
        var insetPct = 7;
        var squareSize = Math.floor(_clamp((minDim * (100 - (insetPct * 2))) / 100, (minDim * 70) / 100, minDim));
        var left = Math.floor((width - squareSize) / 2);
        var top = Math.floor((height - squareSize) / 2);
        var centerX = Math.floor(left + (squareSize / 2));
        var right = left + squareSize;
        var bottomY = top + squareSize;

        var row1H = Math.floor((squareSize * 28) / 100);
        var row2H = Math.floor((squareSize * 35) / 100);
        var row3H = Math.floor((squareSize * 14) / 100);
        var row4H = bottomY - top - row1H - row2H - row3H;
        var row1Y = top + row1H;
        var row2Y = row1Y + row2H;
        var row3Y = row2Y + row3H;

        var leftColX = left;
        var leftColW = centerX - leftColX;
        var rightColX = centerX;
        var rightColW = right - rightColX;

        _drawHeartRateSummaryMedium(dc, leftColX, top, leftColW, row1H);
        _drawPaceSummaryMedium(dc, rightColX, top, rightColW, row1H);

        var bannerInsetY = 2;
        var bannerOverscanX = 6;
        var bannerX = -bannerOverscanX;
        var bannerY = row1Y + bannerInsetY + 2;
        var bannerW = width + (bannerOverscanX * 2);
        var bannerH = row2H - (bannerInsetY * 2);
        var bannerTextInset = 16;
        var bannerTextAreaX = bannerX + (bannerTextInset / 2);
        var bannerTextAreaW = bannerW - bannerTextInset;
        var bannerLabelText = _cardLine1;
        var bannerLabelFont = Gfx.FONT_TINY;
        var bannerMessageText = _cardLine2;
        var bannerMessageFont = Gfx.FONT_SMALL;
        if (bannerMessageText != null and bannerMessageText.length() > 0 and bannerTextAreaW > 0) {
            _drawMessageBannerFrame(dc, bannerX, bannerY, bannerW, bannerH, 1);
            bannerMessageText = _truncateCardText(bannerMessageText, 16);
            var bannerCenterX = bannerTextAreaX + (bannerTextAreaW / 2);
            var bannerLabelY = bannerY + 5;
            var bannerMessageY = bannerY + ((bannerH - dc.getFontHeight(bannerMessageFont)) / 2) + 8;
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            if (bannerLabelText != null and bannerLabelText.length() > 0) {
                dc.drawText(bannerTextAreaX + 6, bannerLabelY, bannerLabelFont, bannerLabelText, Gfx.TEXT_JUSTIFY_LEFT);
            }
            dc.drawText(bannerCenterX, bannerMessageY, bannerMessageFont, bannerMessageText, Gfx.TEXT_JUSTIFY_CENTER);
        }

        var metricFont = Gfx.FONT_MEDIUM;
        var metricFontHeight = dc.getFontHeight(metricFont);
        var metricY = CoachUtils.textYByRatio(row2Y, row3H, 54, metricFontHeight);
        var metricInset = 12;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        _drawDistanceSummaryMedium(dc, leftColX + metricInset, metricY, _distanceText, metricFont);
        dc.drawText(rightColX + metricInset, metricY, metricFont, _elapsedTimeText, Gfx.TEXT_JUSTIFY_LEFT);

        var footerTimeFont = Gfx.FONT_SMALL;
        var footerDiffFont = Gfx.FONT_XTINY;
        var footerLabelFont = Gfx.FONT_XTINY;
        var footerAreaH = row4H;
        var footerTimeY = CoachUtils.textYByRatio(row3Y, footerAreaH, 32, dc.getFontHeight(footerTimeFont));
        var footerDiffY = CoachUtils.textYByRatio(row3Y, footerAreaH, 82, dc.getFontHeight(footerDiffFont));
        _drawGoalPredictionTimeWithLabel(dc, width / 2, footerTimeY, footerTimeFont, footerLabelFont);
        dc.drawText(width / 2, footerDiffY, footerDiffFont, _goalPredictionDiffText, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function _drawStep3LayoutLarge(dc as Gfx.Dc, width, height, minDim) {
        var insetPct = 9;
        var squareSize = Math.floor(_clamp((minDim * (100 - (insetPct * 2))) / 100, (minDim * 72) / 100, minDim));
        var left = Math.floor((width - squareSize) / 2);
        var top = Math.floor((height - squareSize) / 2);
        var centerX = Math.floor(left + (squareSize / 2));
        var right = left + squareSize;
        var bottomY = top + squareSize;

        var row1H = Math.floor((squareSize * 28) / 100);
        var row2H = Math.floor((squareSize * 34) / 100);
        var row3H = Math.floor((squareSize * 15) / 100);
        var row4H = bottomY - top - row1H - row2H - row3H;
        var row1Y = top + row1H;
        var row2Y = row1Y + row2H;
        var row3Y = row2Y + row3H;

        var leftColX = left;
        var leftColW = centerX - leftColX;
        var rightColX = centerX;
        var rightColW = right - rightColX;

        _drawHeartRateSummaryLarge(dc, leftColX, top, leftColW, row1H);
        _drawPaceSummaryLarge(dc, rightColX, top, rightColW, row1H);

        var bannerInsetY = 3;
        var bannerX = 0;
        var bannerY = row1Y + bannerInsetY + 2;
        var bannerW = width;
        var bannerH = row2H - (bannerInsetY * 2);
        var bannerTextInset = 20;
        var bannerTextAreaX = bannerX + (bannerTextInset / 2);
        var bannerTextAreaW = bannerW - bannerTextInset;
        var bannerLabelText = _cardLine1;
        var bannerLabelFont = Gfx.FONT_TINY;
        var bannerMessageText = _cardLine2;
        var bannerMessageFont = Gfx.FONT_SMALL;
        if (bannerMessageText != null and bannerMessageText.length() > 0 and bannerTextAreaW > 0) {
            _drawMessageBannerFrame(dc, bannerX, bannerY, bannerW, bannerH, 2);
            bannerMessageText = _truncateCardText(bannerMessageText, 18);
            var bannerCenterX = bannerTextAreaX + (bannerTextAreaW / 2);
            var bannerLabelY = bannerY + 6;
            var bannerMessageY = bannerY + ((bannerH - dc.getFontHeight(bannerMessageFont)) / 2) + 10;
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            if (bannerLabelText != null and bannerLabelText.length() > 0) {
                dc.drawText(bannerTextAreaX + 8, bannerLabelY, bannerLabelFont, bannerLabelText, Gfx.TEXT_JUSTIFY_LEFT);
            }
            dc.drawText(bannerCenterX, bannerMessageY, bannerMessageFont, bannerMessageText, Gfx.TEXT_JUSTIFY_CENTER);
        }

        var metricFont = Gfx.FONT_MEDIUM;
        var metricFontHeight = dc.getFontHeight(metricFont);
        var metricY = CoachUtils.textYByRatio(row2Y, row3H, 56, metricFontHeight);
        var metricInset = 14;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        _drawDistanceSummaryMedium(dc, leftColX + metricInset, metricY, _distanceText, metricFont);
        dc.drawText(rightColX + metricInset, metricY, metricFont, _elapsedTimeText, Gfx.TEXT_JUSTIFY_LEFT);

        var footerTimeFont = Gfx.FONT_SMALL;
        var footerDiffFont = Gfx.FONT_XTINY;
        var footerLabelFont = Gfx.FONT_XTINY;
        var footerAreaH = row4H;
        var footerTimeY = CoachUtils.textYByRatio(row3Y, footerAreaH, 32, dc.getFontHeight(footerTimeFont));
        var footerDiffY = CoachUtils.textYByRatio(row3Y, footerAreaH, 82, dc.getFontHeight(footerDiffFont));
        _drawGoalPredictionTimeWithLabel(dc, width / 2, footerTimeY, footerTimeFont, footerLabelFont);
        dc.drawText(width / 2, footerDiffY, footerDiffFont, _goalPredictionDiffText, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function _drawGoalPredictionTimeWithLabel(dc as Gfx.Dc, centerX, timeY, timeFont, labelFont) {
        dc.drawText(centerX, timeY, timeFont, _goalPredictionTimeText, Gfx.TEXT_JUSTIFY_CENTER);

        if (_goalPredictionLabelText == null or _goalPredictionLabelText.length() == 0) {
            return;
        }

        var timeTextWidth = dc.getTextWidthInPixels(_goalPredictionTimeText, timeFont);
        var labelGap = 3;
        var labelRightX = centerX - Math.floor(timeTextWidth / 2) - labelGap;
        var labelY = timeY - 2;
        dc.drawText(labelRightX, labelY, labelFont, _goalPredictionLabelText, Gfx.TEXT_JUSTIFY_RIGHT);
    }

    function _drawMessageBannerFrame(dc as Gfx.Dc, bannerX, bannerY, bannerW, bannerH, sizeClass) {
        if (bannerW < 20 or bannerH < 12) {
            return;
        }

        var borderColor = _resolveMessageBannerBorderColor();
        var panelMarginX = 8;
        var panelMarginY = 3;
        if (sizeClass == 1) {
            panelMarginX = 10;
            panelMarginY = 4;
        } else if (sizeClass == 2) {
            panelMarginX = 14;
            panelMarginY = 5;
        }

        var panelX = bannerX + panelMarginX;
        var panelY = bannerY + panelMarginY;
        var panelW = bannerW - (panelMarginX * 2);
        var panelH = bannerH - (panelMarginY * 2);
        if (panelW < 12 or panelH < 8) {
            return;
        }

        dc.setColor(borderColor, Gfx.COLOR_BLACK);
        dc.fillRectangle(bannerX, bannerY, bannerW, bannerH);

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        if (sizeClass == 0) {
            dc.fillRectangle(panelX, panelY, panelW, panelH);
            return;
        }

        var panelCorner = _clamp(panelH / 5, 4, 10);
        var maxPanelCorner = _max((_min(panelW, panelH) / 2) - 1, 2);
        if (panelCorner > maxPanelCorner) {
            panelCorner = maxPanelCorner;
        }
        dc.fillRoundedRectangle(panelX, panelY, panelW, panelH, panelCorner);
    }

    function _resolveMessageBannerBorderColor() {
        if (_cardVariant == CARD_VARIANT_WARMUP) {
            return 0x55C3AA;
        }
        if (_cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return 0x4CC3FF;
        }
        if (_cardVariant == CARD_VARIANT_ACTION_EASE) {
            return 0xF6B547;
        }
        if (_cardVariant == CARD_VARIANT_FUEL_SOON) {
            return 0xFF9A1F;
        }
        if (_cardVariant == CARD_VARIANT_FUEL_NOW) {
            return 0xFF4F64;
        }
        if (_cardVariant == CARD_VARIANT_RECOVERY) {
            return 0x49DB8F;
        }
        if (_cardVariant == CARD_VARIANT_HR_WARNING) {
            return 0xFF5A3B;
        }
        return 0xA6B2BC;
    }

    function _drawDistanceSummaryMedium(dc as Gfx.Dc, drawX, drawY, distanceText, valueFont) {
        var splitIndex = distanceText.find(" ");
        if (splitIndex == null or splitIndex <= 0) {
            dc.drawText(drawX, drawY, valueFont, distanceText, Gfx.TEXT_JUSTIFY_LEFT);
            return;
        }

        var valueText = distanceText.substring(0, splitIndex);
        var unitText = distanceText.substring(splitIndex, distanceText.length());
        var unitFont = Gfx.FONT_XTINY;
        var valueTextW = dc.getTextWidthInPixels(valueText, valueFont);
        var unitX = drawX + valueTextW + 2;
        var unitY = drawY + dc.getFontHeight(valueFont) - dc.getFontHeight(unitFont) - 1;

        dc.drawText(drawX, drawY, valueFont, valueText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(unitX, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawHeartRateSummarySmall(dc as Gfx.Dc, areaX, areaY, areaW, areaH) {
        var capFont = Gfx.FONT_XTINY;
        var valueFont = Gfx.FONT_SMALL;
        var capText = "cap --";
        if (_allowedMaxHeartRate != null) {
            capText = "cap " + _allowedMaxHeartRate.format("%d");
        }
        var valueText = "--";
        if (_currentHeartRate != null) {
            try {
                valueText = _currentHeartRate.format("%d");
            } catch (e) {
                valueText = "--";
            }
        }
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(areaX + 4, areaY + 4, capFont, capText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(areaX + 4, areaY + 18, valueFont, valueText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawHeartRateSummaryMedium(dc as Gfx.Dc, areaX, areaY, areaW, areaH) {
        var capFont = Gfx.FONT_TINY;
        var valueFont = Gfx.FONT_MEDIUM;
        var stateFont = Gfx.FONT_XTINY;
        var bottomPad = 1;
        var capText = "cap --";
        if (_allowedMaxHeartRate != null) {
            capText = "cap " + _allowedMaxHeartRate.format("%d");
        }
        var valueText = _formatHeartRateValueText(_currentHeartRate);

        var gaugeState = _resolveHeartRateGaugeState();
        var stateText = "SAFE";
        if (gaugeState == HR_CAP_STATE_CAUTION) {
            stateText = "CAUTION";
        } else if (gaugeState == HR_CAP_STATE_OVER) {
            stateText = "OVER";
        }

        var drawRightX = Math.floor(areaX + areaW - 10);
        var valueTextW = dc.getTextWidthInPixels(valueText, valueFont);
        var valueY = Math.floor(areaY + areaH - dc.getFontHeight(valueFont) - bottomPad);
        var capY = valueY - dc.getFontHeight(capFont) - 4;
        if (capY < (areaY + 2)) {
            capY = areaY + 2;
        }
        var stateTextW = dc.getTextWidthInPixels(stateText, stateFont);
        var stateX = Math.floor(drawRightX - valueTextW - 8 - stateTextW);
        if (stateX < (areaX + 2)) {
            stateX = areaX + 2;
        }
        var stateY = Math.floor(areaY + areaH - dc.getFontHeight(stateFont) - bottomPad);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawRightX, capY, capFont, capText, Gfx.TEXT_JUSTIFY_RIGHT);
        dc.setColor(_getHeartRateGaugeMarkerColor(gaugeState), Gfx.COLOR_TRANSPARENT);
        dc.drawText(stateX, stateY, stateFont, stateText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawRightX, valueY, valueFont, valueText, Gfx.TEXT_JUSTIFY_RIGHT);
    }

    function _drawHeartRateSummaryLarge(dc as Gfx.Dc, areaX, areaY, areaW, areaH) {
        var capFont = Gfx.FONT_SMALL;
        var valueFont = Gfx.FONT_LARGE;
        var stateFont = Gfx.FONT_XTINY;
        var bottomPad = 0;
        var valueDrop = 6;
        var capText = "cap --";
        if (_allowedMaxHeartRate != null) {
            capText = "cap " + _allowedMaxHeartRate.format("%d");
        }
        var valueText = _formatHeartRateValueText(_currentHeartRate);
        var gaugeState = _resolveHeartRateGaugeState();
        var stateText = "SAFE";
        if (gaugeState == HR_CAP_STATE_CAUTION) {
            stateText = "CAUTION";
        } else if (gaugeState == HR_CAP_STATE_OVER) {
            stateText = "OVER";
        }

        var drawRightX = Math.floor(areaX + areaW - 6);
        var valueTextW = dc.getTextWidthInPixels(valueText, valueFont);
        var valueY = Math.floor(areaY + areaH - dc.getFontHeight(valueFont) - bottomPad + valueDrop);
        var capY = valueY - dc.getFontHeight(capFont) - 6;
        if (capY < areaY) {
            capY = areaY;
        }
        var stateTextW = dc.getTextWidthInPixels(stateText, stateFont);
        var stateX = Math.floor(drawRightX - valueTextW - 10 - stateTextW);
        if (stateX < (areaX + 2)) {
            stateX = areaX + 2;
        }
        var stateY = Math.floor(areaY + areaH - dc.getFontHeight(stateFont) - bottomPad);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawRightX, capY, capFont, capText, Gfx.TEXT_JUSTIFY_RIGHT);
        dc.setColor(_getHeartRateGaugeMarkerColor(gaugeState), Gfx.COLOR_TRANSPARENT);
        dc.drawText(stateX, stateY, stateFont, stateText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawRightX, valueY, valueFont, valueText, Gfx.TEXT_JUSTIFY_RIGHT);
    }

    function _drawPaceSummarySmall(dc as Gfx.Dc, areaX, areaY, areaW, areaH) {
        var paceFont = Gfx.FONT_MEDIUM;
        var unitFont = Gfx.FONT_XTINY;
        var bottomPad = 1;
        var paceText = _paceNowText;
        var rightPad = 18;
        var unitGap = 3;
        var paceTextW = dc.getTextWidthInPixels(paceText, paceFont);
        var unitTextW = dc.getTextWidthInPixels("/km", unitFont);
        var totalTextW = paceTextW + unitGap + unitTextW;
        var drawX = areaX + areaW - rightPad - totalTextW;
        var minX = areaX + 4;
        if (drawX < minX) {
            drawX = minX;
        }

        var paceY = Math.floor(areaY + areaH - dc.getFontHeight(paceFont) - bottomPad);
        var unitY = paceY + dc.getFontHeight(paceFont) - dc.getFontHeight(unitFont) - 1;

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawX, paceY, paceFont, paceText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(drawX + paceTextW + unitGap, unitY, unitFont, "/km", Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawPaceSummaryMedium(dc as Gfx.Dc, areaX, areaY, areaW, areaH) {
        var paceFont = Gfx.FONT_LARGE;
        var unitFont = Gfx.FONT_XTINY;
        var bottomPad = 1;
        var rightPad = 10;
        var unitGap = 4;
        var paceText = _paceNowText;
        var paceTextW = dc.getTextWidthInPixels(paceText, paceFont);
        var unitTextW = dc.getTextWidthInPixels("/km", unitFont);
        var totalTextW = paceTextW + unitGap + unitTextW;
        var drawX = areaX + areaW - rightPad - totalTextW;
        var minX = areaX + 8;
        if (drawX < minX) {
            drawX = minX;
        }

        var rowBottomY = Math.floor(areaY + areaH - bottomPad);
        var paceY = rowBottomY - dc.getFontHeight(paceFont);
        var unitY = rowBottomY - dc.getFontHeight(unitFont);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawX, paceY, paceFont, paceText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(drawX + paceTextW + unitGap, unitY, unitFont, "/km", Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawPaceSummaryLarge(dc as Gfx.Dc, areaX, areaY, areaW, areaH) {
        var paceFont = Gfx.FONT_LARGE;
        var unitFont = Gfx.FONT_TINY;
        var bottomPad = 0;
        var paceDrop = 6;
        var rightPad = 12;
        var unitGap = 5;
        var paceText = _paceNowText;
        var paceTextW = dc.getTextWidthInPixels(paceText, paceFont);
        var unitTextW = dc.getTextWidthInPixels("/km", unitFont);
        var totalTextW = paceTextW + unitGap + unitTextW;
        var drawX = areaX + areaW - rightPad - totalTextW;
        var minX = areaX + 10;
        if (drawX < minX) {
            drawX = minX;
        }

        var rowBottomY = Math.floor(areaY + areaH - bottomPad);
        var paceY = rowBottomY - dc.getFontHeight(paceFont) + paceDrop;
        var unitY = rowBottomY - dc.getFontHeight(unitFont);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(drawX, paceY, paceFont, paceText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(drawX + paceTextW + unitGap, unitY, unitFont, "/km", Gfx.TEXT_JUSTIFY_LEFT);
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

    function _getHeartRateGaugeMarkerColor(gaugeState) {
        if (gaugeState == HR_CAP_STATE_CAUTION) {
            return HR_CAP_MARKER_CAUTION_COLOR;
        }
        if (gaugeState == HR_CAP_STATE_OVER) {
            return HR_CAP_MARKER_OVER_COLOR;
        }
        if (gaugeState == HR_CAP_STATE_SAFE) {
            return HR_CAP_MARKER_SAFE_COLOR;
        }
        return Gfx.COLOR_WHITE;
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

        var distanceText = "--.- km";
        if (distanceKm != null) {
            distanceText = CoachUtils.formatDistanceKm(distanceKm);
        }

        var elapsedText = "--:--:--";
        if (elapsedSec != null) {
            elapsedText = CoachUtils.formatElapsedTime(elapsedSec);
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

        _goalPredictionTimeText = _buildGoalPredictionTimeText(predictedTotalSec);
        _goalPredictionDiffText = _buildGoalPredictionDiffText(predictedTotalSec);
        _goalDeltaText = _buildGoalDeltaText(predictedTotalSec);
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

    function _logCoachMessageDiag(stage, elapsedSec, stateKey, fuelState, labelText, selectedMessage, messagePool) {
        if (!COACH_MESSAGE_DIAG_LOG) {
            return;
        }

        var poolSize = 0;
        if (messagePool != null) {
            poolSize = messagePool.size();
        }

        var line =
            "[COACH_MSG]" +
            " stage=" + _factValue(stage) +
            " elapsed=" + _factValue(elapsedSec) +
            " stateKey=" + _factValue(stateKey) +
            " fuelState=" + _factValue(fuelState) +
            " lang=" + _factValue(_coachMessageLanguage) +
            " category=" + _factValue(_coachMessageCategory) +
            " poolSize=" + _factValue(poolSize) +
            " selected=" + _factValue(selectedMessage) +
            " label=" + _factValue(labelText) +
            " line1=" + _factValue(_cardLine1) +
            " line2=" + _factValue(_cardLine2) +
            " line3=" + _factValue(_cardLine3);
        if (_isSameText(_lastCoachMessageDiagLine, line)) {
            return;
        }
        _lastCoachMessageDiagLine = line;
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
            " cardVariant=" + _factValue(_cardVariant) +
            " stateKey=" + _factValue(_coachMessageStateKey) +
            " fuelState=" + _factValue(_coachMessageFuelState) +
            " slope=" + _factValue(_slopeState) +
            " currentMsg=" + _factValue(_coachMessageCurrentText) +
            " prevMsg=" + _factValue(_coachMessagePreviousText) +
            " line1=" + _factValue(_cardLine1) +
            " line2=" + _factValue(_cardLine2) +
            " line3=" + _factValue(_cardLine3) +
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
        var fuelState = _resolveFuelState();
        var isLastSpurt = _isLastSpurtSegment(info);
        _updateBeepNotifications(elapsedSec, fuelOverdue, hrOver);

        if (isLastSpurt) {
            fuelState = CoachMessageUtils.FUEL_STATE_NONE;
            _cardMode = CARD_MODE_ACTION;
        } else if (_isSameText(fuelState, CoachMessageUtils.FUEL_STATE_NOW)) {
            _cardMode = CARD_MODE_FUEL_OVERDUE;
        } else if (_isSameText(fuelState, CoachMessageUtils.FUEL_STATE_PREP)) {
            _cardMode = CARD_MODE_FUEL;
        } else {
            _cardMode = CARD_MODE_ACTION;
        }

        _setActionCardDisplay(elapsedSec, fuelState, info, false);
    }

    function _resolveFuelState() {
        if (!_isFuelCardEnabled() or _fuelRemainingSec == null) {
            return CoachMessageUtils.FUEL_STATE_NONE;
        }
        if (_fuelRemainingSec <= 0) {
            return CoachMessageUtils.FUEL_STATE_NOW;
        }
        if (_fuelRemainingSec <= _resolveFuelToggleLeadSec()) {
            return CoachMessageUtils.FUEL_STATE_PREP;
        }
        return CoachMessageUtils.FUEL_STATE_NONE;
    }

    function _isLastSpurtSegment(info) {
        var distanceKm = _extractElapsedDistanceKm(info);
        var progress = _resolveRaceProgress(distanceKm);
        return progress != null and progress >= RACE_PHASE_4_END_PROGRESS;
    }

    function _resetCoachMessageState() {
        _coachMessageStateKey = null;
        _coachMessageFuelState = CoachMessageUtils.FUEL_STATE_NONE;
        _coachMessageCurrentText = "";
        _coachMessagePreviousText = "";
        _coachMessageLastChangeSec = null;
        _actionEaseReason = ACTION_EASE_REASON_NONE;
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

    function _resolveActionVariant() {
        var distanceKm = _extractElapsedDistanceKm(_fallbackActivityInfo);
        var paceDeltaSec = null;
        if (_paceNowSecPerKm != null and _targetPaceSecPerKm != null) {
            paceDeltaSec = _paceNowSecPerKm - _targetPaceSecPerKm;
        }

        var hrHeadroom = null;
        if (_allowedMaxHeartRate != null and _currentHeartRate != null) {
            hrHeadroom = _allowedMaxHeartRate - _currentHeartRate;
        }

        var easePaceDeltaThreshold = _adjustEasePaceThresholdSec(ACTION_EASE_PACE_DELTA_SEC);
        var easeHeadroomThreshold = _adjustEaseHeadroomThresholdBpm(_getActionEaseMinHeadroomBpm(distanceKm));

        var easeByPace = paceDeltaSec != null and paceDeltaSec <= easePaceDeltaThreshold;
        var easeByHr = hrHeadroom != null and hrHeadroom <= easeHeadroomThreshold;
        _actionEaseReason = _resolveActionEaseReasonValue(easeByPace, easeByHr);
        if (_actionEaseReason != ACTION_EASE_REASON_NONE) {
            return CARD_VARIANT_ACTION_EASE;
        }

        _actionEaseReason = ACTION_EASE_REASON_NONE;
        if (_pushActive) {
            return CARD_VARIANT_ACTION_PUSH;
        }

        return CARD_VARIANT_ACTION_HOLD;
    }

    function _resolveActionEaseReasonValue(easeByPace, easeByHr) {
        if (easeByPace and easeByHr) {
            return ACTION_EASE_REASON_BOTH;
        }
        if (easeByPace) {
            return ACTION_EASE_REASON_PACE;
        }
        if (easeByHr) {
            return ACTION_EASE_REASON_HR;
        }
        return ACTION_EASE_REASON_NONE;
    }

    function _getActionEaseReason() {
        return _actionEaseReason;
    }

    function _resolveActionMessage(actionVariant) {
        if (actionVariant == CARD_VARIANT_ACTION_EASE) {
            if (_getActionEaseReason() == ACTION_EASE_REASON_PACE) {
                return _actionEasePaceText;
            }
            return _actionEaseText;
        }
        if (actionVariant == CARD_VARIANT_ACTION_PUSH) {
            return _actionPushText;
        }
        return _actionHoldText;
    }

    function _resolveActionKey(actionVariant) {
        if (actionVariant == CARD_VARIANT_ACTION_PUSH) {
            return "PUSH";
        }
        if (actionVariant == CARD_VARIANT_ACTION_EASE) {
            return "EASE";
        }
        return "HOLD";
    }

    function _resolveCardStateKey(actionVariant, isLastSpurt) {
        if (isLastSpurt) {
            return CoachMessageUtils.STATE_KEY_LAST_SPURT;
        }
        if (actionVariant == CARD_VARIANT_ACTION_EASE) {
            return _slopeState + "_" + _resolveActionEaseStateKey();
        }
        return _slopeState + "_" + _resolveActionKey(actionVariant);
    }

    function _resolveActionEaseStateKey() {
        var easeReason = _getActionEaseReason();
        if (easeReason == ACTION_EASE_REASON_PACE) {
            return "EASE_PACE";
        }
        if (easeReason == ACTION_EASE_REASON_HR) {
            return "EASE_HR";
        }
        if (easeReason == ACTION_EASE_REASON_BOTH) {
            return "EASE_BOTH";
        }
        return "EASE";
    }

    function _resolveCardLabelText(actionVariant, fuelState, isLastSpurt) {
        if (isLastSpurt) {
            return _lastSpurtLabelText;
        }
        if (_isSameText(fuelState, CoachMessageUtils.FUEL_STATE_NOW)) {
            return _fuelNowLabelText;
        }
        if (_isSameText(fuelState, CoachMessageUtils.FUEL_STATE_PREP)) {
            return _fuelPrepLabelText;
        }
        return _resolveActionMessage(actionVariant);
    }

    function _pickCoachMessage(pool as Lang.Array) {
        if (pool == null or pool.size() <= 0) {
            return _actionHoldText;
        }

        var avoid1 = -1;
        var avoid2 = -1;
        for (var i = 0; i < pool.size(); i += 1) {
            if (pool[i] == _coachMessageCurrentText) {
                avoid1 = i;
            } else if (pool[i] == _coachMessagePreviousText) {
                avoid2 = i;
            }
        }

        var pickIdx = CoachUtils.randomMessageIndex(pool.size(), avoid1, avoid2);
        return pool[pickIdx];
    }

    function _resolveCoachMessageCategory(language, fuelState, stateKey) {
        var categories = CoachMessageUtils.displayCategories();
        if (categories == null or categories.size() <= 0) {
            return CoachMessageUtils.defaultCategory();
        }

        var availableCategories = [];
        for (var i = 0; i < categories.size(); i += 1) {
            var category = categories[i];
            var pool = CoachMessageUtils.getMessagePool(language, category, fuelState, stateKey);
            if (pool != null and pool.size() > 0) {
                availableCategories.add(category);
            }
        }

        if (availableCategories.size() <= 0) {
            return CoachMessageUtils.defaultCategory();
        }

        var pickIdx = CoachUtils.randomMessageIndex(availableCategories.size(), -1, -1);
        return availableCategories[pickIdx];
    }

    function _setActionCardDisplay(elapsedSec, fuelState, info, forceRefresh) {
        var actionVariant = _resolveActionVariant();
        var isLastSpurt = _isLastSpurtSegment(info);
        if (isLastSpurt) {
            fuelState = CoachMessageUtils.FUEL_STATE_NONE;
            _cardVariant = CARD_VARIANT_ACTION_PUSH;
        } else {
            _cardVariant = _resolveDisplayCardVariant(actionVariant, fuelState);
        }
        var stateKey = _resolveCardStateKey(actionVariant, isLastSpurt);
        var labelText = _resolveCardLabelText(actionVariant, fuelState, isLastSpurt);
        var language = CoachMessageUtils.resolveLanguage(_resolvePredictionSystemLanguage());
        var category = _coachMessageCategory;
        var messagePool = CoachMessageUtils.getMessagePool(language, category, fuelState, stateKey);

        var shouldRefresh = forceRefresh;
        if (_coachMessageStateKey == null or !_isSameText(_coachMessageStateKey, stateKey)) {
            shouldRefresh = true;
        }
        if (!_isSameText(_coachMessageFuelState, fuelState)) {
            shouldRefresh = true;
        }
        if (!_isSameText(_coachMessageLanguage, language)) {
            shouldRefresh = true;
        }
        if (_coachMessageCurrentText == null or _coachMessageCurrentText.length() == 0) {
            shouldRefresh = true;
        }
        if (
            !shouldRefresh and
            elapsedSec != null and
            _coachMessageLastChangeSec != null and
            (elapsedSec - _coachMessageLastChangeSec) >= MESSAGE_ROTATE_SEC
        ) {
            shouldRefresh = true;
        }

        if (shouldRefresh) {
            category = _resolveCoachMessageCategory(language, fuelState, stateKey);
            messagePool = CoachMessageUtils.getMessagePool(language, category, fuelState, stateKey);
            var nextMessage = _pickCoachMessage(messagePool);
            if (nextMessage == null or nextMessage.toString().length() == 0) {
                _logCoachMessageDiag("empty_pick", elapsedSec, stateKey, fuelState, labelText, nextMessage, messagePool);
                if (_coachMessageCurrentText != null and _coachMessageCurrentText.length() > 0) {
                    nextMessage = _coachMessageCurrentText;
                } else {
                    nextMessage = _resolveActionMessage(actionVariant);
                }
            }
            _coachMessagePreviousText = _coachMessageCurrentText;
            _coachMessageCurrentText = nextMessage;
            _coachMessageLastChangeSec = elapsedSec;
            _logCoachMessageDiag("refresh", elapsedSec, stateKey, fuelState, labelText, _coachMessageCurrentText, messagePool);
        }

        _coachMessageLanguage = language;
        _coachMessageCategory = category;
        _coachMessageStateKey = stateKey;
        _coachMessageFuelState = fuelState;
        _setCardLabelAndMessage(labelText, _coachMessageCurrentText);
        if (_cardLine2 == null or _cardLine2.length() == 0) {
            _logCoachMessageDiag("line2_empty", elapsedSec, stateKey, fuelState, labelText, _coachMessageCurrentText, messagePool);
        }
    }

    function _resolveDisplayCardVariant(actionVariant, fuelState) {
        if (_isSameText(fuelState, CoachMessageUtils.FUEL_STATE_NOW)) {
            return CARD_VARIANT_FUEL_NOW;
        }
        if (_isSameText(fuelState, CoachMessageUtils.FUEL_STATE_PREP)) {
            return CARD_VARIANT_FUEL_SOON;
        }
        return actionVariant;
    }

    function _setCardLabelAndMessage(labelText, messageText) {
        _cardLine1 = "";
        _cardLine2 = "";
        _cardLine3 = "";

        if (labelText != null) {
            _cardLine1 = _truncateCardText(labelText.toString(), 12);
        }
        if (messageText == null) {
            return;
        }

        var message = messageText.toString();
        if (message.length() == 0) {
            return;
        }
        _cardLine2 = message;
    }

    function _truncateCardText(text, maxChars) {
        if (text == null) {
            return "";
        }
        var raw = text.toString();
        if (raw.length() <= maxChars) {
            return raw;
        }
        if (maxChars <= 1) {
            return raw.substring(0, 1);
        }
        return raw.substring(0, maxChars - 1) + ".";
    }

    function _truncateTextToFit(dc as Gfx.Dc, font, text, maxWidth) {
        if (text == null or maxWidth <= 0) {
            return "";
        }

        var raw = text.toString();
        if (raw.length() == 0 or dc.getTextWidthInPixels(raw, font) <= maxWidth) {
            return raw;
        }

        if (raw.length() <= 1) {
            return raw.substring(0, 1);
        }

        for (var keep = raw.length() - 1; keep >= 1; keep -= 1) {
            var candidate = raw.substring(0, keep) + ".";
            if (dc.getTextWidthInPixels(candidate, font) <= maxWidth) {
                return candidate;
            }
        }

        return raw.substring(0, 1);
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
