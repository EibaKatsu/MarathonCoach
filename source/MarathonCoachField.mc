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
using DistanceNotifyUtils;
using FuelMeterUtils;
using RaceStrategyUtils;
using RenderUtils;
using SettingsLoader;

class MarathonCoachField extends Ui.DataField {
    const KEY_RACE_DISTANCE_KM = "race_distance_km";
    const KEY_TARGET_TIME_HOUR = "target_time_hour";
    const KEY_TARGET_TIME_MINUTE = "target_time_minute";
    const LAYOUT_DEBUG_OVERLAY = false;
    const FUEL_INTERVAL_SEC = 35 * 60;
    const HALF_FUEL_INTERVAL_SEC = 60 * 60;
    const LAP_DEBOUNCE_SEC = 20;
    const CARD_TOGGLE_SEC = 3;
    const DISTANCE_CARD_DISPLAY_SEC = 7;
    const DISTANCE_EVENT_EPSILON_KM = 0.02;
    const FUEL_TOGGLE_LEAD_SEC = 2 * 60;
    const FUEL_METER_WARNING_LEAD_SEC = 0;
    const FUEL_METER_LABEL_TOGGLE_SEC = 2;
    const FUEL_WARNING_BLINK_PERIOD_SEC = 2;
    const FUEL_WARNING_BLINK_ON_SEC = 1;
    const LAP_DIAG_LOG = false;
    const FUEL_PLAN_DIAG_LOG = false;
    const HR_OVER_TRIGGER_MARGIN_BPM = 1;
    const WARMUP_MESSAGE_ROTATE_SEC = 15;
    const DRIFT_BASELINE_START_SEC = 20 * 60;
    const DRIFT_BASELINE_MIN_DISTANCE_KM = 3.0;
    const DRIFT_WINDOW_SEC = 10 * 60;
    const DRIFT_PACE_STABLE_THRESHOLD_SEC = 5;
    const DRIFT_HR_ON_DELTA = 10;
    const DRIFT_HR_OFF_DELTA = 6;
    const DRIFT_OFF_CONFIRM_SEC = 60;
    const MIN_DISTANCE_FOR_PREDICTION_KM = 0.5;
    const PREDICTION_ON_PACE_THRESHOLD_SEC = 60;
    const ACTION_EASE_PACE_DELTA_SEC = -8;
    const ACTION_PUSH_TRIGGER_SEC = 6;
    const ACTION_PUSH_RELEASE_SEC = 5;
    const ACTION_PUSH_RELEASE_PACE_HYSTERESIS_SEC = 2;
    const ACTION_PUSH_RELEASE_HR_HYSTERESIS_BPM = 1;
    const ACTION_EASE_MIN_HEADROOM_BPM = 3;
    const ACTION_EASE_BASELINE_HR_DELTA_BPM = 6;
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
    const CARDIAC_COST_PUSH_MAX_RATIO_FULL = 1.06;
    const CARDIAC_COST_PUSH_MAX_RATIO_HALF = 1.08;
    const CARDIAC_COST_PUSH_MAX_RATIO_SHORT = 1.10;
    const CARDIAC_COST_EASE_MIN_RATIO_FULL = 1.10;
    const CARDIAC_COST_EASE_MIN_RATIO_HALF = 1.12;
    const CARDIAC_COST_EASE_MIN_RATIO_SHORT = 1.15;
    const CARDIAC_COST_MIN_SAMPLES = 30;
    const CARD_VARIANT_PREVIEW_ENABLED = false;
    const CARD_VARIANT_PREVIEW_SEC = 3;
    const SETTINGS_LOG = false;
    const FIT_FACT_LOG = false;
    const DIST_PROBE_LOG = false;

    const CARD_MODE_ACTION = 0;
    const CARD_MODE_FUEL = 1;
    const CARD_MODE_FUEL_OVERDUE = 2;
    const CARD_MODE_HR_OVER = 3;
    const CARD_MODE_DRIFT = 4;
    const CARD_MODE_DISTANCE = 5;
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
    const DISTANCE_NOTIFY_EVENT_NONE = 0;
    const DISTANCE_NOTIFY_EVENT_SPLIT = 1;
    const DISTANCE_NOTIFY_EVENT_MILESTONE = 2;
    const BEEP_HR_SUPPRESS_SEC = 75;
    const BEEP_DRIFT_SUPPRESS_SEC = 5 * 60;
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
    const FUEL_METER_CENTER_COLOR = 0x101820;
    const FUEL_RING_NORMAL_TRACK_COLOR = 0x23425C;
    const FUEL_RING_NORMAL_FILL_COLOR = 0x52B7E8;
    const FUEL_RING_CAUTION_TRACK_COLOR = 0x5E4E28;
    const FUEL_RING_CAUTION_FILL_COLOR = 0xF29F67;
    const FUEL_RING_WARNING_TRACK_COLOR = 0x6B2121;
    const FUEL_RING_WARNING_FILL_COLOR = 0xF01818;

    var _statusText = "Step3 Layout";
    var _fuelLabelText = "Fuel";
    var _goalTimeLabelText = "Tgt";
    var _goalDeltaText = "--:--(waiting)";
    var _predictionWaitingText = "waiting";
    var _predictionOnPaceText = "on pace";
    var _predictionAheadSuffixText = "m ahead";
    var _predictionBehindSuffixText = "m behind";
    var _actionPushText = "Push a bit";
    var _actionHoldText = "Hold pace";
    var _actionEaseText = "Ease down";
    var _hrOverLine1Text = "HR";
    var _hrOverLine2Text = "Over";
    var _hrOverLine3Text = "Zone";
    var _driftLine1Text = "Water";
    var _driftLine2Text = "+";
    var _driftLine3Text = "Fuel";
    var _fuelSoonLine2Text = "Soon";
    var _fuelNowLine2Text = "Now";
    var _fuelNowLine3Text = "!";
    var _fuelMeterPrimaryLabelText = "Fuel";
    var _fuelMeterAltLabelText = "Soon";
    var _fuelMeterWarningText = "Fuel now";
    var _fuelMeterWarningSubText = "Press lap";
    var _fuelMeterCautionPrefixText = "In ";
    var _fuelMeterCautionSuffixText = "m";
    var _fuelMeterMinuteSuffixText = "m";
    var _fuelMeterDoneText = "Done";
    var _fuelMeterNoPlanText = "No plan";
    var _distanceLabelFullText = "FULL";
    var _distanceLabelHalfText = "HALF";
    var _distanceLabel10kText = "10km";
    var _distanceLabel5kText = "5km";
    var _distanceSplitEarlyLine2 as Lang.Array = ["Early", "Relax", "No rush"];
    var _distanceSplitEarlyLine3 as Lang.Array = ["Settle", "Rhythm", "Smooth"];
    var _distanceSplitMidLine2 as Lang.Array = ["Flow", "Stable", "Steady"];
    var _distanceSplitMidLine3 as Lang.Array = ["Keep", "No slip", "Rhythm"];
    var _distanceSplitLateLine2 as Lang.Array = ["Go now", "Hang on", "Almost"];
    var _distanceSplitLateLine3 as Lang.Array = ["Step", "Forward", "No slip"];
    var _distanceMilestoneHalfLine2Text = "2nd half";
    var _distanceMilestoneHalfLine3Text = "Rhythm";
    var _distanceMilestone10kLine2Text = "2nd half";
    var _distanceMilestone10kLine3Text = "Steady";
    var _distanceMilestone5kLine2Text = "2nd half";
    var _distanceMilestone5kLine3Text = "Keep";
    var _distanceGoalLine2Text = "Done";
    var _distanceGoalLine3Text = "Nice";
    var _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
    var _customMode = CUSTOM_MODE_CORE;
    var _customCodeValid = false;
    var _customFuelMode = CUSTOM_FUEL_MODE_TIME;
    var _customFirstFuelAfterMin = CustomModeUtils.DEFAULT_FIRST_FUEL_AFTER_MIN;
    var _customFuelIntervalMin = CustomModeUtils.DEFAULT_FUEL_INTERVAL_MIN;
    var _customFuelAlertLeadMin = CustomModeUtils.DEFAULT_FUEL_ALERT_LEAD_MIN;
    var _customPhaseAggressiveness = CustomModeUtils.DEFAULT_PHASE_AGGRESSIVENESS;
    var _customHrCapBiasBpm = CustomModeUtils.DEFAULT_HR_CAP_BIAS_BPM;
    var _customDriftSensitivity = CustomModeUtils.DEFAULT_DRIFT_SENSITIVITY;
    var _fuelPlanSignature = null;
    var _targetTimeHms = null;
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
    var _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
    var _timerRunning = false;
    var _lastElapsedSec = null;
    var _lastLapResetSec = null;
    var _currentHeartRate = null;
    var _activeHeartRateZones as Lang.Array<Lang.Number> = [];
    var _currentHeartRateZone = null;
    var _allowedMaxHeartRate = null;
    var _hrZoneText = "-- / --";
    var _hrOverActive = false;
    var _hrOverStartSec = null;
    var _hrRecoverStartSec = null;
    var _pushActive = false;
    var _pushStartSec = null;
    var _pushRecoverStartSec = null;
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
    var _lastSettingsLogLine = null;
    var _probeLocDistanceM = 0.0;
    var _probeLocLastLocation = null;
    var _probeLocLastElapsedSec = null;
    var _probeSpeedDistanceM = 0.0;
    var _probeSpeedLastElapsedSec = null;
    var _lastDistanceProbeLogLine = null;
    var _warmupMessages as Lang.Array = [];
    var _warmupMessageSlot = -1;
    var _distanceNotifyRaceType = -1;
    var _distanceNotifyNextSplitKm = 1;
    var _distanceNotifyNextCheckpointIdx = 0;
    var _distanceNotifyLine1 = "";
    var _distanceNotifyLine2 = "";
    var _distanceNotifyLine3 = "";
    var _distanceNotifyUntilSec = null;
    var _cardMode = CARD_MODE_ACTION;
    var _cardVariant = CARD_VARIANT_ACTION_HOLD;
    var _cardLine1 = "EASE";
    var _cardLine2 = "DOWN";
    var _cardLine3 = "v -10s";
    var _cardBgWarmupSmall = null;
    var _cardBgActionPushSmall = null;
    var _cardBgActionHoldSmall = null;
    var _cardBgActionEaseSmall = null;
    var _cardBgFuelSoonSmall = null;
    var _cardBgFuelNowSmall = null;
    var _cardBgRecoverySmall = null;
    var _cardBgHrWarningSmall = null;
    var _beepStateInitialized = false;
    var _beepPrevFuelMeterState = FUEL_METER_STATE_NORMAL;
    var _beepPrevHrOver = false;
    var _beepPrevDriftOn = false;
    var _beepFuelNowActive = false;
    var _beepFuelNowNextRepeatSec = null;
    var _beepLastHrAlertSec = null;
    var _beepLastDriftAlertSec = null;
    var _beepLastElapsedSec = null;

