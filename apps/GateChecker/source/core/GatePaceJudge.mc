using Toybox.Lang as Lang;

module GatePaceJudge {
    const STATE_NONE = 0;
    const STATE_PLENTY = 1;
    const STATE_OK = 2;
    const STATE_TIGHT = 3;
    const STATE_PUSH = 4;
    const STATE_OVER = 5;

    const CFG_HAS_STATE = 0;
    const CFG_STATE = 1;
    const CFG_REASON = 2;

    const PACE_PLENTY_SEC_PER_KM = 12 * 60;
    const PACE_OK_SEC_PER_KM = 9 * 60;
    const PACE_TIGHT_SEC_PER_KM = 6 * 60;

    function newDefaultConfig() as Lang.Array {
        return [false, STATE_NONE, "empty"];
    }

    function judgeRequiredPace(requiredPaceSecPerKm, remainingSec) as Lang.Array {
        var config = newDefaultConfig();
        if (remainingSec == null) {
            config[CFG_REASON] = "time_unavailable";
            return config;
        }
        if (remainingSec <= 0) {
            config[CFG_HAS_STATE] = true;
            config[CFG_STATE] = STATE_OVER;
            config[CFG_REASON] = "time_expired";
            return config;
        }
        if (requiredPaceSecPerKm == null) {
            config[CFG_REASON] = "pace_unavailable";
            return config;
        }

        config[CFG_HAS_STATE] = true;
        config[CFG_REASON] = "ok";
        if (requiredPaceSecPerKm >= PACE_PLENTY_SEC_PER_KM) {
            config[CFG_STATE] = STATE_PLENTY;
            return config;
        }
        if (requiredPaceSecPerKm >= PACE_OK_SEC_PER_KM) {
            config[CFG_STATE] = STATE_OK;
            return config;
        }
        if (requiredPaceSecPerKm >= PACE_TIGHT_SEC_PER_KM) {
            config[CFG_STATE] = STATE_TIGHT;
            return config;
        }
        config[CFG_STATE] = STATE_PUSH;
        return config;
    }

    function hasState(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_HAS_STATE, false);
    }

    function getState(config) {
        return _getConfigValue(config, CFG_STATE, STATE_NONE);
    }

    function getReason(config) {
        return _getConfigValue(config, CFG_REASON, "empty");
    }

    function isOver(config) as Lang.Boolean {
        return getState(config) == STATE_OVER;
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
