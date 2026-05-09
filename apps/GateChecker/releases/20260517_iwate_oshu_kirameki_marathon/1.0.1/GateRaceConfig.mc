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
        return "20260517_iwate_oshu_kirameki_marathon";
    }

    function getRaceNameJpn() {
        return "2026第10回いわて奥州きらめきマラソン";
    }

    function getRaceNameEng() {
        return "Iwate Oshu Kirameki Marathon 2026";
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
                    [7900, 0, 575],
                    [13000, 0, 610],
                    [18900, 0, 660],
                    [25000, 0, 710],
                    [30900, 0, 765],
                    [37200, 0, 815],
                    [GOAL, 0, 870]
                ],
                [1800, 5700, 9400, 11500, 14100, 18100, 20900, 23600, 26800, 28600, 32000, 34200, 37200, 40100]
            ]
            ];
        }
        return _courses;
    }
}
