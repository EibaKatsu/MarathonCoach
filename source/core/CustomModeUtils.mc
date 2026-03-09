using Toybox.Lang as Lang;
using Toybox.Math as Math;

module CustomModeUtils {
    const MODE_CORE = 0;
    const MODE_CUSTOM = 1;

    const FUEL_MODE_OFF = 0;
    const FUEL_MODE_TIME = 1;

    const DEFAULT_FIRST_FUEL_AFTER_MIN = 35;
    const DEFAULT_FUEL_INTERVAL_MIN = 35;
    const DEFAULT_FUEL_ALERT_LEAD_MIN = 2;
    const DEFAULT_PHASE_AGGRESSIVENESS = 10;
    const DEFAULT_HR_CAP_BIAS_BPM = 0;
    const DEFAULT_DRIFT_SENSITIVITY = 3;

    const MIN_FIRST_FUEL_AFTER_MIN = 1;
    const MAX_FIRST_FUEL_AFTER_MIN = 99;
    const MIN_FUEL_INTERVAL_MIN = 1;
    const MAX_FUEL_INTERVAL_MIN = 99;
    const MIN_FUEL_ALERT_LEAD_MIN = 0;
    const MAX_FUEL_ALERT_LEAD_MIN = 5;
    const MIN_PHASE_AGGRESSIVENESS = 0;
    const MAX_PHASE_AGGRESSIVENESS = 20;
    const MIN_HR_CAP_BIAS_BPM = -8;
    const MAX_HR_CAP_BIAS_BPM = 8;
    const MIN_DRIFT_SENSITIVITY = 0;
    const MAX_DRIFT_SENSITIVITY = 7;

    const CODE_PREFIX = "C1";
    const CODE_PAYLOAD_LEN = 14;
    const CODE_CHECKSUM_LEN = 2;
    const BASE36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const BASE36_PAIR_RADIX = 36;
    const BASE36_PAIR_MOD = 1296; // 36^2

    const CFG_MODE = 0;
    const CFG_CODE_VALID = 1;
    const CFG_FUEL_MODE = 2;
    const CFG_FIRST_FUEL_AFTER_MIN = 3;
    const CFG_FUEL_INTERVAL_MIN = 4;
    const CFG_FUEL_ALERT_LEAD_MIN = 5;
    const CFG_PHASE_AGGRESSIVENESS = 6;
    const CFG_HR_CAP_BIAS_BPM = 7;
    const CFG_DRIFT_SENSITIVITY = 8;

    function newDefaultConfig() as Lang.Array {
        var config = [];
        config.add(MODE_CORE);
        config.add(false);
        config.add(FUEL_MODE_TIME);
        config.add(DEFAULT_FIRST_FUEL_AFTER_MIN);
        config.add(DEFAULT_FUEL_INTERVAL_MIN);
        config.add(DEFAULT_FUEL_ALERT_LEAD_MIN);
        config.add(DEFAULT_PHASE_AGGRESSIVENESS);
        config.add(DEFAULT_HR_CAP_BIAS_BPM);
        config.add(DEFAULT_DRIFT_SENSITIVITY);
        return config;
    }

