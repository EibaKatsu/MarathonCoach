module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "pittsburgh_marathon_2026";
    }

    function getRaceNameJpn() {
        return "ピッツバーグマラソン2026";
    }

    function getRaceNameEng() {
        return "Pittsburgh Marathon 2026";
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
            [71, 0, 520],
            [130, 0, 580],
            [171, 0, 640],
            [GOAL, 0, 839]
        ];
    }

    function getAids() {
        return [32, 60, 85, 100, 129, 146, 159, 171, 200, 217, 243, 266, 285, 303, 319, 332, 357, 372, 393, 409];
    }
}
