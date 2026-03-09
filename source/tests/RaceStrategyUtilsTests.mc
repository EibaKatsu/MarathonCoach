using Toybox.Test;

const RS_SHORT_DISTANCE_MAX_KM = 10.5;
const RS_HALF_DISTANCE_KM = 21.0975;
const RS_HALF_TOLERANCE_KM = 0.25;
const RS_PHASE_1_END = 0.24;
const RS_PHASE_2_END = 0.59;
const RS_PHASE_3_END = 0.83;
const RS_PHASE_4_END = 0.95;

function _rsAssertNear(actual, expected, epsilon, message) {
    Test.assertMessage((actual - expected) <= epsilon and (expected - actual) <= epsilon, message);
}

function _rsPhase(distanceKm, raceDistanceKm) {
    return RaceStrategyUtils.resolveRacePhase(
        distanceKm,
        raceDistanceKm,
        RS_PHASE_1_END,
        RS_PHASE_2_END,
        RS_PHASE_3_END,
        RS_PHASE_4_END
    );
}

function _rsAllowedZone(distanceKm, raceDistanceKm) {
    return RaceStrategyUtils.getAllowedZoneNumber(
        distanceKm,
        raceDistanceKm,
        RS_SHORT_DISTANCE_MAX_KM,
        RS_HALF_DISTANCE_KM,
        RS_HALF_TOLERANCE_KM,
        RS_PHASE_1_END,
        RS_PHASE_2_END,
        RS_PHASE_3_END,
        RS_PHASE_4_END
    );
}

function _rsAllowedZoneOffset(distanceKm, raceDistanceKm) {
    return RaceStrategyUtils.getAllowedZoneOffsetBpm(
        distanceKm,
        raceDistanceKm,
        RS_SHORT_DISTANCE_MAX_KM,
        RS_HALF_DISTANCE_KM,
        RS_HALF_TOLERANCE_KM,
        RS_PHASE_1_END,
        RS_PHASE_2_END,
        RS_PHASE_3_END,
        RS_PHASE_4_END
    );
}

(:test)
function testRaceStrategyResolveProfile(logger) {
    Test.assertEqual(
        RaceStrategyUtils.PROFILE_SHORT,
        RaceStrategyUtils.resolveRaceProfile(
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM
        )
    );
    Test.assertEqual(
        RaceStrategyUtils.PROFILE_HALF,
        RaceStrategyUtils.resolveRaceProfile(
            21.20,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM
        )
    );
    Test.assertEqual(
        RaceStrategyUtils.PROFILE_FULL,
        RaceStrategyUtils.resolveRaceProfile(
            20.84,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM
        )
    );
    Test.assertEqual(
        RaceStrategyUtils.PROFILE_FULL,
        RaceStrategyUtils.resolveRaceProfile(
            null,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM
        )
    );
    return true;
}

(:test)
function testRaceStrategyProgressAndPhase(logger) {
    Test.assertMessage(RaceStrategyUtils.resolveRaceProgress(null, 42.195) == null, "null distance");
    Test.assertMessage(RaceStrategyUtils.resolveRaceProgress(1.0, null) == null, "null race distance");
    _rsAssertNear(RaceStrategyUtils.resolveRaceProgress(-1.0, 42.195), 0.0, 0.0001, "progress lower clamp");
    _rsAssertNear(RaceStrategyUtils.resolveRaceProgress(50.0, 42.195), 1.0, 0.0001, "progress upper clamp");
    _rsAssertNear(RaceStrategyUtils.resolveRaceProgress(21.0975, 42.195), 0.5, 0.0001, "progress half");

    Test.assertEqual(RaceStrategyUtils.PHASE_1, _rsPhase(null, 42.195));
    Test.assertEqual(RaceStrategyUtils.PHASE_1, _rsPhase(42.195 * 0.23, 42.195));
    Test.assertEqual(RaceStrategyUtils.PHASE_2, _rsPhase(42.195 * 0.24, 42.195));
    Test.assertEqual(RaceStrategyUtils.PHASE_3, _rsPhase(42.195 * 0.59, 42.195));
    Test.assertEqual(RaceStrategyUtils.PHASE_4, _rsPhase(42.195 * 0.83, 42.195));
    Test.assertEqual(RaceStrategyUtils.PHASE_5, _rsPhase(42.195 * 0.95, 42.195));
    return true;
}

