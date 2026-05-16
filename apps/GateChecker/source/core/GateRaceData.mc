using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using GateDistanceUtils;
using GateSettingsLoader;

module GateRaceData {
    const GATE_POINT = 0;
    const GATE_CUTOFF_DAY_OFFSET = 1;
    const GATE_CUTOFF_MINUTE_OF_DAY = 2;

    const ENTRY_RACE_CODE = 0;
    const ENTRY_RACE_ID = 1;
    const ENTRY_COURSE_ID = 2;
    const ENTRY_RACE_NAME_JPN = 3;
    const ENTRY_RACE_NAME_ENG = 4;
    const ENTRY_COURSE_NAME_JPN = 5;
    const ENTRY_COURSE_NAME_ENG = 6;
    const ENTRY_RACE_YEAR = 7;
    const ENTRY_RACE_MONTH = 8;
    const ENTRY_RACE_DAY = 9;
    const ENTRY_RACE_TIMEZONE = 10;
    const ENTRY_DISTANCE_KM = 11;
    const ENTRY_GATES = 12;
    const ENTRY_AIDS = 13;

    const RESOLVED_ENTRY = 0;
    const RESOLVED_REQUESTED_CODE = 1;
    const RESOLVED_REASON = 2;
    const COURSE_DEBUG_LOG = false;

    var _requestedRaceCode = null;
    var _resolvedCourseStateCache = null;

    function getRaceNameJpn() {
        var course = _getResolvedCourse();
        var raceName = _getEntryValue(course, ENTRY_RACE_NAME_JPN);
        if (raceName == null) {
            return "";
        }
        return raceName;
    }

    function getRaceNameEng() {
        var course = _getResolvedCourse();
        var raceName = _getEntryValue(course, ENTRY_RACE_NAME_ENG);
        if (raceName == null) {
            return "";
        }
        return raceName;
    }

    function getRaceId() {
        return _getEntryValue(_getResolvedCourse(), ENTRY_RACE_ID);
    }

    function getSelectedRaceCode() {
        return _getEntryValue(_getResolvedCourse(), ENTRY_RACE_CODE);
    }

    function getSelectedCourseId() {
        return _getEntryValue(_getResolvedCourse(), ENTRY_COURSE_ID);
    }

    function getSelectedCourseNameJpn() {
        var courseName = _getEntryValue(_getResolvedCourse(), ENTRY_COURSE_NAME_JPN);
        if (courseName == null) {
            return "";
        }
        return courseName;
    }

    function getSelectedCourseNameEng() {
        var courseName = _getEntryValue(_getResolvedCourse(), ENTRY_COURSE_NAME_ENG);
        if (courseName == null) {
            return "";
        }
        return courseName;
    }

    function getPreStartCourseNameJpn() {
        return getSelectedCourseNameJpn();
    }

    function getPreStartCourseNameEng() {
        return getSelectedCourseNameEng();
    }

    function getSelectedRaceReason() {
        var reason = _getResolvedCourseStateValue(RESOLVED_REASON);
        if (reason == null) {
            return "no_courses";
        }
        return reason;
    }

    function getRequestedRaceCode() {
        return _normalizeRaceCode(_requestedRaceCode);
    }

    function hasResolvedRaceCode() as Lang.Boolean {
        return _getResolvedCourse() != null;
    }

    function isRaceCodeMissing() as Lang.Boolean {
        return getSelectedRaceReason() == "race_code_missing";
    }

    function isRaceCodeNotFound() as Lang.Boolean {
        return getSelectedRaceReason() == "race_code_not_found";
    }

    function getCourseCount() {
        var courses = GateRaceConfig.getRaceCourses();
        if (courses == null or !(courses instanceof Lang.Array)) {
            return 0;
        }
        return courses.size();
    }

    function getRaceDistanceKm() {
        return _getEntryValue(_getResolvedCourse(), ENTRY_DISTANCE_KM);
    }

    function getRaceYear() {
        var year = _getEntryValue(_getResolvedCourse(), ENTRY_RACE_YEAR);
        if (year == null) {
            return 0;
        }
        return year;
    }

    function getRaceMonth() {
        var month = _getEntryValue(_getResolvedCourse(), ENTRY_RACE_MONTH);
        if (month == null) {
            return 0;
        }
        return month;
    }

    function getRaceDay() {
        var day = _getEntryValue(_getResolvedCourse(), ENTRY_RACE_DAY);
        if (day == null) {
            return 0;
        }
        return day;
    }

