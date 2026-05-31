using Toybox.Application as App;
using Toybox.Application.Properties as Props;
using Toybox.Lang as Lang;
using Toybox.System as Sys;

module GateSettingsLoader {
    const SETTINGS_DEBUG_LOG = true;

    function loadRaceCode() {
        var raceCode = loadPropertyString("raceCode");
        _log("loadRaceCode", "raceCode=" + _diag(raceCode));
        return raceCode;
    }

    function loadGateLapAdjustEnabled() {
        return loadPropertyBoolean("gateLapAdjustEnabled", false);
    }

    function loadSimulatorManualLapFallbackEnabled() {
        return loadPropertyBoolean("simulatorManualLapFallbackEnabled", false);
    }

    function loadPropertyString(key) {
        var value = getPropertyValue(key);
        if (value == null) {
            return "";
        }
        return value.toString();
    }

    function loadPropertyBoolean(key, defaultValue) {
        var value = getPropertyValue(key);
        if (value == null) {
            return defaultValue;
        }
        if (value instanceof Lang.Boolean) {
            return value;
        }

        var valueText = value.toString();
        if (valueText == "true" or valueText == "TRUE" or valueText == "1") {
            return true;
        }
        if (valueText == "false" or valueText == "FALSE" or valueText == "0") {
            return false;
        }
        return defaultValue;
    }

    function loadAppProperties() {
        _log(
            "loadAppProperties",
            "raceCode=" + _diag(getPropertyValue("raceCode")) +
            " gateLapAdjustEnabled=" + _diag(getPropertyValue("gateLapAdjustEnabled")) +
            " simulatorManualLapFallbackEnabled=" + _diag(getPropertyValue("simulatorManualLapFallbackEnabled"))
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