(:test)
function testRaceStrategyAllowedZoneRules(logger) {
    Test.assertEqual(4, _rsAllowedZone(1.0, 10.0));
    Test.assertEqual(5, _rsAllowedZone(3.0, 10.0));
    Test.assertEqual(0, _rsAllowedZoneOffset(1.0, 10.0));
    Test.assertEqual(2, _rsAllowedZoneOffset(3.0, 10.0));
    Test.assertEqual(4, _rsAllowedZoneOffset(8.8, 10.0));
    Test.assertEqual(5, _rsAllowedZoneOffset(10.0, 10.0));

    Test.assertEqual(3, _rsAllowedZone(1.0, RS_HALF_DISTANCE_KM));
    Test.assertEqual(4, _rsAllowedZone(12.6, RS_HALF_DISTANCE_KM));
    Test.assertEqual(0, _rsAllowedZoneOffset(1.0, RS_HALF_DISTANCE_KM));
    Test.assertEqual(-2, _rsAllowedZoneOffset(11.0, RS_HALF_DISTANCE_KM));
    Test.assertEqual(2, _rsAllowedZoneOffset(19.5, RS_HALF_DISTANCE_KM));
    Test.assertEqual(4, _rsAllowedZoneOffset(21.1, RS_HALF_DISTANCE_KM));

    Test.assertEqual(2, _rsAllowedZone(5.0, 42.195));
    Test.assertEqual(3, _rsAllowedZone(20.0, 42.195));
    Test.assertEqual(3, _rsAllowedZone(30.0, 42.195));
    Test.assertEqual(4, _rsAllowedZone(38.0, 42.195));
    Test.assertEqual(4, _rsAllowedZone(42.2, 42.195));
    Test.assertEqual(0, _rsAllowedZoneOffset(20.0, 42.195));
    Test.assertEqual(2, _rsAllowedZoneOffset(30.0, 42.195));
    Test.assertEqual(3, _rsAllowedZoneOffset(42.2, 42.195));
    return true;
}

