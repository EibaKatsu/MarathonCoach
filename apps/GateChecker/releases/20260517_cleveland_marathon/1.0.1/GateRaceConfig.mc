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
        return "20260517_cleveland_marathon";
    }

    function getRaceNameJpn() {
        return "クリーブランドマラソン2026";
    }

    function getRaceNameEng() {
        return "Cleveland Marathon 2026";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 5;
    }

    function getRaceDay() {
        return 17;
    }

    function getRaceTimezone() {
        return "America/New_York";
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
                    [14806, 0, 580],
                    [20921, 0, 640],
                    [GOAL, 0, 840]
                ],
                [2736, 6116, 8530, 10944, 13358, 14806, 17220, 19795, 21887, 24623, 26393, 28485, 30417, 32348, 34279, 34440, 36532, 38946, 40877]
            ]
            ];
        }
        return _courses;
    }
}
