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
            [7081, 0, 520],
            [13036, 0, 580],
            [17059, 0, 640],
            [GOAL, 0, 840]
        ];
    }

    function getAids() {
        return [3219, 5955, 8530, 9978, 12875, 14645, 15772, 15933, 17059, 19956, 20117, 21726, 24301, 26554, 28485, 30256, 31865, 33152, 35727, 37176, 39268, 40877];
    }
}
