using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.WatchUi as Ui;
using GateCodeDecoder;
using GateDistanceUtils;
using GateNextSelector;
using GateCurrentPace;
using GateRemainingDistance;
using GateRequiredPace;
using GateRemainingTime;
using GateCodeValidator;

module GateDisplayModel {
    const STATE_CODE_ERROR = "code_error";
    const STATE_WAIT_DIST = "wait_dist";
    const STATE_ALL_PASSED = "all_passed";
    const STATE_OVER = "over";
    const STATE_PACE_NA = "pace_na";
    const STATE_NORMAL = "normal";

    const CFG_STATE = 0;
    const CFG_SINGLE_TEXT = 1;
    const CFG_LINE1 = 2;
    const CFG_LINE2 = 3;
    const CFG_LINE3_LEFT = 4;
    const CFG_LINE3_RIGHT = 5;
    const CFG_LINE4 = 6;
    const CFG_LINE3_LEFT_COLOR = 7;

    const OVER_COLOR = 0xF01818;

    function newDefaultConfig() as Lang.Array {
        return [STATE_CODE_ERROR, Ui.loadResource(Rez.Strings.CodeError), "", "", "", "", "", Gfx.COLOR_WHITE];
    }

    function buildDisplayModel(
        codeConfig,
        decodeConfig,
        nextGateConfig,
        remainingDistanceConfig,
        requiredPaceConfig,
        remainingTimeConfig,
        currentPaceConfig,
        currentDistanceKm
    ) as Lang.Array {
        var config = newDefaultConfig();
        if (!GateCodeValidator.isCodeValid(codeConfig) or !GateCodeDecoder.isDecoded(decodeConfig)) {
            config[CFG_STATE] = STATE_CODE_ERROR;
            config[CFG_SINGLE_TEXT] = Ui.loadResource(Rez.Strings.CodeError);
            return config;
        }

        if (GateNextSelector.isDistanceUnavailable(nextGateConfig)) {
            config[CFG_STATE] = STATE_WAIT_DIST;
            config[CFG_SINGLE_TEXT] = Ui.loadResource(Rez.Strings.WaitDist);
            return config;
        }

        if (!GateNextSelector.hasNextGate(nextGateConfig)) {
            config[CFG_STATE] = STATE_ALL_PASSED;
            config[CFG_SINGLE_TEXT] = "";
            config[CFG_LINE1] = _buildAllPassedLine1(decodeConfig);
            config[CFG_LINE2] = Ui.loadResource(Rez.Strings.AllPassed);
            config[CFG_LINE3_LEFT] = "";
            config[CFG_LINE3_RIGHT] = "";
            config[CFG_LINE4] = _buildCurrentSnapshotLine(currentDistanceKm, remainingTimeConfig);
            return config;
        }

        var nextGate = GateNextSelector.getNextGate(nextGateConfig);
        var remainingSec = GateRemainingTime.getRemainingSec(remainingTimeConfig);
        config[CFG_SINGLE_TEXT] = "";
        config[CFG_LINE1] = _buildGateLine(nextGate);
        config[CFG_LINE2] = _buildFactLine(remainingDistanceConfig, remainingSec);
        config[CFG_LINE4] = _buildCurrentSnapshotLine(currentDistanceKm, remainingTimeConfig);
        config[CFG_LINE3_LEFT_COLOR] = Gfx.COLOR_WHITE;

        var currentPaceText = GateCurrentPace.getDisplayText(currentPaceConfig) + "/km";
        if (remainingSec != null and remainingSec < 0) {
            config[CFG_STATE] = STATE_OVER;
            config[CFG_LINE2] = _buildLateFactLine(remainingDistanceConfig, remainingSec);
            config[CFG_LINE3_LEFT] = Ui.loadResource(Rez.Strings.PaceStateOver);
            config[CFG_LINE3_RIGHT] = currentPaceText;
            config[CFG_LINE3_LEFT_COLOR] = OVER_COLOR;
            return config;
        }

        if (
            GateRemainingDistance.hasRemainingDistance(remainingDistanceConfig) and
            GateRemainingTime.hasRemainingTime(remainingTimeConfig) and
            !GateRequiredPace.hasRequiredPace(requiredPaceConfig)
        ) {
            config[CFG_STATE] = STATE_PACE_NA;
            config[CFG_LINE3_LEFT] = Ui.loadResource(Rez.Strings.PaceNa);
            config[CFG_LINE3_RIGHT] = currentPaceText;
            return config;
        }

        config[CFG_STATE] = STATE_NORMAL;
        config[CFG_LINE3_LEFT] = GateRequiredPace.formatPaceSecPerKm(GateRequiredPace.getRequiredPaceSecPerKm(requiredPaceConfig));
        config[CFG_LINE3_RIGHT] = currentPaceText;
        return config;
    }

