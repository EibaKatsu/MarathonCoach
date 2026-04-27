using Toybox.Lang as Lang;
using Toybox.Math as Math;

module GateDistanceUtils {
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
        if (distanceKm == null) {
            return "--.- km";
        }

        var roundedTenth = Math.floor((distanceKm * 10.0) + 0.5);
        if (roundedTenth < 0) {
            roundedTenth = 0;
        }
        var kmWhole = Math.floor(roundedTenth / 10);
        var kmDecimal = roundedTenth - (kmWhole * 10);
        return kmWhole.format("%d") + "." + kmDecimal.format("%d") + " km";
    }

    function formatCompactDistanceKm(distanceKm) {
        if (distanceKm == null) {
            return "--.-km";
        }

        return formatCompactDistanceKmValue(distanceKm) + "km";
    }

    function formatCompactDistanceKmValue(distanceKm) {
        if (distanceKm == null) {
            return "--.-";
        }

        var roundedTenth = Math.floor((distanceKm * 10.0) + 0.5);
        if (roundedTenth < 0) {
            roundedTenth = 0;
        }
        var kmWhole = Math.floor(roundedTenth / 10);
        var kmDecimal = roundedTenth - (kmWhole * 10);
        return kmWhole.format("%d") + "." + kmDecimal.format("%d");
    }

    function formatDistanceTenthKm(distanceTenthKm) {
        if (distanceTenthKm == null) {
            return "--.- km";
        }
        return formatDistanceKm(distanceTenthKm / 10.0);
    }

    function formatCompactDistanceTenthKm(distanceTenthKm) {
        if (distanceTenthKm == null) {
            return "--.-km";
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
        if (distanceKm == null) {
            return "--.--km";
        }
        return formatLiveDistanceKmValue(distanceKm) + "km";
    }

    function formatLiveDistanceKmValue(distanceKm) {
        if (distanceKm == null) {
            return "--.--";
        }
        if (distanceKm < 1.0) {
            var roundedHundredth = Math.floor((distanceKm * 100.0) + 0.5);
            if (roundedHundredth < 0) {
                roundedHundredth = 0;
            }
            var wholePart = Math.floor(roundedHundredth / 100);
            var fracPart = roundedHundredth - (wholePart * 100);
            return wholePart.format("%d") + "." + fracPart.format("%02d");
        }
        return formatCompactDistanceKmValue(distanceKm);
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
}
