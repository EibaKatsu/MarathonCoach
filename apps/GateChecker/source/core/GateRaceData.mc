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
    const RESOLVED_EFFECTIVE_CODE = 2;
    const RESOLVED_REASON = 3;

    var _resolvedCourseState = null;

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
        return _getResolvedCourseStateValue(RESOLVED_EFFECTIVE_CODE);
    }

    function getSelectedCourseNameJpn() {
        var course = _getSelectedCourse();
        var courseName = _getCourseValue(course, COURSE_NAME_JPN);
        if (courseName == null or courseName.length() <= 0) {
            return "NO COURSE";
        }
        return courseName;
    }

    function getSelectedCourseNameEng() {
        var course = _getSelectedCourse();
        var courseName = _getCourseValue(course, COURSE_NAME_ENG);
        if (courseName == null or courseName.length() <= 0) {
            return "NO COURSE";
        }
        return courseName;
    }

    function getSelectedCourseReason() {
        var reason = _getResolvedCourseStateValue(RESOLVED_REASON);
        if (reason == null) {
            return "empty";
        }
        return reason;
    }

    function getRequestedCourseCode() {
        var requestedCode = _getResolvedCourseStateValue(RESOLVED_REQUESTED_CODE);
        if (requestedCode == null) {
            return "";
        }
        return requestedCode;
    }

    function getCourseCount() {
        var courses = GateRaceConfig.getCourses();
        if (courses == null or !(courses instanceof Lang.Array)) {
            return 0;
        }
        return courses.size();
    }

    function getRaceDistanceKm() {
        var course = _getSelectedCourse();
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
        var course = _getSelectedCourse();
        var gates = _getCourseValue(course, COURSE_GATES);
        if (gates == null or !(gates instanceof Lang.Array)) {
            return [];
        }
        return gates;
    }

    function getAids() as Lang.Array {
        var course = _getSelectedCourse();
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
        _resolvedCourseState = null;
    }

    function _getSelectedCourse() {
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
        var requestedCourseCode = GateSettingsLoader.loadCourseCode();
        var cacheKey = _buildCacheKey(courses, requestedCourseCode);
        if (_resolvedCourseState != null and _resolvedCourseState instanceof Lang.Array) {
            var cachedRequestedCode = _getStateValue(_resolvedCourseState, RESOLVED_REQUESTED_CODE);
            var cachedCourse = _getStateValue(_resolvedCourseState, RESOLVED_COURSE);
            if (
                cacheKey == _buildCacheKey(courses, cachedRequestedCode) and
                cachedCourse != null
            ) {
                return _resolvedCourseState;
            }
        }

        _resolvedCourseState = _computeResolvedCourseState(courses, requestedCourseCode);
        return _resolvedCourseState;
    }

    function _computeResolvedCourseState(courses, requestedCourseCode) {
        if (courses == null or !(courses instanceof Lang.Array) or courses.size() <= 0) {
            return [null, requestedCourseCode, null, "no_courses"];
        }

        if (courses.size() == 1) {
            var onlyCourse = courses[0];
            return [
                onlyCourse,
                requestedCourseCode,
                _getCourseValue(onlyCourse, COURSE_CODE),
                "single_course"
            ];
        }

        var normalizedRequestedCode = _normalizeCourseCode(requestedCourseCode);
        if (normalizedRequestedCode.length() > 0) {
            var requestedCourse = _findCourseByCode(courses, normalizedRequestedCode);
            if (requestedCourse != null) {
                return [
                    requestedCourse,
                    normalizedRequestedCode,
                    _getCourseValue(requestedCourse, COURSE_CODE),
                    "requested_course"
                ];
            }
        }

        var defaultCourseCode = _normalizeCourseCode(GateRaceConfig.getDefaultCourseCode());
        if (defaultCourseCode.length() > 0) {
            var defaultCourse = _findCourseByCode(courses, defaultCourseCode);
            if (defaultCourse != null) {
                return [
                    defaultCourse,
                    normalizedRequestedCode,
                    _getCourseValue(defaultCourse, COURSE_CODE),
                    "default_course"
                ];
            }
        }

        var firstCourse = courses[0];
        if (firstCourse != null) {
            return [
                firstCourse,
                normalizedRequestedCode,
                _getCourseValue(firstCourse, COURSE_CODE),
                "first_course"
            ];
        }

        return [null, normalizedRequestedCode, null, "no_course_match"];
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

    function _buildCacheKey(courses, requestedCourseCode) {
        var courseCount = 0;
        if (courses != null and courses instanceof Lang.Array) {
            courseCount = courses.size();
        }
        return courseCount.toString() + "|" + _normalizeCourseCode(requestedCourseCode);
    }

    function _normalizeCourseCode(rawCourseCode) {
        if (rawCourseCode == null) {
            return "";
        }
        var text = rawCourseCode.toString();
        if (text.length() <= 0) {
            return "";
        }
        return text;
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

    function _getStateValue(state, index) {
        if (state == null or !(state instanceof Lang.Array)) {
            return null;
        }
        if (index < 0 or index >= state.size()) {
            return null;
        }
        return state[index];
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
