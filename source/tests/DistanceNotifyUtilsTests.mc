using Toybox.Test;

function _distanceNotifyAbs(value) {
    if (value < 0) {
        return -value;
    }
    return value;
}

function _distanceNotifyAssertNear(actual, expected, epsilon, message) {
    if (actual == null or expected == null) {
        Test.assertMessage(actual == expected, message);
        return;
    }
    Test.assertMessage(_distanceNotifyAbs(actual - expected) <= epsilon, message);
}

(:test)
function testDistanceNotifyResolveRaceType(logger) {
    Test.assertEqual(
        DistanceNotifyUtils.RACE_FIVE,
        DistanceNotifyUtils.resolveRaceType(5.0, 21.0975, 0.25)
    );
    Test.assertEqual(
        DistanceNotifyUtils.RACE_HALF,
        DistanceNotifyUtils.resolveRaceType(21.20, 21.0975, 0.25)
    );
    Test.assertEqual(
        DistanceNotifyUtils.RACE_TEN,
        DistanceNotifyUtils.resolveRaceType(10.0, 21.0975, 0.25)
    );
    Test.assertEqual(
        DistanceNotifyUtils.RACE_FULL,
        DistanceNotifyUtils.resolveRaceType(30.0, 21.0975, 0.25)
    );
    return true;
}

(:test)
function testDistanceNotifyCheckpointCount(logger) {
    Test.assertEqual(1, DistanceNotifyUtils.getCheckpointCount(DistanceNotifyUtils.RACE_FIVE));
    Test.assertEqual(2, DistanceNotifyUtils.getCheckpointCount(DistanceNotifyUtils.RACE_TEN));
    Test.assertEqual(2, DistanceNotifyUtils.getCheckpointCount(DistanceNotifyUtils.RACE_HALF));
    Test.assertEqual(2, DistanceNotifyUtils.getCheckpointCount(DistanceNotifyUtils.RACE_FULL));
    return true;
}

(:test)
function testDistanceNotifyCheckpointKm(logger) {
    _distanceNotifyAssertNear(
        DistanceNotifyUtils.getCheckpointKm(DistanceNotifyUtils.RACE_FULL, 0),
        21.1,
        0.0001,
        "full checkpoint 0"
    );
    _distanceNotifyAssertNear(
        DistanceNotifyUtils.getCheckpointKm(DistanceNotifyUtils.RACE_FULL, 1),
        42.2,
        0.0001,
        "full checkpoint 1"
    );
    _distanceNotifyAssertNear(
        DistanceNotifyUtils.getCheckpointKm(DistanceNotifyUtils.RACE_HALF, 0),
        10.0,
        0.0001,
        "half checkpoint 0"
    );
    _distanceNotifyAssertNear(
        DistanceNotifyUtils.getCheckpointKm(DistanceNotifyUtils.RACE_TEN, 1),
        10.0,
        0.0001,
        "ten checkpoint 1"
    );
    _distanceNotifyAssertNear(
        DistanceNotifyUtils.getCheckpointKm(DistanceNotifyUtils.RACE_FIVE, 0),
        5.0,
        0.0001,
        "five checkpoint 0"
    );
    Test.assertMessage(
        DistanceNotifyUtils.getCheckpointKm(DistanceNotifyUtils.RACE_FIVE, 1) == null,
        "five checkpoint 1 should be null"
    );
    return true;
}

(:test)
function testDistanceNotifyMaxSplitKm(logger) {
    Test.assertEqual(42, DistanceNotifyUtils.getMaxSplitKm(DistanceNotifyUtils.RACE_FULL));
    Test.assertEqual(21, DistanceNotifyUtils.getMaxSplitKm(DistanceNotifyUtils.RACE_HALF));
    Test.assertEqual(9, DistanceNotifyUtils.getMaxSplitKm(DistanceNotifyUtils.RACE_TEN));
    Test.assertEqual(4, DistanceNotifyUtils.getMaxSplitKm(DistanceNotifyUtils.RACE_FIVE));
    return true;
}

(:test)
function testDistanceNotifyResolveSplitPhase(logger) {
    Test.assertEqual(DistanceNotifyUtils.PHASE_EARLY, DistanceNotifyUtils.resolveSplitPhase(1, 42.195));
    Test.assertEqual(DistanceNotifyUtils.PHASE_MID, DistanceNotifyUtils.resolveSplitPhase(15, 42.195));
    Test.assertEqual(DistanceNotifyUtils.PHASE_LATE, DistanceNotifyUtils.resolveSplitPhase(35, 42.195));
    Test.assertEqual(DistanceNotifyUtils.PHASE_EARLY, DistanceNotifyUtils.resolveSplitPhase(5, null));
    return true;
}

(:test)
function testDistanceNotifyHasReachedTarget(logger) {
    Test.assertEqual(false, DistanceNotifyUtils.hasReachedTarget(null, 10.0, 0.02));
    Test.assertEqual(false, DistanceNotifyUtils.hasReachedTarget(9.95, 10.0, 0.02));
    Test.assertEqual(true, DistanceNotifyUtils.hasReachedTarget(9.99, 10.0, 0.02));
    Test.assertEqual(true, DistanceNotifyUtils.hasReachedTarget(10.0, 10.0, 0.02));
    return true;
}
