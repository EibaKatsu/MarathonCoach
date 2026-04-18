using Toybox.Lang as Lang;
using GateCodeChecksum;

module GateCodeDecoder {
    const HEADER_LEN = 4;
    const GATE_BLOCK_LEN = 8;
    const CHECKSUM_LEN = 2;

    const CFG_DECODED = 0;
    const CFG_GATES = 1;
    const CFG_REASON = 2;
    const CFG_DECODED_COUNT = 3;

    const GATE_DISTANCE_TENTH_KM = 0;
    const GATE_CLOSE_HOUR = 1;
    const GATE_CLOSE_MINUTE = 2;

    function newDefaultConfig() as Lang.Array {
        return [false, [], "empty", 0];
    }

    function decodeGateList(normalizedCode, gateCount) as Lang.Array {
        var config = newDefaultConfig();
        if (normalizedCode == null) {
            config[CFG_REASON] = "null";
            return config;
        }
        if (gateCount == null or gateCount <= 0) {
            config[CFG_REASON] = "gate_count_invalid";
            return config;
        }

        var codeText = normalizedCode.toString();
        if (codeText.length() < HEADER_LEN) {
            config[CFG_REASON] = "too_short_for_payload";
            return config;
        }
        var expectedLength = HEADER_LEN + (gateCount * GATE_BLOCK_LEN) + CHECKSUM_LEN;
        if (codeText.length() != expectedLength) {
            config[CFG_REASON] = "length_mismatch";
            return config;
        }

        var payloadEnd = expectedLength - CHECKSUM_LEN;
        var codeWithoutChecksum = codeText.substring(0, payloadEnd);
        var checksumText = codeText.substring(payloadEnd, expectedLength);
        if (!GateCodeChecksum.isChecksumMatch(codeWithoutChecksum, checksumText)) {
            config[CFG_REASON] = "checksum_mismatch";
            return config;
        }

        var gates = [];
        for (var i = 0; i < gateCount; i += 1) {
            var blockStart = HEADER_LEN + (i * GATE_BLOCK_LEN);
            var blockEnd = blockStart + GATE_BLOCK_LEN;
            if (blockEnd > codeText.length()) {
                config[CFG_REASON] = "gate_block_shortage";
                config[CFG_GATES] = gates;
                config[CFG_DECODED_COUNT] = gates.size();
                return config;
            }

            var block = codeText.substring(blockStart, blockEnd);
            var gate = _decodeGateBlock(block);
            if (gate == null) {
                config[CFG_REASON] = "gate_block_invalid";
                config[CFG_GATES] = gates;
                config[CFG_DECODED_COUNT] = gates.size();
                return config;
            }
            gates.add(gate);
        }

        config[CFG_DECODED] = true;
        config[CFG_GATES] = gates;
        config[CFG_REASON] = "ok";
        config[CFG_DECODED_COUNT] = gates.size();
        return config;
    }

    function isDecoded(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_DECODED, false);
    }

    function getReason(config) {
        return _getConfigValue(config, CFG_REASON, "unknown");
    }

    function getGates(config) as Lang.Array {
        return _getConfigValue(config, CFG_GATES, []);
    }

    function getDecodedCount(config) {
        return _getConfigValue(config, CFG_DECODED_COUNT, 0);
    }

    function getGateDistanceTenthKm(gate) {
        return _getGateValue(gate, GATE_DISTANCE_TENTH_KM);
    }

    function getGateCloseHour(gate) {
        return _getGateValue(gate, GATE_CLOSE_HOUR);
    }

    function getGateCloseMinute(gate) {
        return _getGateValue(gate, GATE_CLOSE_MINUTE);
    }

    function formatGateSummary(gate) {
        if (gate == null) {
            return "null";
        }

        var distanceTenthKm = getGateDistanceTenthKm(gate);
        var closeHour = getGateCloseHour(gate);
        var closeMinute = getGateCloseMinute(gate);
        if (distanceTenthKm == null or closeHour == null or closeMinute == null) {
            return "invalid";
        }

        var kmWhole = distanceTenthKm / 10;
        var kmFrac = distanceTenthKm % 10;
        return kmWhole.format("%d") + "." + kmFrac.format("%d") + "km@" + closeHour.format("%02d") + ":" + closeMinute.format("%02d");
    }

    function _decodeGateBlock(block as Lang.String) {
        if (block.length() != GATE_BLOCK_LEN) {
            return null;
        }

        var distanceTenthKm = _parseFixedDigits(block.substring(0, 4));
        var closeHour = _parseFixedDigits(block.substring(4, 6));
        var closeMinute = _parseFixedDigits(block.substring(6, 8));
        if (distanceTenthKm == null or closeHour == null or closeMinute == null) {
            return null;
        }
        if (closeHour < 0 or closeHour > 23 or closeMinute < 0 or closeMinute > 59) {
            return null;
        }

        return [distanceTenthKm, closeHour, closeMinute];
    }

    function _parseFixedDigits(text as Lang.String) {
        if (text == null or text.length() == 0) {
            return null;
        }

        var value = 0;
        for (var i = 0; i < text.length(); i += 1) {
            var digit = _digitValue(text.substring(i, i + 1));
            if (digit == null) {
                return null;
            }
            value = (value * 10) + digit;
        }
        return value;
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

    function _getGateValue(gate, index) {
        if (gate == null or !(gate instanceof Lang.Array)) {
            return null;
        }
        if (index < 0 or index >= gate.size()) {
            return null;
        }
        return gate[index];
    }
}
