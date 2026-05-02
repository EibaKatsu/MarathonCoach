using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;

module GateDistanceUtils {
    const DISPLAY_UNIT_KM = "km";
    const DISPLAY_UNIT_MI = "mi";
    const KM_PER_MILE = 1.609344;
    const DISTANCE_PARTS_VALUE = 0;
    const DISTANCE_PARTS_UNIT = 1;

    function extractElapsedDistanceKm(info) {
        var rawDistanceM = (info != null) ? info.elapsedDistance : null;
        if (!_isNumericValue(rawDistanceM)) {
            return null;
        }
        if (rawDistanceM < 0) {
            return null;
        }
        return rawDistanceM / 1000.0;
    }

    function formatDistanceKm(distanceKm) {
        return formatDistance(distanceKm);
    }

    function formatDistance(distanceKm) {
        var parts = formatCompactDistanceParts(distanceKm);
        return parts[DISTANCE_PARTS_VALUE] + " " + parts[DISTANCE_PARTS_UNIT];
    }

    function formatCompactDistanceKm(distanceKm) {
        return formatCompactDistance(distanceKm);
    }

    function formatCompactDistance(distanceKm) {
        var parts = formatCompactDistanceParts(distanceKm);
        return parts[DISTANCE_PARTS_VALUE] + parts[DISTANCE_PARTS_UNIT];
    }

    function formatCompactDistanceKmValue(distanceKm) {
        return formatCompactDistanceValue(distanceKm);
    }

    function formatCompactDistanceValue(distanceKm) {
        return formatCompactDistanceParts(distanceKm)[DISTANCE_PARTS_VALUE];
    }

    function formatCompactDistanceParts(distanceKm) {
        var unitSetting = _getDistanceUnitsSetting();
        var unit = _distanceUnitsSettingToDisplayUnit(unitSetting);
        if (distanceKm == null) {
            return ["--.-", unit];
        }

        return [_formatTenthDistance(_convertKmToDisplayDistance(distanceKm, unitSetting)), unit];
    }

    function formatDistanceTenthKm(distanceTenthKm) {
        if (distanceTenthKm == null) {
            return "--.- " + getDisplayDistanceUnit();
        }
        return formatDistanceKm(distanceTenthKm / 10.0);
    }

    function formatCompactDistanceTenthKm(distanceTenthKm) {
        if (distanceTenthKm == null) {
            return "--.-" + getDisplayDistanceUnit();
        }
        return formatCompactDistanceKm(distanceTenthKm / 10.0);
    }

    function formatCompactDistanceTenthKmValue(distanceTenthKm) {
        if (distanceTenthKm == null) {
            return "--.-";
        }
        return formatCompactDistanceKmValue(distanceTenthKm / 10.0);
    }

    function formatLiveDistanceKm(distanceKm) {
        return formatLiveDistance(distanceKm);
    }

    function formatLiveDistance(distanceKm) {
        var parts = formatLiveDistanceParts(distanceKm);
        return parts[DISTANCE_PARTS_VALUE] + parts[DISTANCE_PARTS_UNIT];
    }

    function formatLiveDistanceKmValue(distanceKm) {
        return formatLiveDistanceValue(distanceKm);
    }

    function formatLiveDistanceValue(distanceKm) {
        return formatLiveDistanceParts(distanceKm)[DISTANCE_PARTS_VALUE];
    }

    function formatLiveDistanceParts(distanceKm) {
        var unitSetting = _getDistanceUnitsSetting();
        var unit = _distanceUnitsSettingToDisplayUnit(unitSetting);
        if (distanceKm == null) {
            return ["--.--", unit];
        }

        var displayDistance = _convertKmToDisplayDistance(distanceKm, unitSetting);
        if (displayDistance < 1.0) {
            return [_formatHundredthDistance(displayDistance), unit];
        }
        return [_formatTenthDistance(displayDistance), unit];
    }

    function getDisplayDistanceUnit() {
        return _distanceUnitsSettingToDisplayUnit(_getDistanceUnitsSetting());
    }

    function formatCloseTime(closeHour, closeMinute) {
        if (closeHour == null or closeMinute == null) {
            return "--:--";
        }
        return closeHour.format("%02d") + ":" + closeMinute.format("%02d");
    }

    function _isNumericValue(value) {
        return value != null and (
            value instanceof Lang.Number or
            value instanceof Lang.Float or
            value instanceof Lang.Double or
            value instanceof Lang.Long
        );
    }

    function _convertKmToDisplayDistance(distanceKm, unitSetting) {
        if (distanceKm == null) {
            return null;
        }
        if (unitSetting == Sys.UNIT_STATUTE) {
            return distanceKm / KM_PER_MILE;
        }
        return distanceKm;
    }

    function _getDistanceUnitsSetting() {
        try {
            var deviceSettings = Sys.getDeviceSettings();
            if (deviceSettings != null) {
                return deviceSettings.distanceUnits;
            }
        } catch (e) {
        }
        return Sys.UNIT_METRIC;
    }

    function _distanceUnitsSettingToDisplayUnit(unitSetting) {
        if (unitSetting == Sys.UNIT_STATUTE) {
            return DISPLAY_UNIT_MI;
        }
        return DISPLAY_UNIT_KM;
    }

    function _formatTenthDistance(distance) {
        var roundedTenth = Math.floor((distance * 10.0) + 0.5);
        if (roundedTenth < 0) {
            roundedTenth = 0;
        }
        var whole = Math.floor(roundedTenth / 10);
        var decimal = roundedTenth - (whole * 10);
        return whole.format("%d") + "." + decimal.format("%d");
    }

    function _formatHundredthDistance(distance) {
        var roundedHundredth = Math.floor((distance * 100.0) + 0.5);
        if (roundedHundredth < 0) {
            roundedHundredth = 0;
        }
        var wholePart = Math.floor(roundedHundredth / 100);
        var fracPart = roundedHundredth - (wholePart * 100);
        return wholePart.format("%d") + "." + fracPart.format("%02d");
    }
}
