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
        return "20260524_edinburgh_marathon";
    }

    function getRaceNameJpn() {
        return "エディンバラマラソン2026";
    }

    function getRaceNameEng() {
        return "Edinburgh Marathon 2026";
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
        return "Europe/London";
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
                    [GOAL, 0, 990]
                ],
                [4989, 9978, 14484, 14967, 19956, 24945, 26071, 29934, 34923, 35084, 38946, 39107]
            ]
            ];
        }
        return _courses;
    }
}
