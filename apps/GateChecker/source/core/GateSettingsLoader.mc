using Toybox.Application as App;
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
        try {
            var app = App.getApp();
            if (app != null) {
                app.loadProperties();
                _log(
                    "loadAppProperties",
                    "raceCode=" + _diag(getPropertyValue("raceCode"))
                );
            }
        } catch (e) {
            _log("loadAppProperties", "error=" + e.toString());
        }
    }

    function getPropertyValue(key) {
        try {
            var app = App.getApp();
            if (app != null) {
                return app.getProperty(key);
            }
        } catch (e) {
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
