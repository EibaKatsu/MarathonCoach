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
        return 42.19500007008;
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
            [28164, 0, 735],
            [GOAL, 0, 810]
        ];
    }

    function getAids() {
        return [1609, 3219, 4828, 6437, 8047, 9656, 11265, 14484, 16093, 17703, 19312, 20921, 22531, 24140, 25750, 27359, 28968, 30578, 32187, 33796, 35406, 37015, 38624, 40234];
    }
}
