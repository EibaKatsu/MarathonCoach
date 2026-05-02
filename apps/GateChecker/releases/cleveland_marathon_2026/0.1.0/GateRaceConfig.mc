module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "cleveland_marathon_2026";
    }

    function getRaceNameJpn() {
        return "クリーブランドマラソン2026";
    }

    function getRaceNameEng() {
        return "Cleveland Marathon 2026";
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
        return 17;
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
            [14806, 0, 580],
            [20921, 0, 640],
            [GOAL, 0, 840]
        ];
    }

    function getAids() {
        return [2736, 6116, 8530, 10944, 13358, 14806, 17220, 19795, 21887, 24623, 26393, 28485, 30417, 32348, 34279, 34440, 36532, 38946, 40877];
    }
}
