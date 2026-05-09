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
        return "20260524_tartan_ottawa_international_marathon";
    }

    function getRaceNameJpn() {
        return "オタワ国際マラソン2026";
    }

    function getRaceNameEng() {
        return "Tartan Ottawa International Marathon 2026";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 5;
    }

    function getRaceDay() {
        return 24;
    }

    function getRaceTimezone() {
        return "America/Toronto";
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
                    [27000, 0, 690],
                    [GOAL, 0, 840]
                ],
                [3000, 6000, 9000, 11500, 12000, 15000, 16900, 18000, 21000, 24000, 27000, 30000, 32000, 33000, 36000, 38000, 39000]
            ]
            ];
        }
        return _courses;
    }
}
