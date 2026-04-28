module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "toyama_marathon_2026";
    }

    function getRaceNameJpn() {
        return "富山マラソン2026 関門チェッカー";
    }

    function getRaceNameEng() {
        return "Toyama Marathon 2026 Gate Checker";
    }

    function getRaceDistanceKm() {
        return 42.195;
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 11;
    }

    function getRaceDay() {
        return 1;
    }

    function getRaceTimezone() {
        return "Asia/Tokyo";
    }

    // [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceTenthKm
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [90, 0, 860],
            [150, 0, 910],
            [211, 0, 960],
            [300, 0, 1040],
            [360, 0, 1090],
            [GOAL, 0, 1140]
        ];
    }

    function getAids() {
        return [50, 105, 158, 211, 270, 325, 380];
    }
}
