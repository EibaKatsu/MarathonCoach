module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "kurobe_meisui_marathon_2026";
    }

    function getRaceNameJpn() {
        return "黒部名水マラソン2026";
    }

    function getRaceNameEng() {
        return "Kurobe Meisui Marathon 2026";
    }

    function getRaceDistanceKm() {
        return 42.195;
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 5;
    }

    function getRaceDay() {
        return 24;
    }

    function getRaceTimezone() {
        return "Asia/Tokyo";
    }

    // [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceMeters
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [9000, 0, 625],
            [17100, 0, 690],
            [23200, 0, 740],
            [28200, 0, 780],
            [31800, 0, 810],
            [36500, 0, 850],
            [40300, 0, 885],
            [GOAL, 0, 900]
        ];
    }

    function getAids() {
        return [2300, 4400, 6700, 9200, 11200, 14000, 16100, 17400, 19500, 21100, 23100, 25400, 27700, 29400, 31800, 33600, 35100, 36500, 37700, 39200, 40900];
    }
}
