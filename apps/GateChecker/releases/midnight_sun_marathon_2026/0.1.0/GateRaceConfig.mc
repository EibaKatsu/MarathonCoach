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
        return "midnight_sun_marathon_2026";
    }

    function getRaceNameJpn() {
        return "ミッドナイトサンマラソン2026";
    }

    function getRaceNameEng() {
        return "Midnight Sun Marathon 2026";
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
        return "Europe/Oslo";
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
                    [GOAL, 1, 120]
                ],
                [5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000]
            ]
            ];
        }
        return _courses;
    }
}
