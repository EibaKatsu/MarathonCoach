using Toybox.Lang as Lang;

module GateRemainingDistance {
    const REASON_EMPTY = 0;
    const REASON_OK = 1;
    const REASON_DISTANCE_UNAVAILABLE = 2;
    const REASON_GATE_UNAVAILABLE = 3;

    const CFG_HAS_REMAINING = 0;
    const CFG_REMAINING_DISTANCE_KM = 1;
    const CFG_REASON = 2;

    function newDefaultConfig() as Lang.Array {
        return [false, null, REASON_EMPTY];
    }

    function computeRemainingDistance(currentDistanceKm, targetDistanceKm) as Lang.Array {
        var config = newDefaultConfig();
        if (targetDistanceKm == null or targetDistanceKm < 0) {
            config[CFG_REASON] = REASON_GATE_UNAVAILABLE;
            return config;
        }
        if (currentDistanceKm == null or currentDistanceKm < 0) {
            config[CFG_REASON] = REASON_DISTANCE_UNAVAILABLE;
            return config;
        }

        var remainingDistanceKm = targetDistanceKm - currentDistanceKm;
        if (remainingDistanceKm < 0) {
            remainingDistanceKm = 0.0;
        }

        config[CFG_HAS_REMAINING] = true;
        config[CFG_REMAINING_DISTANCE_KM] = remainingDistanceKm;
        config[CFG_REASON] = REASON_OK;
        return config;
    }

    function hasRemainingDistance(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_HAS_REMAINING, false);
    }

    function getRemainingDistanceKm(config) {
        return _getConfigValue(config, CFG_REMAINING_DISTANCE_KM, null);
    }

    function getReason(config) {
        var reasonCode = _getConfigValue(config, CFG_REASON, REASON_EMPTY);
        if (reasonCode == REASON_OK) {
            return "ok";
        }
        if (reasonCode == REASON_DISTANCE_UNAVAILABLE) {
            return "distance_unavailable";
        }
        if (reasonCode == REASON_GATE_UNAVAILABLE) {
            return "gate_unavailable";
        }
        return "empty";
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
