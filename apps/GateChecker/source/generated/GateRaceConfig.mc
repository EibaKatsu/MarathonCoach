module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "flying_pig_marathon_2026";
    }

    function getRaceNameJpn() {
        return "シンシナティ フライング・ピッグ・マラソン2026";
    }

    function getRaceNameEng() {
        return "Flying Pig Marathon 2026";
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
        return 3;
    }

    function getRaceTimezone() {
        return "America/New_York";
    }

    // [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceMeters
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [28200, 0, 735],
            [GOAL, 0, 809]
        ];
    }

    function getAids() {
        return [2400, 4500, 7400, 9500, 11400, 13500, 14000, 15900, 18000, 19800, 21400, 23700, 25400, 26700, 29500, 31400, 33500, 34400, 36500, 38500, 38600, 40600];
    }
}
