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
            "raceCode=" + _diag(getPropertyValue("raceCode"))
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
