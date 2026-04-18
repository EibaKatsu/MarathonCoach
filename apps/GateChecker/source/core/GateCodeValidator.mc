using Toybox.Lang as Lang;

module GateCodeValidator {
    const CODE_PREFIX = "G1";
    const HEADER_LEN = 4;
    const GATE_BLOCK_LEN = 8;
    const CHECKSUM_LEN = 2;

    const CFG_CODE_VALID = 0;
    const CFG_NORMALIZED_CODE = 1;
    const CFG_GATE_COUNT = 2;
    const CFG_REASON = 3;
    const CFG_MINIMUM_LENGTH = 4;
    const CFG_ACTUAL_LENGTH = 5;

    function newDefaultConfig() as Lang.Array {
        return [false, "", null, "empty", null, null];
    }

    function inspectGateCode(rawCode) as Lang.Array {
        var config = newDefaultConfig();
        if (rawCode == null) {
            config[CFG_REASON] = "null";
            return config;
        }

        var rawText = rawCode.toString();
        if (rawText.length() == 0) {
            config[CFG_REASON] = "empty";
            return config;
        }
        var normalized = _normalizeCode(rawText);
        config[CFG_NORMALIZED_CODE] = normalized;
        config[CFG_ACTUAL_LENGTH] = normalized.length();
        if (normalized.length() < CODE_PREFIX.length()) {
            config[CFG_REASON] = "too_short_for_prefix";
            return config;
        }
        if (!_hasGateCodePrefix(normalized)) {
            config[CFG_REASON] = "prefix_mismatch";
            return config;
        }
        if (normalized.length() < (HEADER_LEN + CHECKSUM_LEN)) {
            config[CFG_REASON] = "too_short_for_header";
            return config;
        }

        var gateCount = _parseTwoDigitCount(normalized.substring(2, 4));
        config[CFG_GATE_COUNT] = gateCount;
        if (gateCount == null or gateCount <= 0) {
            config[CFG_REASON] = "gate_count_invalid";
            return config;
        }

        var minimumLength = HEADER_LEN + (gateCount * GATE_BLOCK_LEN) + CHECKSUM_LEN;
        config[CFG_MINIMUM_LENGTH] = minimumLength;
        if (normalized.length() < minimumLength) {
            config[CFG_REASON] = "length_shortage";
            return config;
        }

        config[CFG_CODE_VALID] = true;
        config[CFG_REASON] = "ok";
        return config;
    }

    function isCodeValid(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_CODE_VALID, false);
    }

    function getNormalizedCode(config) {
        return _getConfigValue(config, CFG_NORMALIZED_CODE, "");
    }

    function getGateCount(config) {
        return _getConfigValue(config, CFG_GATE_COUNT, null);
    }

    function getReason(config) {
        return _getConfigValue(config, CFG_REASON, "unknown");
    }

    function getMinimumLength(config) {
        return _getConfigValue(config, CFG_MINIMUM_LENGTH, null);
    }

    function getActualLength(config) {
        return _getConfigValue(config, CFG_ACTUAL_LENGTH, null);
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

    function _normalizeCode(rawCode as Lang.String) as Lang.String {
        var normalized = "";
        for (var i = 0; i < rawCode.length(); i += 1) {
            var chText = rawCode.substring(i, i + 1);
            if (chText == "-") {
                continue;
            }
            normalized += chText;
        }

        return normalized;
    }

    function _parseTwoDigitCount(text as Lang.String) {
        if (text.length() != 2) {
            return null;
        }

        var firstDigit = _digitValue(text.substring(0, 1));
        var secondDigit = _digitValue(text.substring(1, 2));
        if (firstDigit == null or secondDigit == null) {
            return null;
        }
        return (firstDigit * 10) + secondDigit;
    }

    function _digitValue(ch as Lang.String) {
        if (ch == null or ch.length() != 1) {
            return null;
        }

        var index = "0123456789".find(ch);
        if (index == null or index < 0) {
            return null;
        }
        return index;
    }

    function _hasGateCodePrefix(text as Lang.String) as Lang.Boolean {
        var chars = text.toCharArray();
        if (!(chars instanceof Lang.Array) or chars.size() < 2) {
            return false;
        }
        return chars[0].toNumber() == 71 and chars[1].toNumber() == 49;
    }
}