    function decodeCustomCode(rawCode) {
        var config = newDefaultConfig();
        if (rawCode == null) {
            return config;
        }

        var normalized = _normalizeCode(rawCode.toString());
        if (normalized.length() == 0) {
            return config;
        }

        var totalLen = CODE_PREFIX.length() + CODE_PAYLOAD_LEN + CODE_CHECKSUM_LEN;
        if (normalized.length() != totalLen) {
            return config;
        }
        var prefixChars = normalized.toCharArray();
        if (
            !(prefixChars instanceof Lang.Array) or
            prefixChars.size() < 2 or
            prefixChars[0] == null or
            prefixChars[1] == null or
            prefixChars[0].toNumber() != 67 or
            prefixChars[1].toNumber() != 49
        ) {
            return config;
        }

        var payloadStart = CODE_PREFIX.length();
        var payloadEnd = payloadStart + CODE_PAYLOAD_LEN;
        var payload = normalized.substring(payloadStart, payloadEnd);
        var checksumText = normalized.substring(payloadEnd, payloadEnd + CODE_CHECKSUM_LEN);
        var expectedChecksum = _encodeBase36Pair(_computeChecksum(CODE_PREFIX + payload));
        if (!_stringEquals(checksumText, expectedChecksum)) {
            return config;
        }

        var fuelModeEnc = _decodeBase36Pair(payload.substring(0, 2));
        var firstFuelOffsetEnc = _decodeBase36Pair(payload.substring(2, 4));
        var fuelIntervalOffsetEnc = _decodeBase36Pair(payload.substring(4, 6));
        var fuelAlertLeadEnc = _decodeBase36Pair(payload.substring(6, 8));
        var phaseAggressivenessEnc = _decodeBase36Pair(payload.substring(8, 10));
        var hrCapBiasOffsetEnc = _decodeBase36Pair(payload.substring(10, 12));
        var driftSensitivityEnc = _decodeBase36Pair(payload.substring(12, 14));

        if (fuelModeEnc == null or (fuelModeEnc != FUEL_MODE_OFF and fuelModeEnc != FUEL_MODE_TIME)) {
            return config;
        }
        if (
            firstFuelOffsetEnc == null or
            firstFuelOffsetEnc < MIN_FIRST_FUEL_AFTER_MIN or
            firstFuelOffsetEnc > MAX_FIRST_FUEL_AFTER_MIN
        ) {
            return config;
        }
        if (
            fuelIntervalOffsetEnc == null or
            fuelIntervalOffsetEnc < MIN_FUEL_INTERVAL_MIN or
            fuelIntervalOffsetEnc > MAX_FUEL_INTERVAL_MIN
        ) {
            return config;
        }
        if (fuelAlertLeadEnc == null or fuelAlertLeadEnc < 0 or fuelAlertLeadEnc > 5) {
            return config;
        }
        if (phaseAggressivenessEnc == null or phaseAggressivenessEnc < 0 or phaseAggressivenessEnc > 20) {
            return config;
        }
        if (hrCapBiasOffsetEnc == null or hrCapBiasOffsetEnc < 0 or hrCapBiasOffsetEnc > 16) {
            return config;
        }
        if (driftSensitivityEnc == null or driftSensitivityEnc < 0 or driftSensitivityEnc > 7) {
            return config;
        }

        config[CFG_MODE] = MODE_CUSTOM;
        config[CFG_CODE_VALID] = true;
        config[CFG_FUEL_MODE] = fuelModeEnc;
        config[CFG_FIRST_FUEL_AFTER_MIN] = firstFuelOffsetEnc;
        config[CFG_FUEL_INTERVAL_MIN] = fuelIntervalOffsetEnc;
        config[CFG_FUEL_ALERT_LEAD_MIN] = fuelAlertLeadEnc;
        config[CFG_PHASE_AGGRESSIVENESS] = phaseAggressivenessEnc;
        config[CFG_HR_CAP_BIAS_BPM] = MIN_HR_CAP_BIAS_BPM + hrCapBiasOffsetEnc;
        config[CFG_DRIFT_SENSITIVITY] = driftSensitivityEnc;
        return config;
    }

    function encodeCustomCode(
        fuelMode,
        firstFuelAfterMin,
        fuelIntervalMin,
        fuelAlertLeadMin,
        phaseAggressiveness,
        hrCapBiasBpm,
        driftSensitivity
    ) {
        if (fuelMode != FUEL_MODE_OFF and fuelMode != FUEL_MODE_TIME) {
            return null;
        }
        if (
            firstFuelAfterMin < MIN_FIRST_FUEL_AFTER_MIN or
            firstFuelAfterMin > MAX_FIRST_FUEL_AFTER_MIN or
            fuelIntervalMin < MIN_FUEL_INTERVAL_MIN or
            fuelIntervalMin > MAX_FUEL_INTERVAL_MIN or
            fuelAlertLeadMin < MIN_FUEL_ALERT_LEAD_MIN or
            fuelAlertLeadMin > MAX_FUEL_ALERT_LEAD_MIN or
            phaseAggressiveness < MIN_PHASE_AGGRESSIVENESS or
            phaseAggressiveness > MAX_PHASE_AGGRESSIVENESS or
            hrCapBiasBpm < MIN_HR_CAP_BIAS_BPM or
            hrCapBiasBpm > MAX_HR_CAP_BIAS_BPM or
            driftSensitivity < MIN_DRIFT_SENSITIVITY or
            driftSensitivity > MAX_DRIFT_SENSITIVITY
        ) {
            return null;
        }

        var payload =
            _encodeBase36Pair(fuelMode) +
            _encodeBase36Pair(firstFuelAfterMin) +
            _encodeBase36Pair(fuelIntervalMin) +
            _encodeBase36Pair(fuelAlertLeadMin) +
            _encodeBase36Pair(phaseAggressiveness) +
            _encodeBase36Pair(hrCapBiasBpm - MIN_HR_CAP_BIAS_BPM) +
            _encodeBase36Pair(driftSensitivity);
        var checksum = _encodeBase36Pair(_computeChecksum(CODE_PREFIX + payload));
        return CODE_PREFIX + payload + checksum;
    }

    function getMode(config) {
        return _getConfigValue(config, CFG_MODE, MODE_CORE);
    }

    function isCustomMode(config) {
        return getMode(config) == MODE_CUSTOM;
    }

