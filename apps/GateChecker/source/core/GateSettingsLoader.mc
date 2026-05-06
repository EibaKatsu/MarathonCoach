using Toybox.Application as App;
using Toybox.System as Sys;

module GateSettingsLoader {
    const SETTINGS_DEBUG_LOG = true;

    function loadGateCode(key) {
        return loadPropertyString(key);
    }

    function loadCourseIndex() {
        var courseIndex = parseNonNegativeInteger(loadPropertyString("courseIndex"));
        _log("loadCourseIndex", "courseIndex=" + _diag(courseIndex));
        return courseIndex;
    }

    function loadCourseCode() {
        var courseCode = loadPropertyString("courseCode");
        _log("loadCourseCode", "courseCode=" + _diag(courseCode));
        return courseCode;
    }

    function saveCourseCode(courseCode) {
        if (courseCode == null or courseCode.length() <= 0) {
            _log("saveCourseCode", "skip empty");
            return;
        }
        try {
            var app = App.getApp();
            if (app != null) {
                app.setProperty("courseCode", courseCode);
                app.saveProperties();
                _log("saveCourseCode", "saved courseCode=" + _diag(courseCode));
            }
        } catch (e) {
            _log("saveCourseCode", "error=" + e.toString());
        }
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
                    "courseIndex=" + _diag(getPropertyValue("courseIndex")) +
                    " courseCode=" + _diag(getPropertyValue("courseCode"))
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

    function parseNonNegativeInteger(text) {
        if (text == null or text.length() <= 0) {
            return null;
        }
        var chars = text.toCharArray();
        if (chars == null or chars.size() <= 0) {
            return null;
        }
        var value = 0;
        for (var i = 0; i < chars.size(); i += 1) {
            var digit = chars[i].toNumber() - 48;
            if (digit < 0 or digit > 9) {
                return null;
            }
            value = (value * 10) + digit;
        }
        return value;
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
