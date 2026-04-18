using Toybox.Lang as Lang;
using Toybox.Math as Math;

module GateCurrentPace {
    const PACE_EMA_WINDOW_SEC = 18;
    const PACE_EMA_ALPHA = 2.0 / (PACE_EMA_WINDOW_SEC + 1.0);

    const CFG_HAS_PACE = 0;
    const CFG_PACE_SEC_PER_KM = 1;
    const CFG_PACE_TEXT = 2;
    const CFG_LAST_SAMPLE_ELAPSED_SEC = 3;
    const CFG_FALLBACK_LAST_ELAPSED_SEC = 4;
    const CFG_FALLBACK_LAST_DISTANCE_KM = 5;
    const CFG_REASON = 6;

    function newDefaultConfig() as Lang.Array {
        return [false, null, "--:--", null, null, null, "empty"];
    }

    function updateCurrentPace(config, info, currentDistanceKm) as Lang.Array {
        var nextConfig = _normalizeConfig(config);
        var elapsedSec = _extractElapsedSec(info);
        if (elapsedSec == null) {
            _setPace(nextConfig, null);
            nextConfig[CFG_REASON] = "elapsed_unavailable";
            return nextConfig;
        }

        var samplePaceSecPerKm = _extractPaceSecPerKm(info);
        if (samplePaceSecPerKm == null) {
            samplePaceSecPerKm = _extractPaceFromDistanceDelta(nextConfig, currentDistanceKm, elapsedSec);
        }

        var lastSampleElapsedSec = nextConfig[CFG_LAST_SAMPLE_ELAPSED_SEC];
        if (lastSampleElapsedSec != null and elapsedSec < lastSampleElapsedSec) {
            _resetRuntime(nextConfig);
            lastSampleElapsedSec = null;
        }

        if (samplePaceSecPerKm != null and (lastSampleElapsedSec == null or elapsedSec > lastSampleElapsedSec)) {
            var currentPaceSecPerKm = nextConfig[CFG_PACE_SEC_PER_KM];
            nextConfig[CFG_PACE_SEC_PER_KM] = _applyEmaSample(currentPaceSecPerKm, samplePaceSecPerKm, PACE_EMA_ALPHA);
            nextConfig[CFG_LAST_SAMPLE_ELAPSED_SEC] = elapsedSec;
        }

        _setPace(nextConfig, nextConfig[CFG_PACE_SEC_PER_KM]);
        if (nextConfig[CFG_HAS_PACE]) {
            nextConfig[CFG_REASON] = "ok";
        } else {
            nextConfig[CFG_REASON] = "pace_unavailable";
        }
        return nextConfig;
    }

    function hasCurrentPace(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_HAS_PACE, false);
    }

    function getCurrentPaceSecPerKm(config) {
        return _getConfigValue(config, CFG_PACE_SEC_PER_KM, null);
    }

    function getDisplayText(config) {
        return _getConfigValue(config, CFG_PACE_TEXT, "--:--");
    }

    function getReason(config) {
        return _getConfigValue(config, CFG_REASON, "empty");
    }

    function _normalizeConfig(config) as Lang.Array {
        if (config == null or !(config instanceof Lang.Array) or config.size() < 7) {
            return newDefaultConfig();
        }
        return config;
    }

    function _resetRuntime(config as Lang.Array) {
        config[CFG_PACE_SEC_PER_KM] = null;
        config[CFG_LAST_SAMPLE_ELAPSED_SEC] = null;
        config[CFG_FALLBACK_LAST_ELAPSED_SEC] = null;
        config[CFG_FALLBACK_LAST_DISTANCE_KM] = null;
        _setPace(config, null);
    }

    function _setPace(config as Lang.Array, paceSecPerKm) {
        if (paceSecPerKm == null) {
            config[CFG_HAS_PACE] = false;
            config[CFG_PACE_SEC_PER_KM] = null;
            config[CFG_PACE_TEXT] = "--:--";
            return;
        }

        config[CFG_HAS_PACE] = true;
        config[CFG_PACE_SEC_PER_KM] = paceSecPerKm;
        config[CFG_PACE_TEXT] = formatPaceSecPerKm(paceSecPerKm);
    }

    function formatPaceSecPerKm(paceSecPerKm) {
        if (paceSecPerKm == null) {
            return "--:--";
        }

        var roundedSec = Math.floor(paceSecPerKm + 0.5);
        if (roundedSec < 0) {
            roundedSec = 0;
        }

        var minPart = Math.floor(roundedSec / 60);
        var secPart = roundedSec - (minPart * 60);
        return minPart.format("%d") + ":" + secPart.format("%02d");
    }

    function _extractElapsedSec(info) {
        var rawElapsed = null;
        if (info != null and info has :elapsedTime) {
            rawElapsed = info.elapsedTime;
        }
        if (!_isNumericValue(rawElapsed) and info != null and info has :timerTime) {
            rawElapsed = info.timerTime;
        }
        if (!_isNumericValue(rawElapsed)) {
            return null;
        }

        var elapsedSec = rawElapsed / 1000.0;
        if (elapsedSec < 0) {
            elapsedSec = 0;
        }
        return Math.floor(elapsedSec);
    }

    function _extractPaceSecPerKm(info) {
        var speedMps = _extractCurrentSpeed(info);
        if (speedMps == null or speedMps <= 0) {
            return null;
        }

        var paceSecPerKm = 1000.0 / speedMps;
        if (paceSecPerKm < 120 or paceSecPerKm > 1200) {
            return null;
        }
        return paceSecPerKm;
    }

    function _extractCurrentSpeed(info) {
        if (info != null and _isNumericValue(info.currentSpeed)) {
            return info.currentSpeed;
        }
        if (info != null and info has :averageSpeed and _isNumericValue(info.averageSpeed)) {
            return info.averageSpeed;
        }
        return null;
    }

    function _extractPaceFromDistanceDelta(config as Lang.Array, currentDistanceKm, elapsedSec) {
        var samplePaceSecPerKm = null;
        var lastElapsedSec = config[CFG_FALLBACK_LAST_ELAPSED_SEC];
        var lastDistanceKm = config[CFG_FALLBACK_LAST_DISTANCE_KM];
        if (
            currentDistanceKm != null and
            lastElapsedSec != null and
            lastDistanceKm != null and
            elapsedSec > lastElapsedSec
        ) {
            var deltaSec = elapsedSec - lastElapsedSec;
            var deltaDistanceKm = currentDistanceKm - lastDistanceKm;
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

        config[CFG_FALLBACK_LAST_ELAPSED_SEC] = elapsedSec;
        config[CFG_FALLBACK_LAST_DISTANCE_KM] = currentDistanceKm;
        return samplePaceSecPerKm;
    }

    function _applyEmaSample(currentValue, sampleValue, alpha) {
        if (sampleValue == null) {
            return currentValue;
        }
        if (currentValue == null) {
            return sampleValue;
        }
        return currentValue + ((sampleValue - currentValue) * alpha);
    }

    function _isNumericValue(value) as Lang.Boolean {
        return value != null and (
            value instanceof Lang.Number or
            value instanceof Lang.Float or
            value instanceof Lang.Double or
            value instanceof Lang.Long
        );
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
