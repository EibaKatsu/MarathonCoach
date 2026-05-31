using Toybox.Lang as Lang;
using Toybox.Math as Math;
using GateRaceData;

module GateDistanceCorrection {
    const LAP_ADJUST_INTERVAL_KM = 1.0;
    const LAP_ADJUST_WINDOW_KM = 0.2;
    const AUTO_LAP_EXACT_DISTANCE_TOLERANCE_KM = 0.001;
    const MANUAL_LAP_TRIGGER_VALUE = 0;

    const CFG_ENABLED = 0;
    const CFG_OFFSET_KM = 1;
    const CFG_LAST_CORRECTED_MARKER_INDEX = 2;

    const RESULT_APPLIED = 0;
    const RESULT_TARGET_DISTANCE_KM = 1;
    const RESULT_OFFSET_KM = 2;
    const RESULT_REASON = 3;

    function newDefaultConfig(enabled) as Lang.Array {
        return [enabled == true, 0.0, null];
    }

    function syncEnabled(config, enabled) as Lang.Array {
        var currentConfig = _normalizeConfig(config);
        var enabledValue = enabled == true;
        if (currentConfig[CFG_ENABLED] == enabledValue) {
            return currentConfig;
        }
        return newDefaultConfig(enabledValue);
    }

    function reset(config) as Lang.Array {
        return newDefaultConfig(isEnabled(config));
    }

