using Toybox.Application.Properties as Props;
using Toybox.Graphics as Gfx;
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

    function initialize() {
        DataField.initialize();
        _statusText = Ui.loadResource(Rez.Strings.Step3Status);
        _loadSettings();
    }

    function compute(info) {
        // Step 2: load and reflect settings values.
        _loadSettings();
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

        var outerPadding = _clamp((minDim * 5) / 100, 8, 16);
        var left = outerPadding;
        var top = outerPadding;
        var safeWidth = width - (outerPadding * 2);
        var safeHeight = height - (outerPadding * 2);
        var centerX = left + (safeWidth / 2);

        var row1Y = top + (safeHeight / 4);
        var row2Y = top + ((safeHeight * 2) / 4);
        var row3Y = top + ((safeHeight * 3) / 4);
        var bottomY = top + safeHeight;

        var leftColX = left;
        var leftColW = centerX - leftColX;
        var rightColX = centerX;
        var rightColW = (left + safeWidth) - rightColX;

        // 1st row left: HR/CAP
        dc.drawText(
            leftColX + (leftColW / 2),
            top + 28,
            Gfx.FONT_TINY,
            "152 / 155",
            Gfx.TEXT_JUSTIFY_CENTER
        );

        // Right col row1-2 span: FUEL ring
        var fuelSpanTop = top;
        var fuelSpanBottom = row2Y;
        var fuelCenterY = fuelSpanTop + ((fuelSpanBottom - fuelSpanTop) / 2);
        var fuelRadius = _clamp((_min(rightColW, fuelSpanBottom - fuelSpanTop) / 2) - 6, 20, 58);
        // Move slightly left so the circle just crosses the center guide line.
        var fuelCenterX = rightColX + fuelRadius - 2;

        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        dc.fillCircle(fuelCenterX, fuelCenterY, fuelRadius);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLUE);
        dc.drawText(fuelCenterX, fuelCenterY - 20, Gfx.FONT_XTINY, "FUEL", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(fuelCenterX, fuelCenterY + 2, Gfx.FONT_SMALL, "6:20", Gfx.TEXT_JUSTIFY_CENTER);

        // Left col row2-3 span: coach card
        var cardX = leftColX + 4;
        var cardY = row1Y + 4;
        var cardW = leftColW - 8;
        var cardH = (row3Y - row1Y) - 8;
        var cardCorner = _clamp(cardW / 8, 10, 26);

        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
        dc.fillRoundedRectangle(cardX, cardY, cardW, cardH, cardCorner);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLUE);
        dc.drawText(cardX + (cardW / 2), cardY + 7, Gfx.FONT_SMALL, "EASE", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(cardX + (cardW / 2), cardY + 37, Gfx.FONT_SMALL, "DOWN", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(cardX + (cardW / 2), cardY + cardH - 38, Gfx.FONT_SMALL, "v -10s", Gfx.TEXT_JUSTIFY_CENTER);

        // 3rd row right: pace
        var paceTop = row2Y;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.drawText(
            rightColX + (rightColW / 2),
            paceTop + 16,
            Gfx.FONT_MEDIUM,
            "7:21",
            Gfx.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            rightColX + rightColW - 6,
            row3Y - 18,
            Gfx.FONT_XTINY,
            "/km",
            Gfx.TEXT_JUSTIFY_RIGHT
        );

        // 4th row: DIST / TIME + PACE delta
        var row4CenterY = row3Y + ((bottomY - row3Y) / 2);
        dc.drawText(width / 2, row3Y + 4, Gfx.FONT_SMALL, "22.3 km  2:33:12", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, row4CenterY + 8, Gfx.FONT_TINY, "PACE +10s", Gfx.TEXT_JUSTIFY_CENTER);

        if (LAYOUT_DEBUG_OVERLAY) {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
            dc.drawLine(centerX, top, centerX, bottomY);
            dc.drawLine(left, row1Y, left + safeWidth, row1Y);
            dc.drawLine(left, row2Y, left + safeWidth, row2Y);
            dc.drawLine(left, row3Y, left + safeWidth, row3Y);
        }
    }

    function _min(a, b) {
        if (a < b) {
            return a;
        }
        return b;
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
