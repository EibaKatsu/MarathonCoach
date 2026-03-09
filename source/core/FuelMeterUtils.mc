using Toybox.Math as Math;

module FuelMeterUtils {
    const STATE_NORMAL = 0;
    const STATE_CAUTION = 1;
    const STATE_WARNING = 2;

    const DISPLAY_COUNTDOWN = 0;
    const DISPLAY_DUE = 1;
    const DISPLAY_DONE_FLASH = 2;
    const DISPLAY_NO_PLAN = 3;
    const DISPLAY_DISABLED = 4;

    function resolveMeterState(fuelDisplayMode, fuelRemainingSec, fuelToggleLeadSec) {
        if (fuelDisplayMode == DISPLAY_DUE) {
            return STATE_WARNING;
        }
        if (fuelDisplayMode != DISPLAY_COUNTDOWN) {
            return STATE_NORMAL;
        }
        if (fuelRemainingSec != null and fuelRemainingSec <= fuelToggleLeadSec) {
            return STATE_CAUTION;
        }
        return STATE_NORMAL;
    }

    function resolveTrackColor(meterState, normalColor, cautionColor, warningColor) {
        if (meterState == STATE_WARNING) {
            return warningColor;
        }
        if (meterState == STATE_CAUTION) {
            return cautionColor;
        }
        return normalColor;
    }

    function resolveFillColor(meterState, normalColor, cautionColor, warningColor) {
        if (meterState == STATE_WARNING) {
            return warningColor;
        }
        if (meterState == STATE_CAUTION) {
            return cautionColor;
        }
        return normalColor;
    }

    function resolveProgressRatio(fuelDisplayMode, meterState, fuelRemainingSec, fuelIntervalSec) {
        if (fuelDisplayMode == DISPLAY_DISABLED) {
            return 0.0;
        }
        if (fuelDisplayMode == DISPLAY_DUE) {
            return 1.0;
        }
        if (fuelDisplayMode != DISPLAY_COUNTDOWN) {
            return 0.0;
        }
        if (meterState == STATE_WARNING) {
            return 1.0;
        }
        if (fuelRemainingSec == null) {
            return 0.0;
        }

        var remainingSec = clamp(fuelRemainingSec, 0, fuelIntervalSec);
        return clamp((remainingSec * 1.0) / (fuelIntervalSec * 1.0), 0.0, 1.0);
    }

    function resolveCenterText(
        fuelDisplayMode,
        meterState,
        fuelRemainingSec,
        fuelMeterMinuteSuffixText,
        fuelMeterDoneText,
        fuelMeterNoPlanText,
        fuelMeterWarningText
    ) {
        if (fuelDisplayMode == DISPLAY_DISABLED) {
            return null;
        }
        if (fuelDisplayMode == DISPLAY_DONE_FLASH) {
            return fuelMeterDoneText;
        }
        if (fuelDisplayMode == DISPLAY_NO_PLAN) {
            return fuelMeterNoPlanText;
        }
        if (meterState == STATE_WARNING) {
            return fuelMeterWarningText;
        }

        var remainingMin = resolveRemainingMin(fuelRemainingSec);
        if (remainingMin != null) {
            return remainingMin.format("%d") + fuelMeterMinuteSuffixText;
        }
        return "--";
    }

    function resolveWarningSubText(fuelDisplayMode, meterState, fuelMeterWarningSubText) {
        if (fuelDisplayMode == DISPLAY_DUE and meterState == STATE_WARNING) {
            return fuelMeterWarningSubText;
        }
        return null;
    }

    function resolveRemainingMin(fuelRemainingSec) {
        if (fuelRemainingSec == null) {
            return null;
        }

        var remainingSec = fuelRemainingSec;
        if (remainingSec < 0) {
            remainingSec = 0;
        }
        if (remainingSec == 0) {
            return 0;
        }
        return Math.floor((remainingSec + 59) / 60);
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
}
