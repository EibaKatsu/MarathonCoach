module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "gatechecker_beta_check_2026";
    }

    function getRaceNameJpn() {
        return "GateChecker BETA確認用";
    }

    function getRaceNameEng() {
        return "GateChecker Beta Check";
    }

    function getRaceDistanceKm() {
        return 12.5;
    }

    function getRaceYear() {
        return 2026;
    }

    function getRaceMonth() {
        return 4;
    }

    function getRaceDay() {
        return 28;
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
            [5, 0, 1200],
            [10, 0, 1230]
        ];
    }

    function getAids() {
        return [3, 116];
    }
}