    function isEnabled(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_ENABLED, false);
    }

    function getCorrectionOffsetKm(config) {
        return _getConfigValue(config, CFG_OFFSET_KM, 0.0);
    }

    function getLastCorrectedMarkerIndex(config) {
        return _getConfigValue(config, CFG_LAST_CORRECTED_MARKER_INDEX, null);
    }

    function getEffectiveDistanceKm(rawDistanceKm, config) {
        if (rawDistanceKm == null) {
            return null;
        }
        if (!isEnabled(config)) {
            return rawDistanceKm;
        }
        return rawDistanceKm + getCorrectionOffsetKm(config);
    }

    function isManualLapTrigger(trigger) as Lang.Boolean {
        if (trigger == null or !(trigger has :lapTrigger)) {
            return false;
        }

        var lapTrigger = trigger[:lapTrigger];
        if (!_isNumericValue(lapTrigger)) {
            return false;
        }
        return lapTrigger == MANUAL_LAP_TRIGGER_VALUE;
    }

    function applyManualLapCorrection(config, rawDistanceKm) as Lang.Array {
        var currentConfig = _normalizeConfig(config);
        if (!isEnabled(currentConfig)) {
            return [false, null, getCorrectionOffsetKm(currentConfig), "disabled"];
        }
        if (rawDistanceKm == null or rawDistanceKm < 0) {
            return [false, null, getCorrectionOffsetKm(currentConfig), "distance_unavailable"];
        }

        var effectiveDistanceKm = getEffectiveDistanceKm(rawDistanceKm, currentConfig);
        var markerIndex = _resolveAdjustmentMarkerIndex(effectiveDistanceKm);
        if (markerIndex == null) {
            return [false, null, getCorrectionOffsetKm(currentConfig), "out_of_window"];
        }
        if (markerIndex == getLastCorrectedMarkerIndex(currentConfig)) {
            return [false, _markerIndexToDistanceKm(markerIndex), getCorrectionOffsetKm(currentConfig), "already_corrected"];
        }

        var targetDistanceKm = _markerIndexToDistanceKm(markerIndex);
        if (targetDistanceKm == null) {
            return [false, null, getCorrectionOffsetKm(currentConfig), "marker_unavailable"];
        }

        var offsetKm = targetDistanceKm - rawDistanceKm;
        currentConfig[CFG_OFFSET_KM] = offsetKm;
        currentConfig[CFG_LAST_CORRECTED_MARKER_INDEX] = markerIndex;
        return [true, targetDistanceKm, offsetKm, "applied"];
    }

    function getAdjustmentCandidateDistanceKm(config, rawDistanceKm) {
        var currentConfig = _normalizeConfig(config);
        if (!isEnabled(currentConfig) or rawDistanceKm == null or rawDistanceKm < 0) {
            return null;
        }

        var effectiveDistanceKm = getEffectiveDistanceKm(rawDistanceKm, currentConfig);
        var markerIndex = _resolveAdjustmentMarkerIndex(effectiveDistanceKm);
        if (markerIndex == null) {
            return null;
        }
        if (markerIndex == getLastCorrectedMarkerIndex(currentConfig)) {
            return null;
        }
        return _markerIndexToDistanceKm(markerIndex);
    }

    function isWithinAdjustmentWindow(currentDistanceKm, targetDistanceKm) as Lang.Boolean {
        if (currentDistanceKm == null or targetDistanceKm == null) {
            return false;
        }
        return _isWithinAdjustmentWindow(currentDistanceKm, targetDistanceKm);
    }

    function isExactIntervalMarkerDistance(rawDistanceKm) as Lang.Boolean {
        if (rawDistanceKm == null or rawDistanceKm < 0) {
            return false;
        }

        var raceDistanceKm = GateRaceData.getRaceDistanceKm();
        if (raceDistanceKm == null or raceDistanceKm <= 0) {
            return false;
        }

        var markerIndex = Math.floor((rawDistanceKm / LAP_ADJUST_INTERVAL_KM) + 0.5);
        if (markerIndex == null or markerIndex <= 0) {
            return false;
        }

        var markerDistanceKm = _markerIndexToDistanceKm(markerIndex);
        if (markerDistanceKm == null or markerDistanceKm > raceDistanceKm) {
            return false;
        }

        var distanceDiffKm = rawDistanceKm - markerDistanceKm;
        if (distanceDiffKm < 0) {
            distanceDiffKm = -distanceDiffKm;
        }
        return distanceDiffKm <= AUTO_LAP_EXACT_DISTANCE_TOLERANCE_KM;
    }

    function _resolveAdjustmentMarkerIndex(currentDistanceKm) {
        if (currentDistanceKm == null or currentDistanceKm < 0) {
            return null;
        }

        var raceDistanceKm = GateRaceData.getRaceDistanceKm();
        if (raceDistanceKm == null or raceDistanceKm <= 0) {
            return null;
        }

        var lowerMarkerIndex = Math.floor(currentDistanceKm / LAP_ADJUST_INTERVAL_KM);
        if (_isEligibleMarkerIndex(lowerMarkerIndex, currentDistanceKm, raceDistanceKm)) {
            return lowerMarkerIndex;
        }

        var upperMarkerIndex = lowerMarkerIndex + 1;
        if (_isEligibleMarkerIndex(upperMarkerIndex, currentDistanceKm, raceDistanceKm)) {
            return upperMarkerIndex;
        }

        return null;
    }

    function _isEligibleMarkerIndex(markerIndex, currentDistanceKm, raceDistanceKm) as Lang.Boolean {
        if (markerIndex == null or markerIndex <= 0) {
            return false;
        }

        var markerDistanceKm = _markerIndexToDistanceKm(markerIndex);
        if (markerDistanceKm == null or markerDistanceKm > raceDistanceKm) {
            return false;
        }
        return _isWithinAdjustmentWindow(currentDistanceKm, markerDistanceKm);
    }

    function _markerIndexToDistanceKm(markerIndex) {
        if (markerIndex == null or markerIndex <= 0) {
            return null;
        }
        return markerIndex * LAP_ADJUST_INTERVAL_KM;
    }

    function _isWithinAdjustmentWindow(currentDistanceKm, targetDistanceKm) as Lang.Boolean {
        var distanceDiffKm = currentDistanceKm - targetDistanceKm;
        if (distanceDiffKm < 0) {
            distanceDiffKm = -distanceDiffKm;
        }
        return distanceDiffKm <= LAP_ADJUST_WINDOW_KM;
    }

    function _normalizeConfig(config) as Lang.Array {
        if (config == null or !(config instanceof Lang.Array) or config.size() < 3) {
            return newDefaultConfig(false);
        }
        return config;
    }

    function _getConfigValue(config, index, defaultValue) {
        if (config == null or !(config instanceof Lang.Array)) {
            return defaultValue;
        }
        if (index < 0 or index >= config.size()) {
            return defaultValue;
        }
        var value = config[index];
        if (value == null) {
            return defaultValue;
        }
        return value;
    }

    function _isNumericValue(value) as Lang.Boolean {
        return value != null and (
            value instanceof Lang.Number or
            value instanceof Lang.Float or
            value instanceof Lang.Double or
            value instanceof Lang.Long
        );
    }
}
