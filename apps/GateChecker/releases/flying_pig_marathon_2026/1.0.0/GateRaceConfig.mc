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
    //   numeric = distanceTenthKm
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [282, 0, 735],
            [GOAL, 0, 809]
        ];
    }

    function getAids() {
        return [24, 45, 74, 95, 114, 135, 140, 159, 180, 198, 214, 237, 254, 267, 295, 314, 335, 344, 365, 385, 386, 406];
    }
}