    function getRaceTimezone() {
        var timezone = _getEntryValue(_getResolvedCourse(), ENTRY_RACE_TIMEZONE);
        if (timezone == null) {
            return "";
        }
        return timezone;
    }

    function getGates() as Lang.Array {
        var gates = _getEntryValue(_getResolvedCourse(), ENTRY_GATES);
        if (gates == null or !(gates instanceof Lang.Array)) {
            return [];
        }
        return gates;
    }

    function getAids() as Lang.Array {
        var aids = _getEntryValue(_getResolvedCourse(), ENTRY_AIDS);
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
        _requestedRaceCode = null;
        _resolvedCourseStateCache = null;
    }

    function applyRaceCodeSelectionFromPropertyValue(propertyValue) {
        _requestedRaceCode = _normalizeRaceCode(propertyValue);
        _resolvedCourseStateCache = null;
        _log(
            "applyRaceCodeSelectionFromPropertyValue",
            "requestedRaceCode=" + _diag(_requestedRaceCode)
        );
        return _requestedRaceCode;
    }

    function loadRequestedRaceCodeFromProperties() {
        _resolvedCourseStateCache = null;
        _requestedRaceCode = _normalizeRaceCode(GateSettingsLoader.loadRaceCode());
        _log(
            "loadRequestedRaceCodeFromProperties",
            "raceCode=" + _diag(_requestedRaceCode)
        );
        return _requestedRaceCode;
    }

    function _getResolvedCourse() {
        return _getResolvedCourseStateValue(RESOLVED_ENTRY);
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
        if (_resolvedCourseStateCache != null and _resolvedCourseStateCache instanceof Lang.Array) {
            return _resolvedCourseStateCache;
        }
        _resolvedCourseStateCache = _buildResolvedCourseState();
        return _resolvedCourseStateCache;
    }

    function _buildResolvedCourseState() {
        var courses = GateRaceConfig.getRaceCourses();
        if (courses == null or !(courses instanceof Lang.Array) or courses.size() <= 0) {
            return [null, "", "no_courses"];
        }

        var requestedRaceCode = _normalizeRaceCode(_requestedRaceCode);
        if (requestedRaceCode.length() <= 0) {
            return [null, "", "race_code_missing"];
        }

        var requestedCourse = _findCourseByRaceCode(courses, requestedRaceCode);
        if (requestedCourse != null) {
            _log(
                "_buildResolvedCourseState",
                "requested=" + _diag(requestedRaceCode) +
                " selected=" + _diag(_getEntryValue(requestedCourse, ENTRY_RACE_CODE)) +
                " reason=race_code_matched"
            );
            return [requestedCourse, requestedRaceCode, "race_code_matched"];
        }

        _log(
            "_buildResolvedCourseState",
            "requested=" + _diag(requestedRaceCode) +
            " selected=null reason=race_code_not_found"
        );
        return [null, requestedRaceCode, "race_code_not_found"];
    }

    function _findCourseByRaceCode(courses, raceCode) {
        if (courses == null or !(courses instanceof Lang.Array)) {
            return null;
        }
        for (var i = 0; i < courses.size(); i += 1) {
            var course = courses[i];
            if (_getEntryValue(course, ENTRY_RACE_CODE) == raceCode) {
                return course;
            }
        }
        return null;
    }

    function _normalizeRaceCode(rawRaceCode) {
        if (rawRaceCode == null) {
            return "";
        }
        var text = rawRaceCode.toString();
        if (text.length() <= 0) {
            return "";
        }

        var normalized = "";
        var chars = text.toCharArray();
        if (!(chars instanceof Lang.Array)) {
            return "";
        }
        for (var i = 0; i < chars.size(); i += 1) {
            if (chars[i] == null) {
                continue;
            }
            var code = chars[i].toNumber();
            if (
                code == 32 or
                code == 9 or
                code == 10 or
                code == 13 or
                code == 12288
            ) {
                continue;
            }
            if (code >= 97 and code <= 122) {
                code -= 32;
            }
            normalized += _charFromCode(code);
        }
        return normalized;
    }

    function _charFromCode(code) {
        if (code == 45) {
            return "-";
        }
        if (code >= 48 and code <= 57) {
            return (code - 48).format("%d");
        }
        if (code >= 65 and code <= 90) {
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".substring(code - 65, (code - 65) + 1);
        }
        return "";
    }

    function _getEntryValue(course, index) {
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

    function _log(tag, message) {
        if (!COURSE_DEBUG_LOG) {
            return;
        }
        Sys.println("[GATE_COURSE] " + tag + " " + message);
    }

    function _diag(value) {
        if (value == null) {
            return "null";
        }
        return value.toString();
    }
}
