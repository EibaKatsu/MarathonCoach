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
        GateRaceData.loadRequestedRaceCodeFromProperties();
        _log(
            "onStart",
            "requested=" + GateRaceData.getRequestedRaceCode() +
            " selected=" + GateRaceData.getSelectedRaceCode() +
            " reason=" + GateRaceData.getSelectedRaceReason()
        );
    }

    function getInitialView() {
        return [new GateCheckerField()];
    }

    function onValidateProperty(key, value) {
        if (key == "raceCode") {
            GateRaceData.applyRaceCodeSelectionFromPropertyValue(value);
            _log(
                "onValidateProperty",
                "key=" + key +
                " value=" + value.toString() +
                " normalized=" + GateRaceData.getRequestedRaceCode()
            );
        }
        return true;
    }

    function onSettingsChanged() {
        GateRaceData.loadRequestedRaceCodeFromProperties();
        _log(
            "onSettingsChanged",
            "requested=" + GateRaceData.getRequestedRaceCode() +
            " selected=" + GateRaceData.getSelectedRaceCode() +
            " reason=" + GateRaceData.getSelectedRaceReason()
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
