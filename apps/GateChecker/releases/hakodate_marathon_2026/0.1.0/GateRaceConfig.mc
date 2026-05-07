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
        return "hakodate_marathon_2026";
    }

    function getRaceNameJpn() {
        return "函館マラソン2026";
    }

    function getRaceNameEng() {
        return "Hakodate Marathon 2026";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 6;
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
                42.195,
                [
                    [5000, 0, 594],
                    [8300, 0, 619],
                    [13700, 0, 660],
                    [19300, 0, 700],
                    [24300, 0, 744],
                    [29400, 0, 788],
                    [33500, 0, 824],
                    [37300, 0, 857],
                    [39900, 0, 880],
                    [GOAL, 0, 900]
                ],
                [4700, 8400, 10300, 14100, 17800, 21500, 24100, 26500, 28700, 30000, 31300, 33500, 35800, 37300, 39400]
            ]
            ];
        }
        return _courses;
    }
}
