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
    //   numeric = distanceTenthKm
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
            [79, 0, 575],
            [130, 0, 610],
            [189, 0, 660],
            [250, 0, 710],
            [309, 0, 765],
            [372, 0, 815],
            [GOAL, 0, 870]
        ];
    }

    function getAids() {
        return [18, 57, 94, 115, 141, 181, 209, 236, 268, 286, 320, 342, 372, 401];
    }
}
