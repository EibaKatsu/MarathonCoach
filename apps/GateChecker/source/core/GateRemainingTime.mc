using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;

module GateRemainingTime {
    const REASON_EMPTY = 0;
    const REASON_OK = 1;
    const REASON_CLOCK_UNAVAILABLE = 2;

    const CFG_HAS_REMAINING = 0;
    const CFG_REMAINING_SEC = 1;
    const CFG_REASON = 2;
    const CFG_CURRENT_CLOCK_SEC = 3;
    const CFG_CLOSE_CLOCK_SEC = 4;
    const CFG_CLOCK_TEXT = 5;

    function newDefaultConfig() as Lang.Array {
        return [false, null, REASON_EMPTY, null, null, null];
    }

    function computeRemainingTime(closeHour, closeMinute) as Lang.Array {
        var config = newDefaultConfig();
        if (closeHour == null or closeMinute == null) {
            return config;
        }

        var clockTime = null;
        try {
            clockTime = Sys.getClockTime();
        } catch (e) {
            clockTime = null;
        }
        if (clockTime == null) {
            config[CFG_REASON] = REASON_CLOCK_UNAVAILABLE;
            return config;
        }

        var currentClockSec = (clockTime.hour * 3600) + (clockTime.min * 60) + clockTime.sec;
        var closeClockSec = (closeHour * 3600) + (closeMinute * 60);

        config[CFG_HAS_REMAINING] = true;
        config[CFG_REMAINING_SEC] = closeClockSec - currentClockSec;
        config[CFG_REASON] = REASON_OK;
        config[CFG_CURRENT_CLOCK_SEC] = currentClockSec;
        config[CFG_CLOSE_CLOCK_SEC] = closeClockSec;
        config[CFG_CLOCK_TEXT] = _formatClockText(clockTime.hour, clockTime.min, clockTime.sec);
        return config;
    }

    function hasRemainingTime(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_HAS_REMAINING, false);
    }

    function isClockUnavailable(config) as Lang.Boolean {
        return _getConfigValue(config, CFG_REASON, REASON_EMPTY) == REASON_CLOCK_UNAVAILABLE;
    }

    function getReason(config) {
        var reasonCode = _getConfigValue(config, CFG_REASON, REASON_EMPTY);
        if (reasonCode == REASON_OK) {
            return "ok";
        }
        if (reasonCode == REASON_CLOCK_UNAVAILABLE) {
            return "clock_unavailable";
        }
        return "empty";
    }

    function getRemainingSec(config) {
        return _getConfigValue(config, CFG_REMAINING_SEC, null);
    }

    function getCurrentClockSec(config) {
        return _getConfigValue(config, CFG_CURRENT_CLOCK_SEC, null);
    }

    function getCloseClockSec(config) {
        return _getConfigValue(config, CFG_CLOSE_CLOCK_SEC, null);
    }

    function getClockText(config) {
        return _getConfigValue(config, CFG_CLOCK_TEXT, null);
    }

    function formatRemainingLabel(remainingSec) {
        if (remainingSec == null) {
            return "WAIT TIME";
        }

        var isOver = remainingSec < 0;
        var absSec = remainingSec;
        if (absSec < 0) {
            absSec = -absSec;
        }

        var totalMinutes = Math.floor((absSec + 59) / 60);
        var hourPart = Math.floor(totalMinutes / 60);
        var minPart = totalMinutes - (hourPart * 60);
        if (isOver) {
            return "OVER " + hourPart.format("%d") + ":" + minPart.format("%02d");
        }
        return "LEFT " + hourPart.format("%d") + ":" + minPart.format("%02d");
    }

    function formatRemainingFact(remainingSec) {
        if (remainingSec == null) {
            return "WAIT TIME";
        }

        var isLate = remainingSec < 0;
        var absSec = remainingSec;
        if (absSec < 0) {
            absSec = -absSec;
        }

        var totalMinutes = Math.floor((absSec + 59) / 60);
        var hourPart = Math.floor(totalMinutes / 60);
        var minPart = totalMinutes - (hourPart * 60);
        if (isLate) {
            return "LATE " + hourPart.format("%d") + ":" + minPart.format("%02d");
        }
        return hourPart.format("%d") + ":" + minPart.format("%02d");
    }

    function formatCurrentClockHourMinute(config) {
        var currentClockSec = getCurrentClockSec(config);
        if (currentClockSec == null) {
            return captureCurrentClockHourMinuteText();
        }

        var hourPart = Math.floor(currentClockSec / 3600);
        var minPart = Math.floor((currentClockSec - (hourPart * 3600)) / 60);
        return hourPart.format("%02d") + ":" + minPart.format("%02d");
    }

    function captureCurrentClockHourMinuteText() {
        var clockTime = null;
        try {
            clockTime = Sys.getClockTime();
        } catch (e) {
            clockTime = null;
        }
        if (clockTime == null) {
            return "--:--";
        }
        return clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d");
    }

    function _formatClockText(hourPart, minutePart, secondPart) {
        return hourPart.format("%02d") + ":" + minutePart.format("%02d") + ":" + secondPart.format("%02d");
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
