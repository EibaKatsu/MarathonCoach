using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.WatchUi as Ui;
using GateDistanceUtils;
using GateSettingsLoader;

module GateRaceData {
    const GATE_POINT = 0;
    const GATE_CUTOFF_DAY_OFFSET = 1;
    const GATE_CUTOFF_MINUTE_OF_DAY = 2;

    const COURSE_CODE = 0;
    const COURSE_NAME_JPN = 1;
    const COURSE_NAME_ENG = 2;
    const COURSE_DISTANCE_KM = 3;
    const COURSE_GATES = 4;
    const COURSE_AIDS = 5;

    const RESOLVED_COURSE = 0;
    const RESOLVED_REQUESTED_CODE = 1;
    const RESOLVED_REASON = 2;

    function getRaceNameJpn() {
        return GateRaceConfig.getRaceNameJpn();
    }

    function getRaceNameEng() {
        return GateRaceConfig.getRaceNameEng();
    }

    function getRaceKey() {
        return GateRaceConfig.getRaceKey();
    }

    function getSelectedCourseCode() {
        var course = _getResolvedCourse();
        return _getCourseValue(course, COURSE_CODE);
    }

    function getSelectedCourseNameJpn() {
        var course = _getResolvedCourse();
        var courseName = _getCourseValue(course, COURSE_NAME_JPN);
        if (courseName == null or courseName.length() <= 0) {
            return "NO COURSE";
        }
        return courseName;
    }

    function getSelectedCourseNameEng() {
        var course = _getResolvedCourse();
        var courseName = _getCourseValue(course, COURSE_NAME_ENG);
        if (courseName == null or courseName.length() <= 0) {
            return "NO COURSE";
        }
        return courseName;
    }

    function getPreStartCourseNameJpn() {
        var course = _getDefaultOrFirstCourse();
        var courseName = _getCourseValue(course, COURSE_NAME_JPN);
        if (courseName == null or courseName.length() <= 0) {
            return "NO COURSE";
        }
        return courseName;
    }

    function getPreStartCourseNameEng() {
        var course = _getDefaultOrFirstCourse();
        var courseName = _getCourseValue(course, COURSE_NAME_ENG);
        if (courseName == null or courseName.length() <= 0) {
            return "NO COURSE";
        }
        return courseName;
    }

    function getSelectedCourseReason() {
        var reason = _getResolvedCourseStateValue(RESOLVED_REASON);
        if (reason == null) {
            return "no_courses";
        }
        return reason;
    }

    function getRequestedCourseCode() {
        var requestedCourseCode = _getResolvedCourseStateValue(RESOLVED_REQUESTED_CODE);
        if (requestedCourseCode == null) {
            return "";
        }
        return requestedCourseCode;
    }

    function getCourseCount() {
        var courses = GateRaceConfig.getCourses();
        if (courses == null or !(courses instanceof Lang.Array)) {
            return 0;
        }
        return courses.size();
    }

    function getRaceDistanceKm() {
        var course = _getResolvedCourse();
        return _getCourseValue(course, COURSE_DISTANCE_KM);
    }

    function getRaceYear() {
        return GateRaceConfig.getRaceYear();
    }

    function getRaceMonth() {
        return GateRaceConfig.getRaceMonth();
    }

    function getRaceDay() {
        return GateRaceConfig.getRaceDay();
    }

    function getGates() as Lang.Array {
        var course = _getResolvedCourse();
        var gates = _getCourseValue(course, COURSE_GATES);
        if (gates == null or !(gates instanceof Lang.Array)) {
            return [];
        }
        return gates;
    }

    function getAids() as Lang.Array {
        var course = _getResolvedCourse();
        var aids = _getCourseValue(course, COURSE_AIDS);
        if (aids == null or !(aids instanceof Lang.Array)) {
            return [];
        }
        return aids;
    }

    function isGoalPoint(point) as Lang.Boolean {
        return point == GateRaceConfig.GOAL;
    }

    function isGoalGate(gate) as Lang.Boolean {
        return isGoalPoint(_getGateValue(gate, GATE_POINT));
    }

    function getGateDistanceKm(gate) {
        var pointMeters = getGateDistanceMeters(gate);
        if (pointMeters == null) {
            return null;
        }
        return pointMeters / 1000.0;
    }

    function getGateDistanceMeters(gate) {
        var point = _getGateValue(gate, GATE_POINT);
        if (point == null) {
            return null;
        }
        if (isGoalPoint(point)) {
            return _distanceKmToMeters(getRaceDistanceKm());
        }
        return point;
    }

    function getGateDistanceTenthKm(gate) {
        var distanceMeters = getGateDistanceMeters(gate);
        if (distanceMeters == null) {
            return null;
        }
        return Math.floor((distanceMeters / 100.0) + 0.5);
    }

    function getGateDisplayValue(gate) {
        return getGateDisplayParts(gate)[0];
    }

    function getGateDisplayUnit(gate) {
        return getGateDisplayParts(gate)[1];
    }

    function getGateDisplayParts(gate) {
        if (isGoalGate(gate)) {
            return [Ui.loadResource(Rez.Strings.GoalLabel), ""];
        }
        return GateDistanceUtils.formatCompactDistanceParts(getGateDistanceKm(gate));
    }

    function getGateCutoffDayOffset(gate) {
        return _getGateValue(gate, GATE_CUTOFF_DAY_OFFSET);
    }

    function getGateCutoffMinuteOfDay(gate) {
        return _getGateValue(gate, GATE_CUTOFF_MINUTE_OF_DAY);
    }

