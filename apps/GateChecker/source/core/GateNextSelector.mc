using Toybox.Lang as Lang;
using GatePointTransitionPolicy;
using GateRaceData;

module GateNextSelector {
    const REASON_EMPTY = 0;
    const REASON_OK = 1;
    const REASON_NO_GATES = 2;
    const REASON_DISTANCE_UNAVAILABLE = 3;
    const REASON_PASSED_ALL_GATES = 4;

    const CFG_HAS_NEXT_GATE = 0;
    const CFG_NEXT_GATE = 1;
    const CFG_NEXT_INDEX = 2;
    const CFG_REASON = 3;

    function newDefaultConfig() as Lang.Array {
        return [false, null, null, REASON_EMPTY];
    }

    function selectNextGate(gates, currentDistanceKm) as Lang.Array {
        return selectNextGateFromIndex(gates, currentDistanceKm, 0);
    }

    function selectNextGateFromIndex(gates, currentDistanceKm, startIndex) as Lang.Array {
        var config = newDefaultConfig();
        if (gates == null or !(gates instanceof Lang.Array) or gates.size() <= 0) {
            config[CFG_REASON] = REASON_NO_GATES;
            return config;
        }
        if (currentDistanceKm == null or currentDistanceKm < 0) {
            config[CFG_REASON] = REASON_DISTANCE_UNAVAILABLE;
            return config;
        }

        var resolvedStartIndex = startIndex;
        if (resolvedStartIndex == null or resolvedStartIndex < 0) {
            resolvedStartIndex = 0;
        }
        if (resolvedStartIndex >= gates.size()) {
            config[CFG_REASON] = REASON_PASSED_ALL_GATES;
            return config;
        }

        for (var i = resolvedStartIndex; i < gates.size(); i += 1) {
            var gate = gates[i];
            var gateDistanceKm = GateRaceData.getGateDistanceKm(gate);
            if (gateDistanceKm == null) {
                continue;
            }
            if (GatePointTransitionPolicy.shouldDisplayPoint(currentDistanceKm, gateDistanceKm)) {
                config[CFG_HAS_NEXT_GATE] = true;
                config[CFG_NEXT_GATE] = gate;
                config[CFG_NEXT_INDEX] = i;
                config[CFG_REASON] = REASON_OK;
                return config;
            }
        }

        config[CFG_REASON] = REASON_PASSED_ALL_GATES;
        return config;
    }

    function hasNextGate(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_HAS_NEXT_GATE, false);
    }

    function getNextGate(config) {
        return _getConfigValue(config, CFG_NEXT_GATE, null);
    }

    function getNextIndex(config) {
        return _getConfigValue(config, CFG_NEXT_INDEX, null);
    }

    function getReason(config) {
        var reasonCode = _getConfigValue(config, CFG_REASON, REASON_EMPTY);
        if (reasonCode == REASON_OK) {
            return "ok";
        }
        if (reasonCode == REASON_NO_GATES) {
            return "no_gates";
        }
        if (reasonCode == REASON_DISTANCE_UNAVAILABLE) {
            return "distance_unavailable";
        }
        if (reasonCode == REASON_PASSED_ALL_GATES) {
            return "passed_all_gates";
        }
        return "empty";
    }

    function isDistanceUnavailable(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_REASON, REASON_EMPTY) == REASON_DISTANCE_UNAVAILABLE;
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
