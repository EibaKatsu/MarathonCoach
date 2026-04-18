using Toybox.Lang as Lang;
using Toybox.Math as Math;

module GateRequiredPace {
    const REASON_EMPTY = 0;
    const REASON_OK = 1;
    const REASON_DISTANCE_UNAVAILABLE = 2;
    const REASON_TIME_UNAVAILABLE = 3;
    const REASON_DISTANCE_ZERO = 4;
    const REASON_TIME_EXPIRED = 5;

    const CFG_HAS_PACE = 0;
    const CFG_PACE_SEC_PER_KM = 1;
    const CFG_REASON = 2;

    function newDefaultConfig() as Lang.Array {
        return [false, null, REASON_EMPTY];
    }

    function computeRequiredPace(remainingDistanceKm, remainingSec) as Lang.Array {
        var config = newDefaultConfig();
        if (remainingDistanceKm == null) {
            config[CFG_REASON] = REASON_DISTANCE_UNAVAILABLE;
            return config;
        }
        if (remainingSec == null) {
            config[CFG_REASON] = REASON_TIME_UNAVAILABLE;
            return config;
        }
        if (remainingDistanceKm <= 0) {
            config[CFG_REASON] = REASON_DISTANCE_ZERO;
            return config;
        }
        if (remainingSec <= 0) {
            config[CFG_REASON] = REASON_TIME_EXPIRED;
            return config;
        }

        config[CFG_HAS_PACE] = true;
        config[CFG_PACE_SEC_PER_KM] = remainingSec / remainingDistanceKm;
        config[CFG_REASON] = REASON_OK;
        return config;
    }

    function hasRequiredPace(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_HAS_PACE, false);
    }

    function getRequiredPaceSecPerKm(config) {
        return _getConfigValue(config, CFG_PACE_SEC_PER_KM, null);
    }

    function getReason(config) {
        var reasonCode = _getConfigValue(config, CFG_REASON, REASON_EMPTY);
        if (reasonCode == REASON_OK) {
            return "ok";
        }
        if (reasonCode == REASON_DISTANCE_UNAVAILABLE) {
            return "distance_unavailable";
        }
        if (reasonCode == REASON_TIME_UNAVAILABLE) {
            return "time_unavailable";
        }
        if (reasonCode == REASON_DISTANCE_ZERO) {
            return "distance_zero";
        }
        if (reasonCode == REASON_TIME_EXPIRED) {
            return "time_expired";
        }
        return "empty";
    }

    function isTimeExpired(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_REASON, REASON_EMPTY) == REASON_TIME_EXPIRED;
    }

    function formatPaceSecPerKm(paceSecPerKm) {
        if (paceSecPerKm == null) {
            return "--:--";
        }

        var roundedSec = Math.floor(paceSecPerKm + 0.5);
        if (roundedSec < 0) {
            roundedSec = 0;
        }
        var minutePart = Math.floor(roundedSec / 60);
        var secondPart = roundedSec - (minutePart * 60);
        return minutePart.format("%d") + ":" + secondPart.format("%02d");
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
}
