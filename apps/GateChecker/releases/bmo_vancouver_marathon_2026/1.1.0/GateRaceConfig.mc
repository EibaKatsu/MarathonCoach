module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "bmo_vancouver_marathon_2026";
    }

    function getRaceNameJpn() {
        return "BMOバンクーバーマラソン2026";
    }

    function getRaceNameEng() {
        return "BMO Vancouver Marathon 2026";
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
        return "America/Vancouver";
    }

    // [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceMeters
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [30000, 0, 750],
            [GOAL, 0, 870]
        ];
    }

    function getAids() {
        return [5200, 8900, 10800, 12700, 16100, 17800, 21100, 24400, 25800, 28500, 30800, 32400, 34000, 36700, 38400, 39800];
    }
}
