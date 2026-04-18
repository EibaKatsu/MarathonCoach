using Toybox.Lang as Lang;
using Toybox.Math as Math;

module GateCodeChecksum {
    const BASE36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const BASE36_PAIR_RADIX = 36;
    const BASE36_PAIR_MOD = 1296;

    function computeChecksumText(text) as Lang.String {
        return _encodeBase36Pair(_computeChecksumValue(text));
    }

    function isChecksumMatch(text, checksumText) as Lang.Boolean {
        if (text == null or checksumText == null) {
            return false;
        }
        return _stringEquals(checksumText.toString(), computeChecksumText(text));
    }

    function _computeChecksumValue(text) {
        if (text == null) {
            return 0;
        }

        var sum = 0;
        var textValue = text.toString();
        for (var i = 0; i < textValue.length(); i += 1) {
            var digitValue = _base36Index(textValue.substring(i, i + 1));
            if (digitValue == null) {
                continue;
            }
            sum += (i + 1) * digitValue;
        }
        return sum % BASE36_PAIR_MOD;
    }

    function _encodeBase36Pair(value) as Lang.String {
        var clamped = value;
        if (clamped == null) {
            clamped = 0;
        }
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

    function _stringEquals(a, b) as Lang.Boolean {
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
