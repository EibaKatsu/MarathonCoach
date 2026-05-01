using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.WatchUi as Ui;
using GateDistanceUtils;

module GateRaceData {
    const GATE_POINT = 0;
    const GATE_CUTOFF_DAY_OFFSET = 1;
    const GATE_CUTOFF_MINUTE_OF_DAY = 2;

    function getRaceNameJpn() {
        return GateRaceConfig.getRaceNameJpn();
    }

    function getRaceNameEng() {
        return GateRaceConfig.getRaceNameEng();
    }

    function getRaceKey() {
        return GateRaceConfig.getRaceKey();
    }

    function getRaceDistanceKm() {
        return GateRaceConfig.getRaceDistanceKm();
    }

    function getRaceYear() {
        return GateRaceConfig.getRaceYear();
    }

    function getRaceMonth() {
        return GateRaceConfig.getRaceMonth();
    }

    function getRaceDay() {
        return GateRaceConfig.getRaceDay();
    }

    function getGates() as Lang.Array {
        return GateRaceConfig.getGates();
    }

    function getAids() as Lang.Array {
        return GateRaceConfig.getAids();
    }

    function isGoalPoint(point) as Lang.Boolean {
        return point == GateRaceConfig.GOAL;
    }

    function isGoalGate(gate) as Lang.Boolean {
        return isGoalPoint(_getGateValue(gate, GATE_POINT));
    }

    function getGateDistanceKm(gate) {
        var pointMeters = getGateDistanceMeters(gate);
        if (pointMeters == null) {
            return null;
        }
        return pointMeters / 1000.0;
    }

    function getGateDistanceMeters(gate) {
        var point = _getGateValue(gate, GATE_POINT);
        if (point == null) {
            return null;
        }
        if (isGoalPoint(point)) {
            return _distanceKmToMeters(getRaceDistanceKm());
        }
        return point;
    }

    function getGateDistanceTenthKm(gate) {
        var distanceMeters = getGateDistanceMeters(gate);
        if (distanceMeters == null) {
            return null;
        }
        return Math.floor((distanceMeters / 100.0) + 0.5);
    }

    function getGateDisplayValue(gate) {
        if (isGoalGate(gate)) {
            return Ui.loadResource(Rez.Strings.GoalLabel);
        }
        return GateDistanceUtils.formatCompactDistanceValue(getGateDistanceKm(gate));
    }

    function getGateDisplayUnit(gate) {
        if (isGoalGate(gate)) {
            return "";
        }
        return GateDistanceUtils.getDisplayDistanceUnit();
    }

    function getGateCutoffDayOffset(gate) {
        return _getGateValue(gate, GATE_CUTOFF_DAY_OFFSET);
    }

    function getGateCutoffMinuteOfDay(gate) {
        return _getGateValue(gate, GATE_CUTOFF_MINUTE_OF_DAY);
    }

    function getGateCloseHour(gate) {
        var minuteOfDay = getGateCutoffMinuteOfDay(gate);
        if (minuteOfDay == null) {
            return null;
        }
        return Math.floor(minuteOfDay / 60);
    }

    function getGateCloseMinute(gate) {
        var minuteOfDay = getGateCutoffMinuteOfDay(gate);
        var closeHour = getGateCloseHour(gate);
        if (minuteOfDay == null or closeHour == null) {
            return null;
        }
        return minuteOfDay - (closeHour * 60);
    }

    function formatGateSummary(gate) {
        if (gate == null) {
            return "null";
        }

        return getGateDisplayValue(gate) +
            getGateDisplayUnit(gate) +
            "@" +
            GateDistanceUtils.formatCloseTime(
                getGateCloseHour(gate),
                getGateCloseMinute(gate)
            );
    }

    function getAidDistanceKm(aid) {
        var aidDistanceMeters = getAidDistanceMeters(aid);
        if (aidDistanceMeters == null) {
            return null;
        }
        return aidDistanceMeters / 1000.0;
    }

    function getAidDistanceMeters(aid) {
        if (aid == null) {
            return null;
        }
        return aid;
    }

    function getAidDisplayValue(aid) {
        return GateDistanceUtils.formatCompactDistanceValue(getAidDistanceKm(aid));
    }

    function getAidDisplayUnit(aid) {
        return GateDistanceUtils.getDisplayDistanceUnit();
    }

    function _getGateValue(gate, index) {
        if (gate == null or !(gate instanceof Lang.Array)) {
            return null;
        }
        if (index < 0 or index >= gate.size()) {
            return null;
        }
        return gate[index];
    }

    function _distanceKmToMeters(distanceKm) {
        if (distanceKm == null) {
            return null;
        }
        return Math.floor((distanceKm * 1000.0) + 0.5);
    }
}
