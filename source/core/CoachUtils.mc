using Toybox.Lang as Lang;
using Toybox.Math as Math;

module CoachUtils {
    function formatHourMinuteSecond(hourPart, minutePart) {
        return hourPart.format("%02d") + ":" + minutePart.format("%02d") + ":00";
    }

    function mapRaceDistanceIndexToKm(index) {
        if (index == 0) {
            return 42.195;
        }
        if (index == 1) {
            return 21.0975;
        }
        if (index == 2) {
            return 10.0;
        }
        if (index == 3) {
            return 5.0;
        }
        return null;
    }

    function containsNonAscii(text) as Lang.Boolean {
        if (text == null) {
            return false;
        }

        var chars = text.toString().toCharArray();
        if (!(chars instanceof Lang.Array)) {
            return false;
        }
        for (var i = 0; i < chars.size(); i += 1) {
            var ch = chars[i];
            if (ch != null and ch instanceof Lang.Char and ch.toNumber() > 127) {
                return true;
            }
        }
        return false;
    }

    function splitWords(text) as Lang.Array {
        var words = [];
        var remaining = text;

        while (remaining != null and remaining.length() > 0) {
            var spaceIndex = remaining.find(" ");
            if (spaceIndex == null) {
                if (remaining.length() > 0) {
                    words.add(remaining);
                }
                break;
            }

            if (spaceIndex > 0) {
                words.add(remaining.substring(0, spaceIndex));
            }

            if ((spaceIndex + 1) >= remaining.length()) {
                break;
            }
            remaining = remaining.substring(spaceIndex + 1, remaining.length());
            while (remaining.length() > 0 and remaining.substring(0, 1) == " ") {
                if (remaining.length() == 1) {
                    remaining = "";
                    break;
                }
                remaining = remaining.substring(1, remaining.length());
            }
            if (remaining.length() == 0) {
                break;
            } else {
                continue;
            }
        }

        return words;
    }

    function randomMessageIndex(size, avoid1, avoid2) {
        if (size <= 0) {
            return 0;
        }

        var idx = 0;
        for (var i = 0; i < 10; i += 1) {
            idx = Math.floor(Math.rand()) % size;
            if (idx < 0) {
                idx += size;
            }
            if (idx != avoid1 and idx != avoid2) {
                return idx;
            }
        }

        for (var j = 0; j < size; j += 1) {
            if (j != avoid1 and j != avoid2) {
                return j;
            }
        }
        return 0;
    }

    function parseTimeToSec(text) {
        if (text == null) {
            return null;
        }

        var raw = normalizeTimeText(text.toString());
        if (raw.length() == 0) {
            return null;
        }

        var p1 = raw.find(":");
        if (p1 == null or p1 < 0) {
            return null;
        }

        var tail = raw.substring(p1 + 1, raw.length());
        var p2rel = tail.find(":");
        var hourText = raw.substring(0, p1);
        var minText = "";
        var secText = "0";
        if (p2rel == null or p2rel < 0) {
            minText = tail;
        } else {
            var p2 = p1 + 1 + p2rel;
            minText = raw.substring(p1 + 1, p2);
            secText = raw.substring(p2 + 1, raw.length());
        }

        var h = parsePositiveInt(hourText);
        var m = parsePositiveInt(minText);
        var s = parsePositiveInt(secText);
        if (h == null or m == null or s == null) {
            return null;
        }
        if (m >= 60 or s >= 60) {
            return null;
        }
        return (h * 3600) + (m * 60) + s;
    }

    function parsePositiveInt(text) {
        var rawText = normalizeTimeText(text);
        if (rawText == null or rawText.length() == 0) {
            return null;
        }

        var value = 0;
        for (var i = 0; i < rawText.length(); i += 1) {
            var ch = rawText.substring(i, i + 1);
            var digit = digitValue(ch);
            if (digit == null) {
                return null;
            }
            value = (value * 10) + digit;
        }
        return value;
    }

    function parsePositiveDecimal(text) {
        var rawText = normalizeTimeText(text);
        if (rawText == null or rawText.length() == 0) {
            return null;
        }

        var intPart = 0;
        var fracPart = 0.0;
        var fracDivisor = 1.0;
        var seenDot = false;
        var hasDigit = false;

        for (var i = 0; i < rawText.length(); i += 1) {
            var ch = rawText.substring(i, i + 1);
            if (ch == "." or ch == "．") {
                if (seenDot) {
                    return null;
                }
                seenDot = true;
                continue;
            }

            var digit = digitValue(ch);
            if (digit == null) {
                return null;
            }

            hasDigit = true;
            if (!seenDot) {
                intPart = (intPart * 10) + digit;
            } else {
                fracPart = (fracPart * 10.0) + digit;
                fracDivisor *= 10.0;
            }
        }

        if (!hasDigit) {
            return null;
        }
        return intPart + (fracPart / fracDivisor);
    }

