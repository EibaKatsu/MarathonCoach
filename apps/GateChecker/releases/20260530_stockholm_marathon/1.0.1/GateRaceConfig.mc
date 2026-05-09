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
        return "20260530_stockholm_marathon";
    }

    function getRaceNameJpn() {
        return "ストックホルムマラソン2026";
    }

    function getRaceNameEng() {
        return "adidas Stockholm Marathon 2026";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 5;
    }

    function getRaceDay() {
        return 30;
    }

    function getRaceTimezone() {
        return "Europe/Stockholm";
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
                    [21100, 0, 925],
                    [27000, 0, 980],
                    [32000, 0, 1025],
                    [35500, 0, 1060],
                    [GOAL, 0, 1110]
                ],
                [3800, 5600, 7200, 8800, 11200, 12900, 15500, 17400, 20200, 22500, 25500, 27000, 27900, 30100, 32200, 34000, 37400, 40000]
            ]
            ];
        }
        return _courses;
    }
}
