using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using GateRaceData;
using GateSettingsLoader;

class GateCheckerApp extends App.AppBase {
    const SETTINGS_DEBUG_LOG = true;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        GateSettingsLoader.loadAppProperties();
        GateRaceData.loadRequestedCourseCodeFromProperties();
        _log(
            "onStart",
            "requested=" + GateRaceData.getRequestedCourseCode() +
            " selected=" + GateRaceData.getSelectedCourseCode() +
            " reason=" + GateRaceData.getSelectedCourseReason()
        );
    }

    function getInitialView() {
        return [new GateCheckerField()];
    }

    function onValidateProperty(key, value) {
        if (key == "courseIndex") {
            var courseCode = GateRaceData.applyCourseSelectionFromPropertyValue(value);
            _log(
                "onValidateProperty",
                "key=" + key +
                " value=" + value.toString() +
                " mappedCourse=" + courseCode
            );
            GateSettingsLoader.saveCourseCode(courseCode);
        }
        return true;
    }

    function onSettingsChanged() {
        GateRaceData.loadRequestedCourseCodeFromProperties();
        _log(
            "onSettingsChanged",
            "requested=" + GateRaceData.getRequestedCourseCode() +
            " selected=" + GateRaceData.getSelectedCourseCode() +
            " reason=" + GateRaceData.getSelectedCourseReason()
        );
        Ui.requestUpdate();
    }

    function _log(tag, message) {
        if (!SETTINGS_DEBUG_LOG) {
            return;
        }
        Sys.println("[GATE_APP] " + tag + " " + message);
    }
}
