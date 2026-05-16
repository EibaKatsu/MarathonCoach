module GateRaceConfig {
    const GOAL = -1;
    const COURSE_CODE = 0;
    const COURSE_NAME_JPN = 1;
    const COURSE_NAME_ENG = 2;
    const COURSE_DISTANCE_KM = 3;
    const COURSE_GATES = 4;
    const COURSE_AIDS = 5;

    var _courses = null;

    function getRaceKey() {
        return $race_key_literal;
    }

    function getRaceNameJpn() {
        return $race_name_jpn_literal;
    }

    function getRaceNameEng() {
        return $race_name_eng_literal;
    }

    function getRaceYear() {
        return $race_year;
    }

    function getRaceMonth() {
        return $race_month;
    }

    function getRaceDay() {
        return $race_day;
    }

    function getRaceTimezone() {
        return $race_timezone_literal;
    }

    function getDefaultCourseCode() {
        return $default_course_code_literal;
    }

    // [
    //   courseCode,
    //   courseNameJpn,
    //   courseNameEng,
    //   distanceKm,
    //   gates,
    //   aids
    // ]
    //
    // gates item: [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceMeters
    //   GOAL = GateRaceConfig.GOAL
    function getCourses() {
        if (_courses == null) {
            _courses = [
$courses_body
            ];
        }
        return _courses;
    }

    function getRaceCourses() {
        return getCourses();
    }
}
