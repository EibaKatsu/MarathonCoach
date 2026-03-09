module DistanceNotifyUtils {
    const RACE_FULL = 0;
    const RACE_HALF = 1;
    const RACE_TEN = 2;
    const RACE_FIVE = 3;

    const PHASE_EARLY = 0;
    const PHASE_MID = 1;
    const PHASE_LATE = 2;

    function resolveRaceType(raceDistanceKm, halfDistanceKm, halfToleranceKm) {
        if (raceDistanceKm == null) {
            return RACE_FULL;
        }
        if (raceDistanceKm <= 7.0) {
            return RACE_FIVE;
        }

        var halfDelta = raceDistanceKm - halfDistanceKm;
        if (halfDelta < 0) {
            halfDelta = -halfDelta;
        }
        if (halfDelta <= halfToleranceKm) {
            return RACE_HALF;
        }
        if (raceDistanceKm <= 15.0) {
            return RACE_TEN;
        }
        return RACE_FULL;
    }

    function getCheckpointCount(raceType) {
        if (raceType == RACE_FIVE) {
            return 1;
        }
        return 2;
    }

    function getCheckpointKm(raceType, checkpointIdx) {
        if (raceType == RACE_FULL) {
            if (checkpointIdx == 0) {
                return 21.1;
            }
            if (checkpointIdx == 1) {
                return 42.2;
            }
            return null;
        }

        if (raceType == RACE_HALF) {
            if (checkpointIdx == 0) {
                return 10.0;
            }
            if (checkpointIdx == 1) {
                return 21.1;
            }
            return null;
        }

        if (raceType == RACE_TEN) {
            if (checkpointIdx == 0) {
                return 5.0;
            }
            if (checkpointIdx == 1) {
                return 10.0;
            }
            return null;
        }

        if (checkpointIdx == 0) {
            return 5.0;
        }
        return null;
    }

    function getMaxSplitKm(raceType) {
        if (raceType == RACE_FULL) {
            return 42;
        }
        if (raceType == RACE_HALF) {
            return 21;
        }
        if (raceType == RACE_TEN) {
            return 9;
        }
        return 4;
    }

    function resolveSplitPhase(splitKm, raceDistanceKm) {
        if (raceDistanceKm == null or raceDistanceKm <= 0) {
            return PHASE_EARLY;
        }

        var progress = splitKm / raceDistanceKm;
        if (progress < 0.34) {
            return PHASE_EARLY;
        }
        if (progress < 0.80) {
            return PHASE_MID;
        }
        return PHASE_LATE;
    }

    function hasReachedTarget(distanceKm, targetKm, epsilonKm) {
        if (distanceKm == null or targetKm == null) {
            return false;
        }
        return distanceKm >= (targetKm - epsilonKm);
    }
}
