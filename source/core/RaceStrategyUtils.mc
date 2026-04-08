using Toybox.Lang as Lang;
using Toybox.Math as Math;

module RaceStrategyUtils {
    const PROFILE_FULL = 0;
    const PROFILE_HALF = 1;
    const PROFILE_SHORT = 2;

    const PHASE_1 = 0;
    const PHASE_2 = 1;
    const PHASE_3 = 2;
    const PHASE_4 = 3;
    const PHASE_5 = 4;

    const CAP_SOURCE_NONE = 0;
    const CAP_SOURCE_CUSTOM_CODE = 1;
    const CAP_SOURCE_LTHR_PROPERTY = 2;
    const CAP_SOURCE_LTHR_DEVICE = 3;
    const CAP_SOURCE_HRR = 4;
    const CAP_SOURCE_MAXHR = 5;

    const MIN_VALID_HEART_RATE_BPM = 30;
    const MAX_VALID_HEART_RATE_BPM = 260;
    const MIN_PLAUSIBLE_MAXHR_ABOVE_LTHR_BPM = 5;

    const CAP_RATIO_LTHR = [
        [0.95, 0.96, 0.97, 0.98, 0.99],
        [0.97, 0.98, 0.99, 1.00, 1.01],
        [0.99, 1.00, 1.01, 1.02, 1.03]
    ];
    const CAP_RATIO_HRR = [
        [0.78, 0.80, 0.82, 0.84, 0.86],
        [0.83, 0.85, 0.87, 0.89, 0.90],
        [0.88, 0.89, 0.90, 0.91, 0.92]
    ];
    const CAP_RATIO_MAXHR = [
        [0.84, 0.85, 0.86, 0.87, 0.88],
        [0.88, 0.89, 0.90, 0.91, 0.92],
        [0.90, 0.91, 0.92, 0.93, 0.94]
    ];

    const HR_OVER_TRIGGER_DELTA_BPM = 2;
    const HR_OVER_STRONG_TRIGGER_DELTA_BPM = 4;
    const HR_OVER_RELEASE_DELTA_BPM = 2;
    const HR_OVER_TRIGGER_SEC = 8;
    const HR_OVER_STRONG_TRIGGER_SEC = 3;
    const HR_OVER_RELEASE_SEC = 5;

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

    function resolveCapSource(propertyLthr, deviceLthr, maxHeartRate, restingHeartRate) {
        if (_isValidHeartRateAnchor(propertyLthr)) {
            return CAP_SOURCE_LTHR_PROPERTY;
        }
        if (_isValidHeartRateAnchor(deviceLthr)) {
            return CAP_SOURCE_LTHR_DEVICE;
        }
        if (
            _isValidHeartRateAnchor(maxHeartRate) and
            _isValidHeartRateAnchor(restingHeartRate) and
            maxHeartRate > restingHeartRate
        ) {
            return CAP_SOURCE_HRR;
        }
        if (_isValidHeartRateAnchor(maxHeartRate)) {
            return CAP_SOURCE_MAXHR;
        }
        return CAP_SOURCE_NONE;
    }

