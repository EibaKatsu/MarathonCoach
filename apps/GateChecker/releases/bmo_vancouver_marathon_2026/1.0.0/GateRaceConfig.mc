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
    //   numeric = distanceTenthKm
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [300, 0, 750],
            [GOAL, 0, 870]
        ];
    }

    function getAids() {
        return [52, 89, 108, 127, 161, 178, 211, 244, 258, 285, 308, 324, 340, 367, 384, 398];
    }
}
