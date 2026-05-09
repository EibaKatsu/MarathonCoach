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
        return "20260628_lake_saroma_100km_ultra_marathon";
    }

    function getRaceNameJpn() {
        return "サロマ湖100kmウルトラマラソン2026";
    }

    function getRaceNameEng() {
        return "Lake Saroma 100km Ultra Marathon 2026";
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
                100,
                [
                    [10000, 0, 383],
                    [20000, 0, 459],
                    [30000, 0, 535],
                    [41000, 0, 620],
                    [50000, 0, 690],
                    [60000, 0, 768],
                    [69300, 0, 842],
                    [79300, 0, 919],
                    [91500, 0, 1014],
                    [GOAL, 0, 1080]
                ],
                [5000, 8500, 10000, 12500, 15000, 17500, 20000, 22500, 25000, 27500, 30000, 32500, 35000, 37500, 40000, 42500, 45000, 52000, 54500, 60000, 63500, 68000, 69000, 72500, 73800, 77500, 80000, 82500, 85000, 87500, 90000, 95000]
            ]
            ];
        }
        return _courses;
    }
}