    function resolveCapHeartRateDecision(
        profile,
        phase,
        customCodeDirectCapHeartRates,
        propertyLthr,
        deviceLthr,
        maxHeartRate,
        restingHeartRate
    ) {
        var customCodeCap = resolveCustomCodeDirectCapHeartRate(customCodeDirectCapHeartRates, phase);
        if (customCodeCap != null) {
            return [customCodeCap, CAP_SOURCE_CUSTOM_CODE, null];
        }

        var propertyCap = resolveCapHeartRate(
            CAP_SOURCE_LTHR_PROPERTY,
            profile,
            phase,
            propertyLthr,
            maxHeartRate,
            restingHeartRate
        );
        if (propertyCap != null) {
            return [propertyCap, CAP_SOURCE_LTHR_PROPERTY, propertyLthr];
        }

        var deviceCap = resolveCapHeartRate(
            CAP_SOURCE_LTHR_DEVICE,
            profile,
            phase,
            deviceLthr,
            maxHeartRate,
            restingHeartRate
        );
        if (deviceCap != null) {
            return [deviceCap, CAP_SOURCE_LTHR_DEVICE, deviceLthr];
        }

        var hrrCap = resolveCapHeartRate(
            CAP_SOURCE_HRR,
            profile,
            phase,
            null,
            maxHeartRate,
            restingHeartRate
        );
        if (hrrCap != null) {
            return [hrrCap, CAP_SOURCE_HRR, null];
        }

        var maxHrCap = resolveCapHeartRate(
            CAP_SOURCE_MAXHR,
            profile,
            phase,
            null,
            maxHeartRate,
            restingHeartRate
        );
        if (maxHrCap != null) {
            return [maxHrCap, CAP_SOURCE_MAXHR, null];
        }

        return [null, CAP_SOURCE_NONE, null];
    }

    function resolveCapRatio(profile, phase, source) {
        var table = null;
        if (_isLthrSource(source)) {
            table = CAP_RATIO_LTHR;
        } else if (source == CAP_SOURCE_HRR) {
            table = CAP_RATIO_HRR;
        } else if (source == CAP_SOURCE_MAXHR) {
            table = CAP_RATIO_MAXHR;
        } else {
            return null;
        }

        if (profile == null or profile < PROFILE_FULL or profile > PROFILE_SHORT) {
            return null;
        }
        if (phase == null or phase < PHASE_1 or phase > PHASE_5) {
            return null;
        }

        return table[profile][phase];
    }

    function resolveCapBaseHeartRate(source, profile, phase, lthr, maxHeartRate, restingHeartRate) {
        var ratio = resolveCapRatio(profile, phase, source);
        if (ratio == null) {
            return null;
        }

        if (_isLthrSource(source)) {
            if (!_isValidHeartRateAnchor(lthr)) {
                return null;
            }
            return lthr * ratio;
        }

        if (source == CAP_SOURCE_HRR) {
            if (
                !_isValidHeartRateAnchor(maxHeartRate) or
                !_isValidHeartRateAnchor(restingHeartRate) or
                maxHeartRate <= restingHeartRate
            ) {
                return null;
            }
            return restingHeartRate + ((maxHeartRate - restingHeartRate) * ratio);
        }

        if (source == CAP_SOURCE_MAXHR) {
            if (!_isValidHeartRateAnchor(maxHeartRate)) {
                return null;
            }
            return maxHeartRate * ratio;
        }

        return null;
    }

    function resolveCapUpperClip(profile, source, lthr, maxHeartRate) {
        var upper = null;
        var allowMaxHeartRateClip = _canApplyMaxHeartRateClip(source, lthr, maxHeartRate);

        if (profile == PROFILE_FULL) {
            if (_isLthrSource(source) and _isValidHeartRateAnchor(lthr)) {
                upper = lthr + 1;
            }
            if (allowMaxHeartRateClip) {
                upper = _minNonNull(upper, maxHeartRate - 3);
            }
            return upper;
        }

        if (profile == PROFILE_HALF) {
            if (_isLthrSource(source) and _isValidHeartRateAnchor(lthr)) {
                upper = lthr + 3;
            }
            if (allowMaxHeartRateClip) {
                upper = _minNonNull(upper, maxHeartRate - 2);
            }
            return upper;
        }

        if (profile == PROFILE_SHORT and allowMaxHeartRateClip) {
            return maxHeartRate - 1;
        }

        return null;
    }

    function resolveCapLowerClip(restingHeartRate) {
        if (_isValidHeartRateAnchor(restingHeartRate)) {
            return restingHeartRate + 1;
        }
        return 1;
    }

