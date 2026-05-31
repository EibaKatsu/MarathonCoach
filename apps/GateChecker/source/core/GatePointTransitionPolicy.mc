using Toybox.Lang as Lang;

module GatePointTransitionPolicy {
    const DISPLAY_HOLD_AFTER_POINT_KM = 0.2;

    function shouldDisplayPoint(currentDistanceKm, pointDistanceKm) as Lang.Boolean {
        if (currentDistanceKm == null or pointDistanceKm == null) {
            return false;
        }

        return currentDistanceKm < getAdvanceDistanceKm(pointDistanceKm);
    }

    function getAdvanceDistanceKm(pointDistanceKm) {
        if (pointDistanceKm == null) {
            return null;
        }

        return pointDistanceKm + DISPLAY_HOLD_AFTER_POINT_KM;
    }
}
