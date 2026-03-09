module RaceStrategyUtils {
    const PROFILE_FULL = 0;
    const PROFILE_HALF = 1;
    const PROFILE_SHORT = 2;

    const PHASE_1 = 0;
    const PHASE_2 = 1;
    const PHASE_3 = 2;
    const PHASE_4 = 3;
    const PHASE_5 = 4;

    function resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm) {
        if (raceDistanceKm != null and raceDistanceKm <= shortDistanceMaxKm) {
            return PROFILE_SHORT;
        }
        if (raceDistanceKm != null and abs(raceDistanceKm - halfDistanceKm) <= halfToleranceKm) {
            return PROFILE_HALF;
        }
        return PROFILE_FULL;
    }

    function resolveRaceProgress(distanceKm, raceDistanceKm) {
        if (distanceKm == null or raceDistanceKm == null or raceDistanceKm <= 0) {
            return null;
        }
        var progress = distanceKm / raceDistanceKm;
        if (progress < 0) {
            progress = 0;
        }
        if (progress > 1.0) {
            progress = 1.0;
        }
        return progress;
    }

    function resolveRacePhase(
        distanceKm,
        raceDistanceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress
    ) {
        var progress = resolveRaceProgress(distanceKm, raceDistanceKm);
        if (progress == null) {
            return PHASE_1;
        }
        if (progress < phase1EndProgress) {
            return PHASE_1;
        }
        if (progress < phase2EndProgress) {
            return PHASE_2;
        }
        if (progress < phase3EndProgress) {
            return PHASE_3;
        }
        if (progress < phase4EndProgress) {
            return PHASE_4;
        }
        return PHASE_5;
    }

    function getAllowedZoneNumber(
        distanceKm,
        raceDistanceKm,
        shortDistanceMaxKm,
        halfDistanceKm,
        halfToleranceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress
    ) {
        var phase = resolveRacePhase(
            distanceKm,
            raceDistanceKm,
            phase1EndProgress,
            phase2EndProgress,
            phase3EndProgress,
            phase4EndProgress
        );
        var profile = resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm);
        if (profile == PROFILE_SHORT) {
            if (phase == PHASE_1) {
                return 4;
            }
            return 5;
        }
        if (profile == PROFILE_HALF) {
            if (phase == PHASE_1) {
                return 3;
            }
            return 4;
        }
        if (phase == PHASE_1) {
            return 2;
        }
        if (phase == PHASE_2 or phase == PHASE_3) {
            return 3;
        }
        return 4;
    }

    function getAllowedZoneOffsetBpm(
        distanceKm,
        raceDistanceKm,
        shortDistanceMaxKm,
        halfDistanceKm,
        halfToleranceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress
    ) {
        var phase = resolveRacePhase(
            distanceKm,
            raceDistanceKm,
            phase1EndProgress,
            phase2EndProgress,
            phase3EndProgress,
            phase4EndProgress
        );
        var profile = resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm);
        if (profile == PROFILE_SHORT) {
            if (phase == PHASE_1) {
                return 0;
            }
            if (phase == PHASE_2) {
                return 2;
            }
            if (phase == PHASE_3) {
                return 3;
            }
            if (phase == PHASE_4) {
                return 4;
            }
            return 5;
        }
        if (profile == PROFILE_HALF) {
            if (phase == PHASE_2) {
                return -2;
            }
            if (phase == PHASE_4) {
                return 2;
            }
            if (phase == PHASE_5) {
                return 4;
            }
            return 0;
        }
        if (phase == PHASE_3) {
            return 2;
        }
        if (phase == PHASE_5) {
            return 3;
        }
        return 0;
    }

    function getHrOverTriggerSec(
        distanceKm,
        raceDistanceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress
    ) {
        var phase = resolveRacePhase(
            distanceKm,
            raceDistanceKm,
            phase1EndProgress,
            phase2EndProgress,
            phase3EndProgress,
            phase4EndProgress
        );
        if (phase == PHASE_4) {
            return 10;
        }
        if (phase == PHASE_5) {
            return 20;
        }
        return 12;
    }

    function getHrOverReleaseSec(distanceKm) {
        return 5;
    }

    function getHrOverReleaseOffsetBpm(
        distanceKm,
        raceDistanceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress
    ) {
        var phase = resolveRacePhase(
            distanceKm,
            raceDistanceKm,
            phase1EndProgress,
            phase2EndProgress,
            phase3EndProgress,
            phase4EndProgress
        );
        if (phase == PHASE_4) {
            return 1;
        }
        return 2;
    }

    function getPushPaceDeltaThresholdSec(
        distanceKm,
        raceDistanceKm,
        shortDistanceMaxKm,
        halfDistanceKm,
        halfToleranceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress
    ) {
        var phase = resolveRacePhase(
            distanceKm,
            raceDistanceKm,
            phase1EndProgress,
            phase2EndProgress,
            phase3EndProgress,
            phase4EndProgress
        );
        var profile = resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm);
        if (profile == PROFILE_SHORT) {
            if (phase == PHASE_1) {
                return 8;
            }
            if (phase == PHASE_2) {
                return 5;
            }
            if (phase == PHASE_3) {
                return 3;
            }
            if (phase == PHASE_4) {
                return 2;
            }
            return 1;
        }
        if (profile == PROFILE_HALF) {
            if (phase == PHASE_1) {
                return 10;
            }
            if (phase == PHASE_2) {
                return 6;
            }
            if (phase == PHASE_3) {
                return 4;
            }
            if (phase == PHASE_4) {
                return 3;
            }
            return 2;
        }
        if (phase == PHASE_1) {
            return 12;
        }
        if (phase == PHASE_2) {
            return 8;
        }
        if (phase == PHASE_3) {
            return 6;
        }
        if (phase == PHASE_4) {
            return 4;
        }
        return 3;
    }

    function getPushHeadroomThresholdBpm(
        distanceKm,
        raceDistanceKm,
        shortDistanceMaxKm,
        halfDistanceKm,
        halfToleranceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress
    ) {
        var phase = resolveRacePhase(
            distanceKm,
            raceDistanceKm,
            phase1EndProgress,
            phase2EndProgress,
            phase3EndProgress,
            phase4EndProgress
        );
        var profile = resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm);
        if (profile == PROFILE_SHORT) {
            if (phase == PHASE_1) {
                return 6;
            }
            if (phase == PHASE_2) {
                return 4;
            }
            if (phase == PHASE_3) {
                return 2;
            }
            if (phase == PHASE_4) {
                return 1;
            }
            return 0;
        }
        if (profile == PROFILE_HALF) {
            if (phase == PHASE_1) {
                return 7;
            }
            if (phase == PHASE_2) {
                return 5;
            }
            if (phase == PHASE_3) {
                return 3;
            }
            if (phase == PHASE_4) {
                return 2;
            }
            return 1;
        }
        if (phase == PHASE_1) {
            return 8;
        }
        if (phase == PHASE_2) {
            return 6;
        }
        if (phase == PHASE_3) {
            return 4;
        }
        if (phase == PHASE_4) {
            return 3;
        }
        return 2;
    }

    function getActionEaseMinHeadroomBpm(
        distanceKm,
        raceDistanceKm,
        shortDistanceMaxKm,
        halfDistanceKm,
        halfToleranceKm,
        defaultValue
    ) {
        var profile = resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm);
        if (profile == PROFILE_SHORT) {
            return 1;
        }
        if (profile == PROFILE_HALF) {
            return 2;
        }
        return defaultValue;
    }

    function getActionEaseBaselineHrDeltaBpm(
        distanceKm,
        raceDistanceKm,
        shortDistanceMaxKm,
        halfDistanceKm,
        halfToleranceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress,
        defaultValue
    ) {
        var phase = resolveRacePhase(
            distanceKm,
            raceDistanceKm,
            phase1EndProgress,
            phase2EndProgress,
            phase3EndProgress,
            phase4EndProgress
        );
        var profile = resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm);
        if (profile == PROFILE_SHORT) {
            if (phase == PHASE_1) {
                return 8;
            }
            if (phase == PHASE_2) {
                return 9;
            }
            if (phase == PHASE_3) {
                return 10;
            }
            if (phase == PHASE_4) {
                return 11;
            }
            return 12;
        }
        if (profile == PROFILE_HALF) {
            if (phase == PHASE_1) {
                return 6;
            }
            if (phase == PHASE_2) {
                return 7;
            }
            if (phase == PHASE_3) {
                return 8;
            }
            if (phase == PHASE_4) {
                return 9;
            }
            return 10;
        }
        if (phase == PHASE_1) {
            return 5;
        }
        if (phase == PHASE_4) {
            return 5;
        }
        if (phase == PHASE_5) {
            return 4;
        }
        return defaultValue;
    }

    function getCardiacCostPushMaxRatio(
        distanceKm,
        raceDistanceKm,
        shortDistanceMaxKm,
        halfDistanceKm,
        halfToleranceKm,
        fullRatio,
        halfRatio,
        shortRatio
    ) {
        var profile = resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm);
        if (profile == PROFILE_SHORT) {
            return shortRatio;
        }
        if (profile == PROFILE_HALF) {
            return halfRatio;
        }
        return fullRatio;
    }

    function getCardiacCostEaseMinRatio(
        distanceKm,
        raceDistanceKm,
        shortDistanceMaxKm,
        halfDistanceKm,
        halfToleranceKm,
        fullRatio,
        halfRatio,
        shortRatio
    ) {
        var profile = resolveRaceProfile(raceDistanceKm, shortDistanceMaxKm, halfDistanceKm, halfToleranceKm);
        if (profile == PROFILE_SHORT) {
            return shortRatio;
        }
        if (profile == PROFILE_HALF) {
            return halfRatio;
        }
        return fullRatio;
    }

    function abs(value) {
        if (value < 0) {
            return -value;
        }
        return value;
    }
}
