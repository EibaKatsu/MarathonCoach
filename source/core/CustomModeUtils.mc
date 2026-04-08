using Toybox.Lang as Lang;
using Toybox.Math as Math;

module CustomModeUtils {
    const MODE_CORE = 0;
    const MODE_CUSTOM = 1;

    const MIN_DIRECT_CAP_BPM = 30;
    const MAX_DIRECT_CAP_BPM = 260;

    const CODE_PREFIX = "C2";
    const CODE_PAYLOAD_LEN = 10;
    const CODE_CHECKSUM_LEN = 2;
    const BASE36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const BASE36_PAIR_RADIX = 36;
    const BASE36_PAIR_MOD = 1296; // 36^2

    const CFG_MODE = 0;
    const CFG_CODE_VALID = 1;
    const CFG_DIRECT_CAP_S1 = 2;
    const CFG_DIRECT_CAP_S2 = 3;
    const CFG_DIRECT_CAP_S3 = 4;
    const CFG_DIRECT_CAP_S4 = 5;
    const CFG_DIRECT_CAP_S5 = 6;

    function newDefaultConfig() as Lang.Array {
        var config = [];
        config.add(MODE_CORE);
        config.add(false);
        config.add(null);
        config.add(null);
        config.add(null);
        config.add(null);
        config.add(null);
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
            prefixChars[1].toNumber() != 50
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

        var directCapS1 = _normalizeDirectCapHeartRate(_decodeBase36Pair(payload.substring(0, 2)));
        var directCapS2 = _normalizeDirectCapHeartRate(_decodeBase36Pair(payload.substring(2, 4)));
        var directCapS3 = _normalizeDirectCapHeartRate(_decodeBase36Pair(payload.substring(4, 6)));
        var directCapS4 = _normalizeDirectCapHeartRate(_decodeBase36Pair(payload.substring(6, 8)));
        var directCapS5 = _normalizeDirectCapHeartRate(_decodeBase36Pair(payload.substring(8, 10)));

        if (
            directCapS1 == null or
            directCapS2 == null or
            directCapS3 == null or
            directCapS4 == null or
            directCapS5 == null
        ) {
            return config;
        }

        config[CFG_MODE] = MODE_CUSTOM;
        config[CFG_CODE_VALID] = true;
        config[CFG_DIRECT_CAP_S1] = directCapS1;
        config[CFG_DIRECT_CAP_S2] = directCapS2;
        config[CFG_DIRECT_CAP_S3] = directCapS3;
        config[CFG_DIRECT_CAP_S4] = directCapS4;
        config[CFG_DIRECT_CAP_S5] = directCapS5;
        return config;
    }

    function encodeCustomCode(
        directCapS1,
        directCapS2,
        directCapS3,
        directCapS4,
        directCapS5
    ) {
        var normalizedCapS1 = _normalizeDirectCapHeartRate(directCapS1);
        var normalizedCapS2 = _normalizeDirectCapHeartRate(directCapS2);
        var normalizedCapS3 = _normalizeDirectCapHeartRate(directCapS3);
        var normalizedCapS4 = _normalizeDirectCapHeartRate(directCapS4);
        var normalizedCapS5 = _normalizeDirectCapHeartRate(directCapS5);
        if (
            normalizedCapS1 == null or
            normalizedCapS2 == null or
            normalizedCapS3 == null or
            normalizedCapS4 == null or
            normalizedCapS5 == null
        ) {
            return null;
        }

        var payload =
            _encodeBase36Pair(normalizedCapS1) +
            _encodeBase36Pair(normalizedCapS2) +
            _encodeBase36Pair(normalizedCapS3) +
            _encodeBase36Pair(normalizedCapS4) +
            _encodeBase36Pair(normalizedCapS5);
        var checksum = _encodeBase36Pair(_computeChecksum(CODE_PREFIX + payload));
        return CODE_PREFIX + payload + checksum;
    }

    function getMode(config) {
        return _getConfigValue(config, CFG_MODE, MODE_CORE);
    }

    function isCustomMode(config) {
        return getMode(config) == MODE_CUSTOM;
    }

    function isCustomCode(config) {
        return getMode(config) == MODE_CUSTOM;
    }

    function isCodeValid(config) {
        return _getConfigValue(config, CFG_CODE_VALID, false);
    }

    function getDirectCapS1(config) {
        return _getConfigValue(config, CFG_DIRECT_CAP_S1, null);
    }

    function getDirectCapS2(config) {
        return _getConfigValue(config, CFG_DIRECT_CAP_S2, null);
    }

    function getDirectCapS3(config) {
        return _getConfigValue(config, CFG_DIRECT_CAP_S3, null);
    }

    function getDirectCapS4(config) {
        return _getConfigValue(config, CFG_DIRECT_CAP_S4, null);
    }

    function getDirectCapS5(config) {
        return _getConfigValue(config, CFG_DIRECT_CAP_S5, null);
    }

    function getDirectCapHeartRates(config) as Lang.Array {
        return [
            getDirectCapS1(config),
            getDirectCapS2(config),
            getDirectCapS3(config),
            getDirectCapS4(config),
            getDirectCapS5(config)
        ];
    }

    function getDirectCapHeartRate(config, phase) {
        if (phase == null) {
            return null;
        }
        if (phase == 0) {
            return getDirectCapS1(config);
        }
        if (phase == 1) {
            return getDirectCapS2(config);
        }
        if (phase == 2) {
            return getDirectCapS3(config);
        }
        if (phase == 3) {
            return getDirectCapS4(config);
        }
        if (phase == 4) {
            return getDirectCapS5(config);
        }
        return null;
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

    function _normalizeDirectCapHeartRate(value) {
        if (value == null) {
            return null;
        }
        try {
            if (value != value) {
                return null;
            }
        } catch (e) {
            return null;
        }

        var rounded = Math.floor(value + 0.5);
        if (rounded < MIN_DIRECT_CAP_BPM or rounded > MAX_DIRECT_CAP_BPM) {
            return null;
        }
        return rounded;
    }
}
