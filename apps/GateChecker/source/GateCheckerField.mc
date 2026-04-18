using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using GateCodeDecoder;
using GateCurrentPace;
using GateDisplayModel;
using GateDistanceUtils;
using GateNextSelector;
using GatePaceJudge;
using GateRemainingDistance;
using GateRequiredPace;
using GateRemainingTime;
using GateCodeValidator;
using GateSettingsLoader;

class GateCheckerField extends Ui.DataField {
    const KEY_GATE_CODE = "gate_code";
    const CODE_DEBUG_LOG = true;

    var _singleText = "CODE ERROR";
    var _line1Text = "";
    var _line2Text = "";
    var _line3LeftText = "";
    var _line3RightText = "";
    var _line3LeftColor = Gfx.COLOR_WHITE;
    var _line4Text = "";
    var _currentPaceConfig = null;
    var _lastCodeDiagLine = null;

    function initialize() {
        DataField.initialize();
        _currentPaceConfig = GateCurrentPace.newDefaultConfig();
        _loadViewState(null);
    }

    function compute(info) {
        _loadViewState(info);
    }

    function onUpdate(dc) {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var line1Font = Gfx.FONT_XTINY;
        var line2Font = Gfx.FONT_SMALL;
        var line3LeftFont = Gfx.FONT_TINY;
        var line3RightFont = Gfx.FONT_SMALL;
        var line4Font = Gfx.FONT_XTINY;
        var line1Height = Gfx.getFontHeight(line1Font);
        var line2Height = Gfx.getFontHeight(line2Font);
        var line3Height = _maxInt(Gfx.getFontHeight(line3LeftFont), Gfx.getFontHeight(line3RightFont));
        var line4Height = Gfx.getFontHeight(line4Font);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        if (_singleText != null and _singleText.length() > 0) {
            dc.drawText(centerX, centerY - Math.floor(line2Height / 2), line2Font, _singleText, Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        var lineGap = 2;
        var totalHeight = line1Height + lineGap + line2Height + lineGap + line3Height + lineGap + line4Height;
        var line1Y = centerY - Math.floor(totalHeight / 2);
        var line2Y = line1Y + line1Height + lineGap;
        var line3Y = line2Y + line2Height + lineGap;
        var line4Y = line3Y + line3Height + lineGap;

        _drawCenteredLine(dc, centerX, line1Y, line1Font, _line1Text, Gfx.COLOR_WHITE);
        _drawCenteredLine(dc, centerX, line2Y, line2Font, _line2Text, Gfx.COLOR_WHITE);
        _drawSplitLine(dc, centerX, line3Y, line3LeftFont, _line3LeftText, _line3LeftColor, line3RightFont, _line3RightText, Gfx.COLOR_WHITE);
        _drawCenteredLine(dc, centerX, line4Y, line4Font, _line4Text, Gfx.COLOR_WHITE);
    }

    function _loadViewState(info) {
        var rawCode = GateSettingsLoader.loadGateCode(KEY_GATE_CODE);
        var codeConfig = GateCodeValidator.inspectGateCode(rawCode);
        var decodeConfig = GateCodeDecoder.newDefaultConfig();
        var nextGateConfig = GateNextSelector.newDefaultConfig();
        var remainingDistanceConfig = GateRemainingDistance.newDefaultConfig();
        var paceJudgeConfig = GatePaceJudge.newDefaultConfig();
        var requiredPaceConfig = GateRequiredPace.newDefaultConfig();
        var remainingTimeConfig = GateRemainingTime.newDefaultConfig();
        var currentDistanceKm = GateDistanceUtils.extractElapsedDistanceKm(info);
        _currentPaceConfig = GateCurrentPace.updateCurrentPace(_currentPaceConfig, info, currentDistanceKm);
        if (GateCodeValidator.isCodeValid(codeConfig)) {
            decodeConfig = GateCodeDecoder.decodeGateList(
                GateCodeValidator.getNormalizedCode(codeConfig),
                GateCodeValidator.getGateCount(codeConfig)
            );
        }
        if (GateCodeDecoder.isDecoded(decodeConfig)) {
            nextGateConfig = GateNextSelector.selectNextGate(
                GateCodeDecoder.getGates(decodeConfig),
                currentDistanceKm
            );
        }

        if (GateNextSelector.hasNextGate(nextGateConfig)) {
            var nextGate = GateNextSelector.getNextGate(nextGateConfig);
            remainingDistanceConfig = GateRemainingDistance.computeRemainingDistance(
                currentDistanceKm,
                GateCodeDecoder.getGateDistanceTenthKm(nextGate)
            );
            remainingTimeConfig = GateRemainingTime.computeRemainingTime(
                GateCodeDecoder.getGateCloseHour(nextGate),
                GateCodeDecoder.getGateCloseMinute(nextGate)
            );
            requiredPaceConfig = GateRequiredPace.computeRequiredPace(
                GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig),
                GateRemainingTime.getRemainingSec(remainingTimeConfig)
            );
            paceJudgeConfig = GatePaceJudge.judgeRequiredPace(
                GateRequiredPace.getRequiredPaceSecPerKm(requiredPaceConfig),
                GateRemainingTime.getRemainingSec(remainingTimeConfig)
            );
        }
        var displayConfig = GateDisplayModel.buildDisplayModel(
            codeConfig,
            decodeConfig,
            nextGateConfig,
            remainingDistanceConfig,
            requiredPaceConfig,
            remainingTimeConfig,
            _currentPaceConfig,
            currentDistanceKm
        );
        _singleText = GateDisplayModel.getSingleText(displayConfig);
        _line1Text = GateDisplayModel.getLine1(displayConfig);
        _line2Text = GateDisplayModel.getLine2(displayConfig);
        _line3LeftText = GateDisplayModel.getLine3Left(displayConfig);
        _line3RightText = GateDisplayModel.getLine3Right(displayConfig);
        _line3LeftColor = GateDisplayModel.getLine3LeftColor(displayConfig);
        _line4Text = GateDisplayModel.getLine4(displayConfig);
        _logCodeDiag(
            rawCode,
            codeConfig,
            decodeConfig,
            nextGateConfig,
            remainingDistanceConfig,
            paceJudgeConfig,
            requiredPaceConfig,
            remainingTimeConfig,
            _currentPaceConfig,
            displayConfig,
            currentDistanceKm,
            _singleText,
            _line1Text,
            _line2Text,
            _line3LeftText,
            _line3RightText,
            _line4Text
        );
    }

    function _logCodeDiag(rawCode, codeConfig, decodeConfig, nextGateConfig, remainingDistanceConfig, paceJudgeConfig, requiredPaceConfig, remainingTimeConfig, currentPaceConfig, displayConfig, currentDistanceKm, singleText, line1Text, line2Text, line3LeftText, line3RightText, line4Text) {
        if (!CODE_DEBUG_LOG) {
            return;
        }

        var firstGateSummary = "none";
        var gates = GateCodeDecoder.getGates(decodeConfig);
        if (gates.size() > 0) {
            firstGateSummary = GateCodeDecoder.formatGateSummary(gates[0]);
        }

        var nextGateSummary = "none";
        var nextGate = GateNextSelector.getNextGate(nextGateConfig);
        if (nextGate != null) {
            nextGateSummary = GateCodeDecoder.formatGateSummary(nextGate);
        }

        var line =
            "[GATE_CODE_DIAG]" +
            " raw=" + _diagValue(rawCode) +
            " normalized=" + _diagValue(GateCodeValidator.getNormalizedCode(codeConfig)) +
            " declaredGateCount=" + _diagValue(GateCodeValidator.getGateCount(codeConfig)) +
            " actualLen=" + _diagValue(GateCodeValidator.getActualLength(codeConfig)) +
            " minimumLen=" + _diagValue(GateCodeValidator.getMinimumLength(codeConfig)) +
            " validateReason=" + _diagValue(GateCodeValidator.getReason(codeConfig)) +
            " validateOk=" + _diagValue(GateCodeValidator.isCodeValid(codeConfig)) +
            " decodeReason=" + _diagValue(GateCodeDecoder.getReason(decodeConfig)) +
            " decodedCount=" + _diagValue(GateCodeDecoder.getDecodedCount(decodeConfig)) +
            " firstGate=" + _diagValue(firstGateSummary) +
            " currentDistanceKm=" + _diagValue(currentDistanceKm) +
            " nextReason=" + _diagValue(GateNextSelector.getReason(nextGateConfig)) +
            " nextIndex=" + _diagValue(GateNextSelector.getNextIndex(nextGateConfig)) +
            " nextGate=" + _diagValue(nextGateSummary) +
            " remainDistReason=" + _diagValue(GateRemainingDistance.getReason(remainingDistanceConfig)) +
            " remainDistKm=" + _diagValue(GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig)) +
            " judgeReason=" + _diagValue(GatePaceJudge.getReason(paceJudgeConfig)) +
            " judgeState=" + _diagValue(_resolvePaceJudgeLabel(paceJudgeConfig)) +
            " paceReason=" + _diagValue(GateRequiredPace.getReason(requiredPaceConfig)) +
            " reqPaceSecPerKm=" + _diagValue(GateRequiredPace.getRequiredPaceSecPerKm(requiredPaceConfig)) +
            " currentPaceReason=" + _diagValue(GateCurrentPace.getReason(currentPaceConfig)) +
            " currentPaceSecPerKm=" + _diagValue(GateCurrentPace.getCurrentPaceSecPerKm(currentPaceConfig)) +
            " currentPaceText=" + _diagValue(GateCurrentPace.getDisplayText(currentPaceConfig)) +
            " timeReason=" + _diagValue(GateRemainingTime.getReason(remainingTimeConfig)) +
            " currentClock=" + _diagValue(GateRemainingTime.getClockText(remainingTimeConfig)) +
            " currentClockSec=" + _diagValue(GateRemainingTime.getCurrentClockSec(remainingTimeConfig)) +
            " closeClockSec=" + _diagValue(GateRemainingTime.getCloseClockSec(remainingTimeConfig)) +
            " remainingSec=" + _diagValue(GateRemainingTime.getRemainingSec(remainingTimeConfig)) +
            " displayState=" + _diagValue(GateDisplayModel.getState(displayConfig)) +
            " single=" + _diagValue(singleText) +
            " line1=" + _diagValue(line1Text) +
            " line2=" + _diagValue(line2Text) +
            " line3Left=" + _diagValue(line3LeftText) +
            " line3Right=" + _diagValue(line3RightText) +
            " line4=" + _diagValue(line4Text);
        if (_lastCodeDiagLine == line) {
            return;
        }
        _lastCodeDiagLine = line;
        Sys.println(line);
    }

