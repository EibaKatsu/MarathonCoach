using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using GateRaceData;
using GateSettingsLoader;

class GateCheckerApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        GateSettingsLoader.loadAppProperties();
        GateRaceData.loadRequestedCourseCodeFromProperties();
    }

    function getInitialView() {
        return [new GateCheckerField()];
    }

    function onValidateProperty(key, value) {
        if (key == "courseIndex") {
            var courseCode = GateRaceData.applyCourseSelectionFromPropertyValue(value);
            GateSettingsLoader.saveCourseCode(courseCode);
        }
        return true;
    }

    function onSettingsChanged() {
        GateRaceData.loadRequestedCourseCodeFromProperties();
        Ui.requestUpdate();
    }
}
