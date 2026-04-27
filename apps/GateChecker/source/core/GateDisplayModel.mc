using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.WatchUi as Ui;
using GateCodeDecoder;
using GateDistanceUtils;
using GateNextSelector;
using GateCurrentPace;
using GateRemainingDistance;
using GateRemainingTime;
using GateCodeValidator;

module GateDisplayModel {
    const STATE_CODE_ERROR = 0;
    const STATE_WAIT_DIST = 1;
    const STATE_ALL_PASSED = 2;
    const STATE_OVER = 3;
    const STATE_PACE_NA = 4;
    const STATE_NORMAL = 5;

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
        config[CFG_LINE1] = _buildGateLine(nextGate, GateNextSelector.getNextIndex(nextGateConfig));
        config[CFG_LINE2] = _buildFactLine(remainingDistanceConfig, remainingSec);
        config[CFG_LINE4] = _buildCurrentSnapshotLine(currentDistanceKm, remainingTimeConfig);
        config[CFG_LINE3_LEFT_COLOR] = Gfx.COLOR_WHITE;

        var remainingDistanceKm = GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig);
        var currentPaceSecPerKm = GateCurrentPace.getCurrentPaceSecPerKm(currentPaceConfig);
        var etaClockText = GateRemainingTime.computeEtaClockText(
            remainingTimeConfig,
            remainingDistanceKm,
            currentPaceSecPerKm
        );
        if (remainingSec != null and remainingSec < 0) {
            config[CFG_STATE] = STATE_OVER;
            config[CFG_LINE2] = _buildLateFactLine(remainingDistanceConfig, remainingSec);
            config[CFG_LINE3_LEFT] = Ui.loadResource(Rez.Strings.PaceStateOver);
            config[CFG_LINE3_RIGHT] = "";
            config[CFG_LINE3_LEFT_COLOR] = OVER_COLOR;
            return config;
        }

        if (etaClockText == null) {
            config[CFG_STATE] = STATE_PACE_NA;
            config[CFG_LINE3_LEFT] = Ui.loadResource(Rez.Strings.PaceNa);
            config[CFG_LINE3_RIGHT] = "";
            return config;
        }

        config[CFG_STATE] = STATE_NORMAL;
        config[CFG_LINE3_LEFT] = "PACE " + GateCurrentPace.getDisplayText(currentPaceConfig) + "/km";
        config[CFG_LINE3_RIGHT] = "ETA " + etaClockText;
        return config;
    }

    function getState(config) {
        return _getConfigValue(config, CFG_STATE, STATE_CODE_ERROR);
    }

    function getStateLabel(config) {
        var state = getState(config);
        if (state == STATE_WAIT_DIST) {
            return "wait_dist";
        }
        if (state == STATE_ALL_PASSED) {
            return "all_passed";
        }
        if (state == STATE_OVER) {
            return "over";
        }
        if (state == STATE_PACE_NA) {
            return "pace_na";
        }
        if (state == STATE_NORMAL) {
            return "normal";
        }
        return "code_error";
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
        return Ui.loadResource(Rez.Strings.Last) + " / CUT " + GateDistanceUtils.formatCloseTime(
            GateCodeDecoder.getGateCloseHour(lastGate),
            GateCodeDecoder.getGateCloseMinute(lastGate)
        );
    }

    function _buildGateLine(nextGate, nextIndex) {
        if (nextGate == null) {
            return "GATE --.-km / CUT --:--";
        }

        return _formatOrdinal(nextIndex) + " GATE " + GateDistanceUtils.formatCompactDistanceTenthKm(GateCodeDecoder.getGateDistanceTenthKm(nextGate)) +
            " / CUT " +
            GateDistanceUtils.formatCloseTime(
                GateCodeDecoder.getGateCloseHour(nextGate),
                GateCodeDecoder.getGateCloseMinute(nextGate)
            );
    }

    function _buildFactLine(remainingDistanceConfig, remainingSec) {
        return "REMAIN " + GateDistanceUtils.formatCompactDistanceKm(GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig)) +
            " / LEFT " +
            GateRemainingTime.formatRemainingDuration(remainingSec);
    }

    function _buildLateFactLine(remainingDistanceConfig, remainingSec) {
        return "REMAIN " + GateDistanceUtils.formatCompactDistanceKm(GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig)) +
            " / LATE " +
            GateRemainingTime.formatRemainingDuration(remainingSec);
    }

    function _buildCurrentSnapshotLine(currentDistanceKm, remainingTimeConfig) {
        return "DIST " + GateDistanceUtils.formatLiveDistanceKm(currentDistanceKm) +
            " / NOW " +
            GateRemainingTime.formatCurrentClockHourMinute(remainingTimeConfig);
    }

    function _formatOrdinal(index) {
        if (index == null or index < 0) {
            return "";
        }

        var number = index + 1;
        var mod100 = number % 100;
        var suffix = "th";
        if (mod100 < 11 or mod100 > 13) {
            var mod10 = number % 10;
            if (mod10 == 1) {
                suffix = "st";
            } else if (mod10 == 2) {
                suffix = "nd";
            } else if (mod10 == 3) {
                suffix = "rd";
            }
        }
        return number.format("%d") + suffix;
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
