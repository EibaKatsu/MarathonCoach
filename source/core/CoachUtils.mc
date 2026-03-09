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
            var ch = rawText.substring(i, i + 1).toString();
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

        var dotPos = rawText.find(".");
        var fullDotPos = rawText.find("．");
        if (dotPos != null and dotPos >= 0 and fullDotPos != null and fullDotPos >= 0) {
            return null;
        }
        if (dotPos == null or dotPos < 0) {
            dotPos = fullDotPos;
        }

        if (dotPos == null or dotPos < 0) {
            return parsePositiveInt(rawText);
        }

        var tail = rawText.substring(dotPos + 1, rawText.length());
        if (tail.find(".") != null or tail.find("．") != null) {
            return null;
        }

        var intText = rawText.substring(0, dotPos);
        var fracText = rawText.substring(dotPos + 1, rawText.length());
        if (intText.length() == 0 and fracText.length() == 0) {
            return null;
        }

        var intPart = 0;
        if (intText.length() > 0) {
            intPart = parsePositiveInt(intText);
            if (intPart == null) {
                return null;
            }
        }

        if (fracText.length() == 0) {
            return intPart * 1.0;
        }

        var fracPartInt = parsePositiveInt(fracText);
        if (fracPartInt == null) {
            return null;
        }

        var divisor = 1.0;
        for (var i = 0; i < fracText.length(); i += 1) {
            divisor *= 10.0;
        }
        return intPart + (fracPartInt / divisor);
    }

    function normalizeTimeText(text) {
        if (text == null) {
            return "";
        }

        var raw = text.toString();
        var chars = raw.toCharArray();
        if (!(chars instanceof Lang.Array)) {
            return raw;
        }

        var start = 0;
        while (start < chars.size()) {
            var firstCode = chars[start].toNumber();
            if (firstCode != 32 and firstCode != 9 and firstCode != 12288) {
                break;
            }
            start += 1;
        }

        var endExclusive = chars.size();
        while (endExclusive > start) {
            var lastCode = chars[endExclusive - 1].toNumber();
            if (lastCode != 32 and lastCode != 9 and lastCode != 12288) {
                break;
            }
            endExclusive -= 1;
        }

        if (start >= endExclusive) {
            return "";
        }

        var normalized = "";
        for (var i = start; i < endExclusive; i += 1) {
            var ch = chars[i];
            if (ch == null) {
                continue;
            }

            var code = ch.toNumber();
            if (code == 65306 or code == 8758) {
                normalized += ":";
                continue;
            }
            if (code == 65294) {
                normalized += ".";
                continue;
            }
            if (code >= 65296 and code <= 65305) {
                normalized += (code - 65296).format("%d");
                continue;
            }
            normalized += ch.toString();
        }
        return normalized;
    }

    function fullWidthDigitToAscii(ch) {
        if (ch == null) {
            return null;
        }

        var raw = ch.toString();
        if (raw.length() != 1) {
            return null;
        }

        var fullWidthDigits = "０１２３４５６７８９";
        var idx = fullWidthDigits.find(raw);
        if (idx == null or idx < 0) {
            return null;
        }
        return idx.format("%d");
    }

    function digitValue(ch) {
        if (ch == null) {
            return null;
        }

        var raw = ch.toString();
        if (raw.length() != 1) {
            return null;
        }

        var asciiDigits = "0123456789";
        var idx = asciiDigits.find(raw);
        if (idx == null or idx < 0) {
            return null;
        }
        return idx;
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