    function getGateCloseHour(gate) {
        var minuteOfDay = getGateCutoffMinuteOfDay(gate);
        if (minuteOfDay == null) {
            return null;
        }
        return Math.floor(minuteOfDay / 60);
    }

    function getGateCloseMinute(gate) {
        var minuteOfDay = getGateCutoffMinuteOfDay(gate);
        var closeHour = getGateCloseHour(gate);
        if (minuteOfDay == null or closeHour == null) {
            return null;
        }
        return minuteOfDay - (closeHour * 60);
    }

    function formatGateSummary(gate) {
        if (gate == null) {
            return "null";
        }

        return getGateDisplayValue(gate) +
            getGateDisplayUnit(gate) +
            "@" +
            GateDistanceUtils.formatCloseTime(
                getGateCloseHour(gate),
                getGateCloseMinute(gate)
            );
    }

    function getAidDistanceKm(aid) {
        var aidDistanceMeters = getAidDistanceMeters(aid);
        if (aidDistanceMeters == null) {
            return null;
        }
        return aidDistanceMeters / 1000.0;
    }

    function getAidDistanceMeters(aid) {
        if (aid == null) {
            return null;
        }
        return aid;
    }

    function getAidDisplayValue(aid) {
        return getAidDisplayParts(aid)[0];
    }

    function getAidDisplayUnit(aid) {
        return getAidDisplayParts(aid)[1];
    }

    function getAidDisplayParts(aid) {
        return GateDistanceUtils.formatCompactDistanceParts(getAidDistanceKm(aid));
    }

    function resetSelectedCourseCache() {
        // Course selection is resolved from the latest properties on demand.
    }

    function getCourseCodeForPropertyValue(propertyValue) {
        var courseIndex = _parseCourseIndex(propertyValue);
        if (courseIndex == null) {
            return null;
        }
        var courses = GateRaceConfig.getCourses();
        if (courses == null or !(courses instanceof Lang.Array)) {
            return null;
        }
        for (var i = 0; i < courses.size(); i += 1) {
            if (i == courseIndex) {
                return _getCourseValue(courses[i], COURSE_CODE);
            }
        }
        return null;
    }

    function _getDefaultOrFirstCourse() {
        var courses = GateRaceConfig.getCourses();
        if (courses == null or !(courses instanceof Lang.Array) or courses.size() <= 0) {
            return null;
        }
        if (courses.size() == 1) {
            return courses[0];
        }
        var defaultCourse = _findCourseByCode(courses, GateRaceConfig.getDefaultCourseCode());
        if (defaultCourse != null) {
            return defaultCourse;
        }
        return courses[0];
    }

    function _getResolvedCourse() {
        return _getResolvedCourseStateValue(RESOLVED_COURSE);
    }

    function _getResolvedCourseStateValue(index) {
        var state = _resolveSelectedCourseState();
        if (state == null or !(state instanceof Lang.Array)) {
            return null;
        }
        if (index < 0 or index >= state.size()) {
            return null;
        }
        return state[index];
    }

    function _resolveSelectedCourseState() {
        var courses = GateRaceConfig.getCourses();
        if (courses == null or !(courses instanceof Lang.Array) or courses.size() <= 0) {
            return [null, "", "no_courses"];
        }
        if (courses.size() == 1) {
            return [
                courses[0],
                _getCourseValue(courses[0], COURSE_CODE),
                "single_course"
            ];
        }

        var requestedCourseCode = _normalizeCourseCode(GateSettingsLoader.loadCourseCode());
        if (requestedCourseCode.length() > 0) {
            var requestedCourse = _findCourseByCode(courses, requestedCourseCode);
            if (requestedCourse != null) {
                return [
                    requestedCourse,
                    requestedCourseCode,
                    "requested_code"
                ];
            }
        }

        var defaultCourse = _findCourseByCode(courses, GateRaceConfig.getDefaultCourseCode());
        if (defaultCourse != null) {
            var defaultReason = "default_course";
            if (requestedCourseCode.length() > 0) {
                defaultReason = "invalid_code_default";
            }
            return [
                defaultCourse,
                requestedCourseCode,
                defaultReason
            ];
        }

        var firstReason = "first_course";
        if (requestedCourseCode.length() > 0) {
            firstReason = "invalid_code_first";
        }
        return [
            courses[0],
            requestedCourseCode,
            firstReason
        ];
    }

    function _findCourseByCode(courses, courseCode) {
        if (courses == null or !(courses instanceof Lang.Array)) {
            return null;
        }
        for (var i = 0; i < courses.size(); i += 1) {
            var course = courses[i];
            if (_getCourseValue(course, COURSE_CODE) == courseCode) {
                return course;
            }
        }
        return null;
    }

    function _normalizeCourseCode(rawCourseCode) {
        if (rawCourseCode == null) {
            return "";
        }
        var courseCode = rawCourseCode.toString();
        if (courseCode.length() <= 0) {
            return "";
        }
        return courseCode;
    }

    function _parseCourseIndex(propertyValue) {
        if (propertyValue == null) {
            return null;
        }
        var text = propertyValue.toString();
        if (text.length() <= 0) {
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

    function _getCourseValue(course, index) {
        if (course == null or !(course instanceof Lang.Array)) {
            return null;
        }
        if (index < 0 or index >= course.size()) {
            return null;
        }
        return course[index];
    }

    function _getGateValue(gate, index) {
        if (gate == null or !(gate instanceof Lang.Array)) {
            return null;
        }
        if (index < 0 or index >= gate.size()) {
            return null;
        }
        return gate[index];
    }

    function _distanceKmToMeters(distanceKm) {
        if (distanceKm == null) {
            return null;
        }
        return Math.floor((distanceKm * 1000.0) + 0.5);
    }
}
