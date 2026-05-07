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
        return "20260503_bmo_vancouver_marathon";
    }

    function getRaceNameJpn() {
        return "BMOバンクーバーマラソン2026";
    }

    function getRaceNameEng() {
        return "BMO Vancouver Marathon 2026";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 5;
    }

    function getRaceDay() {
        return 3;
    }

    function getRaceTimezone() {
        return "America/Vancouver";
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
                42.195,
                [
                    [30000, 0, 750],
                    [GOAL, 0, 870]
                ],
                [5200, 8900, 10800, 12700, 16100, 17800, 21100, 24400, 25800, 28500, 30800, 32400, 34000, 36700, 38400, 39800]
            ]
            ];
        }
        return _courses;
    }
}
