using Toybox.Application.Properties as Props;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MarathonCoachField extends Ui.DataField {
    const KEY_RACE_DISTANCE_KM = "race_distance_km";
    const KEY_TARGET_TIME_HMS = "target_time_hms";

    const DEFAULT_RACE_DISTANCE_KM = 42.195;
    const DEFAULT_TARGET_TIME_HMS = "05:00:00";

    var _statusText = "STEP2 SETTINGS";
    var _raceDistanceKm = DEFAULT_RACE_DISTANCE_KM;
    var _targetTimeHms = DEFAULT_TARGET_TIME_HMS;

    function initialize() {
        DataField.initialize();
        _statusText = Ui.loadResource(Rez.Strings.Step2Status);
        _loadSettings();
    }

    function compute(info) {
        // Step 2: load and reflect settings values.
        _loadSettings();
        return;
    }

    function onUpdate(dc as Gfx.Dc) {
        var centerX = dc.getWidth() / 2;

        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);

        dc.drawText(
            centerX,
            8,
            Gfx.FONT_TINY,
            _statusText,
            Gfx.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(centerX, 34, Gfx.FONT_SMALL, "DIST " + _raceDistanceKm.toString() + "km", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 58, Gfx.FONT_SMALL, "GOAL " + _targetTimeHms, Gfx.TEXT_JUSTIFY_CENTER);
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
}
