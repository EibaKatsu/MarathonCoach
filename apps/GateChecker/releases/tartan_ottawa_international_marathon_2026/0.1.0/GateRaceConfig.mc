module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "tartan_ottawa_international_marathon_2026";
    }

    function getRaceNameJpn() {
        return "オタワ国際マラソン2026";
    }

    function getRaceNameEng() {
        return "Tartan Ottawa International Marathon 2026";
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
        return "America/Toronto";
    }

    // [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceMeters
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [27000, 0, 690],
            [GOAL, 0, 840]
        ];
    }

    function getAids() {
        return [3000, 6000, 9000, 11500, 12000, 15000, 16900, 18000, 21000, 24000, 27000, 30000, 32000, 33000, 36000, 38000, 39000];
    }
}
