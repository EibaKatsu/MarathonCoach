using Toybox.Application.Properties as Props;
using Toybox.Lang as Lang;
using Toybox.Math as Math;

module SettingsLoader {
    function loadRaceDistanceKm(defaultRaceDistanceKm, raceDistanceKey) {
        var raceDistance = getPropertyValue(raceDistanceKey);
        if (raceDistance == null) {
            return defaultRaceDistanceKm;
        }

        var parsedDistance = null;
        if (_isNumericValue(raceDistance)) {
            parsedDistance = raceDistance;
        } else {
            parsedDistance = CoachUtils.parsePositiveDecimal(raceDistance.toString());
        }

        if (parsedDistance == null or parsedDistance <= 0) {
            return defaultRaceDistanceKm;
        }
        var rounded = Math.floor(parsedDistance + 0.5);
        var raceDistanceKm = parsedDistance;
        if (CoachUtils.abs(parsedDistance - rounded) < 0.001) {
            var mapped = CoachUtils.mapRaceDistanceIndexToKm(rounded);
            if (mapped != null and mapped > 0) {
                raceDistanceKm = mapped;
            }
        }
        return raceDistanceKm;
    }

    function loadTargetTimeHour(targetHourKey) {
        var hour = loadIntSettingValue(targetHourKey);
        if (hour == null or hour < 0 or hour > 8) {
            return null;
        }
        return hour;
    }

    function loadTargetTimeMinute(targetMinuteKey) {
        var minute = loadIntSettingValue(targetMinuteKey);
        if (minute == null or minute < 0 or minute > 59) {
            return null;
        }
        return minute;
    }

    function loadIntSettingValue(key) {
        var value = getPropertyValue(key);
        if (value == null) {
            return null;
        }

        if (_isNumericValue(value)) {
            return Math.floor(value + 0.5);
        }

        var parsed = CoachUtils.parsePositiveInt(value.toString());
        if (parsed == null) {
            var parsedDecimal = CoachUtils.parsePositiveDecimal(value.toString());
            if (parsedDecimal == null) {
                return null;
            }
            return Math.floor(parsedDecimal + 0.5);
        }
        return parsed;
    }

    function getPropertyValue(key) {
        try {
            return Props.getValue(key);
        } catch (e) {
            return null;
        }
    }

    function _isNumericValue(value) {
        return value != null and (
            value instanceof Lang.Number or
            value instanceof Lang.Float or
            value instanceof Lang.Double or
            value instanceof Lang.Long
        );
    }
}
