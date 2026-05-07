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
        return "20260428_gatechecker_beta_check";
    }

    function getRaceNameJpn() {
        return "GateChecker BETA確認用";
    }

    function getRaceNameEng() {
        return "GateChecker Beta Check";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 4;
    }

    function getRaceDay() {
        return 28;
    }

    function getRaceTimezone() {
        return "Asia/Tokyo";
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
                12.5,
                [
                    [500, 0, 1200],
                    [1000, 0, 1230]
                ],
                [300, 11600]
            ]
            ];
        }
        return _courses;
    }
}