    function isCodeValid(config) {
        return _getConfigValue(config, CFG_CODE_VALID, false);
    }

    function getFuelMode(config) {
        return _getConfigValue(config, CFG_FUEL_MODE, FUEL_MODE_TIME);
    }

    function getFirstFuelAfterMin(config) {
        return _getConfigValue(config, CFG_FIRST_FUEL_AFTER_MIN, DEFAULT_FIRST_FUEL_AFTER_MIN);
    }

    function getFuelIntervalMin(config) {
        return _getConfigValue(config, CFG_FUEL_INTERVAL_MIN, DEFAULT_FUEL_INTERVAL_MIN);
    }

    function getFuelAlertLeadMin(config) {
        return _getConfigValue(config, CFG_FUEL_ALERT_LEAD_MIN, DEFAULT_FUEL_ALERT_LEAD_MIN);
    }

    function getPhaseAggressiveness(config) {
        return _getConfigValue(config, CFG_PHASE_AGGRESSIVENESS, DEFAULT_PHASE_AGGRESSIVENESS);
    }

    function getHrCapBiasBpm(config) {
        return _getConfigValue(config, CFG_HR_CAP_BIAS_BPM, DEFAULT_HR_CAP_BIAS_BPM);
    }

    function getDriftSensitivity(config) {
        return _getConfigValue(config, CFG_DRIFT_SENSITIVITY, DEFAULT_DRIFT_SENSITIVITY);
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

    function _normalizeCode(rawCode) {
        var normalized = "";
        var chars = rawCode.toCharArray();
        if (!(chars instanceof Lang.Array)) {
            return normalized;
        }

        for (var i = 0; i < chars.size(); i += 1) {
            var ch = chars[i];
            if (ch == null) {
                continue;
            }
            var code = ch.toNumber();
            if (code == 45 or code == 95 or code == 32 or code == 9) {
                continue;
            }

            var idx = null;
            if (code >= 48 and code <= 57) {
                idx = code - 48;
            } else if (code >= 65 and code <= 90) {
                idx = 10 + (code - 65);
            } else if (code >= 97 and code <= 122) {
                idx = 10 + (code - 97);
            }

            if (idx != null and idx >= 0 and idx < BASE36.length()) {
                normalized += BASE36.substring(idx, idx + 1);
            }
        }
        return normalized;
    }

    function _computeChecksum(text) {
        var sum = 0;
        for (var i = 0; i < text.length(); i += 1) {
            var val = _base36Index(text.substring(i, i + 1));
            if (val == null) {
                continue;
            }
            sum += (i + 1) * val;
        }
        return sum % BASE36_PAIR_MOD;
    }

    function _decodeBase36Pair(pair) {
        if (pair == null or pair.length() != 2) {
            return null;
        }
        var hi = _base36Index(pair.substring(0, 1));
        var lo = _base36Index(pair.substring(1, 2));
        if (hi == null or lo == null) {
            return null;
        }
        return (hi * BASE36_PAIR_RADIX) + lo;
    }

    function _encodeBase36Pair(value) {
        if (value == null) {
            return "00";
        }
        var clamped = value;
        if (clamped < 0) {
            clamped = 0;
        }
        if (clamped >= BASE36_PAIR_MOD) {
            clamped = BASE36_PAIR_MOD - 1;
        }

        var hi = Math.floor(clamped / BASE36_PAIR_RADIX);
        var lo = clamped - (hi * BASE36_PAIR_RADIX);
        return BASE36.substring(hi, hi + 1) + BASE36.substring(lo, lo + 1);
    }

    function _base36Index(ch) {
        if (ch == null or ch.length() != 1) {
            return null;
        }
        var chars = ch.toCharArray();
        if (!(chars instanceof Lang.Array) or chars.size() == 0 or chars[0] == null) {
            return null;
        }
        var code = chars[0].toNumber();
        if (code >= 48 and code <= 57) {
            return code - 48;
        }
        if (code >= 65 and code <= 90) {
            return 10 + (code - 65);
        }
        if (code >= 97 and code <= 122) {
            return 10 + (code - 97);
        }
        return null;
    }

    function _stringEquals(a, b) {
        if (a == null or b == null) {
            return a == b;
        }
        if (a.length() != b.length()) {
            return false;
        }
        var aChars = a.toCharArray();
        var bChars = b.toCharArray();
        if (
            !(aChars instanceof Lang.Array) or
            !(bChars instanceof Lang.Array) or
            aChars.size() != bChars.size()
        ) {
            return false;
        }
        for (var i = 0; i < aChars.size(); i += 1) {
            if (aChars[i] == null or bChars[i] == null) {
                return false;
            }
            if (aChars[i].toNumber() != bChars[i].toNumber()) {
                return false;
            }
        }
        return true;
    }
}