    function initialize() {
        DataField.initialize();
        _loadLocalizedTexts();
        _loadSettings();
    }

    function _loadLocalizedTexts() {
        _statusText = Ui.loadResource(Rez.Strings.Step3Status);
        _fuelLabelText = Ui.loadResource(Rez.Strings.FuelLabel);
        _goalTimeLabelText = Ui.loadResource(Rez.Strings.GoalTimeLabel);
        _predictionWaitingText = Ui.loadResource(Rez.Strings.PredictionWaiting);
        _predictionOnPaceText = Ui.loadResource(Rez.Strings.PredictionOnPace);
        _predictionAheadSuffixText = Ui.loadResource(Rez.Strings.PredictionAheadSuffix);
        _predictionBehindSuffixText = Ui.loadResource(Rez.Strings.PredictionBehindSuffix);
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
        _fuelMeterPrimaryLabelText = Ui.loadResource(Rez.Strings.FuelMeterPrimaryLabel);
        _fuelMeterAltLabelText = Ui.loadResource(Rez.Strings.FuelMeterAltLabel);
        _fuelMeterWarningText = Ui.loadResource(Rez.Strings.FuelMeterWarningText);
        _fuelMeterWarningSubText = Ui.loadResource(Rez.Strings.FuelMeterWarningSubText);
        _fuelMeterCautionPrefixText = Ui.loadResource(Rez.Strings.FuelMeterCautionPrefix);
        _fuelMeterCautionSuffixText = Ui.loadResource(Rez.Strings.FuelMeterCautionSuffix);
        _fuelMeterMinuteSuffixText = Ui.loadResource(Rez.Strings.FuelMeterMinuteSuffix);
        _fuelMeterDoneText = Ui.loadResource(Rez.Strings.FuelMeterDoneText);
        _fuelMeterNoPlanText = Ui.loadResource(Rez.Strings.FuelMeterNoPlanText);
        _distanceLabelFullText = Ui.loadResource(Rez.Strings.DistanceLabelFull);
        _distanceLabelHalfText = Ui.loadResource(Rez.Strings.DistanceLabelHalf);
        _distanceLabel10kText = Ui.loadResource(Rez.Strings.DistanceLabel10k);
        _distanceLabel5kText = Ui.loadResource(Rez.Strings.DistanceLabel5k);

        _distanceSplitEarlyLine2 = [
            Ui.loadResource(Rez.Strings.DistanceSplitEarly1Line2),
            Ui.loadResource(Rez.Strings.DistanceSplitEarly2Line2),
            Ui.loadResource(Rez.Strings.DistanceSplitEarly3Line2)
        ];
        _distanceSplitEarlyLine3 = [
            Ui.loadResource(Rez.Strings.DistanceSplitEarly1Line3),
            Ui.loadResource(Rez.Strings.DistanceSplitEarly2Line3),
            Ui.loadResource(Rez.Strings.DistanceSplitEarly3Line3)
        ];
        _distanceSplitMidLine2 = [
            Ui.loadResource(Rez.Strings.DistanceSplitMid1Line2),
            Ui.loadResource(Rez.Strings.DistanceSplitMid2Line2),
            Ui.loadResource(Rez.Strings.DistanceSplitMid3Line2)
        ];
        _distanceSplitMidLine3 = [
            Ui.loadResource(Rez.Strings.DistanceSplitMid1Line3),
            Ui.loadResource(Rez.Strings.DistanceSplitMid2Line3),
            Ui.loadResource(Rez.Strings.DistanceSplitMid3Line3)
        ];
        _distanceSplitLateLine2 = [
            Ui.loadResource(Rez.Strings.DistanceSplitLate1Line2),
            Ui.loadResource(Rez.Strings.DistanceSplitLate2Line2),
            Ui.loadResource(Rez.Strings.DistanceSplitLate3Line2)
        ];
        _distanceSplitLateLine3 = [
            Ui.loadResource(Rez.Strings.DistanceSplitLate1Line3),
            Ui.loadResource(Rez.Strings.DistanceSplitLate2Line3),
            Ui.loadResource(Rez.Strings.DistanceSplitLate3Line3)
        ];

        _distanceMilestoneHalfLine2Text = Ui.loadResource(Rez.Strings.DistanceMilestoneHalfLine2);
        _distanceMilestoneHalfLine3Text = Ui.loadResource(Rez.Strings.DistanceMilestoneHalfLine3);
        _distanceMilestone10kLine2Text = Ui.loadResource(Rez.Strings.DistanceMilestone10kLine2);
        _distanceMilestone10kLine3Text = Ui.loadResource(Rez.Strings.DistanceMilestone10kLine3);
        _distanceMilestone5kLine2Text = Ui.loadResource(Rez.Strings.DistanceMilestone5kLine2);
        _distanceMilestone5kLine3Text = Ui.loadResource(Rez.Strings.DistanceMilestone5kLine3);
        _distanceGoalLine2Text = Ui.loadResource(Rez.Strings.DistanceGoalLine2);
        _distanceGoalLine3Text = Ui.loadResource(Rez.Strings.DistanceGoalLine3);

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
            Ui.loadResource(Rez.Strings.WarmupMsg10),
            Ui.loadResource(Rez.Strings.WarmupMsg11),
            Ui.loadResource(Rez.Strings.WarmupMsg12),
            Ui.loadResource(Rez.Strings.WarmupMsg13),
            Ui.loadResource(Rez.Strings.WarmupMsg14),
            Ui.loadResource(Rez.Strings.WarmupMsg15)
        ];

        _cardBgWarmupSmall = Ui.loadResource(Rez.Drawables.CardBgWarmupSmall);
        _cardBgActionPushSmall = Ui.loadResource(Rez.Drawables.CardBgActionPushSmall);
        _cardBgActionHoldSmall = Ui.loadResource(Rez.Drawables.CardBgActionHoldSmall);
        _cardBgActionEaseSmall = Ui.loadResource(Rez.Drawables.CardBgActionEaseSmall);
        _cardBgFuelSoonSmall = Ui.loadResource(Rez.Drawables.CardBgFuelSoonSmall);
        _cardBgFuelNowSmall = Ui.loadResource(Rez.Drawables.CardBgFuelNowSmall);
        _cardBgRecoverySmall = Ui.loadResource(Rez.Drawables.CardBgRecoverySmall);
        _cardBgHrWarningSmall = Ui.loadResource(Rez.Drawables.CardBgHrWarningSmall);

        _cardMode = CARD_MODE_ACTION;
        _cardVariant = CARD_VARIANT_ACTION_HOLD;
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
        _updatePushState(info);
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
        _lastFuelTimeSec = null;
        _fuelDueTimeSec = null;
        _fuelRemainingSec = null;
        _fuelRemainingText = "--:--";
        _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        _resetPaceWindow();
        _paceNowSecPerKm = null;
        _paceNowText = "--:--";
        _distanceTimeText = "--.- km  --:--:--";
        _goalDeltaText = _buildGoalDeltaText(null);
        _currentHeartRate = null;
        _activeHeartRateZones = [];
        _currentHeartRateZone = null;
        _allowedMaxHeartRate = null;
        _hrZoneText = "-- / --";
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
        _resetDistanceNotifyState();
        _resetBeepState();
        _setActionCardByBaseline(null);
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

    function onUpdate(dc as Gfx.Dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        _drawStep3Layout(dc);
    }

