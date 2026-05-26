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
        return "20260614_hida_takayama_ultramarathon";
    }

    function getRaceNameJpn() {
        return "第14回 飛騨高山ウルトラマラソン";
    }

    function getRaceNameEng() {
        return "Hida Takayama Ultramarathon";
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 6;
    }

    function getRaceDay() {
        return 14;
    }

    function getRaceTimezone() {
        return "Asia/Tokyo";
    }

    function getDefaultCourseCode() {
        return "100k_wave_a";
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
                "100k_wave_a",
                "100km WAVE A",
                "100 km Wave A",
                100,
                [
                    [25900, 0, 500],
                    [44800, 0, 660],
                    [56700, 0, 750],
                    [73800, 0, 890],
                    [93000, 0, 1050],
                    [GOAL, 0, 1110]
                ],
                [5900, 10700, 16700, 19600, 25900, 30000, 35100, 40400, 44800, 52600, 56700, 61300, 65100, 68800, 73800, 78200, 82400, 87000, 90800, 93000, 95800, 100000]
            ],
            [
                "100k_wave_b",
                "100km WAVE B",
                "100 km Wave B",
                100,
                [
                    [25900, 0, 520],
                    [44800, 0, 680],
                    [56700, 0, 770],
                    [73800, 0, 910],
                    [93000, 0, 1070],
                    [GOAL, 0, 1130]
                ],
                [5900, 10700, 16700, 19600, 25900, 30000, 35100, 40400, 44800, 52600, 56700, 61300, 65100, 68800, 73800, 78200, 82400, 87000, 90800, 93000, 95800, 100000]
            ],
            [
                "71k_wave_c",
                "71km WAVE C",
                "71 km Wave C",
                70.2,
                [
                    [25900, 0, 570],
                    [44800, 0, 750],
                    [56700, 0, 850],
                    [GOAL, 0, 980]
                ],
                [5900, 10700, 16700, 19600, 25900, 30000, 35100, 40400, 44800, 52600, 56700, 61100, 65200, 70200]
            ]
            ];
        }
        return _courses;
    }

    function getRaceCourses() {
        return getCourses();
    }
}
