using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using GateRaceData;

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

    function computeRemainingTime(closeDayOffset, closeMinuteOfDay) as Lang.Array {
        var config = newDefaultConfig();
        if (closeDayOffset == null or closeMinuteOfDay == null) {
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

        var currentDayOffset = _computeCurrentRaceDayOffset(clockTime);
        var currentClockSec = (currentDayOffset * 86400) + (clockTime.hour * 3600) + (clockTime.min * 60) + clockTime.sec;
        var closeClockSec = (closeDayOffset * 86400) + (closeMinuteOfDay * 60);

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
            return Ui.loadResource(Rez.Strings.WaitTime);
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
            return Ui.loadResource(Rez.Strings.PaceStateOver) + " " + hourPart.format("%d") + ":" + minPart.format("%02d");
        }
        return Ui.loadResource(Rez.Strings.LeftLabel) + " " + hourPart.format("%d") + ":" + minPart.format("%02d");
    }

    function formatRemainingFact(remainingSec) {
        if (remainingSec == null) {
            return Ui.loadResource(Rez.Strings.WaitTime);
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
            return Ui.loadResource(Rez.Strings.LateLabel) + " " + hourPart.format("%d") + ":" + minPart.format("%02d");
        }
        return hourPart.format("%d") + ":" + minPart.format("%02d");
    }

    function formatRemainingDuration(remainingSec) {
        if (remainingSec == null) {
            return "--:--";
        }

        var absSec = remainingSec;
        if (absSec < 0) {
            absSec = -absSec;
        }

        var totalMinutes = Math.floor((absSec + 59) / 60);
        var hourPart = Math.floor(totalMinutes / 60);
        var minPart = totalMinutes - (hourPart * 60);
        return hourPart.format("%d") + ":" + minPart.format("%02d");
    }

    function formatCurrentClockHourMinute(config) {
        var currentClockSec = getCurrentClockSec(config);
        if (currentClockSec == null) {
            return captureCurrentClockHourMinuteText();
        }

        return _formatClockHourMinute(currentClockSec);
    }

    function computeEtaClockText(config, remainingDistanceKm, paceSecPerKm) {
        var currentClockSec = getCurrentClockSec(config);
        if (currentClockSec == null or remainingDistanceKm == null or paceSecPerKm == null) {
            return null;
        }
        if (remainingDistanceKm <= 0 or paceSecPerKm <= 0) {
            return null;
        }

        var travelSec = Math.floor((remainingDistanceKm * paceSecPerKm) + 0.5);
        return _formatClockHourMinute(currentClockSec + travelSec);
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

    function _computeCurrentRaceDayOffset(clockTime) {
        if (clockTime == null) {
            return 0;
        }

        var currentYear = null;
        var currentMonth = null;
        var currentDay = null;
        if (clockTime has :year) {
            currentYear = clockTime.year;
        }
        if (clockTime has :month) {
            currentMonth = clockTime.month;
        }
        if (clockTime has :day) {
            currentDay = clockTime.day;
        }

        var currentDays = _daysFromCivil(currentYear, currentMonth, currentDay);
        var raceDays = _daysFromCivil(
            GateRaceData.getRaceYear(),
            GateRaceData.getRaceMonth(),
            GateRaceData.getRaceDay()
        );
        if (currentDays == null or raceDays == null) {
            return 0;
        }
        return currentDays - raceDays;
    }

    function _formatClockText(hourPart, minutePart, secondPart) {
        return hourPart.format("%02d") + ":" + minutePart.format("%02d") + ":" + secondPart.format("%02d");
    }

    function _formatClockHourMinute(clockSec) {
        if (clockSec == null) {
            return "--:--";
        }

        while (clockSec < 0) {
            clockSec += 86400;
        }
        while (clockSec >= 86400) {
            clockSec -= 86400;
        }

        var hourPart = Math.floor(clockSec / 3600);
        var minPart = Math.floor((clockSec - (hourPart * 3600)) / 60);
        return hourPart.format("%02d") + ":" + minPart.format("%02d");
    }

    function _daysFromCivil(yearPart, monthPart, dayPart) {
        if (yearPart == null or monthPart == null or dayPart == null) {
            return null;
        }

        var adjustedYear = yearPart;
        if (monthPart <= 2) {
            adjustedYear -= 1;
        }

        var era = Math.floor(adjustedYear / 400);
        var yearOfEra = adjustedYear - (era * 400);
        var monthPrime = monthPart;
        if (monthPrime > 2) {
            monthPrime -= 3;
        } else {
            monthPrime += 9;
        }

        var dayOfYear = Math.floor(((153 * monthPrime) + 2) / 5) + dayPart - 1;
        var dayOfEra = (yearOfEra * 365) +
            Math.floor(yearOfEra / 4) -
            Math.floor(yearOfEra / 100) +
            dayOfYear;
        return (era * 146097) + dayOfEra - 719468;
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
