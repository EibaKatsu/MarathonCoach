module GateRaceConfig {
    const GOAL = -1;
    const RACE_CODE = 0;
    const RACE_ID = 1;
    const COURSE_ID = 2;
    const RACE_NAME_JPN = 3;
    const RACE_NAME_ENG = 4;
    const COURSE_NAME_JPN = 5;
    const COURSE_NAME_ENG = 6;
    const RACE_YEAR = 7;
    const RACE_MONTH = 8;
    const RACE_DAY = 9;
    const RACE_TIMEZONE = 10;
    const COURSE_DISTANCE_KM = 11;
    const COURSE_GATES = 12;
    const COURSE_AIDS = 13;

    var _raceCourses = null;

    // [
    //   raceCode,
    //   raceId,
    //   courseId,
    //   raceNameJpn,
    //   raceNameEng,
    //   courseNameJpn,
    //   courseNameEng,
    //   raceYear,
    //   raceMonth,
    //   raceDay,
    //   timezone,
    //   distanceKm,
    //   gates,
    //   aids
    // ]
    //
    // gates item: [point, cutoffDayOffset, cutoffMinuteOfDay]
    // point:
    //   numeric = distanceMeters
    //   GOAL = GateRaceConfig.GOAL
    function getRaceCourses() {
        if (_raceCourses == null) {
            _raceCourses = [
$race_courses_body
            ];
        }
        return _raceCourses;
    }
}
