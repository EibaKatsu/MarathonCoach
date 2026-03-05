using Toybox.Application.Properties as Props;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MarathonCoachField extends Ui.DataField {
    const KEY_RACE_DISTANCE_KM = "race_distance_km";
    const KEY_TARGET_TIME_HMS = "target_time_hms";
    const LAYOUT_DEBUG_OVERLAY = false;

    const DEFAULT_RACE_DISTANCE_KM = 42.195;
    const DEFAULT_TARGET_TIME_HMS = "05:00:00";

    var _statusText = "STEP3 LAYOUT";
    var _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
    var _targetTimeHms = DEFAULT_TARGET_TIME_HMS;
    var _paceNowSecPerKm = null;
    var _paceNowText = "--:--";
    var _paceSampleMs as Lang.Array = [];
    var _paceSampleSecPerKm as Lang.Array = [];

    function initialize() {
        DataField.initialize();
        _statusText = Ui.loadResource(Rez.Strings.Step3Status);
        _loadSettings();
    }

    function compute(info) {
        // Step 2 settings + Step 4 pace window update.
        _loadSettings();
        _updatePaceWindow(info);
        return;
    }

    function onUpdate(dc as Gfx.Dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        _drawStep3Layout(dc);
    }

    function _loadSettings() {
        _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
        _targetTimeHms = DEFAULT_TARGET_TIME_HMS;

        var raceDistance = Props.getValue(KEY_RACE_DISTANCE_KM);
        if (raceDistance != null and raceDistance instanceof Number and raceDistance > 0) {
            _raceDistanceKm = raceDistance;
        }

        var targetTime = Props.getValue(KEY_TARGET_TIME_HMS);
        if (targetTime != null) {
            var targetTimeText = targetTime.toString();
            if (targetTimeText.length() > 0) {
                _targetTimeHms = targetTimeText;
            }
        }
    }

    function _drawStep3Layout(dc as Gfx.Dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var minDim = _min(width, height);
        var sizeClass = _getSizeClass(minDim);

        var insetPct = 7;
        var hrFont = Gfx.FONT_TINY;
        var cardFont = Gfx.FONT_SMALL;
        var paceFont = Gfx.FONT_LARGE;
        var footerFont = Gfx.FONT_SMALL;
        var paceDeltaFont = Gfx.FONT_TINY;
        var fuelLabelFont = Gfx.FONT_XTINY;
        var fuelTimeFont = Gfx.FONT_SMALL;
        var fuelRadiusPct = 46;

        if (sizeClass == 2) {
            insetPct = 9;
            hrFont = Gfx.FONT_XTINY;
            cardFont = Gfx.FONT_TINY;
            paceFont = Gfx.FONT_LARGE;
            footerFont = Gfx.FONT_SMALL;
            paceDeltaFont = Gfx.FONT_TINY;
            fuelLabelFont = Gfx.FONT_TINY;
            fuelTimeFont = Gfx.FONT_MEDIUM;
            fuelRadiusPct = 50;
        } else if (sizeClass == 0) {
            insetPct = 6;
            hrFont = Gfx.FONT_XTINY;
            cardFont = Gfx.FONT_TINY;
            paceFont = Gfx.FONT_MEDIUM;
            footerFont = Gfx.FONT_TINY;
            paceDeltaFont = Gfx.FONT_XTINY;
            fuelRadiusPct = 44;
        }

        // Use an inscribed square area so round displays keep consistent composition.
        var squareSize = _clamp((minDim * (100 - (insetPct * 2))) / 100, (minDim * 70) / 100, minDim);
        var left = (width - squareSize) / 2;
        var top = (height - squareSize) / 2;
        var right = left + squareSize;
        var bottomY = top + squareSize;
        var centerX = left + (squareSize / 2);

        var row1Y = top + (squareSize / 4);
        var row2Y = top + ((squareSize * 2) / 4);
        var row3Y = top + ((squareSize * 3) / 4);

        var leftColX = left;
        var leftColW = centerX - leftColX;
        var rightColX = centerX;
        var rightColW = right - rightColX;
        var rowHeight = squareSize / 4;
        var row12Height = row2Y - top;
        var row4Height = bottomY - row3Y;

        // 1st row left: HR/CAP
        var hrY = _textYByRatio(top, rowHeight, 66, dc.getFontHeight(hrFont));
        dc.drawText(
            leftColX + (leftColW / 2),
            hrY,
            hrFont,
            "152 / 155",
            Gfx.TEXT_JUSTIFY_CENTER
        );

        // Right col row1-2 span: FUEL ring
        var fuelRadius = _clamp(
            _min((rightColW * fuelRadiusPct) / 100, (row12Height * fuelRadiusPct) / 100),
            20,
            (minDim * 28) / 100
        );
        var fuelCenterX = rightColX + fuelRadius - _clamp((squareSize * 1) / 100, 2, 6);
        var maxFuelCenterX = right - fuelRadius - 2;
        if (fuelCenterX > maxFuelCenterX) {
            fuelCenterX = maxFuelCenterX;
        }
        var fuelCenterY = top + (row12Height / 2);
        var fuelLabelY = _textYByRatio(
            fuelCenterY - fuelRadius,
            fuelRadius * 2,
            31,
            dc.getFontHeight(fuelLabelFont)
        );
        var fuelTimeY = _textYByRatio(
            fuelCenterY - fuelRadius,
            fuelRadius * 2,
            60,
            dc.getFontHeight(fuelTimeFont)
        );

        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        dc.fillCircle(fuelCenterX, fuelCenterY, fuelRadius);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLUE);
        dc.drawText(fuelCenterX, fuelLabelY, fuelLabelFont, "FUEL", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(fuelCenterX, fuelTimeY, fuelTimeFont, "6:20", Gfx.TEXT_JUSTIFY_CENTER);

        // Left col row2-3 span: coach card
        var cardInset = _clamp((squareSize * 2) / 100, 2, 10);
        var cardX = leftColX + cardInset;
        var cardY = row1Y + cardInset;
        var cardW = leftColW - (cardInset * 2);
        var cardH = (row3Y - row1Y) - (cardInset * 2);
        var cardCorner = _clamp(cardW / 8, 10, 26);
        var cardFontH = dc.getFontHeight(cardFont);
        var cardGap = _max((cardH - (cardFontH * 3)) / 4, 1);
        var cardLine1Y = cardY + cardGap;
        var cardLine2Y = cardLine1Y + cardFontH + cardGap;
        var cardLine3Y = cardLine2Y + cardFontH + cardGap;

        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        dc.fillRoundedRectangle(cardX, cardY, cardW, cardH, cardCorner);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLUE);
        dc.drawText(cardX + (cardW / 2), cardLine1Y, cardFont, "EASE", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(cardX + (cardW / 2), cardLine2Y, cardFont, "DOWN", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(cardX + (cardW / 2), cardLine3Y, cardFont, "v -10s", Gfx.TEXT_JUSTIFY_CENTER);

        // 3rd row right: pace
        var paceY = row2Y;
        var paceUnitY = _textYByRatio(row2Y, rowHeight, 86, dc.getFontHeight(Gfx.FONT_XTINY));
        var paceUnitX = rightColX + rightColW - _clamp((rightColW * 4) / 100, 4, 12);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.drawText(
            rightColX + (rightColW / 2),
            paceY,
            paceFont,
            _paceNowText,
            Gfx.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            paceUnitX,
            paceUnitY,
            Gfx.FONT_XTINY,
            "/km",
            Gfx.TEXT_JUSTIFY_RIGHT
        );

        // 4th row: DIST / TIME + PACE delta
        var mergedY = _textYByRatio(row3Y, row4Height, 24, dc.getFontHeight(footerFont));
        var paceDeltaY = _textYByRatio(row3Y, row4Height, 70, dc.getFontHeight(paceDeltaFont));
        dc.drawText(width / 2, mergedY, footerFont, "22.3 km  2:33:12", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, paceDeltaY, paceDeltaFont, "PACE +10s", Gfx.TEXT_JUSTIFY_CENTER);

        if (LAYOUT_DEBUG_OVERLAY) {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
            dc.drawLine(centerX, top, centerX, bottomY);
            dc.drawLine(left, row1Y, right, row1Y);
            dc.drawLine(left, row2Y, right, row2Y);
            dc.drawLine(left, row3Y, right, row3Y);
        }
    }

    function _min(a, b) {
        if (a < b) {
            return a;
        }
        return b;
    }

    function _max(a, b) {
        if (a > b) {
            return a;
        }
        return b;
    }

    function _getSizeClass(minDim) {
        if (minDim >= 261) {
            return 2; // large
        }
        if (minDim <= 218) {
            return 0; // small
        }
        return 1; // medium
    }

    function _updatePaceWindow(info) {
        var nowMs = Sys.getTimer();
        var samplePaceSecPerKm = _extractPaceSecPerKm(info);

        if (samplePaceSecPerKm != null) {
            _paceSampleMs.add(nowMs);
            _paceSampleSecPerKm.add(samplePaceSecPerKm);
        }

        var keepWindowMs = 10000;
        while (_paceSampleMs.size() > 0 and (nowMs - _paceSampleMs[0]) > keepWindowMs) {
            _paceSampleMs.remove(0);
            _paceSampleSecPerKm.remove(0);
        }

        if (_paceSampleSecPerKm.size() == 0) {
            _paceNowSecPerKm = null;
            _paceNowText = "--:--";
            return;
        }

        var sumPace = 0.0;
        for (var i = 0; i < _paceSampleSecPerKm.size(); i += 1) {
            sumPace += _paceSampleSecPerKm[i];
        }

        _paceNowSecPerKm = sumPace / _paceSampleSecPerKm.size();
        _paceNowText = _formatPaceSecPerKm(_paceNowSecPerKm);
    }

    function _extractPaceSecPerKm(info) {
        if (info == null or info.currentSpeed == null) {
            return null;
        }

        var speedMps = info.currentSpeed;
        if (speedMps <= 0) {
            return null;
        }

        var paceSecPerKm = 1000.0 / speedMps;
        // Reject clearly invalid GPS/sensor spikes.
        if (paceSecPerKm < 120 or paceSecPerKm > 1200) {
            return null;
        }

        return paceSecPerKm;
    }

    function _formatPaceSecPerKm(paceSecPerKm) {
        var roundedSec = Math.floor(paceSecPerKm + 0.5);
        var minPart = Math.floor(roundedSec / 60);
        var secPart = roundedSec - (minPart * 60);
        return minPart.format("%d") + ":" + secPart.format("%02d");
    }

    function _textYByRatio(blockTop, blockHeight, ratioPct, fontHeight) {
        return blockTop + ((blockHeight * ratioPct) / 100) - (fontHeight / 2);
    }

    function _clamp(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }
}