(:test)
function testRaceStrategyHrOverRules(logger) {
    Test.assertEqual(
        10,
        RaceStrategyUtils.getHrOverTriggerSec(
            40.0,
            42.195,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        20,
        RaceStrategyUtils.getHrOverTriggerSec(
            42.2,
            42.195,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        12,
        RaceStrategyUtils.getHrOverTriggerSec(
            20.0,
            42.195,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(5, RaceStrategyUtils.getHrOverReleaseSec(20.0));
    Test.assertEqual(
        1,
        RaceStrategyUtils.getHrOverReleaseOffsetBpm(
            40.0,
            42.195,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        2,
        RaceStrategyUtils.getHrOverReleaseOffsetBpm(
            20.0,
            42.195,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    return true;
}

(:test)
function testRaceStrategyPushThresholdRules(logger) {
    Test.assertEqual(
        8,
        RaceStrategyUtils.getPushPaceDeltaThresholdSec(
            1.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        2,
        RaceStrategyUtils.getPushPaceDeltaThresholdSec(
            9.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        10,
        RaceStrategyUtils.getPushPaceDeltaThresholdSec(
            1.0,
            RS_HALF_DISTANCE_KM,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        2,
        RaceStrategyUtils.getPushPaceDeltaThresholdSec(
            21.1,
            RS_HALF_DISTANCE_KM,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        12,
        RaceStrategyUtils.getPushPaceDeltaThresholdSec(
            1.0,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        3,
        RaceStrategyUtils.getPushPaceDeltaThresholdSec(
            42.2,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );

    Test.assertEqual(
        6,
        RaceStrategyUtils.getPushHeadroomThresholdBpm(
            1.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        0,
        RaceStrategyUtils.getPushHeadroomThresholdBpm(
            10.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        7,
        RaceStrategyUtils.getPushHeadroomThresholdBpm(
            1.0,
            RS_HALF_DISTANCE_KM,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        1,
        RaceStrategyUtils.getPushHeadroomThresholdBpm(
            21.1,
            RS_HALF_DISTANCE_KM,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        8,
        RaceStrategyUtils.getPushHeadroomThresholdBpm(
            1.0,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    Test.assertEqual(
        2,
        RaceStrategyUtils.getPushHeadroomThresholdBpm(
            42.2,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END
        )
    );
    return true;
}

(:test)
function testRaceStrategyActionEaseAndCardiacCostRules(logger) {
    Test.assertEqual(
        1,
        RaceStrategyUtils.getActionEaseMinHeadroomBpm(
            1.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            3
        )
    );
    Test.assertEqual(
        2,
        RaceStrategyUtils.getActionEaseMinHeadroomBpm(
            1.0,
            RS_HALF_DISTANCE_KM,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            3
        )
    );
    Test.assertEqual(
        3,
        RaceStrategyUtils.getActionEaseMinHeadroomBpm(
            1.0,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            3
        )
    );

    Test.assertEqual(
        8,
        RaceStrategyUtils.getActionEaseBaselineHrDeltaBpm(
            1.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END,
            6
        )
    );
    Test.assertEqual(
        12,
        RaceStrategyUtils.getActionEaseBaselineHrDeltaBpm(
            10.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END,
            6
        )
    );
    Test.assertEqual(
        9,
        RaceStrategyUtils.getActionEaseBaselineHrDeltaBpm(
            19.5,
            RS_HALF_DISTANCE_KM,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END,
            6
        )
    );
    Test.assertEqual(
        5,
        RaceStrategyUtils.getActionEaseBaselineHrDeltaBpm(
            1.0,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END,
            6
        )
    );
    Test.assertEqual(
        6,
        RaceStrategyUtils.getActionEaseBaselineHrDeltaBpm(
            20.0,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END,
            6
        )
    );
    Test.assertEqual(
        4,
        RaceStrategyUtils.getActionEaseBaselineHrDeltaBpm(
            42.2,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            RS_PHASE_1_END,
            RS_PHASE_2_END,
            RS_PHASE_3_END,
            RS_PHASE_4_END,
            6
        )
    );

    _rsAssertNear(
        RaceStrategyUtils.getCardiacCostPushMaxRatio(
            20.0,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            1.06,
            1.08,
            1.10
        ),
        1.06,
        0.0001,
        "push max full"
    );
    _rsAssertNear(
        RaceStrategyUtils.getCardiacCostPushMaxRatio(
            20.0,
            RS_HALF_DISTANCE_KM,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            1.06,
            1.08,
            1.10
        ),
        1.08,
        0.0001,
        "push max half"
    );
    _rsAssertNear(
        RaceStrategyUtils.getCardiacCostPushMaxRatio(
            8.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            1.06,
            1.08,
            1.10
        ),
        1.10,
        0.0001,
        "push max short"
    );
    _rsAssertNear(
        RaceStrategyUtils.getCardiacCostEaseMinRatio(
            20.0,
            42.195,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            1.10,
            1.12,
            1.15
        ),
        1.10,
        0.0001,
        "ease min full"
    );
    _rsAssertNear(
        RaceStrategyUtils.getCardiacCostEaseMinRatio(
            20.0,
            RS_HALF_DISTANCE_KM,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            1.10,
            1.12,
            1.15
        ),
        1.12,
        0.0001,
        "ease min half"
    );
    _rsAssertNear(
        RaceStrategyUtils.getCardiacCostEaseMinRatio(
            8.0,
            10.0,
            RS_SHORT_DISTANCE_MAX_KM,
            RS_HALF_DISTANCE_KM,
            RS_HALF_TOLERANCE_KM,
            1.10,
            1.12,
            1.15
        ),
        1.15,
        0.0001,
        "ease min short"
    );
    return true;
}
