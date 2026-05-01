module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return "iwate_oshu_kirameki_marathon_2026";
    }

    function getRaceNameJpn() {
        return "2026第10回いわて奥州きらめきマラソン";
    }

    function getRaceNameEng() {
        return "Iwate Oshu Kirameki Marathon 2026";
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
        return 17;
    }

    function getRaceTimezone() {
        return "Asia/Tokyo";
    }

    // [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceMeters
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [7900, 0, 575],
            [13000, 0, 610],
            [18900, 0, 660],
            [25000, 0, 710],
            [30900, 0, 765],
            [37200, 0, 815],
            [GOAL, 0, 870]
        ];
    }

    function getAids() {
        return [1800, 5700, 9400, 11500, 14100, 18100, 20900, 23600, 26800, 28600, 32000, 34200, 37200, 40100];
    }
}
