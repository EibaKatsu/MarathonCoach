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
        return "20260620_grandmas_marathon";
    }

    function getRaceNameJpn() {
        return "グランマズマラソン2026";
    }

    function getRaceNameEng() {
        return "Grandma's Marathon 2026";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 6;
    }

    function getRaceDay() {
        return 20;
    }

    function getRaceTimezone() {
        return "America/Chicago";
    }

    function getDefaultCourseCode() {
        return "main";
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
            [
                "main",
                "メインコース",
                "Main Course",
                42.19500007008,
                [
                    [GOAL, 0, 885]
                ],
                [4828, 8047, 11265, 14484, 17703, 20921, 24140, 27359, 30578, 32187, 33796, 35406, 37015, 37820, 38624, 40234]
            ]
            ];
        }
        return _courses;
    }
}
