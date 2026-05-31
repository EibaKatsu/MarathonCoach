using Toybox.Lang as Lang;
using GatePointTransitionPolicy;
using GateRaceData;

module GateAidSelector {
    const REASON_EMPTY = 0;
    const REASON_OK = 1;
    const REASON_NO_AIDS = 2;
    const REASON_DISTANCE_UNAVAILABLE = 3;
    const REASON_PASSED_ALL_AIDS = 4;

    const CFG_HAS_NEXT_AID = 0;
    const CFG_NEXT_AID = 1;
    const CFG_NEXT_INDEX = 2;
    const CFG_REASON = 3;

    function newDefaultConfig() as Lang.Array {
        return [false, null, null, REASON_EMPTY];
    }

    function selectNextAid(aids, currentDistanceKm) as Lang.Array {
        var config = newDefaultConfig();
        if (aids == null or !(aids instanceof Lang.Array) or aids.size() <= 0) {
            config[CFG_REASON] = REASON_NO_AIDS;
            return config;
        }
        if (currentDistanceKm == null or currentDistanceKm < 0) {
            config[CFG_REASON] = REASON_DISTANCE_UNAVAILABLE;
            return config;
        }

        for (var i = 0; i < aids.size(); i += 1) {
            var aidDistanceKm = GateRaceData.getAidDistanceKm(aids[i]);
            if (aidDistanceKm == null) {
                continue;
            }
            if (GatePointTransitionPolicy.shouldDisplayPoint(currentDistanceKm, aidDistanceKm)) {
                config[CFG_HAS_NEXT_AID] = true;
                config[CFG_NEXT_AID] = aids[i];
                config[CFG_NEXT_INDEX] = i;
                config[CFG_REASON] = REASON_OK;
                return config;
            }
        }

        config[CFG_REASON] = REASON_PASSED_ALL_AIDS;
        return config;
    }

    function hasNextAid(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_HAS_NEXT_AID, false);
    }

    function getNextAid(config) {
        return _getConfigValue(config, CFG_NEXT_AID, null);
    }

    function getNextIndex(config) {
        return _getConfigValue(config, CFG_NEXT_INDEX, null);
    }

    function getReason(config) {
        var reasonCode = _getConfigValue(config, CFG_REASON, REASON_EMPTY);
        if (reasonCode == REASON_OK) {
            return "ok";
        }
        if (reasonCode == REASON_NO_AIDS) {
            return "no_aids";
        }
        if (reasonCode == REASON_DISTANCE_UNAVAILABLE) {
            return "distance_unavailable";
        }
        if (reasonCode == REASON_PASSED_ALL_AIDS) {
            return "passed_all_aids";
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