    function _diagValue(value) {
        if (value == null) {
            return "null";
        }
        return value.toString();
    }

    function _drawCenteredLine(dc, centerX, y, font, text, color) {
        if (text == null or text.length() == 0) {
            return;
        }
        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.drawText(centerX, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function _drawSplitLine(dc, centerX, y, leftFont, leftText, leftColor, rightFont, rightText, rightColor) {
        var hasLeft = leftText != null and leftText.length() > 0;
        var hasRight = rightText != null and rightText.length() > 0;
        if (!hasLeft and !hasRight) {
            return;
        }
        if (!hasRight) {
            _drawCenteredLine(dc, centerX, y, leftFont, leftText, leftColor);
            return;
        }
        if (!hasLeft) {
            _drawCenteredLine(dc, centerX, y, rightFont, rightText, rightColor);
            return;
        }

        var separatorText = " | ";
        var separatorFont = leftFont;
        var leftWidth = dc.getTextWidthInPixels(leftText, leftFont);
        var separatorWidth = dc.getTextWidthInPixels(separatorText, separatorFont);
        var rightWidth = dc.getTextWidthInPixels(rightText, rightFont);
        var startX = centerX - Math.floor((leftWidth + separatorWidth + rightWidth) / 2);

        dc.setColor(leftColor, Gfx.COLOR_BLACK);
        dc.drawText(startX, y, leftFont, leftText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.drawText(startX + leftWidth, y, separatorFont, separatorText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.setColor(rightColor, Gfx.COLOR_BLACK);
        dc.drawText(startX + leftWidth + separatorWidth, y, rightFont, rightText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _maxInt(a, b) {
        if (a == null) {
            return b;
        }
        if (b == null) {
            return a;
        }
        if (a >= b) {
            return a;
        }
        return b;
    }

    function _resolvePaceJudgeLabel(config) {
        var state = GatePaceJudge.getState(config);
        if (state == GatePaceJudge.STATE_PLENTY) {
            return Ui.loadResource(Rez.Strings.PaceStatePlenty);
        }
        if (state == GatePaceJudge.STATE_OK) {
            return Ui.loadResource(Rez.Strings.PaceStateOk);
        }
        if (state == GatePaceJudge.STATE_TIGHT) {
            return Ui.loadResource(Rez.Strings.PaceStateTight);
        }
        if (state == GatePaceJudge.STATE_PUSH) {
            return Ui.loadResource(Rez.Strings.PaceStatePush);
        }
        if (state == GatePaceJudge.STATE_OVER) {
            return Ui.loadResource(Rez.Strings.PaceStateOver);
        }
        return "";
    }
}