    function normalizeTimeText(text) {
        if (text == null) {
            return "";
        }

        var raw = text.toString();
        var normalized = "";
        for (var i = 0; i < raw.length(); i += 1) {
            var ch = raw.substring(i, i + 1);
            if (ch == "：" or ch == "∶") {
                normalized += ":";
                continue;
            }

            var asciiDigit = fullWidthDigitToAscii(ch);
            if (asciiDigit != null) {
                normalized += asciiDigit;
                continue;
            }
            normalized += ch;
        }

        var start = 0;
        while (start < normalized.length()) {
            var first = normalized.substring(start, start + 1);
            if (first != " " and first != "\t" and first != "　") {
                break;
            }
            start += 1;
        }

        var endExclusive = normalized.length();
        while (endExclusive > start) {
            var last = normalized.substring(endExclusive - 1, endExclusive);
            if (last != " " and last != "\t" and last != "　") {
                break;
            }
            endExclusive -= 1;
        }

        if (start >= endExclusive) {
            return "";
        }
        return normalized.substring(start, endExclusive);
    }

    function fullWidthDigitToAscii(ch) {
        if (ch == "０") { return "0"; }
        if (ch == "１") { return "1"; }
        if (ch == "２") { return "2"; }
        if (ch == "３") { return "3"; }
        if (ch == "４") { return "4"; }
        if (ch == "５") { return "5"; }
        if (ch == "６") { return "6"; }
        if (ch == "７") { return "7"; }
        if (ch == "８") { return "8"; }
        if (ch == "９") { return "9"; }
        return null;
    }

    function digitValue(ch) {
        if (ch == "0") { return 0; }
        if (ch == "1") { return 1; }
        if (ch == "2") { return 2; }
        if (ch == "3") { return 3; }
        if (ch == "4") { return 4; }
        if (ch == "5") { return 5; }
        if (ch == "6") { return 6; }
        if (ch == "7") { return 7; }
        if (ch == "8") { return 8; }
        if (ch == "9") { return 9; }
        return null;
    }

    function formatPaceSecPerKm(paceSecPerKm) {
        var roundedSec = Math.floor(paceSecPerKm + 0.5);
        var minPart = Math.floor(roundedSec / 60);
        var secPart = roundedSec - (minPart * 60);
        return minPart.format("%d") + ":" + secPart.format("%02d");
    }

    function formatMinSec(totalSec) {
        var roundedSec = Math.floor(totalSec + 0.5);
        var minPart = Math.floor(roundedSec / 60);
        var secPart = roundedSec - (minPart * 60);
        return minPart.format("%d") + ":" + secPart.format("%02d");
    }

    function formatElapsedTime(totalSec) {
        var sec = Math.floor(totalSec);
        if (sec < 0) {
            sec = 0;
        }
        var hourPart = Math.floor(sec / 3600);
        var remain = sec - (hourPart * 3600);
        var minPart = Math.floor(remain / 60);
        var secPart = remain - (minPart * 60);
        return hourPart.format("%d") + ":" + minPart.format("%02d") + ":" + secPart.format("%02d");
    }

    function formatDistanceKm(distanceKm) {
        var roundedTenth = Math.floor((distanceKm * 10.0) + 0.5);
        if (roundedTenth < 0) {
            roundedTenth = 0;
        }
        var kmWhole = Math.floor(roundedTenth / 10);
        var kmDecimal = roundedTenth - (kmWhole * 10);
        return kmWhole.format("%d") + "." + kmDecimal.format("%d") + " km";
    }

    function formatHourMin(totalSec) {
        if (totalSec == null) {
            return "--:--";
        }

        var roundedTotalMinutes = Math.floor((totalSec + 30.0) / 60.0);
        if (roundedTotalMinutes < 0) {
            roundedTotalMinutes = 0;
        }
        var hourPart = Math.floor(roundedTotalMinutes / 60);
        var minPart = roundedTotalMinutes - (hourPart * 60);
        return hourPart.format("%d") + ":" + minPart.format("%02d");
    }

    function textYByRatio(blockTop, blockHeight, ratioPct, fontHeight) {
        return blockTop + ((blockHeight * ratioPct) / 100) - (fontHeight / 2);
    }

    function min(a, b) {
        if (a < b) {
            return a;
        }
        return b;
    }

    function max(a, b) {
        if (a > b) {
            return a;
        }
        return b;
    }

    function clamp(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }

    function abs(value) {
        if (value < 0) {
            return -value;
        }
        return value;
    }
}