    function getState(config) {
        return _getConfigValue(config, CFG_STATE, STATE_CODE_ERROR);
    }

    function getSingleText(config) {
        return _getConfigValue(config, CFG_SINGLE_TEXT, "");
    }

    function getLine1(config) {
        return _getConfigValue(config, CFG_LINE1, "");
    }

    function getLine2(config) {
        return _getConfigValue(config, CFG_LINE2, "");
    }

    function getLine3Left(config) {
        return _getConfigValue(config, CFG_LINE3_LEFT, "");
    }

    function getLine3Right(config) {
        return _getConfigValue(config, CFG_LINE3_RIGHT, "");
    }

    function getLine4(config) {
        return _getConfigValue(config, CFG_LINE4, "");
    }

    function getLine3LeftColor(config) {
        return _getConfigValue(config, CFG_LINE3_LEFT_COLOR, Gfx.COLOR_WHITE);
    }

    function _buildAllPassedLine1(decodeConfig) {
        var gates = GateCodeDecoder.getGates(decodeConfig);
        if (gates.size() <= 0) {
            return Ui.loadResource(Rez.Strings.Last);
        }

        var lastGate = gates[gates.size() - 1];
        return Ui.loadResource(Rez.Strings.Last) + " / " + GateDistanceUtils.formatCloseTime(
            GateCodeDecoder.getGateCloseHour(lastGate),
            GateCodeDecoder.getGateCloseMinute(lastGate)
        );
    }

    function _buildGateLine(nextGate) {
        if (nextGate == null) {
            return "--.-km / --:--";
        }

        return GateDistanceUtils.formatCompactDistanceTenthKm(GateCodeDecoder.getGateDistanceTenthKm(nextGate)) +
            " / " +
            GateDistanceUtils.formatCloseTime(
                GateCodeDecoder.getGateCloseHour(nextGate),
                GateCodeDecoder.getGateCloseMinute(nextGate)
            );
    }

    function _buildFactLine(remainingDistanceConfig, remainingSec) {
        return GateDistanceUtils.formatCompactDistanceKm(GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig)) +
            " / " +
            GateRemainingTime.formatRemainingFact(remainingSec);
    }

    function _buildLateFactLine(remainingDistanceConfig, remainingSec) {
        return GateDistanceUtils.formatCompactDistanceKm(GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig)) +
            " / " +
            GateRemainingTime.formatRemainingFact(remainingSec);
    }

    function _buildCurrentSnapshotLine(currentDistanceKm, remainingTimeConfig) {
        return GateDistanceUtils.formatLiveDistanceKm(currentDistanceKm) +
            " / " +
            GateRemainingTime.formatCurrentClockHourMinute(remainingTimeConfig);
    }

    function _getConfigValue(config, index, defaultValue) {
        if (config == null or !(config instanceof Lang.Array)) {
            return defaultValue;
        }
        if (index < 0 or index >= config.size()) {
            return defaultValue;
        }
        var value = config[index];
        if (value == null) {
            return defaultValue;
        }
        return value;
    }
}
