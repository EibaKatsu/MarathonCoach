module GateRaceConfig {
    const GOAL = -1;

    function getRaceKey() {
        return $race_key_literal;
    }

    function getRaceNameJpn() {
        return $race_name_jpn_literal;
    }

    function getRaceNameEng() {
        return $race_name_eng_literal;
    }

    function getRaceDistanceKm() {
        return $race_distance_km;
    }

    function getRaceYear() {
        return $race_year;
    }

    function getRaceMonth() {
        return $race_month;
    }

    function getRaceDay() {
        return $race_day;
    }

    function getRaceTimezone() {
        return $race_timezone_literal;
    }

    // [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceTenthKm
    //   GOAL = GateRaceConfig.GOAL
    function getGates() {
        return [
$gates_body
        ];
    }

    function getAids() {
        return [$aids_body];
    }
}
