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
        return "20261101_toyama_marathon";
    }

    function getRaceNameJpn() {
        return "富山マラソン2026";
    }

    function getRaceNameEng() {
        return "Toyama Marathon 2026";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 11;
    }

    function getRaceDay() {
        return 1;
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
                42.195,
                [
                    [9200, 0, 641],
                    [14400, 0, 692],
                    [18300, 0, 729],
                    [22600, 0, 771],
                    [26400, 0, 808],
                    [28900, 0, 832],
                    [33200, 0, 874],
                    [35500, 0, 896],
                    [38500, 0, 925],
                    [41600, 0, 959],
                    [GOAL, 0, 963]
                ],
                [5000, 10500, 15800, 21100, 27000, 32500, 38000]
            ]
            ];
        }
        return _courses;
    }
}
