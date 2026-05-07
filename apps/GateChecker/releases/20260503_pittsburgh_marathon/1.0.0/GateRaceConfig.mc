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
        return "20260503_pittsburgh_marathon";
    }

    function getRaceNameJpn() {
        return "ピッツバーグマラソン2026";
    }

    function getRaceNameEng() {
        return "Pittsburgh Marathon 2026";
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
                    [7081, 0, 520],
                    [13036, 0, 580],
                    [17059, 0, 640],
                    [GOAL, 0, 840]
                ],
                [3219, 5955, 8530, 9978, 12875, 14645, 15772, 15933, 17059, 19956, 20117, 21726, 24301, 26554, 28485, 30256, 31865, 33152, 35727, 37176, 39268, 40877]
            ]
            ];
        }
        return _courses;
    }
}