    function resolveCapHeartRate(source, profile, phase, lthr, maxHeartRate, restingHeartRate) {
        var cap = resolveCapBaseHeartRate(source, profile, phase, lthr, maxHeartRate, restingHeartRate);
        if (cap == null) {
            return null;
        }

        var upper = resolveCapUpperClip(profile, source, lthr, maxHeartRate);
        if (upper != null and cap > upper) {
            cap = upper;
        }

        var lower = resolveCapLowerClip(restingHeartRate);
        if (cap < lower) {
            cap = lower;
        }

        var rounded = roundNearest(cap);
        if (upper != null and rounded > upper) {
            rounded = Math.floor(upper);
        }
        if (rounded < lower) {
            rounded = lower;
        }
        if (rounded < 1) {
            rounded = 1;
        }
        return rounded;
    }

    function resolveCustomCodeDirectCapHeartRate(customCodeDirectCapHeartRates, phase) {
        if (
            customCodeDirectCapHeartRates == null or
            !(customCodeDirectCapHeartRates instanceof Lang.Array) or
            customCodeDirectCapHeartRates.size() != 5
        ) {
            return null;
        }
        if (phase == null or phase < PHASE_1 or phase > PHASE_5) {
            return null;
        }
        for (var i = 0; i < customCodeDirectCapHeartRates.size(); i += 1) {
            if (!_isValidHeartRateAnchor(customCodeDirectCapHeartRates[i])) {
                return null;
            }
        }
        return roundNearest(customCodeDirectCapHeartRates[phase]);
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
        return HR_OVER_TRIGGER_SEC;
    }

    function getHrOverReleaseSec(distanceKm) {
        return HR_OVER_RELEASE_SEC;
    }

    function getHrOverStrongTriggerSec() {
        return HR_OVER_STRONG_TRIGGER_SEC;
    }

    function getHrOverTriggerDeltaBpm() {
        return HR_OVER_TRIGGER_DELTA_BPM;
    }

    function getHrOverStrongTriggerDeltaBpm() {
        return HR_OVER_STRONG_TRIGGER_DELTA_BPM;
    }

    function getHrOverReleaseOffsetBpm(
        distanceKm,
        raceDistanceKm,
        phase1EndProgress,
        phase2EndProgress,
        phase3EndProgress,
        phase4EndProgress
    ) {
        return HR_OVER_RELEASE_DELTA_BPM;
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

    function roundNearest(value) {
        if (value == null) {
            return null;
        }
        if (value >= 0) {
            return Math.floor(value + 0.5);
        }
        return -Math.floor((-value) + 0.5);
    }

    function normalizeHeartRate(value) {
        if (value == null) {
            return null;
        }
        try {
            if (value != value) {
                return null;
            }
        } catch (e) {
            return null;
        }

        var rounded = roundNearest(value);
        if (rounded == null) {
            return null;
        }
        if (rounded < MIN_VALID_HEART_RATE_BPM or rounded > MAX_VALID_HEART_RATE_BPM) {
            return null;
        }
        return rounded;
    }

    function _isValidHeartRateAnchor(value) {
        return normalizeHeartRate(value) != null;
    }

    function _canApplyMaxHeartRateClip(source, lthr, maxHeartRate) {
        if (!_isValidHeartRateAnchor(maxHeartRate)) {
            return false;
        }
        if (!_isLthrSource(source)) {
            return true;
        }
        if (!_isValidHeartRateAnchor(lthr)) {
            return false;
        }
        return maxHeartRate >= (lthr + MIN_PLAUSIBLE_MAXHR_ABOVE_LTHR_BPM);
    }

    function _isLthrSource(source) {
        return source == CAP_SOURCE_LTHR_PROPERTY or source == CAP_SOURCE_LTHR_DEVICE;
    }

    function _minNonNull(left, right) {
        if (left == null) {
            return right;
        }
        if (right == null) {
            return left;
        }
        if (left <= right) {
            return left;
        }
        return right;
    }

    function abs(value) {
        if (value < 0) {
            return -value;
        }
        return value;
    }
}
