module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "ing_night_marathon_luxembourg_2026";
    }

    function getRaceNameJpn() {
        return "ルクセンブルク ナイトマラソン2026";
    }

    function getRaceNameEng() {
        return "ING Night Marathon Luxembourg 2026";
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
        return 16;
    }

    function getRaceTimezone() {
        return "Europe/Luxembourg";
    }

    // [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceMeters
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [GOAL, 1, 60]
        ];
    }

    function getAids() {
        return [5000, 7500, 10000, 12500, 15000, 17500, 20000, 22500, 25000, 27500, 30000, 32500, 35000, 37500, 40000];
    }
}
