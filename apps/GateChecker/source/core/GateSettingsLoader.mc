using Toybox.Application as App;

module GateSettingsLoader {
    function loadGateCode(key) {
        return loadPropertyString(key);
    }

    function loadCourseCode() {
        return loadPropertyString("courseCode");
    }

    function saveCourseCode(courseCode) {
        if (courseCode == null or courseCode.length() <= 0) {
            return;
        }
        try {
            var app = App.getApp();
            if (app != null) {
                app.setProperty("courseCode", courseCode);
                app.saveProperties();
            }
        } catch (e) {
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
            }
        } catch (e) {
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
}
