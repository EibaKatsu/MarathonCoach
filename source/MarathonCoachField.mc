using Toybox.Application.Properties as Props;
using Toybox.Activity;
using Toybox.Attention;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.UserProfile;
using Toybox.WatchUi as Ui;

class MarathonCoachField extends Ui.DataField {
    const KEY_RACE_DISTANCE_KM = "race_distance_km";
    const KEY_TARGET_TIME_HOUR = "target_time_hour";
    const KEY_TARGET_TIME_MINUTE = "target_time_minute";
    const LAYOUT_DEBUG_OVERLAY = false;
    const FUEL_INTERVAL_SEC = 35 * 60;
    const LAP_DEBOUNCE_SEC = 20;
    const CARD_TOGGLE_SEC = 3;
    const DISTANCE_CARD_DISPLAY_SEC = 7;
    const DISTANCE_EVENT_EPSILON_KM = 0.02;
    const FUEL_TOGGLE_LEAD_SEC = 2 * 60;
    const FUEL_METER_WARNING_LEAD_SEC = 0;
    const FUEL_METER_LABEL_TOGGLE_SEC = 2;
    const FUEL_WARNING_BLINK_PERIOD_SEC = 2;
    const FUEL_WARNING_BLINK_ON_SEC = 1;
    const HALF_FUEL_DONE_FLASH_SEC = 10;
    const HALF_FUEL_POINT_1_KM = 10.0;
    const HALF_FUEL_POINT_2_KM = 15.0;
    const HALF_FUEL_POINT_COUNT = 2;
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
    const DIST_NOTIFY_RACE_FULL = 0;
    const DIST_NOTIFY_RACE_HALF = 1;
    const DIST_NOTIFY_RACE_TEN = 2;
    const DIST_NOTIFY_RACE_FIVE = 3;
    const DIST_NOTIFY_PHASE_EARLY = 0;
    const DIST_NOTIFY_PHASE_MID = 1;
    const DIST_NOTIFY_PHASE_LATE = 2;
    const CARDIAC_COST_PUSH_MAX_RATIO_FULL = 1.06;
    const CARDIAC_COST_PUSH_MAX_RATIO_HALF = 1.08;
    const CARDIAC_COST_PUSH_MAX_RATIO_SHORT = 1.10;
    const CARDIAC_COST_EASE_MIN_RATIO_FULL = 1.10;
    const CARDIAC_COST_EASE_MIN_RATIO_HALF = 1.12;
    const CARDIAC_COST_EASE_MIN_RATIO_SHORT = 1.15;
    const CARDIAC_COST_MIN_SAMPLES = 30;
    const CARD_VARIANT_PREVIEW_ENABLED = false;
    const CARD_VARIANT_PREVIEW_SEC = 3;
    const SETTINGS_LOG = true;
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
    const FUEL_METER_STATE_NORMAL = 0;
    const FUEL_METER_STATE_CAUTION = 1;
    const FUEL_METER_STATE_WARNING = 2;
    const FUEL_DISPLAY_COUNTDOWN = 0;
    const FUEL_DISPLAY_DUE = 1;
    const FUEL_DISPLAY_DONE_FLASH = 2;
    const FUEL_DISPLAY_NO_PLAN = 3;
    const FUEL_DISPLAY_DISABLED = 4;
    const DISTANCE_NOTIFY_EVENT_NONE = 0;
    const DISTANCE_NOTIFY_EVENT_SPLIT = 1;
    const DISTANCE_NOTIFY_EVENT_MILESTONE = 2;
    const BEEP_EVENT_NONE = 0;
    const BEEP_EVENT_DISTANCE_SPLIT = 1;
    const BEEP_EVENT_DISTANCE_MILESTONE = 2;
    const BEEP_EVENT_FUEL_SOON = 3;
    const BEEP_EVENT_DRIFT_ON = 4;
    const BEEP_EVENT_HR_OVER = 5;
    const BEEP_EVENT_FUEL_NOW = 6;
    const BEEP_LEVEL_INFO = 1;
    const BEEP_LEVEL_CAUTION = 2;
    const BEEP_LEVEL_URGENT = 3;
    const BEEP_HR_SUPPRESS_SEC = 75;
    const BEEP_DRIFT_SUPPRESS_SEC = 5 * 60;
    const BEEP_FUEL_NOW_REPEAT_FIRST_SEC = 30;
    const BEEP_FUEL_NOW_REPEAT_INTERVAL_SEC = 60;

    const DEFAULT_RACE_DISTANCE_KM = 42.195;
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
    var _halfFuelNextPointIndex = 0;
    var _halfFuelDoneFlashUntilSec = null;
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
        _halfFuelNextPointIndex = 0;
        _halfFuelDoneFlashUntilSec = null;
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
        if (_lastElapsedSec == null) {
            return;
        }