    function _loadSettings() {
        _raceDistanceKm = SettingsLoader.loadRaceDistanceKm(
            DEFAULT_RACE_DISTANCE_KM,
            KEY_RACE_DISTANCE_KM
        );
        _targetTimeHms = null;
        _targetTimeSec = null;
        _targetPaceSecPerKm = null;
        _applyCustomModeConfig(null);

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
        _customDriftSensitivity = CustomModeUtils.getDriftSensitivity(customConfig);
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
        if (_resolveRaceProfile() == RACE_PROFILE_HALF) {
            return HALF_FUEL_INTERVAL_SEC;
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

    function _resolveDriftSensitivityShift() {
        if (!_isCustomModeEnabled()) {
            return 0;
        }
        return _customDriftSensitivity - CustomModeUtils.DEFAULT_DRIFT_SENSITIVITY;
    }

    function _resolveDriftOnDeltaBpm() {
        var shift = _resolveDriftSensitivityShift();
        return _clamp(DRIFT_HR_ON_DELTA - shift, 4, 16);
    }

    function _resolveDriftOffDeltaBpm() {
        var shift = _resolveDriftSensitivityShift();
        return _clamp(DRIFT_HR_OFF_DELTA - shift, 2, 12);
    }

    function _resolveDriftOffConfirmSec() {
        var shift = _resolveDriftSensitivityShift();
        return _clamp(DRIFT_OFF_CONFIRM_SEC - (shift * 5), 30, 90);
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

    function _adjustEaseBaselineHrDeltaThresholdBpm(baseThreshold) {
        var shift = _resolvePhaseAggressivenessShift();
        var hrBias = _signedDivRounded(shift, 2);
        return _clamp(baseThreshold + hrBias, 2, 20);
    }

    function _adjustCardiacCostRatio(baseRatio, ratioStepPerShift, minRatio, maxRatio) {
        var shift = _resolvePhaseAggressivenessShift();
        var adjusted = baseRatio + (shift * ratioStepPerShift);
        return _clamp(adjusted, minRatio, maxRatio);
    }

    function _drawStep3Layout(dc as Gfx.Dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var minDim = _min(width, height);
        var sizeClass = _getSizeClass(minDim);

        var insetPct = 7;
        var paceFont = Gfx.FONT_LARGE;
        var footerFont = Gfx.FONT_SMALL;
        var paceDeltaFont = Gfx.FONT_XTINY;
        var fuelLabelFont = Gfx.FONT_XTINY;
        var fuelTimeFont = Gfx.FONT_SMALL;
        var fuelRadiusPct = 46;

        if (sizeClass == 2) {
            insetPct = 9;
            paceFont = Gfx.FONT_LARGE;
            footerFont = Gfx.FONT_SMALL;
            paceDeltaFont = Gfx.FONT_XTINY;
            fuelLabelFont = Gfx.FONT_XTINY;
            fuelTimeFont = Gfx.FONT_MEDIUM;
            fuelRadiusPct = 50;
        } else if (sizeClass == 0) {
            insetPct = 6;
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

        // 1st row left: HR gauge (value + Z1-Z5 bar + position marker)
        _drawHeartRateGauge(dc, leftColX, top, leftColW, rowHeight, sizeClass);

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
        _drawFuelMeter(dc, sizeClass, fuelCenterX, fuelCenterY, fuelRadius, fuelLabelFont, fuelTimeFont);

        // Left col row2-3 span: coach card
        var cardInset = _clamp((squareSize * 2) / 100, 2, 10);
        var cardX = leftColX + cardInset;
        var cardY = row1Y + cardInset;
        var cardW = leftColW - (cardInset * 2);
        var cardH = (row3Y - row1Y) - (cardInset * 2);
        var cardCorner = _clamp(cardW / 7, 8, 24);
        var maxCardCorner = _max((_min(cardW, cardH) / 2) - 1, 2);
        if (cardCorner > maxCardCorner) {
            cardCorner = maxCardCorner;
        }
        try {
            _drawCoachCardWithPng(dc, sizeClass, cardX, cardY, cardW, cardH, cardCorner);
        } catch (e) {
            _drawCoachCard(dc, sizeClass, cardX, cardY, cardW, cardH, cardCorner);
        }

        // 3rd row right: pace
        var paceY = row2Y;
        var paceUnitY = CoachUtils.textYByRatio(row2Y, rowHeight, 86, dc.getFontHeight(Gfx.FONT_XTINY));
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
        var mergedY = CoachUtils.textYByRatio(row3Y, row4Height, 24, dc.getFontHeight(footerFont));
        var paceDeltaY = CoachUtils.textYByRatio(row3Y, row4Height, 70, dc.getFontHeight(paceDeltaFont));
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

    function _drawCoachCard(dc as Gfx.Dc, sizeClass, cardX, cardY, cardW, cardH, cardCorner) {
        var borderColor = _getCardBorderColor(_cardVariant);
        var gradientTopColor = _getCardGradientTopColor(_cardVariant);
        var gradientMidColor = _getCardGradientMidColor(_cardVariant);
        var gradientBottomColor = _getCardGradientBottomColor(_cardVariant);
        var sheenColor = _getCardSheenColor(_cardVariant);
        var textColor = _getCardTextColor(_cardVariant);

        var borderWidth = _clamp((cardW * 2) / 100, 1, 3);
        var bodyX = cardX + borderWidth;
        var bodyY = cardY + borderWidth;
        var bodyW = cardW - (borderWidth * 2);
        var bodyH = cardH - (borderWidth * 2);
        var bodyCorner = cardCorner - borderWidth;
        var maxBodyCorner = _max((_min(bodyW, bodyH) / 2) - 1, 2);
        if (bodyCorner > maxBodyCorner) {
            bodyCorner = maxBodyCorner;
        }
        if (bodyCorner < 4) {
            bodyCorner = 4;
        }
        if (bodyCorner > maxBodyCorner) {
            bodyCorner = maxBodyCorner;
        }

        if (bodyW < 4 or bodyH < 4) {
            dc.setColor(borderColor, Gfx.COLOR_BLACK);
            dc.fillRoundedRectangle(cardX, cardY, cardW, cardH, cardCorner);
            return;
        }

        dc.setColor(borderColor, Gfx.COLOR_BLACK);
        dc.fillRoundedRectangle(cardX, cardY, cardW, cardH, cardCorner);
        _fillRoundedGradient(
            dc,
            bodyX,
            bodyY,
            bodyW,
            bodyH,
            bodyCorner,
            gradientTopColor,
            gradientMidColor,
            gradientBottomColor
        );

        var sheenInset = _clamp((bodyW * 6) / 100, 5, 18);
        var sheenHeight = _clamp((bodyH * 22) / 100, 5, 22);
        var sheenW = bodyW - (sheenInset * 2);
        if (sheenW > 4 and sheenHeight > 2) {
            dc.setColor(sheenColor, Gfx.COLOR_BLACK);
            dc.fillRectangle(bodyX + sheenInset, bodyY + 1, sheenW, sheenHeight);
        }

        var cardLines = _getCardDisplayLines();
        var cardLineCount = cardLines.size();
        var cardFont = _resolveCardFont(sizeClass, cardLineCount);
        var cardFontH = dc.getFontHeight(cardFont);
        var textPadTop = _clamp((bodyH * 14) / 100, 6, 16);
        var textPadBottom = _clamp((bodyH * 14) / 100, 6, 16);
        var textAreaY = bodyY + textPadTop;
        var textAreaH = bodyH - textPadTop - textPadBottom;
        if (textAreaH < cardFontH) {
            textAreaY = bodyY + _clamp((bodyH - cardFontH) / 2, 1, bodyH);
            textAreaH = cardFontH;
        }

        var cardGap = _resolveCardLineGap(cardLineCount, cardFontH, textAreaH);
        var textTotalH = (cardFontH * cardLineCount) + (cardGap * (cardLineCount - 1));
        var cardLineY = textAreaY + _max((textAreaH - textTotalH) / 2, 0);
        var textLeft = bodyX + _clamp((bodyW * 15) / 100, 10, 24);
        var textRight = bodyX + bodyW - _clamp((bodyW * 10) / 100, 8, 20);
        var textCenterX = textLeft + ((textRight - textLeft) / 2);

        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        for (var i = 0; i < cardLineCount; i += 1) {
            dc.drawText(textCenterX, cardLineY, cardFont, cardLines[i], Gfx.TEXT_JUSTIFY_CENTER);
            cardLineY += cardFontH + cardGap;
        }
    }

    function _drawCoachCardWithPng(dc as Gfx.Dc, sizeClass, cardX, cardY, cardW, cardH, cardCorner) {
        var frameColor = _getCardBorderColor(_cardVariant);
        var baseColor = _getCardGradientBottomColor(_cardVariant);
        var textColor = _getCardTextColor(_cardVariant);
        var innerX = cardX + 2;
        var innerY = cardY + 2;
        var innerW = cardW - 4;
        var innerH = cardH - 4;

        var bgBitmap = _getCardBgBitmapSmall(_cardVariant);
        if (bgBitmap != null) {
            var bgW = _getBitmapWidth(bgBitmap);
            var bgH = _getBitmapHeight(bgBitmap);
            if (bgW > 0 and bgH > 0) {
                if (sizeClass == 0) {
                    var drawX = cardX + ((cardW - bgW) / 2);
                    var drawY = cardY + ((cardH - bgH) / 2);
                    dc.drawBitmap(drawX, drawY, bgBitmap);
                    innerX = drawX + 2;
                    innerY = drawY + 2;
                    innerW = bgW - 4;
                    innerH = bgH - 4;
                } else {
                    var scaledDrawn = false;
                    if (dc has :drawScaledBitmap) {
                        try {
                            dc.drawScaledBitmap(cardX, cardY, cardW, cardH, bgBitmap);
                            var inset = _clamp((cardW * 3) / 100, 2, 7);
                            innerX = cardX + inset;
                            innerY = cardY + inset;
                            innerW = cardW - (inset * 2);
                            innerH = cardH - (inset * 2);
                            scaledDrawn = true;
                        } catch (e) {
                            scaledDrawn = false;
                        }
                    }

                    if (!scaledDrawn) {
                        var fallbackX = cardX + ((cardW - bgW) / 2);
                        var fallbackY = cardY + ((cardH - bgH) / 2);
                        dc.drawBitmap(fallbackX, fallbackY, bgBitmap);
                        innerX = fallbackX + 2;
                        innerY = fallbackY + 2;
                        innerW = bgW - 4;
                        innerH = bgH - 4;
                    }
                }
            } else {
                dc.drawBitmap(cardX, cardY, bgBitmap);
            }
        } else {
            dc.setColor(frameColor, Gfx.COLOR_BLACK);
            dc.fillRoundedRectangle(cardX, cardY, cardW, cardH, cardCorner);
            var innerCorner = _max(cardCorner - 2, 2);
            dc.setColor(baseColor, Gfx.COLOR_BLACK);
            dc.fillRoundedRectangle(innerX, innerY, innerW, innerH, innerCorner);
        }

        if (innerW < 8 or innerH < 8) {
            return;
        }

        var cardLines = _getCardDisplayLines();
        var cardLineCount = cardLines.size();
        var textPadX = _clamp((innerW * 12) / 100, 8, 12);
        var textAreaX = innerX + textPadX;
        var textAreaW = innerW - (textPadX * 2);
        if (textAreaW < 10) {
            textAreaX = innerX + 4;
            textAreaW = innerW - 8;
        }
        var textAreaY = innerY + _clamp((innerH * 14) / 100, 5, 11);
        var textAreaH = innerH - (_clamp((innerH * 14) / 100, 5, 11) * 2);
        var cardFont = _resolveCardFont(sizeClass, cardLineCount);
        cardFont = _adjustCardFontForSingleLineLimit(cardFont, cardLineCount, cardLines);
        var fontH = dc.getFontHeight(cardFont);
        if (textAreaH < fontH) {
            textAreaY = innerY + _max((innerH - fontH) / 2, 1);
            textAreaH = fontH;
        }

        var gap = _resolveCardLineGap(cardLineCount, fontH, textAreaH);
        var totalH = (fontH * cardLineCount) + (gap * (cardLineCount - 1));
        var textY = textAreaY + _max((textAreaH - totalH) / 2, 0);
        var textX = textAreaX + (textAreaW / 2);

        for (var i = 0; i < cardLineCount; i += 1) {
            _drawCardSmallTextBold(dc, textX, textY, cardFont, cardLines[i], textColor);
            textY += fontH + gap;
        }
    }

    function _drawCardSmallTextBold(dc as Gfx.Dc, x, y, font, text, textColor) {
        RenderUtils.drawCardSmallTextBold(dc, x, y, font, text, textColor);
    }

    function _getCardBgBitmapSmall(cardVariant) {
        return RenderUtils.getCardBgBitmapSmall(
            cardVariant,
            CARD_VARIANT_WARMUP,
            CARD_VARIANT_ACTION_PUSH,
            CARD_VARIANT_ACTION_HOLD,
            CARD_VARIANT_ACTION_EASE,
            CARD_VARIANT_FUEL_SOON,
            CARD_VARIANT_FUEL_NOW,
            CARD_VARIANT_RECOVERY,
            CARD_VARIANT_HR_WARNING,
            _cardBgWarmupSmall,
            _cardBgActionPushSmall,
            _cardBgActionHoldSmall,
            _cardBgFuelSoonSmall,
            _cardBgFuelNowSmall,
            _cardBgHrWarningSmall
        );
    }

    function _getBitmapWidth(bitmap) {
        if (bitmap == null) {
            return 0;
        }
        try {
            return bitmap.getWidth();
        } catch (e) {
            return 0;
        }
    }

    function _getBitmapHeight(bitmap) {
        if (bitmap == null) {
            return 0;
        }
        try {
            return bitmap.getHeight();
        } catch (e) {
            return 0;
        }
    }

    function _getCardBorderColor(cardVariant) {
        return RenderUtils.getCardBorderColor(
            cardVariant,
            CARD_VARIANT_WARMUP,
            CARD_VARIANT_ACTION_PUSH,
            CARD_VARIANT_ACTION_EASE,
            CARD_VARIANT_FUEL_SOON,
            CARD_VARIANT_FUEL_NOW,
            CARD_VARIANT_RECOVERY,
            CARD_VARIANT_HR_WARNING
        );
    }

    function _getCardGradientTopColor(cardVariant) {
        return RenderUtils.getCardGradientTopColor(
            cardVariant,
            CARD_VARIANT_WARMUP,
            CARD_VARIANT_ACTION_PUSH,
            CARD_VARIANT_ACTION_EASE,
            CARD_VARIANT_FUEL_SOON,
            CARD_VARIANT_FUEL_NOW,
            CARD_VARIANT_RECOVERY,
            CARD_VARIANT_HR_WARNING
        );
    }

    function _getCardGradientBottomColor(cardVariant) {
        return RenderUtils.getCardGradientBottomColor(
            cardVariant,
            CARD_VARIANT_WARMUP,
            CARD_VARIANT_ACTION_PUSH,
            CARD_VARIANT_ACTION_EASE,
            CARD_VARIANT_FUEL_SOON,
            CARD_VARIANT_FUEL_NOW,
            CARD_VARIANT_RECOVERY,
            CARD_VARIANT_HR_WARNING
        );
    }

    function _getCardGradientMidColor(cardVariant) {
        return RenderUtils.getCardGradientMidColor(
            cardVariant,
            CARD_VARIANT_WARMUP,
            CARD_VARIANT_ACTION_PUSH,
            CARD_VARIANT_ACTION_EASE,
            CARD_VARIANT_FUEL_SOON,
            CARD_VARIANT_FUEL_NOW,
            CARD_VARIANT_RECOVERY,
            CARD_VARIANT_HR_WARNING
        );
    }

    function _getCardSheenColor(cardVariant) {
        return RenderUtils.getCardSheenColor(
            cardVariant,
            CARD_VARIANT_WARMUP,
            CARD_VARIANT_ACTION_PUSH,
            CARD_VARIANT_ACTION_EASE,
            CARD_VARIANT_FUEL_SOON,
            CARD_VARIANT_FUEL_NOW,
            CARD_VARIANT_RECOVERY,
            CARD_VARIANT_HR_WARNING
        );
    }

    function _getCardAccentColor(cardVariant) {
        return RenderUtils.getCardAccentColor(
            cardVariant,
            CARD_VARIANT_WARMUP,
            CARD_VARIANT_ACTION_PUSH,
            CARD_VARIANT_ACTION_EASE,
            CARD_VARIANT_FUEL_SOON,
            CARD_VARIANT_FUEL_NOW,
            CARD_VARIANT_RECOVERY,
            CARD_VARIANT_HR_WARNING
        );
    }

    function _getCardTopBandColor(cardVariant) {
        return RenderUtils.getCardTopBandColor(
            cardVariant,
            CARD_VARIANT_WARMUP,
            CARD_VARIANT_ACTION_PUSH,
            CARD_VARIANT_ACTION_EASE,
            CARD_VARIANT_FUEL_SOON,
            CARD_VARIANT_FUEL_NOW,
            CARD_VARIANT_RECOVERY,
            CARD_VARIANT_HR_WARNING
        );
    }

    function _getCardTextColor(cardVariant) {
        return RenderUtils.getCardTextColor(cardVariant);
    }

    function _resolveCardFont(sizeClass, cardLineCount) {
        return RenderUtils.resolveCardFont(sizeClass, cardLineCount);
    }

    function _adjustCardFontForSingleLineLimit(font, cardLineCount, cardLines as Lang.Array) {
        return RenderUtils.adjustCardFontForSingleLineLimit(font, cardLineCount, cardLines);
    }

    function _shrinkCardFont(font) {
        return RenderUtils.shrinkCardFont(font);
    }

    function _containsNonAscii(text) as Lang.Boolean {
        return RenderUtils.containsNonAscii(text);
    }

    function _resolveCardLineGap(cardLineCount, fontH, areaH) {
        return RenderUtils.resolveCardLineGap(cardLineCount, fontH, areaH);
    }

    function _resolveCardFontToFit(dc as Gfx.Dc, sizeClass, cardLines as Lang.Array, textAreaW, textAreaH) {
        return RenderUtils.resolveCardFontToFit(dc, sizeClass, cardLines, textAreaW, textAreaH);
    }

    function _isCardTextFit(dc as Gfx.Dc, font, cardLines as Lang.Array, textAreaW, textAreaH) as Lang.Boolean {
        return RenderUtils.isCardTextFit(dc, font, cardLines, textAreaW, textAreaH);
    }

    function _fillRoundedGradient(dc as Gfx.Dc, x, y, width, height, corner, topColor, midColor, bottomColor) {
        RenderUtils.fillRoundedGradient(dc, x, y, width, height, corner, topColor, midColor, bottomColor);
    }

    function _drawFuelMeter(dc as Gfx.Dc, sizeClass, centerX, centerY, radius, labelFont, valueFont) {
        var fuelToggleLeadSec = _resolveFuelToggleLeadSec();
        var fuelIntervalSec = _resolveFuelIntervalSec();
        var meterState = FuelMeterUtils.resolveMeterState(
            _fuelDisplayMode,
            _fuelRemainingSec,
            fuelToggleLeadSec
        );
        var fuelDisplayMode = _fuelDisplayMode;
        var showCenterText = true;
        if (fuelDisplayMode == FUEL_DISPLAY_DISABLED) {
            showCenterText = false;
        } else if (meterState == FUEL_METER_STATE_WARNING) {
            showCenterText = _isFuelWarningBlinkVisible();
        }

        var ringTrackColor = FuelMeterUtils.resolveTrackColor(
            meterState,
            FUEL_RING_NORMAL_TRACK_COLOR,
            FUEL_RING_CAUTION_TRACK_COLOR,
            FUEL_RING_WARNING_TRACK_COLOR
        );
        var ringFillColor = FuelMeterUtils.resolveFillColor(
            meterState,
            FUEL_RING_NORMAL_FILL_COLOR,
            FUEL_RING_CAUTION_FILL_COLOR,
            FUEL_RING_WARNING_FILL_COLOR
        );
        var ringProgress = FuelMeterUtils.resolveProgressRatio(
            _fuelDisplayMode,
            meterState,
            _fuelRemainingSec,
            fuelIntervalSec
        );
        var centerText = FuelMeterUtils.resolveCenterText(
            _fuelDisplayMode,
            meterState,
            _fuelRemainingSec,
            _fuelMeterMinuteSuffixText,
            _fuelMeterDoneText,
            _fuelMeterNoPlanText,
            _fuelMeterWarningText
        );
        var warningSubText = FuelMeterUtils.resolveWarningSubText(
            _fuelDisplayMode,
            meterState,
            _fuelMeterWarningSubText
        );
        var meterLabelText = _resolveFuelMeterLabelText();

        var ringThickness = _clamp(radius / 4, 4, 11);
        if (fuelDisplayMode == FUEL_DISPLAY_DUE and meterState != FUEL_METER_STATE_NORMAL) {
            ringThickness = _clamp(ringThickness + 1, 4, 12);
        }
        var orbitRadius = radius - Math.floor(ringThickness / 2);
        if (orbitRadius < 2) {
            orbitRadius = 2;
        }
        var dotRadius = _clamp(Math.floor((ringThickness + 1) / 2), 2, 6);
        var segmentCount = _clamp((radius * 3), 28, 72);
        var activeSegments = Math.floor((ringProgress * segmentCount) + 0.5);
        if (activeSegments > segmentCount) {
            activeSegments = segmentCount;
        }

        var pi = 3.141592653589793;
        var startAngleRad = -(pi / 2.0);
        var stepAngleRad = (2.0 * pi) / segmentCount;
        for (var i = 0; i < segmentCount; i += 1) {
            var angleRad = startAngleRad + (stepAngleRad * i);
            var ringX = centerX + (Math.cos(angleRad) * orbitRadius);
            var ringY = centerY + (Math.sin(angleRad) * orbitRadius);
            if (i < activeSegments) {
                dc.setColor(ringFillColor, Gfx.COLOR_BLACK);
            } else {
                dc.setColor(ringTrackColor, Gfx.COLOR_BLACK);
            }
            dc.fillCircle(Math.floor(ringX + 0.5), Math.floor(ringY + 0.5), dotRadius);
        }
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawCircle(centerX, centerY, radius);

        var innerRadius = radius - ringThickness - 1;
        if (innerRadius > 0) {
            dc.setColor(FUEL_METER_CENTER_COLOR, Gfx.COLOR_BLACK);
            dc.fillCircle(centerX, centerY, innerRadius);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawCircle(centerX, centerY, innerRadius);
        }

        var centerTextFont = valueFont;
        if (centerText != null and centerText.length() >= 5) {
            if (sizeClass == 2) {
                centerTextFont = Gfx.FONT_SMALL;
            } else {
                centerTextFont = Gfx.FONT_TINY;
            }
        }
        var warningSubTextFont = Gfx.FONT_XTINY;

        var showTopLabel = !(fuelDisplayMode == FUEL_DISPLAY_DUE and meterState == FUEL_METER_STATE_WARNING);
        var labelY = CoachUtils.textYByRatio(
            centerY - radius,
            radius * 2,
            31,
            dc.getFontHeight(labelFont)
        );
        var centerTextRatio = 60;
        if (!showTopLabel) {
            centerTextRatio = 50;
        }
        var centerTextY = CoachUtils.textYByRatio(
            centerY - radius,
            radius * 2,
            centerTextRatio,
            dc.getFontHeight(centerTextFont)
        );
        var warningSubTextY = centerTextY;
        if (warningSubText != null) {
            centerTextY = CoachUtils.textYByRatio(
                centerY - radius,
                radius * 2,
                42,
                dc.getFontHeight(centerTextFont)
            );
            warningSubTextY = CoachUtils.textYByRatio(
                centerY - radius,
                radius * 2,
                64,
                dc.getFontHeight(warningSubTextFont)
            );
        }

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        if (showTopLabel) {
            dc.drawText(centerX, labelY, labelFont, meterLabelText, Gfx.TEXT_JUSTIFY_CENTER);
        }
        if (showCenterText and centerText != null and centerText.length() > 0) {
            dc.drawText(centerX, centerTextY, centerTextFont, centerText, Gfx.TEXT_JUSTIFY_CENTER);
            if (warningSubText != null) {
                dc.drawText(centerX, warningSubTextY, warningSubTextFont, warningSubText, Gfx.TEXT_JUSTIFY_CENTER);
            }
        }
    }

    function _isFuelWarningBlinkVisible() {
        var blinkSec = _lastElapsedSec;
        if (blinkSec == null or blinkSec < 0) {
            blinkSec = Math.floor(Sys.getTimer() / 1000.0);
        }
        if (blinkSec == null or blinkSec < 0) {
            return true;
        }

        var elapsedPeriods = Math.floor(blinkSec / FUEL_WARNING_BLINK_PERIOD_SEC);
        var periodStartSec = elapsedPeriods * FUEL_WARNING_BLINK_PERIOD_SEC;
        var inPeriodSec = blinkSec - periodStartSec;
        return inPeriodSec < FUEL_WARNING_BLINK_ON_SEC;
    }

    function _resolveFuelMeterLabelText() {
        var raceProfile = _resolveRaceProfile();
        if (raceProfile != RACE_PROFILE_FULL) {
            return _fuelMeterPrimaryLabelText;
        }
        var uptimeSec = Math.floor(Sys.getTimer() / 1000.0);
        var slot = Math.floor(uptimeSec / FUEL_METER_LABEL_TOGGLE_SEC);
        var halfSlot = Math.floor(slot / 2);
        if ((slot - (halfSlot * 2)) >= 1) {
            return _fuelMeterAltLabelText;
        }
        return _fuelMeterPrimaryLabelText;
    }

    function _drawHeartRateGauge(dc as Gfx.Dc, areaX, areaY, areaW, areaH, sizeClass) {
        var valueFont = Gfx.FONT_MEDIUM;
        if (sizeClass == 2) {
            valueFont = Gfx.FONT_LARGE;
        } else if (sizeClass == 0) {
            valueFont = Gfx.FONT_SMALL;
        }

        var valueText = "--";
        if (_currentHeartRate != null) {
            valueText = _currentHeartRate.format("%d");
        }

        var valueHeight = dc.getFontHeight(valueFont);
        var markerHeight = _clamp((areaH * 25) / 100, 6, 12);
        var gaugeHeight = _clamp((areaH * 22) / 100, 8, 14);
        // Keep the numeric label position stable, then move only the gauge upward.
        var baseGaugeTop = areaY + areaH - markerHeight - gaugeHeight;
        var valueY = baseGaugeTop - valueHeight;
        if (valueY < areaY) {
            valueY = areaY;
        }
        var glyphBottomInset = _clamp(valueHeight / 6, 2, 6);
        var gaugeTop = (valueY + valueHeight) - glyphBottomInset;
        var maxGaugeTop = areaY + areaH - markerHeight - gaugeHeight;
        if (gaugeTop > maxGaugeTop) {
            gaugeTop = maxGaugeTop;
        }

        var gaugeHorizontalInset = _clamp((areaW * 10) / 100, 6, 18);
        if (sizeClass == 0) {
            gaugeHorizontalInset = _clamp((areaW * 16) / 100, 10, 24);
        } else if (sizeClass == 2) {
            gaugeHorizontalInset = _clamp((areaW * 8) / 100, 4, 14);
        }
        var gaugeAreaX = areaX + gaugeHorizontalInset;
        var gaugeAreaW = areaW - (gaugeHorizontalInset * 2);
        if (gaugeAreaW < 24) {
            gaugeAreaX = areaX;
            gaugeAreaW = areaW;
        }

        var segmentGap = _clamp(gaugeAreaW / 60, 1, 3);
        var totalGap = (HR_GAUGE_ZONE_COUNT - 1) * segmentGap;
        var segmentWidth = Math.floor((gaugeAreaW - totalGap) / HR_GAUGE_ZONE_COUNT);
        if (segmentWidth < 4) {
            segmentWidth = 4;
        }
        var gaugeWidth = (segmentWidth * HR_GAUGE_ZONE_COUNT) + totalGap;
        if (gaugeWidth > gaugeAreaW) {
            gaugeWidth = gaugeAreaW;
            segmentWidth = Math.floor((gaugeWidth - totalGap) / HR_GAUGE_ZONE_COUNT);
            if (segmentWidth < 2) {
                segmentWidth = 2;
            }
            gaugeWidth = (segmentWidth * HR_GAUGE_ZONE_COUNT) + totalGap;
        }

        var gaugeX = Math.floor(gaugeAreaX + ((gaugeAreaW - gaugeWidth) / 2));
        for (var i = 0; i < HR_GAUGE_ZONE_COUNT; i += 1) {
            var segX = gaugeX + (i * (segmentWidth + segmentGap));
            dc.setColor(_getHeartRateZoneGaugeColor(i + 1), Gfx.COLOR_BLACK);
            dc.fillRectangle(segX, gaugeTop, segmentWidth, gaugeHeight);
        }

        if (_currentHeartRate != null) {
            var markerRatio = _resolveHeartRateGaugeRatio();
            var markerX = gaugeX + Math.floor((markerRatio * (gaugeWidth - 1)) + 0.5);
            var markerTipY = gaugeTop + gaugeHeight + 1;
            var markerHalfWidth = _clamp(segmentWidth / 3, 2, 5);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
            _drawUpTriangleMarker(dc, markerX, markerTipY, markerHalfWidth, markerHeight);
        }

        // Draw value last so it always stays above the gauge layer.
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            areaX + (areaW / 2),
            valueY,
            valueFont,
            valueText,
            Gfx.TEXT_JUSTIFY_CENTER
        );
    }

    function _drawUpTriangleMarker(dc as Gfx.Dc, centerX, tipY, halfWidth, height) {
        RenderUtils.drawUpTriangleMarker(dc, centerX, tipY, halfWidth, height);
    }

    function _getHeartRateZoneGaugeColor(zoneNumber) {
        return RenderUtils.getHeartRateZoneGaugeColor(
            zoneNumber,
            HR_ZONE_COLOR_1,
            HR_ZONE_COLOR_2,
            HR_ZONE_COLOR_3,
            HR_ZONE_COLOR_4,
            HR_ZONE_COLOR_5
        );
    }

    function _resolveHeartRateGaugeRatio() {
        if (_currentHeartRate == null) {
            return 0.5;
        }

        var heartRate = _currentHeartRate;
        var zoneNumber = _currentHeartRateZone;
        if (zoneNumber == null) {
            zoneNumber = _resolveHeartRateZone(_currentHeartRate, _activeHeartRateZones);
        }
        if (zoneNumber == null) {
            return _resolveHeartRateGaugeRatioFallback(heartRate);
        }

        zoneNumber = _clamp(zoneNumber, 1, HR_GAUGE_ZONE_COUNT);
        var upper = _getZoneUpperHeartRate(_activeHeartRateZones, zoneNumber);
        if (upper == null) {
            return _resolveHeartRateGaugeRatioFallback(heartRate);
        }

        var lower = null;
        if (zoneNumber > 1) {
            lower = _getZoneUpperHeartRate(_activeHeartRateZones, zoneNumber - 1);
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
            _appendPaceSample(samplePaceSecPerKm);
            _lastPaceSampleElapsedSec = elapsedSec;
        }

        if (_paceRingCount == 0) {
            _paceNowSecPerKm = null;
            _paceNowText = "--:--";
            return;
        }

        _paceNowSecPerKm = _paceRingSum / _paceRingCount;
        _paceNowText = CoachUtils.formatPaceSecPerKm(_paceNowSecPerKm);
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
            distanceText = CoachUtils.formatDistanceKm(distanceKm);
        }

        var elapsedText = "--:--:--";
        if (elapsedSec != null) {
            elapsedText = CoachUtils.formatElapsedTime(elapsedSec);
        }

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

        _goalDeltaText = _buildGoalDeltaText(predictedTotalSec);
    }

    function _updateHeartRate(info) {
        var heartRate = _extractCurrentHeartRate(info);
        if (heartRate != null and heartRate > 0) {
            _currentHeartRate = heartRate;
        } else {
            _currentHeartRate = null;
        }

        _activeHeartRateZones = _resolveActiveHeartRateZones();
        _allowedMaxHeartRate = _resolveAllowedMaxHeartRate(info, _activeHeartRateZones);
        _currentHeartRateZone = _resolveHeartRateZone(_currentHeartRate, _activeHeartRateZones);

        var hrText = "--";
        if (_currentHeartRate != null) {
            hrText = _currentHeartRate.format("%d");
        }

        var zoneText = "--";
        if (_currentHeartRateZone != null) {
            zoneText = "Z" + _currentHeartRateZone.format("%d");
        }

        _hrZoneText = hrText + " / " + zoneText;
    }

    function _resolveActiveHeartRateZones() as Lang.Array<Lang.Number> {
        var zones = _getHeartRateZonesForCurrentSport();
        if (zones != null and zones.size() > 0) {
            return zones;
        }

        var genericZones = _getGenericHeartRateZones();
        if (genericZones != null and genericZones.size() > 0) {
            return genericZones;
        }

        return [];
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
        if (zones == null or zones.size() == 0 or zoneNumber <= 0) {
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
        var line =
            "[SETTINGS] raceRaw=" + _factValue(rawRace) +
            " hourRaw=" + _factValue(rawHour) +
            " minuteRaw=" + _factValue(rawMinute) +
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
            " hrBias=" + _factValue(_customHrCapBiasBpm) +
            " driftSens=" + _factValue(_customDriftSensitivity);
        if (_isSameText(_lastSettingsLogLine, line)) {
            return;
        }
        _lastSettingsLogLine = line;
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

    function _getActionEaseBaselineHrDeltaBpm(distanceKm) {
        return RaceStrategyUtils.getActionEaseBaselineHrDeltaBpm(
            distanceKm,
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM,
            RACE_PHASE_1_END_PROGRESS,
            RACE_PHASE_2_END_PROGRESS,
            RACE_PHASE_3_END_PROGRESS,
            RACE_PHASE_4_END_PROGRESS,
            ACTION_EASE_BASELINE_HR_DELTA_BPM
        );
    }

    function _getCardiacCostPushMaxRatio(distanceKm) {
        var baseRatio = RaceStrategyUtils.getCardiacCostPushMaxRatio(
            distanceKm,
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM,
            CARDIAC_COST_PUSH_MAX_RATIO_FULL,
            CARDIAC_COST_PUSH_MAX_RATIO_HALF,
            CARDIAC_COST_PUSH_MAX_RATIO_SHORT
        );
        return _adjustCardiacCostRatio(baseRatio, 0.003, 1.00, 1.20);
    }

    function _getCardiacCostEaseMinRatio(distanceKm) {
        var baseRatio = RaceStrategyUtils.getCardiacCostEaseMinRatio(
            distanceKm,
            _raceDistanceKm,
            SHORT_DISTANCE_MAX_KM,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM,
            CARDIAC_COST_EASE_MIN_RATIO_FULL,
            CARDIAC_COST_EASE_MIN_RATIO_HALF,
            CARDIAC_COST_EASE_MIN_RATIO_SHORT
        );
        return _adjustCardiacCostRatio(baseRatio, 0.004, 1.00, 1.25);
    }

    function _resolveCardiacCostRatio() {
        if (
            _driftBaseHr == null or _driftBasePace == null or
            _driftRingCount < CARDIAC_COST_MIN_SAMPLES
        ) {
            return null;
        }
        if (_driftBaseHr <= 0 or _driftBasePace <= 0) {
            return null;
        }

        var curHr = _driftRingHrSum / _driftRingCount;
        var curPace = _driftRingPaceSum / _driftRingCount;
        if (curHr == null or curPace == null or curHr <= 0 or curPace <= 0) {
            return null;
        }
        var paceDiffAbs = _abs(curPace - _driftBasePace);
        if (paceDiffAbs > DRIFT_PACE_STABLE_THRESHOLD_SEC) {
            return null;
        }

        var baseCost = _driftBaseHr * _driftBasePace;
        if (baseCost <= 0) {
            return null;
        }
        var curCost = curHr * curPace;
        return curCost / baseCost;
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
        if (!_driftActive and hrDelta >= _resolveDriftOnDeltaBpm()) {
            _driftActive = true;
            _driftOffStartSec = null;
            return;
        }

        if (_driftActive and hrDelta <= _resolveDriftOffDeltaBpm()) {
            if (_driftOffStartSec == null) {
                _driftOffStartSec = elapsedSec;
                return;
            }
            if ((elapsedSec - _driftOffStartSec) >= _resolveDriftOffConfirmSec()) {
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
        if (CARD_VARIANT_PREVIEW_ENABLED) {
            _applyCardVariantPreview();
            return;
        }

        var elapsedSec = _extractElapsedSec(info);
        var fuelOverdue = _isFuelOverdue();
        var hrOver = _isHeartRateOverCap();
        var driftOn = _isDriftOn(info);
        var distanceNotifyEvent = _updateDistanceNotifyState(info, elapsedSec, fuelOverdue or hrOver or driftOn);
        _updateBeepNotifications(elapsedSec, fuelOverdue, hrOver, driftOn, distanceNotifyEvent);

        if (fuelOverdue) {
            _clearDistanceNotifyCard();
            _setCardFixedLines(
                CARD_MODE_FUEL_OVERDUE,
                CARD_VARIANT_FUEL_NOW,
                _fuelNowLine2Text,
                _fuelLabelText + _fuelNowLine3Text,
                ""
            );
            return;
        }

        if (hrOver) {
            _clearDistanceNotifyCard();
            _setCardFixedLines(
                CARD_MODE_HR_OVER,
                CARD_VARIANT_HR_WARNING,
                _hrOverLine1Text,
                _hrOverLine2Text,
                _hrOverLine3Text
            );
            return;
        }

        if (driftOn) {
            _clearDistanceNotifyCard();
            _setCardFixedLines(
                CARD_MODE_DRIFT,
                CARD_VARIANT_RECOVERY,
                _driftLine1Text,
                _driftLine2Text,
                _driftLine3Text
            );
            return;
        }

        if (elapsedSec == null) {
            _setActionCardByBaseline(null);
            return;
        }

        if (_applyDistanceNotifyCard(elapsedSec)) {
            return;
        }

        var fuelToggleLeadSec = _resolveFuelToggleLeadSec();
        // Toggle starts in the configured lead time before fuel due.
        var inFuelToggleWindow = (
            _isFuelCardEnabled() and
            _fuelRemainingSec != null and
            _fuelRemainingSec > 0 and
            _fuelRemainingSec <= fuelToggleLeadSec
        );
        if (inFuelToggleWindow) {
            var toggleSlot = Math.floor(elapsedSec / CARD_TOGGLE_SEC);
            var halfToggleSlot = Math.floor(toggleSlot / 2);
            var showFuelCard = ((toggleSlot - (halfToggleSlot * 2)) >= 1);
            if (showFuelCard) {
                _setCardFixedLines(
                    CARD_MODE_FUEL,
                    CARD_VARIANT_FUEL_SOON,
                    _fuelLabelText,
                    _resolveFuelSoonCardLine2(),
                    ""
                );
                return;
            }
        }

        _setActionCardByBaseline(elapsedSec);
    }

    function _updateDistanceNotifyState(info, elapsedSec, suppressDisplay) {
        if (elapsedSec == null) {
            return DISTANCE_NOTIFY_EVENT_NONE;
        }

        var distanceKm = _extractElapsedDistanceKm(info);
        if (distanceKm == null) {
            return DISTANCE_NOTIFY_EVENT_NONE;
        }

        _ensureDistanceNotifyPlan();

        var notifyLine1 = null;
        var notifyLine2 = null;
        var notifyLine3 = null;
        var notifyEvent = DISTANCE_NOTIFY_EVENT_NONE;

        var checkpointCount = DistanceNotifyUtils.getCheckpointCount(_distanceNotifyRaceType);
        while (_distanceNotifyNextCheckpointIdx < checkpointCount) {
            var checkpointKm = DistanceNotifyUtils.getCheckpointKm(
                _distanceNotifyRaceType,
                _distanceNotifyNextCheckpointIdx
            );
            if (
                checkpointKm == null or
                !DistanceNotifyUtils.hasReachedTarget(distanceKm, checkpointKm, DISTANCE_EVENT_EPSILON_KM)
            ) {
                break;
            }

            var checkpointFloorKm = Math.floor(checkpointKm + DISTANCE_EVENT_EPSILON_KM);
            if (_distanceNotifyNextSplitKm <= checkpointFloorKm) {
                _distanceNotifyNextSplitKm = checkpointFloorKm + 1;
            }

            notifyLine1 = _getDistanceCheckpointLine1(_distanceNotifyRaceType, _distanceNotifyNextCheckpointIdx);
            notifyLine2 = _getDistanceCheckpointLine2(_distanceNotifyRaceType, _distanceNotifyNextCheckpointIdx);
            notifyLine3 = _getDistanceCheckpointLine3(_distanceNotifyRaceType, _distanceNotifyNextCheckpointIdx);
            notifyEvent = DISTANCE_NOTIFY_EVENT_MILESTONE;
            _distanceNotifyNextCheckpointIdx += 1;
        }

        if (notifyLine1 == null) {
            var maxSplitKm = DistanceNotifyUtils.getMaxSplitKm(_distanceNotifyRaceType);
            while (
                _distanceNotifyNextSplitKm <= maxSplitKm and
                DistanceNotifyUtils.hasReachedTarget(
                    distanceKm,
                    _distanceNotifyNextSplitKm,
                    DISTANCE_EVENT_EPSILON_KM
                )
            ) {
                var splitLines = _buildDistanceSplitLines(_distanceNotifyNextSplitKm);
                notifyLine1 = splitLines[0];
                notifyLine2 = splitLines[1];
                notifyLine3 = splitLines[2];
                notifyEvent = DISTANCE_NOTIFY_EVENT_SPLIT;
                _distanceNotifyNextSplitKm += 1;
            }
        }

        if (notifyLine1 == null) {
            return DISTANCE_NOTIFY_EVENT_NONE;
        }

        if (suppressDisplay) {
            _clearDistanceNotifyCard();
            return notifyEvent;
        }

        _setDistanceNotifyCard(notifyLine1, notifyLine2, notifyLine3, elapsedSec);
        return notifyEvent;
    }

    function _resetBeepState() {
        _beepStateInitialized = false;
        _beepPrevFuelMeterState = FUEL_METER_STATE_NORMAL;
        _beepPrevHrOver = false;
        _beepPrevDriftOn = false;
        _beepFuelNowActive = false;
        _beepFuelNowNextRepeatSec = null;
        _beepLastHrAlertSec = null;
        _beepLastDriftAlertSec = null;
        _beepLastElapsedSec = null;
    }

    function _updateBeepNotifications(elapsedSec, fuelOverdue, hrOver, driftOn, distanceNotifyEvent) {
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
            _beepPrevDriftOn = driftOn;
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

            if (driftOn and !_beepPrevDriftOn) {
                if (
                    _beepLastDriftAlertSec == null or
                    (elapsedSec - _beepLastDriftAlertSec) >= BEEP_DRIFT_SUPPRESS_SEC
                ) {
                    beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_DRIFT_ON);
                    _beepLastDriftAlertSec = elapsedSec;
                }
            }

            if (
                fuelMeterState == FUEL_METER_STATE_CAUTION and
                _beepPrevFuelMeterState != FUEL_METER_STATE_CAUTION
            ) {
                beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_FUEL_SOON);
            }

            if (distanceNotifyEvent == DISTANCE_NOTIFY_EVENT_MILESTONE) {
                beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_DISTANCE_MILESTONE);
            } else if (distanceNotifyEvent == DISTANCE_NOTIFY_EVENT_SPLIT) {
                beepEvent = BeepUtils.selectHigherPriorityEvent(beepEvent, BeepUtils.EVENT_DISTANCE_SPLIT);
            }
        }

        _playBeepEvent(beepEvent);
        _beepPrevFuelMeterState = fuelMeterState;
        _beepPrevHrOver = hrOver;
        _beepPrevDriftOn = driftOn;
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

    function _applyDistanceNotifyCard(elapsedSec) {
        if (_distanceNotifyUntilSec == null) {
            return false;
        }
        if (elapsedSec == null or elapsedSec >= _distanceNotifyUntilSec) {
            _clearDistanceNotifyCard();
            return false;
        }

        _setCardFixedLines(
            CARD_MODE_DISTANCE,
            CARD_VARIANT_ACTION_HOLD,
            _distanceNotifyLine1,
            _distanceNotifyLine2,
            _distanceNotifyLine3
        );
        return true;
    }

    function _setDistanceNotifyCard(line1, line2, line3, elapsedSec) {
        _distanceNotifyLine1 = "";
        _distanceNotifyLine2 = "";
        _distanceNotifyLine3 = "";

        if (line1 != null) {
            _distanceNotifyLine1 = line1.toString();
        }
        if (line2 != null) {
            _distanceNotifyLine2 = line2.toString();
        }
        if (line3 != null) {
            _distanceNotifyLine3 = line3.toString();
        }
        _distanceNotifyUntilSec = elapsedSec + DISTANCE_CARD_DISPLAY_SEC;
    }

    function _clearDistanceNotifyCard() {
        _distanceNotifyLine1 = "";
        _distanceNotifyLine2 = "";
        _distanceNotifyLine3 = "";
        _distanceNotifyUntilSec = null;
    }

    function _resetDistanceNotifyState() {
        _distanceNotifyRaceType = -1;
        _distanceNotifyNextSplitKm = 1;
        _distanceNotifyNextCheckpointIdx = 0;
        _clearDistanceNotifyCard();
    }

    function _ensureDistanceNotifyPlan() {
        var raceType = DistanceNotifyUtils.resolveRaceType(
            _raceDistanceKm,
            HALF_DISTANCE_KM,
            HALF_DISTANCE_TOLERANCE_KM
        );
        if (_distanceNotifyRaceType == raceType) {
            return;
        }

        _distanceNotifyRaceType = raceType;
        _distanceNotifyNextSplitKm = 1;
        _distanceNotifyNextCheckpointIdx = 0;
        _clearDistanceNotifyCard();
    }

    function _getDistanceCheckpointLine1(raceType, checkpointIdx) {
        if (raceType == DistanceNotifyUtils.RACE_FULL) {
            if (checkpointIdx == 0) {
                return _distanceLabelHalfText;
            }
            if (checkpointIdx == 1) {
                return _distanceLabelFullText;
            }
            return "";
        }

        if (raceType == DistanceNotifyUtils.RACE_HALF) {
            if (checkpointIdx == 0) {
                return _distanceLabel10kText;
            }
            if (checkpointIdx == 1) {
                return _distanceLabelHalfText;
            }
            return "";
        }

        if (raceType == DistanceNotifyUtils.RACE_TEN) {
            if (checkpointIdx == 0) {
                return _distanceLabel5kText;
            }
            if (checkpointIdx == 1) {
                return _distanceLabel10kText;
            }
            return "";
        }

        return _distanceLabel5kText;
    }

    function _getDistanceCheckpointLine2(raceType, checkpointIdx) {
        if (raceType == DistanceNotifyUtils.RACE_FULL) {
            if (checkpointIdx == 0) {
                return _distanceMilestoneHalfLine2Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine2Text;
            }
            return "";
        }

        if (raceType == DistanceNotifyUtils.RACE_HALF) {
            if (checkpointIdx == 0) {
                return _distanceMilestone10kLine2Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine2Text;
            }
            return "";
        }

        if (raceType == DistanceNotifyUtils.RACE_TEN) {
            if (checkpointIdx == 0) {
                return _distanceMilestone5kLine2Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine2Text;
            }
            return "";
        }

        if (checkpointIdx == 0) {
            return _distanceGoalLine2Text;
        }
        return "";
    }

    function _getDistanceCheckpointLine3(raceType, checkpointIdx) {
        if (raceType == DistanceNotifyUtils.RACE_FULL) {
            if (checkpointIdx == 0) {
                return _distanceMilestoneHalfLine3Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine3Text;
            }
            return "";
        }

        if (raceType == DistanceNotifyUtils.RACE_HALF) {
            if (checkpointIdx == 0) {
                return _distanceMilestone10kLine3Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine3Text;
            }
            return "";
        }

        if (raceType == DistanceNotifyUtils.RACE_TEN) {
            if (checkpointIdx == 0) {
                return _distanceMilestone5kLine3Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine3Text;
            }
            return "";
        }

        if (checkpointIdx == 0) {
            return _distanceGoalLine3Text;
        }
        return "";
    }

    function _buildDistanceSplitLines(splitKm) as Lang.Array {
        var line1 = splitKm.format("%d") + "km";
        var phase = DistanceNotifyUtils.resolveSplitPhase(splitKm, _raceDistanceKm);
        var line2Templates = _distanceSplitEarlyLine2;
        var line3Templates = _distanceSplitEarlyLine3;
        if (phase == DistanceNotifyUtils.PHASE_MID) {
            line2Templates = _distanceSplitMidLine2;
            line3Templates = _distanceSplitMidLine3;
        } else if (phase == DistanceNotifyUtils.PHASE_LATE) {
            line2Templates = _distanceSplitLateLine2;
            line3Templates = _distanceSplitLateLine3;
        }

        var templateCount = line2Templates.size();
        if (templateCount <= 0) {
            return [line1, "", ""];
        }

        var templateIdx = (splitKm - 1) % templateCount;
        if (templateIdx < 0) {
            templateIdx += templateCount;
        }

        var line2 = line2Templates[templateIdx];
        var line3 = "";
        if (templateIdx < line3Templates.size()) {
            line3 = line3Templates[templateIdx];
        }
        return [line1, line2, line3];
    }

    function _applyCardVariantPreview() {
        var tickSec = Math.floor(Sys.getTimer() / 1000);
        var slot = 0;
        if (CARD_VARIANT_PREVIEW_SEC > 0) {
            slot = Math.floor(tickSec / CARD_VARIANT_PREVIEW_SEC);
        }
        var warmupCount = _warmupMessages.size();
        var totalPatterns = warmupCount + 7;
        if (totalPatterns <= 0) {
            _cardMode = CARD_MODE_ACTION;
            _cardVariant = CARD_VARIANT_ACTION_HOLD;
            _setCardLinesFromMessage(_actionHoldText);
            return;
        }

        var pattern = slot % totalPatterns;
        if (pattern < warmupCount) {
            _cardMode = CARD_MODE_ACTION;
            _cardVariant = CARD_VARIANT_WARMUP;
            _setCardLinesFromMessage(_warmupMessages[pattern]);
            return;
        }

        var fixedPattern = pattern - warmupCount;
        if (fixedPattern == 0) {
            _cardMode = CARD_MODE_ACTION;
            _cardVariant = CARD_VARIANT_ACTION_PUSH;
            _setCardLinesFromMessage(_actionPushText);
            return;
        }
        if (fixedPattern == 1) {
            _cardMode = CARD_MODE_ACTION;
            _cardVariant = CARD_VARIANT_ACTION_HOLD;
            _setCardLinesFromMessage(_actionHoldText);
            return;
        }
        if (fixedPattern == 2) {
            _cardMode = CARD_MODE_ACTION;
            _cardVariant = CARD_VARIANT_ACTION_EASE;
            _setCardLinesFromMessage(_actionEaseText);
            return;
        }
        if (fixedPattern == 3) {
            _setCardFixedLines(
                CARD_MODE_FUEL,
                CARD_VARIANT_FUEL_SOON,
                _fuelLabelText,
                _resolveFuelSoonCardLine2(),
                ""
            );
            return;
        }
        if (fixedPattern == 4) {
            _setCardFixedLines(
                CARD_MODE_FUEL_OVERDUE,
                CARD_VARIANT_FUEL_NOW,
                _fuelNowLine2Text,
                _fuelLabelText + _fuelNowLine3Text,
                ""
            );
            return;
        }
        if (fixedPattern == 5) {
            _setCardFixedLines(
                CARD_MODE_DRIFT,
                CARD_VARIANT_RECOVERY,
                _driftLine1Text,
                _driftLine2Text,
                _driftLine3Text
            );
            return;
        }
        _setCardFixedLines(
            CARD_MODE_HR_OVER,
            CARD_VARIANT_HR_WARNING,
            _hrOverLine1Text,
            _hrOverLine2Text,
            _hrOverLine3Text
        );
    }

    function _isFuelOverdue() {
        return _isFuelCardEnabled() and _fuelRemainingSec != null and _fuelRemainingSec <= 0;
    }

    function _resolveFuelSoonCardLine2() {
        if (_fuelSoonLine2Text == null) {
            return "あと少し";
        }
        var text = _fuelSoonLine2Text.toString();
        if (text.length() == 0) {
            return "あと少し";
        }
        if (text == "あと") {
            return "あと少し";
        }
        return text;
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

    function _isDriftOn(info) {
        return _driftActive;
    }

    function _isBaselineReady() {
        return _driftBaseHr != null and _driftBasePace != null;
    }

    function _updatePushState(info) {
        var elapsedSec = _extractElapsedSec(info);
        if (elapsedSec == null) {
            _resetPushState();
            return;
        }

        if (_isFuelOverdue() or _hrOverActive or _driftActive) {
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
        var ccRatio = _resolveCardiacCostRatio();
        var ccPushMaxRatio = _getCardiacCostPushMaxRatio(distanceKm);
        var cardiacCostAllowsPush = (ccRatio == null or ccRatio <= ccPushMaxRatio);
        var canTrigger = (
            paceDeltaSec >= paceTriggerThreshold and
            headroomBpm >= headroomTriggerThreshold and
            cardiacCostAllowsPush
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
            headroomBpm < headroomReleaseThreshold or
            !cardiacCostAllowsPush
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

        var baselineHrDelta = null;
        if (_driftBaseHr != null and _currentHeartRate != null) {
            baselineHrDelta = _currentHeartRate - _driftBaseHr;
        }

        var ccRatio = _resolveCardiacCostRatio();
        var easePaceDeltaThreshold = _adjustEasePaceThresholdSec(ACTION_EASE_PACE_DELTA_SEC);
        var easeHeadroomThreshold = _adjustEaseHeadroomThresholdBpm(_getActionEaseMinHeadroomBpm(distanceKm));
        var easeBaselineHrDeltaThreshold = _adjustEaseBaselineHrDeltaThresholdBpm(
            _getActionEaseBaselineHrDeltaBpm(distanceKm)
        );
        var easeCardiacCostThreshold = _getCardiacCostEaseMinRatio(distanceKm);

        var shouldEase = false;
        if (paceDeltaSec != null and paceDeltaSec <= easePaceDeltaThreshold) {
            shouldEase = true;
        }
        if (hrHeadroom != null and hrHeadroom <= easeHeadroomThreshold) {
            shouldEase = true;
        }
        if (baselineHrDelta != null and baselineHrDelta >= easeBaselineHrDeltaThreshold) {
            shouldEase = true;
        }
        if (ccRatio != null and ccRatio >= easeCardiacCostThreshold) {
            shouldEase = true;
        }
        if (shouldEase) {
            return CARD_VARIANT_ACTION_EASE;
        }

        if (_pushActive) {
            return CARD_VARIANT_ACTION_PUSH;
        }

        return CARD_VARIANT_ACTION_HOLD;
    }

    function _resolveActionMessage(actionVariant) {
        if (actionVariant == CARD_VARIANT_ACTION_EASE) {
            return _actionEaseText;
        }
        if (actionVariant == CARD_VARIANT_ACTION_PUSH) {
            return _actionPushText;
        }
        return _actionHoldText;
    }

    function _setActionCardByBaseline(elapsedSec) {
        _cardMode = CARD_MODE_ACTION;
        if (_isBaselineReady()) {
            _cardVariant = _resolveActionVariant();
            _setCardLinesFromMessage(_resolveActionMessage(_cardVariant));
            return;
        }

        _setWarmupCardMessages(elapsedSec);
    }

    function _setWarmupCardMessages(elapsedSec) {
        var slot = -1;
        if (elapsedSec != null) {
            slot = Math.floor(elapsedSec / WARMUP_MESSAGE_ROTATE_SEC);
        }

        if (
            slot == _warmupMessageSlot and
            _cardVariant == CARD_VARIANT_WARMUP and
            _cardLine1 != null and
            _cardLine2 != null and
            _cardLine3 != null
        ) {
            return;
        }
        _warmupMessageSlot = slot;

        if (_warmupMessages.size() == 0) {
            _cardVariant = CARD_VARIANT_ACTION_HOLD;
            _setCardLinesFromMessage(_actionHoldText);
            return;
        }

        var idx = CoachUtils.randomMessageIndex(_warmupMessages.size(), -1, -1);
        _cardVariant = CARD_VARIANT_WARMUP;
        _setCardLinesFromMessage(_warmupMessages[idx]);
    }

    function _setCardFixedLines(cardMode, cardVariant, line1, line2, line3) {
        _cardMode = cardMode;
        _cardVariant = cardVariant;
        _cardLine1 = "";
        _cardLine2 = "";
        _cardLine3 = "";
        if (line1 != null) {
            _cardLine1 = line1.toString();
        }
        if (line2 != null) {
            _cardLine2 = line2.toString();
        }
        if (line3 != null) {
            _cardLine3 = line3.toString();
        }
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

        var words = CoachUtils.splitWords(text);
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

    function _buildGoalDeltaText(predictedTotalSec) {
        var predictedText = "--:--";
        if (predictedTotalSec != null and predictedTotalSec >= 0) {
            predictedText = CoachUtils.formatHourMin(predictedTotalSec);
        }

        if (
            predictedTotalSec == null or
            _targetTimeSec == null or
            _targetTimeSec <= 0
        ) {
            return predictedText + "(" + _predictionWaitingText + ")";
        }

        var deltaSec = predictedTotalSec - _targetTimeSec;
        if (_abs(deltaSec) <= PREDICTION_ON_PACE_THRESHOLD_SEC) {
            return predictedText + "(" + _predictionOnPaceText + ")";
        }

        var roundedMinuteDelta = Math.floor((_abs(deltaSec) + 30.0) / 60.0);
        if (roundedMinuteDelta < 1) {
            roundedMinuteDelta = 1;
        }
        var deltaText = roundedMinuteDelta.format("%d") + _predictionBehindSuffixText;
        if (deltaSec < 0) {
            deltaText = roundedMinuteDelta.format("%d") + _predictionAheadSuffixText;
        }
        return predictedText + "(" + deltaText + ")";
    }

    function _clamp(value, minValue, maxValue) {
        return CoachUtils.clamp(value, minValue, maxValue);
    }

    function _abs(value) {
        return CoachUtils.abs(value);
    }
}
