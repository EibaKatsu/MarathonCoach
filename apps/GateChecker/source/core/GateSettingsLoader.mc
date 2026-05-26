using Toybox.Application as App;
using Toybox.Application.Properties as Props;
using Toybox.System as Sys;

module GateSettingsLoader {
    const SETTINGS_DEBUG_LOG = true;

    function loadRaceCode() {
        var raceCode = loadPropertyString("raceCode");
        _log("loadRaceCode", "raceCode=" + _diag(raceCode));
        return raceCode;
    }

    function loadCourseCode() {
        var courseCode = loadPropertyString("courseCode");
        _log("loadCourseCode", "courseCode=" + _diag(courseCode));
        return courseCode;
    }

    function loadSelectionCode() {
        var raceCode = loadPropertyString("raceCode");
        var courseCode = loadPropertyString("courseCode");
        var selectionCode = raceCode;
        if (selectionCode.length() <= 0) {
            selectionCode = courseCode;
        }
        _log(
            "loadSelectionCode",
            "raceCode=" + _diag(raceCode) +
            " courseCode=" + _diag(courseCode) +
            " selected=" + _diag(selectionCode)
        );
        return selectionCode;
    }

    function loadPropertyString(key) {
        var value = getPropertyValue(key);
        if (value == null) {
            return "";
        }
        return value.toString();
    }

    function loadAppProperties() {
        _log(
            "loadAppProperties",
            "raceCode=" + _diag(getPropertyValue("raceCode")) +
            " courseCode=" + _diag(getPropertyValue("courseCode")) +
            " courseIndex=" + _diag(getPropertyValue("courseIndex"))
        );
    }

    function getPropertyValue(key) {
        try {
            return Props.getValue(key);
        } catch (e) {
            _log("getPropertyValue", "key=" + key + " error=" + e.toString());
        }
        return null;
    }

    function _log(tag, message) {
        if (!SETTINGS_DEBUG_LOG) {
            return;
        }
        Sys.println("[GATE_SETTINGS] " + tag + " " + message);
    }

    function _diag(value) {
        if (value == null) {
            return "null";
        }
        return value.toString();
    }
}
