module GateRaceConfig {
    const GOAL = -1;
    const COURSE_CODE = 0;
    const COURSE_NAME_JPN = 1;
    const COURSE_NAME_ENG = 2;
    const COURSE_DISTANCE_KM = 3;
    const COURSE_GATES = 4;
    const COURSE_AIDS = 5;

    function getRaceKey() {
        return "flying_pig_marathon_2026";
    }

    function getRaceNameJpn() {
        return "シンシナティ フライング・ピッグ・マラソン2026";
    }

    function getRaceNameEng() {
        return "Flying Pig Marathon 2026";
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
        return [
            [
                "main",
                "メインコース",
                "Main Course",
                42.19500007008,
                [
                    [28164, 0, 735],
                    [GOAL, 0, 810]
                ],
                [1609, 3219, 4828, 6437, 8047, 9656, 11265, 14484, 16093, 17703, 19312, 20921, 22531, 24140, 25750, 27359, 28968, 30578, 32187, 33796, 35406, 37015, 38624, 40234]
            ]
        ];
    }
}
