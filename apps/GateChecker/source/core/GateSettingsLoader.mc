using Toybox.Application.Properties as Props;

module GateSettingsLoader {
    function loadGateCode(key) {
        return loadStringProperty(key);
    }

    function loadCourseCode() {
        return loadStringProperty("courseCode");
    }

    function loadStringProperty(key) {
        var value = getPropertyValue(key);
        if (value == null) {
            return "";
        }
        return value.toString();
    }

    function getPropertyValue(key) {
        try {
            return Props.getValue(key);
        } catch (e) {
            return null;
        }
    }
}