        if (_lastLapResetSec != null and (_lastElapsedSec - _lastLapResetSec) < LAP_DEBOUNCE_SEC) {
            return;
        }

        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            return;
        }
        if (profile == RACE_PROFILE_HALF) {
            _markHalfFuelPointIfDue();
            return;
        }

        _lastFuelTimeSec = _lastElapsedSec;
        _fuelDueTimeSec = _lastFuelTimeSec + FUEL_INTERVAL_SEC;
        _fuelRemainingSec = FUEL_INTERVAL_SEC;
        _fuelRemainingText = _formatMinSec(_fuelRemainingSec);
        _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        _lastLapResetSec = _lastElapsedSec;
    }

    function onUpdate(dc as Gfx.Dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        _drawStep3Layout(dc);
    }

    function _loadSettings() {
        _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
        _targetTimeHms = null;
        _targetTimeSec = null;
        _targetPaceSecPerKm = null;

        var raceDistance = _getPropertyValue(KEY_RACE_DISTANCE_KM);
        if (raceDistance != null) {
            var raceDistanceKm = null;
            if (raceDistance instanceof Number) {
                var raceDistanceIdx = Math.floor(raceDistance + 0.5);
                raceDistanceKm = _mapRaceDistanceIndexToKm(raceDistanceIdx);
                if (raceDistanceKm == null and raceDistance > 0) {
                    // Backward compatibility for older numeric-km saved values.
                    raceDistanceKm = raceDistance;
                }
            } else {
                raceDistanceKm = _parsePositiveDecimal(raceDistance.toString());
            }
            if (raceDistanceKm != null and raceDistanceKm > 0) {
                _raceDistanceKm = raceDistanceKm;
            }
        }

        var targetHour = _loadTargetTimeHour();
        var targetMinute = _loadTargetTimeMinute();
        if (targetHour != null and targetMinute != null) {
            var hourInt = Math.floor(targetHour + 0.5);
            var minuteInt = Math.floor(targetMinute + 0.5);
            _targetTimeHms = _formatHourMinuteSecond(hourInt, minuteInt);
            _targetTimeSec = (hourInt * 3600) + (minuteInt * 60);
        }
        if (_targetTimeSec != null and _targetTimeSec > 0 and _raceDistanceKm > 0) {
            _targetPaceSecPerKm = _targetTimeSec / _raceDistanceKm;
        }
        _logSettingsState(targetHour, targetMinute);
    }

    function _loadTargetTimeHour() {
        var hour = _loadIntSettingValue(KEY_TARGET_TIME_HOUR);
        if (hour == null or hour < 0 or hour > 8) {
            return null;
        }
        return hour;
    }

    function _loadTargetTimeMinute() {
        var minute = _loadIntSettingValue(KEY_TARGET_TIME_MINUTE);
        if (minute == null or minute < 0 or minute > 59) {
            return null;
        }
        return minute;
    }

    function _loadIntSettingValue(key) {
        var value = _getPropertyValue(key);
        if (value == null) {
            return null;
        }

        if (value instanceof Number) {
            return Math.floor(value + 0.5);
        }

        var parsed = _parsePositiveInt(value.toString());
        if (parsed == null) {
            var parsedDecimal = _parsePositiveDecimal(value.toString());
            if (parsedDecimal == null) {
                return null;
            }
            return Math.floor(parsedDecimal + 0.5);
        }
        return parsed;
    }

    function _getPropertyValue(key) {
        try {
            return Props.getValue(key);
        } catch (e) {
            return null;
        }
    }

    function _formatHourMinuteSecond(hourPart, minutePart) {
        return hourPart.format("%02d") + ":" + minutePart.format("%02d") + ":00";
    }

    function _mapRaceDistanceIndexToKm(index) {
        if (index == 0) {
            return 42.195;
        }
        if (index == 1) {
            return 21.0975;
        }
        if (index == 2) {
            return 10.0;
        }
        if (index == 3) {
            return 5.0;
        }
        return null;
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
        _drawCoachCardWithPng(dc, sizeClass, cardX, cardY, cardW, cardH, cardCorner);

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
        // Outline + dual white pass gives readable text on bright/saturated cards.
        dc.setColor(0x131A25, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x - 1, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(x + 1, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, y - 1, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, y + 1, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(x + 1, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function _getCardBgBitmapSmall(cardVariant) {
        if (cardVariant == CARD_VARIANT_WARMUP) {
            return _cardBgWarmupSmall;
        }
        if (cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return _cardBgActionPushSmall;
        }
        if (cardVariant == CARD_VARIANT_ACTION_HOLD) {
            return _cardBgActionHoldSmall;
        }
        if (cardVariant == CARD_VARIANT_ACTION_EASE) {
            return _cardBgActionPushSmall;
        }
        if (cardVariant == CARD_VARIANT_FUEL_SOON) {
            return _cardBgFuelSoonSmall;
        }
        if (cardVariant == CARD_VARIANT_FUEL_NOW) {
            return _cardBgFuelNowSmall;
        }
        if (cardVariant == CARD_VARIANT_RECOVERY) {
            return _cardBgFuelSoonSmall;
        }
        if (cardVariant == CARD_VARIANT_HR_WARNING) {
            return _cardBgHrWarningSmall;
        }
        return _cardBgActionHoldSmall;
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
        if (cardVariant == CARD_VARIANT_WARMUP) {
            return 0x56728F;
        }
        if (cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return 0x4C7898;
        }
        if (cardVariant == CARD_VARIANT_ACTION_EASE) {
            return 0x7F694F;
        }
        if (cardVariant == CARD_VARIANT_FUEL_SOON) {
            return 0x926E49;
        }
        if (cardVariant == CARD_VARIANT_FUEL_NOW) {
            return 0xA14B58;
        }
        if (cardVariant == CARD_VARIANT_RECOVERY) {
            return 0x4F7480;
        }
        if (cardVariant == CARD_VARIANT_HR_WARNING) {
            return 0x97554A;
        }
        return 0x516684;
    }

    function _getCardGradientTopColor(cardVariant) {
        if (cardVariant == CARD_VARIANT_WARMUP) {
            return 0x315B7D;
        }
        if (cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return 0x275778;
        }
        if (cardVariant == CARD_VARIANT_ACTION_EASE) {
            return 0x5E4B36;
        }
        if (cardVariant == CARD_VARIANT_FUEL_SOON) {
            return 0x70543A;
        }
        if (cardVariant == CARD_VARIANT_FUEL_NOW) {
            return 0x883744;
        }
        if (cardVariant == CARD_VARIANT_RECOVERY) {
            return 0x2D5A66;
        }
        if (cardVariant == CARD_VARIANT_HR_WARNING) {
            return 0x7B342F;
        }
        return 0x274A6A;
    }

    function _getCardGradientBottomColor(cardVariant) {
        if (cardVariant == CARD_VARIANT_WARMUP) {
            return 0x182F47;
        }
        if (cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return 0x16324B;
        }
        if (cardVariant == CARD_VARIANT_ACTION_EASE) {
            return 0x2E2418;
        }
        if (cardVariant == CARD_VARIANT_FUEL_SOON) {
            return 0x3D2D20;
        }
        if (cardVariant == CARD_VARIANT_FUEL_NOW) {
            return 0x461925;
        }
        if (cardVariant == CARD_VARIANT_RECOVERY) {
            return 0x183640;
        }
        if (cardVariant == CARD_VARIANT_HR_WARNING) {
            return 0x401B18;
        }
        return 0x182E45;
    }

    function _getCardGradientMidColor(cardVariant) {
        if (cardVariant == CARD_VARIANT_WARMUP) {
            return 0x244767;
        }
        if (cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return 0x204765;
        }
        if (cardVariant == CARD_VARIANT_ACTION_EASE) {
            return 0x463726;
        }
        if (cardVariant == CARD_VARIANT_FUEL_SOON) {
            return 0x594230;
        }
        if (cardVariant == CARD_VARIANT_FUEL_NOW) {
            return 0x6A2835;
        }
        if (cardVariant == CARD_VARIANT_RECOVERY) {
            return 0x234A56;
        }
        if (cardVariant == CARD_VARIANT_HR_WARNING) {
            return 0x5C2722;
        }
        return 0x22415F;
    }

    function _getCardSheenColor(cardVariant) {
        if (cardVariant == CARD_VARIANT_WARMUP) {
            return 0x7FA8D0;
        }
        if (cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return 0x7CAED6;
        }
        if (cardVariant == CARD_VARIANT_ACTION_EASE) {
            return 0xB08A61;
        }
        if (cardVariant == CARD_VARIANT_FUEL_SOON) {
            return 0xC39A70;
        }
        if (cardVariant == CARD_VARIANT_FUEL_NOW) {
            return 0xD97983;
        }
        if (cardVariant == CARD_VARIANT_RECOVERY) {
            return 0x79AAB9;
        }
        if (cardVariant == CARD_VARIANT_HR_WARNING) {
            return 0xCE8476;
        }
        return 0x779DC1;
    }

    function _getCardAccentColor(cardVariant) {
        if (cardVariant == CARD_VARIANT_WARMUP) {
            return 0x9ED7FF;
        }
        if (cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return 0x9CD8FF;
        }
        if (cardVariant == CARD_VARIANT_ACTION_EASE) {
            return 0xF1CC95;
        }
        if (cardVariant == CARD_VARIANT_FUEL_SOON) {
            return 0xFFD29A;
        }
        if (cardVariant == CARD_VARIANT_FUEL_NOW) {
            return 0xFFC2B0;
        }
        if (cardVariant == CARD_VARIANT_RECOVERY) {
            return 0x9DE5EE;
        }
        if (cardVariant == CARD_VARIANT_HR_WARNING) {
            return 0xFFB99B;
        }
        return 0xA9D0F8;
    }

    function _getCardTopBandColor(cardVariant) {
        if (cardVariant == CARD_VARIANT_WARMUP) {
            return 0x6EAED8;
        }
        if (cardVariant == CARD_VARIANT_ACTION_PUSH) {
            return 0x6ABCE3;
        }
        if (cardVariant == CARD_VARIANT_ACTION_EASE) {
            return 0xC39A6E;
        }
        if (cardVariant == CARD_VARIANT_FUEL_SOON) {
            return 0xD7AA76;
        }
        if (cardVariant == CARD_VARIANT_FUEL_NOW) {
            return 0xD96E7E;
        }
        if (cardVariant == CARD_VARIANT_RECOVERY) {
            return 0x63B9C8;
        }
        if (cardVariant == CARD_VARIANT_HR_WARNING) {
            return 0xD97B6A;
        }
        return 0x6AA3CF;
    }

    function _getCardTextColor(cardVariant) {
        return Gfx.COLOR_WHITE;
    }

    function _resolveCardFont(sizeClass, cardLineCount) {
        if (sizeClass == 0) {
            if (cardLineCount <= 1) {
                return Gfx.FONT_SMALL;
            }
            if (cardLineCount == 2) {
                return Gfx.FONT_TINY;
            }
            return Gfx.FONT_XTINY;
        }

        if (sizeClass == 2) {
            if (cardLineCount <= 1) {
                // Large layout card width is still narrow; medium often overflows with CJK text.
                return Gfx.FONT_SMALL;
            }
            if (cardLineCount == 2) {
                return Gfx.FONT_SMALL;
            }
            return Gfx.FONT_TINY;
        }

        if (cardLineCount <= 1) {
            return Gfx.FONT_SMALL;
        }
        if (cardLineCount == 2) {
            return Gfx.FONT_SMALL;
        }
        return Gfx.FONT_TINY;
    }

    function _adjustCardFontForSingleLineLimit(font, cardLineCount, cardLines as Lang.Array) {
        if (cardLineCount != 1 or cardLines.size() <= 0 or cardLines[0] == null) {
            return font;
        }

        var line = cardLines[0].toString();
        if (line.length() <= 0) {
            return font;
        }

        var limit = 7;
        if (_containsNonAscii(line)) {
            limit = 4;
        }

        if (line.length() >= limit) {
            return _shrinkCardFont(font);
        }
        return font;
    }

    function _shrinkCardFont(font) {
        if (font == Gfx.FONT_MEDIUM) {
            return Gfx.FONT_SMALL;
        }
        if (font == Gfx.FONT_SMALL) {
            return Gfx.FONT_TINY;
        }
        if (font == Gfx.FONT_TINY) {
            return Gfx.FONT_XTINY;
        }
        return Gfx.FONT_XTINY;
    }

    function _containsNonAscii(text) as Lang.Boolean {
        if (text == null) {
            return false;
        }

        var chars = text.toString().toCharArray();
        if (!(chars instanceof Lang.Array)) {
            return false;
        }
        for (var i = 0; i < chars.size(); i += 1) {
            var ch = chars[i];
            if (ch != null and ch instanceof Lang.Char and ch.toNumber() > 127) {
                return true;
            }
        }
        return false;
    }

    function _resolveCardLineGap(cardLineCount, fontH, areaH) {
        if (cardLineCount <= 1) {
            return 0;
        }

        var desiredGap = 1;
        if (cardLineCount == 2) {
            desiredGap = _clamp(fontH / 3, 2, 8);
        } else {
            desiredGap = _clamp(fontH / 5, 1, 5);
        }

        var maxGap = _max((areaH - (fontH * cardLineCount)) / (cardLineCount - 1), 1);
        if (desiredGap > maxGap) {
            desiredGap = maxGap;
        }
        return desiredGap;
    }

    function _resolveCardFontToFit(dc as Gfx.Dc, sizeClass, cardLines as Lang.Array, textAreaW, textAreaH) {
        var candidates = [];
        if (sizeClass == 2) {
            candidates = [Gfx.FONT_MEDIUM, Gfx.FONT_SMALL, Gfx.FONT_TINY, Gfx.FONT_XTINY];
        } else if (sizeClass == 0) {
            candidates = [Gfx.FONT_SMALL, Gfx.FONT_TINY, Gfx.FONT_XTINY];
        } else {
            candidates = [Gfx.FONT_SMALL, Gfx.FONT_TINY, Gfx.FONT_XTINY];
        }

        for (var i = 0; i < candidates.size(); i += 1) {
            var font = candidates[i];
            if (_isCardTextFit(dc, font, cardLines, textAreaW, textAreaH)) {
                return font;
            }
        }

        return candidates[candidates.size() - 1];
    }

    function _isCardTextFit(dc as Gfx.Dc, font, cardLines as Lang.Array, textAreaW, textAreaH) as Lang.Boolean {
        if (textAreaW <= 0 or textAreaH <= 0) {
            return false;
        }

        var lineCount = cardLines.size();
        var fontH = dc.getFontHeight(font);
        var minTotalH = fontH * lineCount;
        if (lineCount > 1) {
            minTotalH += (lineCount - 1);
        }
        if (minTotalH > textAreaH) {
            return false;
        }

        for (var i = 0; i < lineCount; i += 1) {
            var line = "";
            if (cardLines[i] != null) {
                line = cardLines[i].toString();
            }
            var lineW = dc.getTextWidthInPixels(line, font);
            // Keep headroom for bold stroke around text.
            if ((lineW + 2) > textAreaW) {
                return false;
            }
        }

        return true;
    }

    function _fillRoundedGradient(dc as Gfx.Dc, x, y, width, height, corner, topColor, midColor, bottomColor) {
        dc.setColor(bottomColor, Gfx.COLOR_BLACK);
        dc.fillRoundedRectangle(x, y, width, height, corner);

        var innerX = x + 1;
        var innerY = y + 1;
        var innerW = width - 2;
        var innerH = height - 2;
        if (innerW < 2 or innerH < 2) {
            return;
        }

        var topH = _clamp((innerH * 38) / 100, 2, innerH - 1);
        var midY = innerY + topH;
        var midH = _clamp((innerH * 34) / 100, 2, innerH - topH);
        var maxMidH = innerH - topH;
        if (midH > maxMidH) {
            midH = maxMidH;
        }
        if (midH < 1) {
            midH = 1;
        }

        dc.setColor(topColor, Gfx.COLOR_BLACK);
        dc.fillRectangle(innerX, innerY, innerW, topH);
        dc.setColor(midColor, Gfx.COLOR_BLACK);
        dc.fillRectangle(innerX, midY, innerW, midH);
    }

    function _drawFuelMeter(dc as Gfx.Dc, sizeClass, centerX, centerY, radius, labelFont, valueFont) {
        var meterState = _resolveFuelMeterState();
        var fuelDisplayMode = _fuelDisplayMode;
        var showCenterText = true;
        if (fuelDisplayMode == FUEL_DISPLAY_DISABLED) {
            showCenterText = false;
        } else if (meterState == FUEL_METER_STATE_WARNING) {
            showCenterText = _isFuelWarningBlinkVisible();
        }

        var ringTrackColor = _getFuelMeterTrackColor(meterState);
        var ringFillColor = _getFuelMeterFillColor(meterState);
        var ringProgress = _resolveFuelMeterProgressRatio(meterState);
        var centerText = _resolveFuelMeterCenterText(meterState);
        var warningSubText = _resolveFuelMeterWarningSubText(meterState);
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
        var labelY = _textYByRatio(
            centerY - radius,
            radius * 2,
            31,
            dc.getFontHeight(labelFont)
        );
        var centerTextRatio = 60;
        if (!showTopLabel) {
            centerTextRatio = 50;
        }
        var centerTextY = _textYByRatio(
            centerY - radius,
            radius * 2,
            centerTextRatio,
            dc.getFontHeight(centerTextFont)
        );
        var warningSubTextY = centerTextY;
        if (warningSubText != null) {
            centerTextY = _textYByRatio(
                centerY - radius,
                radius * 2,
                42,
                dc.getFontHeight(centerTextFont)
            );
            warningSubTextY = _textYByRatio(
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

    function _resolveFuelMeterState() {
        if (_fuelDisplayMode == FUEL_DISPLAY_DUE) {
            return FUEL_METER_STATE_WARNING;
        }
        if (_fuelDisplayMode != FUEL_DISPLAY_COUNTDOWN) {
            return FUEL_METER_STATE_NORMAL;
        }
        if (_fuelRemainingSec != null and _fuelRemainingSec <= FUEL_TOGGLE_LEAD_SEC) {
            return FUEL_METER_STATE_CAUTION;
        }
        return FUEL_METER_STATE_NORMAL;
    }

    function _getFuelMeterTrackColor(meterState) {
        if (meterState == FUEL_METER_STATE_WARNING) {
            return FUEL_RING_WARNING_TRACK_COLOR;
        }
        if (meterState == FUEL_METER_STATE_CAUTION) {
            return FUEL_RING_CAUTION_TRACK_COLOR;
        }
        return FUEL_RING_NORMAL_TRACK_COLOR;
    }

    function _getFuelMeterFillColor(meterState) {
        if (meterState == FUEL_METER_STATE_WARNING) {
            return FUEL_RING_WARNING_FILL_COLOR;
        }
        if (meterState == FUEL_METER_STATE_CAUTION) {
            return FUEL_RING_CAUTION_FILL_COLOR;
        }
        return FUEL_RING_NORMAL_FILL_COLOR;
    }

    function _resolveFuelMeterProgressRatio(meterState) {
        if (_fuelDisplayMode == FUEL_DISPLAY_DISABLED) {
            return 0.0;
        }
        if (_fuelDisplayMode == FUEL_DISPLAY_DUE) {
            return 1.0;
        }
        if (_fuelDisplayMode != FUEL_DISPLAY_COUNTDOWN) {
            return 0.0;
        }
        if (meterState == FUEL_METER_STATE_WARNING) {
            return 1.0;
        }
        if (_fuelRemainingSec == null) {
            return 0.0;
        }

        var remainingSec = _clamp(_fuelRemainingSec, 0, FUEL_INTERVAL_SEC);
        return _clamp((remainingSec * 1.0) / (FUEL_INTERVAL_SEC * 1.0), 0.0, 1.0);
    }

    function _resolveFuelMeterCenterText(meterState) {
        if (_fuelDisplayMode == FUEL_DISPLAY_DISABLED) {
            return null;
        }
        if (_fuelDisplayMode == FUEL_DISPLAY_DONE_FLASH) {
            return _fuelMeterDoneText;
        }
        if (_fuelDisplayMode == FUEL_DISPLAY_NO_PLAN) {
            return _fuelMeterNoPlanText;
        }
        if (meterState == FUEL_METER_STATE_WARNING) {
            return _fuelMeterWarningText;
        }

        var remainingMin = _resolveFuelMeterRemainingMin();
        if (remainingMin != null) {
            return remainingMin.format("%d") + _fuelMeterMinuteSuffixText;
        }
        return "--";
    }

    function _resolveFuelMeterWarningSubText(meterState) {
        if (_fuelDisplayMode == FUEL_DISPLAY_DUE and meterState == FUEL_METER_STATE_WARNING) {
            return _fuelMeterWarningSubText;
        }
        return null;
    }

    function _resolveFuelMeterRemainingMin() {
        if (_fuelRemainingSec == null) {
            return null;
        }

        var remainingSec = _fuelRemainingSec;
        if (remainingSec < 0) {
            remainingSec = 0;
        }
        if (remainingSec == 0) {
            return 0;
        }
        return Math.floor((remainingSec + 59) / 60);
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
        var markerHeight = _max(height, 1);
        var markerHalfWidth = _max(halfWidth, 1);
        for (var row = 0; row < markerHeight; row += 1) {
            var span = Math.floor((markerHalfWidth * (row + 1)) / markerHeight);
            if (span < 1) {
                span = 1;
            }
            dc.drawLine(centerX - span, tipY + row, centerX + span, tipY + row);
        }
    }

    function _getHeartRateZoneGaugeColor(zoneNumber) {
        if (zoneNumber <= 1) {
            return HR_ZONE_COLOR_1;
        }
        if (zoneNumber == 2) {
            return HR_ZONE_COLOR_2;
        }
        if (zoneNumber == 3) {
            return HR_ZONE_COLOR_3;
        }
        if (zoneNumber == 4) {
            return HR_ZONE_COLOR_4;
        }
        return HR_ZONE_COLOR_5;
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
        if (heartRate == null) {
            return 0.5;
        }
        var minHr = 80;
        var maxHr = 200;
        if (maxHr <= minHr) {
            return 0.5;
        }
        return _clamp(((heartRate - minHr) * 1.0) / ((maxHr - minHr) * 1.0), 0.0, 1.0);
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

        var allowed = zoneUpper + _getAllowedZoneOffsetBpm(distanceKm);
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
        if (_lastFactLogLine == line) {
            return;
        }
        _lastFactLogLine = line;
        Sys.println(line);
    }

    function _logSettingsState(targetHour, targetMinute) {
        if (!SETTINGS_LOG) {
            return;
        }
        var rawRace = _getPropertyValue(KEY_RACE_DISTANCE_KM);
        var rawHour = _getPropertyValue(KEY_TARGET_TIME_HOUR);
        var rawMinute = _getPropertyValue(KEY_TARGET_TIME_MINUTE);
        var line =
            "[SETTINGS] raceRaw=" + _factValue(rawRace) +
            " hourRaw=" + _factValue(rawHour) +
            " minuteRaw=" + _factValue(rawMinute) +
            " hourNorm=" + _factValue(targetHour) +
            " minuteNorm=" + _factValue(targetMinute) +
            " raceKm=" + _factValue(_raceDistanceKm) +
            " hms=" + _factValue(_targetTimeHms) +
            " sec=" + _factValue(_targetTimeSec) +
            " paceSecPerKm=" + _factValue(_targetPaceSecPerKm);
        if (_lastSettingsLogLine == line) {
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

    function _resolveRaceProfile() {
        if (_raceDistanceKm != null and _raceDistanceKm <= SHORT_DISTANCE_MAX_KM) {
            return RACE_PROFILE_SHORT;
        }
        if (
            _raceDistanceKm != null and
            _abs(_raceDistanceKm - HALF_DISTANCE_KM) <= HALF_DISTANCE_TOLERANCE_KM
        ) {
            return RACE_PROFILE_HALF;
        }
        return RACE_PROFILE_FULL;
    }

    function _resolveRaceProgress(distanceKm) {
        if (distanceKm == null or _raceDistanceKm == null or _raceDistanceKm <= 0) {
            return null;
        }
        var progress = distanceKm / _raceDistanceKm;
        if (progress < 0) {
            progress = 0;
        }
        if (progress > 1.0) {
            progress = 1.0;
        }
        return progress;
    }

    function _resolveRacePhase(distanceKm) {
        var progress = _resolveRaceProgress(distanceKm);
        if (progress == null) {
            return RACE_PHASE_1;
        }
        if (progress < RACE_PHASE_1_END_PROGRESS) {
            return RACE_PHASE_1;
        }
        if (progress < RACE_PHASE_2_END_PROGRESS) {
            return RACE_PHASE_2;
        }
        if (progress < RACE_PHASE_3_END_PROGRESS) {
            return RACE_PHASE_3;
        }
        if (progress < RACE_PHASE_4_END_PROGRESS) {
            return RACE_PHASE_4;
        }
        return RACE_PHASE_5;
    }

    function _getAllowedZoneNumber(distanceKm) {
        var phase = _resolveRacePhase(distanceKm);
        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            if (phase == RACE_PHASE_1) {
                return 4;
            }
            if (phase == RACE_PHASE_2 or phase == RACE_PHASE_3) {
                return 5;
            }
            return 5;
        }
        if (profile == RACE_PROFILE_HALF) {
            if (phase == RACE_PHASE_1) {
                return 3;
            }
            return 4;
        }

        if (phase == RACE_PHASE_1) {
            return 2;
        }
        if (phase == RACE_PHASE_2 or phase == RACE_PHASE_3) {
            return 3;
        }
        return 4;
    }

    function _getAllowedZoneOffsetBpm(distanceKm) {
        var phase = _resolveRacePhase(distanceKm);
        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            if (phase == RACE_PHASE_1) {
                return 0;
            }
            if (phase == RACE_PHASE_2) {
                return 2;
            }
            if (phase == RACE_PHASE_3) {
                return 3;
            }
            if (phase == RACE_PHASE_4) {
                return 4;
            }
            return 5;
        }
        if (profile == RACE_PROFILE_HALF) {
            if (phase == RACE_PHASE_2) {
                return -2;
            }
            if (phase == RACE_PHASE_4) {
                return 2;
            }
            if (phase == RACE_PHASE_5) {
                return 4;
            }
            return 0;
        }

        if (phase == RACE_PHASE_3) {
            return 2;
        }
        if (phase == RACE_PHASE_5) {
            return 3;
        }
        return 0;
    }

    function _getHrOverTriggerSec(distanceKm) {
        var phase = _resolveRacePhase(distanceKm);
        if (phase == RACE_PHASE_4) {
            return 10;
        }
        if (phase == RACE_PHASE_5) {
            return 20;
        }
        return 12;
    }

    function _getHrOverReleaseSec(distanceKm) {
        return 5;
    }

    function _getHrOverReleaseOffsetBpm(distanceKm) {
        if (_resolveRacePhase(distanceKm) == RACE_PHASE_4) {
            return 1;
        }
        return 2;
    }

    function _getPushPaceDeltaThresholdSec(distanceKm) {
        var phase = _resolveRacePhase(distanceKm);
        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            if (phase == RACE_PHASE_1) {
                return 8;
            }
            if (phase == RACE_PHASE_2) {
                return 5;
            }
            if (phase == RACE_PHASE_3) {
                return 3;
            }
            if (phase == RACE_PHASE_4) {
                return 2;
            }
            return 1;
        }
        if (profile == RACE_PROFILE_HALF) {
            if (phase == RACE_PHASE_1) {
                return 10;
            }
            if (phase == RACE_PHASE_2) {
                return 6;
            }
            if (phase == RACE_PHASE_3) {
                return 4;
            }
            if (phase == RACE_PHASE_4) {
                return 3;
            }
            return 2;
        }

        if (phase == RACE_PHASE_1) {
            return 12;
        }
        if (phase == RACE_PHASE_2) {
            return 8;
        }
        if (phase == RACE_PHASE_3) {
            return 6;
        }
        if (phase == RACE_PHASE_4) {
            return 4;
        }
        return 3;
    }

    function _getPushHeadroomThresholdBpm(distanceKm) {
        var phase = _resolveRacePhase(distanceKm);
        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            if (phase == RACE_PHASE_1) {
                return 6;
            }
            if (phase == RACE_PHASE_2) {
                return 4;
            }
            if (phase == RACE_PHASE_3) {
                return 2;
            }
            if (phase == RACE_PHASE_4) {
                return 1;
            }
            return 0;
        }
        if (profile == RACE_PROFILE_HALF) {
            if (phase == RACE_PHASE_1) {
                return 7;
            }
            if (phase == RACE_PHASE_2) {
                return 5;
            }
            if (phase == RACE_PHASE_3) {
                return 3;
            }
            if (phase == RACE_PHASE_4) {
                return 2;
            }
            return 1;
        }

        if (phase == RACE_PHASE_1) {
            return 8;
        }
        if (phase == RACE_PHASE_2) {
            return 6;
        }
        if (phase == RACE_PHASE_3) {
            return 4;
        }
        if (phase == RACE_PHASE_4) {
            return 3;
        }
        return 2;
    }

    function _getActionEaseMinHeadroomBpm(distanceKm) {
        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            return 1;
        }
        if (profile == RACE_PROFILE_HALF) {
            return 2;
        }
        return ACTION_EASE_MIN_HEADROOM_BPM;
    }

    function _getActionEaseBaselineHrDeltaBpm(distanceKm) {
        var phase = _resolveRacePhase(distanceKm);
        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            if (phase == RACE_PHASE_1) {
                return 8;
            }
            if (phase == RACE_PHASE_2) {
                return 9;
            }
            if (phase == RACE_PHASE_3) {
                return 10;
            }
            if (phase == RACE_PHASE_4) {
                return 11;
            }
            return 12;
        }
        if (profile == RACE_PROFILE_HALF) {
            if (phase == RACE_PHASE_1) {
                return 6;
            }
            if (phase == RACE_PHASE_2) {
                return 7;
            }
            if (phase == RACE_PHASE_3) {
                return 8;
            }
            if (phase == RACE_PHASE_4) {
                return 9;
            }
            return 10;
        }

        if (phase == RACE_PHASE_1) {
            return 5;
        }
        if (phase == RACE_PHASE_4) {
            return 5;
        }
        if (phase == RACE_PHASE_5) {
            return 4;
        }
        return ACTION_EASE_BASELINE_HR_DELTA_BPM;
    }

    function _getCardiacCostPushMaxRatio(distanceKm) {
        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            return CARDIAC_COST_PUSH_MAX_RATIO_SHORT;
        }
        if (profile == RACE_PROFILE_HALF) {
            return CARDIAC_COST_PUSH_MAX_RATIO_HALF;
        }
        return CARDIAC_COST_PUSH_MAX_RATIO_FULL;
    }

    function _getCardiacCostEaseMinRatio(distanceKm) {
        var profile = _resolveRaceProfile();
        if (profile == RACE_PROFILE_SHORT) {
            return CARDIAC_COST_EASE_MIN_RATIO_SHORT;
        }
        if (profile == RACE_PROFILE_HALF) {
            return CARDIAC_COST_EASE_MIN_RATIO_HALF;
        }
        return CARDIAC_COST_EASE_MIN_RATIO_FULL;
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
        var raceProfile = _resolveRaceProfile();

        if (raceProfile == RACE_PROFILE_SHORT) {
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            _fuelDisplayMode = FUEL_DISPLAY_DISABLED;
            return;
        }

        if (raceProfile == RACE_PROFILE_HALF) {
            _updateHalfFuelTimer(elapsedSec, _extractElapsedDistanceKm(info));
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
        _fuelDueTimeSec = _lastFuelTimeSec + FUEL_INTERVAL_SEC;
        _fuelRemainingSec = _fuelDueTimeSec - elapsedSec;
        if (_fuelRemainingSec < 0) {
            _fuelRemainingSec = 0;
        }
        _fuelRemainingText = _formatMinSec(_fuelRemainingSec);
        if (_fuelRemainingSec <= 0) {
            _fuelDisplayMode = FUEL_DISPLAY_DUE;
        } else {
            _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
        }
    }

    function _updateHalfFuelTimer(elapsedSec, distanceKm) {
        if (_halfFuelNextPointIndex >= HALF_FUEL_POINT_COUNT) {
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            if (
                _halfFuelDoneFlashUntilSec != null and
                elapsedSec != null and
                elapsedSec < _halfFuelDoneFlashUntilSec
            ) {
                _fuelDisplayMode = FUEL_DISPLAY_DONE_FLASH;
            } else {
                _fuelDisplayMode = FUEL_DISPLAY_NO_PLAN;
            }
            return;
        }

        if (elapsedSec == null) {
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
            return;
        }

        var nextFuelKm = _getHalfFuelPointKm(_halfFuelNextPointIndex);
        if (nextFuelKm == null) {
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            _fuelDisplayMode = FUEL_DISPLAY_NO_PLAN;
            return;
        }

        if (distanceKm != null and distanceKm >= nextFuelKm) {
            _fuelDueTimeSec = elapsedSec;
            _fuelRemainingSec = 0;
            _fuelRemainingText = _formatMinSec(0);
            _fuelDisplayMode = FUEL_DISPLAY_DUE;
            return;
        }

        var etaSec = _estimateFuelEtaSec(distanceKm, nextFuelKm);
        _fuelDueTimeSec = null;
        if (etaSec != null) {
            _fuelRemainingSec = etaSec;
            _fuelRemainingText = _formatMinSec(_fuelRemainingSec);
        } else {
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
        }
        _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
    }

    function _getHalfFuelPointKm(index) {
        if (index == 0) {
            return HALF_FUEL_POINT_1_KM;
        }
        if (index == 1) {
            return HALF_FUEL_POINT_2_KM;
        }
        return null;
    }

    function _estimateFuelEtaSec(distanceKm, nextFuelKm) {
        if (distanceKm == null or nextFuelKm == null) {
            return null;
        }
        var remainingKm = nextFuelKm - distanceKm;
        if (remainingKm <= 0) {
            return 0;
        }

        var paceSecPerKm = _paceNowSecPerKm;
        if (paceSecPerKm == null or paceSecPerKm <= 0) {
            paceSecPerKm = _targetPaceSecPerKm;
        }
        if (paceSecPerKm == null or paceSecPerKm <= 0) {
            return null;
        }

        var etaSec = Math.floor((remainingKm * paceSecPerKm) + 0.5);
        if (etaSec < 0) {
            etaSec = 0;
        }
        return etaSec;
    }

    function _markHalfFuelPointIfDue() {
        if (_halfFuelNextPointIndex >= HALF_FUEL_POINT_COUNT) {
            return;
        }

        var distanceKm = _extractElapsedDistanceKm(_fallbackActivityInfo);
        var nextFuelKm = _getHalfFuelPointKm(_halfFuelNextPointIndex);
        if (distanceKm == null or nextFuelKm == null or distanceKm < nextFuelKm) {
            return;
        }

        _halfFuelNextPointIndex += 1;
        _lastLapResetSec = _lastElapsedSec;
        if (_halfFuelNextPointIndex >= HALF_FUEL_POINT_COUNT) {
            _fuelDisplayMode = FUEL_DISPLAY_DONE_FLASH;
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
            if (_lastElapsedSec != null) {
                _halfFuelDoneFlashUntilSec = _lastElapsedSec + HALF_FUEL_DONE_FLASH_SEC;
            } else {
                _halfFuelDoneFlashUntilSec = null;
            }
        } else {
            _fuelDisplayMode = FUEL_DISPLAY_COUNTDOWN;
            _fuelDueTimeSec = null;
            _fuelRemainingSec = null;
            _fuelRemainingText = "--:--";
        }
    }

    function _isFuelCardEnabled() {
        var raceProfile = _resolveRaceProfile();
        if (raceProfile == RACE_PROFILE_SHORT) {
            return false;
        }
        if (raceProfile == RACE_PROFILE_HALF and _halfFuelNextPointIndex >= HALF_FUEL_POINT_COUNT) {
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

        // Toggle starts in the final 2 minutes before fuel due.
        var inFuelToggleWindow = (
            _isFuelCardEnabled() and
            _fuelRemainingSec != null and
            _fuelRemainingSec > 0 and
            _fuelRemainingSec <= FUEL_TOGGLE_LEAD_SEC
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

        var checkpointCount = _getDistanceCheckpointCount(_distanceNotifyRaceType);
        while (_distanceNotifyNextCheckpointIdx < checkpointCount) {
            var checkpointKm = _getDistanceCheckpointKm(_distanceNotifyRaceType, _distanceNotifyNextCheckpointIdx);
            if (checkpointKm == null or !_hasReachedDistanceTarget(distanceKm, checkpointKm)) {
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
            var maxSplitKm = _getDistanceMaxSplitKm(_distanceNotifyRaceType);
            while (
                _distanceNotifyNextSplitKm <= maxSplitKm and
                _hasReachedDistanceTarget(distanceKm, _distanceNotifyNextSplitKm)
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

        var fuelMeterState = _resolveFuelMeterState();
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

        var beepEvent = BEEP_EVENT_NONE;

        if (fuelOverdue) {
            if (!_beepFuelNowActive) {
                beepEvent = _selectHigherPriorityBeepEvent(beepEvent, BEEP_EVENT_FUEL_NOW);
                _beepFuelNowActive = true;
                _beepFuelNowNextRepeatSec = elapsedSec + BEEP_FUEL_NOW_REPEAT_FIRST_SEC;
            } else if (_beepFuelNowNextRepeatSec != null and elapsedSec >= _beepFuelNowNextRepeatSec) {
                beepEvent = _selectHigherPriorityBeepEvent(beepEvent, BEEP_EVENT_FUEL_NOW);
                _beepFuelNowNextRepeatSec = elapsedSec + BEEP_FUEL_NOW_REPEAT_INTERVAL_SEC;
            }
        } else {
            _beepFuelNowActive = false;
            _beepFuelNowNextRepeatSec = null;
        }

        if (!fuelOverdue) {
            if (hrOver and !_beepPrevHrOver) {
                if (_beepLastHrAlertSec == null or (elapsedSec - _beepLastHrAlertSec) >= BEEP_HR_SUPPRESS_SEC) {
                    beepEvent = _selectHigherPriorityBeepEvent(beepEvent, BEEP_EVENT_HR_OVER);
                    _beepLastHrAlertSec = elapsedSec;
                }
            }

            if (driftOn and !_beepPrevDriftOn) {
                if (
                    _beepLastDriftAlertSec == null or
                    (elapsedSec - _beepLastDriftAlertSec) >= BEEP_DRIFT_SUPPRESS_SEC
                ) {
                    beepEvent = _selectHigherPriorityBeepEvent(beepEvent, BEEP_EVENT_DRIFT_ON);
                    _beepLastDriftAlertSec = elapsedSec;
                }
            }

            if (
                fuelMeterState == FUEL_METER_STATE_CAUTION and
                _beepPrevFuelMeterState != FUEL_METER_STATE_CAUTION
            ) {
                beepEvent = _selectHigherPriorityBeepEvent(beepEvent, BEEP_EVENT_FUEL_SOON);
            }

            if (distanceNotifyEvent == DISTANCE_NOTIFY_EVENT_MILESTONE) {
                beepEvent = _selectHigherPriorityBeepEvent(beepEvent, BEEP_EVENT_DISTANCE_MILESTONE);
            } else if (distanceNotifyEvent == DISTANCE_NOTIFY_EVENT_SPLIT) {
                beepEvent = _selectHigherPriorityBeepEvent(beepEvent, BEEP_EVENT_DISTANCE_SPLIT);
            }
        }

        _playBeepEvent(beepEvent);
        _beepPrevFuelMeterState = fuelMeterState;
        _beepPrevHrOver = hrOver;
        _beepPrevDriftOn = driftOn;
    }

    function _selectHigherPriorityBeepEvent(currentEvent, candidateEvent) {
        if (_resolveBeepEventPriority(candidateEvent) > _resolveBeepEventPriority(currentEvent)) {
            return candidateEvent;
        }
        return currentEvent;
    }

    function _resolveBeepEventPriority(beepEvent) {
        if (beepEvent == BEEP_EVENT_FUEL_NOW) {
            return 600;
        }
        if (beepEvent == BEEP_EVENT_HR_OVER) {
            return 500;
        }
        if (beepEvent == BEEP_EVENT_DRIFT_ON) {
            return 400;
        }
        if (beepEvent == BEEP_EVENT_FUEL_SOON) {
            return 350;
        }
        if (beepEvent == BEEP_EVENT_DISTANCE_MILESTONE) {
            return 300;
        }
        if (beepEvent == BEEP_EVENT_DISTANCE_SPLIT) {
            return 200;
        }
        return 0;
    }

    function _resolveBeepLevel(beepEvent) {
        if (beepEvent == BEEP_EVENT_DISTANCE_SPLIT) {
            return BEEP_LEVEL_INFO;
        }
        if (
            beepEvent == BEEP_EVENT_DISTANCE_MILESTONE or
            beepEvent == BEEP_EVENT_FUEL_SOON or
            beepEvent == BEEP_EVENT_HR_OVER or
            beepEvent == BEEP_EVENT_DRIFT_ON
        ) {
            return BEEP_LEVEL_CAUTION;
        }
        if (beepEvent == BEEP_EVENT_FUEL_NOW) {
            return BEEP_LEVEL_URGENT;
        }
        return 0;
    }

    function _playBeepEvent(beepEvent) {
        var beepLevel = _resolveBeepLevel(beepEvent);
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
        var raceType = _resolveDistanceNotifyRaceType();
        if (_distanceNotifyRaceType == raceType) {
            return;
        }

        _distanceNotifyRaceType = raceType;
        _distanceNotifyNextSplitKm = 1;
        _distanceNotifyNextCheckpointIdx = 0;
        _clearDistanceNotifyCard();
    }

    function _resolveDistanceNotifyRaceType() {
        if (_raceDistanceKm <= 7.0) {
            return DIST_NOTIFY_RACE_FIVE;
        }
        if (_abs(_raceDistanceKm - HALF_DISTANCE_KM) <= HALF_DISTANCE_TOLERANCE_KM) {
            return DIST_NOTIFY_RACE_HALF;
        }
        if (_raceDistanceKm <= 15.0) {
            return DIST_NOTIFY_RACE_TEN;
        }
        return DIST_NOTIFY_RACE_FULL;
    }

    function _getDistanceCheckpointCount(raceType) {
        if (raceType == DIST_NOTIFY_RACE_FIVE) {
            return 1;
        }
        return 2;
    }

    function _getDistanceCheckpointKm(raceType, checkpointIdx) {
        if (raceType == DIST_NOTIFY_RACE_FULL) {
            if (checkpointIdx == 0) {
                return 21.1;
            }
            if (checkpointIdx == 1) {
                return 42.2;
            }
            return null;
        }

        if (raceType == DIST_NOTIFY_RACE_HALF) {
            if (checkpointIdx == 0) {
                return 10.0;
            }
            if (checkpointIdx == 1) {
                return 21.1;
            }
            return null;
        }

        if (raceType == DIST_NOTIFY_RACE_TEN) {
            if (checkpointIdx == 0) {
                return 5.0;
            }
            if (checkpointIdx == 1) {
                return 10.0;
            }
            return null;
        }

        if (checkpointIdx == 0) {
            return 5.0;
        }
        return null;
    }

    function _getDistanceCheckpointLine1(raceType, checkpointIdx) {
        if (raceType == DIST_NOTIFY_RACE_FULL) {
            if (checkpointIdx == 0) {
                return _distanceLabelHalfText;
            }
            if (checkpointIdx == 1) {
                return _distanceLabelFullText;
            }
            return "";
        }

        if (raceType == DIST_NOTIFY_RACE_HALF) {
            if (checkpointIdx == 0) {
                return _distanceLabel10kText;
            }
            if (checkpointIdx == 1) {
                return _distanceLabelHalfText;
            }
            return "";
        }

        if (raceType == DIST_NOTIFY_RACE_TEN) {
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
        if (raceType == DIST_NOTIFY_RACE_FULL) {
            if (checkpointIdx == 0) {
                return _distanceMilestoneHalfLine2Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine2Text;
            }
            return "";
        }

        if (raceType == DIST_NOTIFY_RACE_HALF) {
            if (checkpointIdx == 0) {
                return _distanceMilestone10kLine2Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine2Text;
            }
            return "";
        }

        if (raceType == DIST_NOTIFY_RACE_TEN) {
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
        if (raceType == DIST_NOTIFY_RACE_FULL) {
            if (checkpointIdx == 0) {
                return _distanceMilestoneHalfLine3Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine3Text;
            }
            return "";
        }

        if (raceType == DIST_NOTIFY_RACE_HALF) {
            if (checkpointIdx == 0) {
                return _distanceMilestone10kLine3Text;
            }
            if (checkpointIdx == 1) {
                return _distanceGoalLine3Text;
            }
            return "";
        }

        if (raceType == DIST_NOTIFY_RACE_TEN) {
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

    function _getDistanceMaxSplitKm(raceType) {
        if (raceType == DIST_NOTIFY_RACE_FULL) {
            return 42;
        }
        if (raceType == DIST_NOTIFY_RACE_HALF) {
            return 21;
        }
        if (raceType == DIST_NOTIFY_RACE_TEN) {
            return 9;
        }
        return 4;
    }

    function _buildDistanceSplitLines(splitKm) as Lang.Array {
        var line1 = splitKm.format("%d") + "km";
        var phase = _resolveDistanceSplitPhase(splitKm);
        var line2Templates = _distanceSplitEarlyLine2;
        var line3Templates = _distanceSplitEarlyLine3;
        if (phase == DIST_NOTIFY_PHASE_MID) {
            line2Templates = _distanceSplitMidLine2;
            line3Templates = _distanceSplitMidLine3;
        } else if (phase == DIST_NOTIFY_PHASE_LATE) {
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

    function _resolveDistanceSplitPhase(splitKm) {
        if (_raceDistanceKm == null or _raceDistanceKm <= 0) {
            return DIST_NOTIFY_PHASE_EARLY;
        }

        var progress = splitKm / _raceDistanceKm;
        if (progress < 0.34) {
            return DIST_NOTIFY_PHASE_EARLY;
        }
        if (progress < 0.80) {
            return DIST_NOTIFY_PHASE_MID;
        }
        return DIST_NOTIFY_PHASE_LATE;
    }

    function _hasReachedDistanceTarget(distanceKm, targetKm) {
        if (distanceKm == null or targetKm == null) {
            return false;
        }
        return distanceKm >= (targetKm - DISTANCE_EVENT_EPSILON_KM);
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
        var paceTriggerThreshold = _getPushPaceDeltaThresholdSec(distanceKm);
        var headroomTriggerThreshold = _getPushHeadroomThresholdBpm(distanceKm);
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
        var easeHeadroomThreshold = _getActionEaseMinHeadroomBpm(distanceKm);
        var easeBaselineHrDeltaThreshold = _getActionEaseBaselineHrDeltaBpm(distanceKm);
        var easeCardiacCostThreshold = _getCardiacCostEaseMinRatio(distanceKm);

        var shouldEase = false;
        if (paceDeltaSec != null and paceDeltaSec <= ACTION_EASE_PACE_DELTA_SEC) {
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

        var idx = _randomMessageIndex(_warmupMessages.size(), -1, -1);
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

    function _parsePositiveDecimal(text) {
        var rawText = _normalizeTimeText(text);
        if (rawText == null or rawText.length() == 0) {
            return null;
        }

        var intPart = 0;
        var fracPart = 0.0;
        var fracDivisor = 1.0;
        var seenDot = false;
        var hasDigit = false;

        for (var i = 0; i < rawText.length(); i += 1) {
            var ch = rawText.substring(i, i + 1);
            if (ch == "." or ch == "．") {
                if (seenDot) {
                    return null;
                }
                seenDot = true;
                continue;
            }

            var digit = _digitValue(ch);
            if (digit == null) {
                return null;
            }

            hasDigit = true;
            if (!seenDot) {
                intPart = (intPart * 10) + digit;
            } else {
                fracPart = (fracPart * 10.0) + digit;
                fracDivisor *= 10.0;
            }
        }

        if (!hasDigit) {
            return null;
        }
        return intPart + (fracPart / fracDivisor);
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

    function _buildGoalDeltaText(predictedTotalSec) {
        var predictedText = "--:--";
        if (predictedTotalSec != null and predictedTotalSec >= 0) {
            predictedText = _formatHourMin(predictedTotalSec);
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

    function _formatHourMin(totalSec) {
        if (totalSec == null) {
            return "--:--";
        }

        var roundedTotalMinutes = Math.floor((totalSec + 30.0) / 60.0);
        if (roundedTotalMinutes < 0) {
            roundedTotalMinutes = 0;
        }
        var hourPart = Math.floor(roundedTotalMinutes / 60);
        var minPart = roundedTotalMinutes - (hourPart * 60);
        return hourPart.format("%d") + ":" + minPart.format("%02d");
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
