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
        return "20261018_sample_multi_course";
    }

    function getRaceNameJpn() {
        return "GateChecker 複数コース確認用";
    }

    function getRaceNameEng() {
        return "GateChecker Multi Course Sample";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 10;
    }

    function getRaceDay() {
        return 18;
    }

    function getRaceTimezone() {
        return "Asia/Tokyo";
    }

    function getDefaultCourseCode() {
        return "full_main";
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
                "full_main",
                "フルマラソン",
                "Full Marathon",
                42.195,
                [
                    [10000, 0, 580],
                    [21100, 0, 675],
                    [32000, 0, 765],
                    [GOAL, 0, 870]
                ],
                [5000, 10000, 15000, 21100, 28000, 35000, 39000]
            ],
            [
                "full_wave2",
                "フルマラソン 第2ウェーブ",
                "Full Marathon Wave 2",
                42.195,
                [
                    [10000, 0, 595],
                    [21100, 0, 690],
                    [32000, 0, 780],
                    [GOAL, 0, 885]
                ],
                [5000, 10000, 15000, 21100, 28000, 35000, 39000]
            ],
            [
                "ultra_100k",
                "100K",
                "100K",
                100,
                [
                    [30000, 0, 690],
                    [60000, 0, 945],
                    [85000, 0, 1150],
                    [GOAL, 0, 1260]
                ],
                [10000, 20000, 30000, 42000, 55000, 68000, 80000, 90000]
            ],
            [
                "ultra_70k",
                "70K",
                "70K",
                70,
                [
                    [25000, 0, 670],
                    [50000, 0, 880],
                    [GOAL, 0, 1040]
                ],
                [10000, 20000, 30000, 42000, 55000, 64000]
            ]
            ];
        }
        return _courses;
    }
}
