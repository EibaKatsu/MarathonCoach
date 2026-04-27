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
    const CODE_DEBUG_LOG = false;
    const LAYOUT_DEBUG_LOG = false;
    const USE_ICON_LABELS = true;
    const ICON_DEBUG_LOG = false;
    const INLINE_CELL_DEBUG_LOG = false;
    const INLINE_CELL_DEBUG_DRAW = false;
    const INLINE_ICON_GAP = 3;
    const INLINE_VALUE_UNIT_GAP = 1;

    var _singleText = "CODE ERROR";
    var _line1Text = "";
    var _line2Text = "";
    var _line3LeftText = "";
    var _line3RightText = "";
    var _line3LeftColor = Gfx.COLOR_WHITE;
    var _line4Text = "";
    var _gateTitleText = "";
    var _gateDistanceText = "";
    var _gateDistanceUnitText = "";
    var _gateTimeText = "";
    var _remainLeftLabelText = "REMAIN";
    var _remainRightLabelText = "LEFT";
    var _remainDistanceText = "";
    var _remainDistanceUnitText = "";
    var _leftTimeText = "";
    var _paceLeftLabelText = "PACE";
    var _paceRightLabelText = "ETA";
    var _paceValueText = "";
    var _paceUnitText = "";
    var _etaValueText = "";
    var _nowLabelText = "NOW";
    var _nowDistanceText = "";
    var _nowDistanceUnitText = "";
    var _nowTimeText = "";
    var _currentPaceConfig = null;
    var _lastCodeDiagLine = null;
    var _lastLayoutDiagLine = null;

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
        var labelFont = Gfx.FONT_SYSTEM_XTINY;
        var edgeValueFont = Gfx.FONT_SMALL;
        var unitFont = Gfx.FONT_SYSTEM_XTINY;
        var edgeValueRowHeight = Gfx.getFontHeight(edgeValueFont);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        if (_singleText != null and _singleText.length() > 0) {
            dc.drawText(centerX, centerY - Math.floor(edgeValueRowHeight / 2), Gfx.FONT_SMALL, _singleText, Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        var layoutTop = Math.floor((dc.getHeight() * 12) / 100);
        var layoutBottom = Math.floor((dc.getHeight() * 86) / 100);
        var layoutHeight = layoutBottom - layoutTop;
        var edgeBlockHeight = Math.floor((layoutHeight * 19) / 100);
        var mainBlockHeight = Math.floor((layoutHeight - (edgeBlockHeight * 2)) / 2);
        var gateBlockY = layoutTop;
        var remainBlockY = gateBlockY + edgeBlockHeight;
        var paceBlockY = remainBlockY + mainBlockHeight;
        var nowBlockY = paceBlockY + mainBlockHeight;
        var columnOffset = Math.floor((dc.getWidth() * 22) / 100);
        var leftX = centerX - columnOffset;
        var rightX = centerX + columnOffset;
        var outerPadding = Math.floor((dc.getWidth() * 7) / 100);
        var centerGap = Math.floor((dc.getWidth() * 6) / 100);
        var leftCellWidth = centerX - Math.floor(centerGap / 2) - outerPadding;
        var rightCellLeft = centerX + Math.floor(centerGap / 2);
        var rightCellWidth = (dc.getWidth() - outerPadding) - rightCellLeft;
        var remainLeftRect = _newRect(outerPadding, remainBlockY, leftCellWidth, mainBlockHeight);
        var remainRightRect = _newRect(rightCellLeft, remainBlockY, rightCellWidth, mainBlockHeight);
        var paceLeftRect = _newRect(outerPadding, paceBlockY, leftCellWidth, mainBlockHeight);
        var paceRightRect = _newRect(rightCellLeft, paceBlockY, rightCellWidth, mainBlockHeight);
        var columnMaxWidth = Math.floor((dc.getWidth() * 41) / 100);
        var remainLeftIcon = _resolveInlineIcon(_remainLeftLabelText, "REMAIN", _remainDistanceText, Rez.Drawables.icon_remain_16, "remain");
        var remainRightIcon = _resolveInlineIcon(_remainRightLabelText, "LEFT", _leftTimeText, Rez.Drawables.icon_left_16, "left");
        var paceLeftIcon = _resolveInlineIcon(_paceLeftLabelText, "PACE", _paceValueText, Rez.Drawables.icon_pace_16, "pace");
        var paceRightIcon = _resolveInlineIcon(_paceRightLabelText, "ETA", _etaValueText, Rez.Drawables.icon_eta_16, "eta");
        var edgeGroupFont = _resolveFourValueGroupFont(
            dc,
            edgeValueFont,
            _gateDistanceText,
            _gateDistanceUnitText,
            _gateTimeText,
            "",
            _nowDistanceText,
            _nowDistanceUnitText,
            _nowTimeText,
            "",
            unitFont,
            columnMaxWidth
        );
        var mainGroupFont = _resolveInlineMetricGroupFont(
            dc,
            Gfx.FONT_NUMBER_HOT,
            Gfx.FONT_MEDIUM,
            unitFont,
            _minInt(_rectWidth(remainLeftRect), _rectWidth(remainRightRect)),
            remainLeftIcon,
            _remainDistanceText,
            _remainDistanceUnitText,
            remainRightIcon,
            _leftTimeText,
            "",
            paceLeftIcon,
            _paceValueText,
            _paceUnitText,
            paceRightIcon,
            _etaValueText,
            ""
        );
        var gateLabelHeight = _measureLabelHeight(dc, labelFont, _gateTitleText, null);
        var nowLabelHeight = _measureLabelHeight(dc, labelFont, _nowLabelText, null);
        var gateValueHeight = _resolveMaxTextHeight(dc, edgeGroupFont, _gateDistanceText, _gateTimeText);
        var nowValueHeight = _resolveMaxTextHeight(dc, edgeGroupFont, _nowDistanceText, _nowTimeText);
        var gateLabelY = _resolveLabelY(gateBlockY, edgeBlockHeight, gateLabelHeight, gateValueHeight);
        var gateValueY = _resolveValueY(gateLabelY, gateLabelHeight);
        var nowLabelY = _resolveLabelY(nowBlockY, edgeBlockHeight, nowLabelHeight, nowValueHeight);
        var nowValueY = _resolveValueY(nowLabelY, nowLabelHeight);

        _drawLabelCentered(dc, centerX, gateLabelY, labelFont, _gateTitleText, Gfx.COLOR_WHITE, null);
        _drawValueWithUnitCentered(dc, leftX, gateValueY, edgeGroupFont, _gateDistanceText, unitFont, _gateDistanceUnitText, Gfx.COLOR_WHITE);
        _drawValueWithUnitCentered(dc, rightX, gateValueY, edgeGroupFont, _gateTimeText, unitFont, "", Gfx.COLOR_WHITE);

        if (USE_ICON_LABELS) {
            _drawInlineMetricBlock(dc, remainLeftRect, true, remainLeftIcon, _remainDistanceText, _remainDistanceUnitText, mainGroupFont, unitFont, Gfx.COLOR_WHITE, "remain_left");
            _drawInlineMetricBlock(dc, remainRightRect, false, remainRightIcon, _leftTimeText, "", mainGroupFont, unitFont, Gfx.COLOR_WHITE, "remain_right");
            _drawInlineMetricBlock(dc, paceLeftRect, true, paceLeftIcon, _paceValueText, _paceUnitText, mainGroupFont, unitFont, _line3LeftColor, "pace_left");
            _drawInlineMetricBlock(dc, paceRightRect, false, paceRightIcon, _etaValueText, "", mainGroupFont, unitFont, Gfx.COLOR_WHITE, "pace_right");
        } else {
            var remainLabelHeight = _resolveMaxTextHeight(dc, labelFont, _remainLeftLabelText, _remainRightLabelText);
            var remainValueHeight = _resolveMaxTextHeight(dc, mainGroupFont, _remainDistanceText, _leftTimeText);
            var paceLabelHeight = _resolveMaxTextHeight(dc, labelFont, _paceLeftLabelText, _paceRightLabelText);
            var paceValueHeight = _resolveMaxTextHeight(dc, mainGroupFont, _paceValueText, _etaValueText);
            var remainRowY = _resolveLabelY(remainBlockY, mainBlockHeight, remainLabelHeight, remainValueHeight);
            var remainValueY = _resolveValueY(remainRowY, remainLabelHeight);
            var paceRowY = _resolveLabelY(paceBlockY, mainBlockHeight, paceLabelHeight, paceValueHeight);
            var paceValueY = _resolveValueY(paceRowY, paceLabelHeight);
            _drawCenteredLine(dc, leftX, remainRowY, labelFont, _remainLeftLabelText, Gfx.COLOR_WHITE);
            _drawCenteredLine(dc, rightX, remainRowY, labelFont, _remainRightLabelText, Gfx.COLOR_WHITE);
            _drawValueWithUnitCentered(dc, leftX, remainValueY, mainGroupFont, _remainDistanceText, unitFont, _remainDistanceUnitText, Gfx.COLOR_WHITE);
            _drawValueWithUnitCentered(dc, rightX, remainValueY, mainGroupFont, _leftTimeText, unitFont, "", Gfx.COLOR_WHITE);
            _drawCenteredLine(dc, leftX, paceRowY, labelFont, _paceLeftLabelText, _line3LeftColor);
            _drawCenteredLine(dc, rightX, paceRowY, labelFont, _paceRightLabelText, Gfx.COLOR_WHITE);
            _drawValueWithUnitCentered(dc, leftX, paceValueY, mainGroupFont, _paceValueText, unitFont, _paceUnitText, _line3LeftColor);
            _drawValueWithUnitCentered(dc, rightX, paceValueY, mainGroupFont, _etaValueText, unitFont, "", Gfx.COLOR_WHITE);
        }

        _drawLabelCentered(dc, centerX, nowLabelY, labelFont, _nowLabelText, Gfx.COLOR_WHITE, null);
        _drawValueWithUnitCentered(dc, leftX, nowValueY, edgeGroupFont, _nowDistanceText, unitFont, _nowDistanceUnitText, Gfx.COLOR_WHITE);
        _drawValueWithUnitCentered(dc, rightX, nowValueY, edgeGroupFont, _nowTimeText, unitFont, "", Gfx.COLOR_WHITE);

        _logLayoutDiag(dc, layoutHeight, gateLabelY, gateValueY, remainBlockY, remainBlockY, paceBlockY, paceBlockY, nowLabelY, nowValueY, labelFont, unitFont, edgeGroupFont, mainGroupFont);
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
        _refreshRenderPartsFromCore(
            displayConfig,
            decodeConfig,
            nextGateConfig,
            remainingDistanceConfig,
            remainingTimeConfig,
            _currentPaceConfig,
            currentDistanceKm
        );
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

    function _refreshRenderPartsFromCore(displayConfig, decodeConfig, nextGateConfig, remainingDistanceConfig, remainingTimeConfig, currentPaceConfig, currentDistanceKm) {
        _resetRenderParts();

        var state = GateDisplayModel.getState(displayConfig);
        _nowDistanceText = GateDistanceUtils.formatLiveDistanceKmValue(currentDistanceKm);
        _nowDistanceUnitText = "km";
        _nowTimeText = GateRemainingTime.formatCurrentClockHourMinute(remainingTimeConfig);

        if (state == GateDisplayModel.STATE_ALL_PASSED) {
            _gateTitleText = Ui.loadResource(Rez.Strings.Last);
            var gates = GateCodeDecoder.getGates(decodeConfig);
            if (gates.size() > 0) {
                var lastGate = gates[gates.size() - 1];
                _gateTimeText = GateDistanceUtils.formatCloseTime(
                    GateCodeDecoder.getGateCloseHour(lastGate),
                    GateCodeDecoder.getGateCloseMinute(lastGate)
                );
            }
            _remainLeftLabelText = "";
            _remainRightLabelText = "";
            _remainDistanceText = Ui.loadResource(Rez.Strings.AllPassed);
            _remainDistanceUnitText = "";
            _leftTimeText = "";
            _paceLeftLabelText = "";
            _paceRightLabelText = "";
            return;
        }

        var nextGate = GateNextSelector.getNextGate(nextGateConfig);
        if (nextGate != null) {
            _gateTitleText = _formatOrdinal(GateNextSelector.getNextIndex(nextGateConfig)) + " GATE";
            _gateDistanceText = GateDistanceUtils.formatCompactDistanceTenthKmValue(
                GateCodeDecoder.getGateDistanceTenthKm(nextGate)
            );
            _gateDistanceUnitText = "km";
            _gateTimeText = GateDistanceUtils.formatCloseTime(
                GateCodeDecoder.getGateCloseHour(nextGate),
                GateCodeDecoder.getGateCloseMinute(nextGate)
            );
        }

        _remainDistanceText = GateDistanceUtils.formatCompactDistanceKmValue(
            GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig)
        );
        _remainDistanceUnitText = "km";
        _leftTimeText = GateRemainingTime.formatRemainingDuration(
            GateRemainingTime.getRemainingSec(remainingTimeConfig)
        );

        if (state == GateDisplayModel.STATE_OVER) {
            _remainRightLabelText = "LATE";
            _paceLeftLabelText = "";
            _paceRightLabelText = "";
            _paceValueText = Ui.loadResource(Rez.Strings.PaceStateOver);
            _paceUnitText = "";
            _etaValueText = "";
            return;
        }

        if (state == GateDisplayModel.STATE_PACE_NA) {
            _paceValueText = "N/A";
            _paceUnitText = "";
            _etaValueText = "";
            return;
        }

        if (state == GateDisplayModel.STATE_NORMAL) {
            var remainingDistanceKm = GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig);
            var currentPaceSecPerKm = GateCurrentPace.getCurrentPaceSecPerKm(currentPaceConfig);
            var etaClockText = GateRemainingTime.computeEtaClockText(
                remainingTimeConfig,
                remainingDistanceKm,
                currentPaceSecPerKm
            );
            _paceValueText = GateCurrentPace.getDisplayText(currentPaceConfig);
            _paceUnitText = "/km";
            _etaValueText = (etaClockText == null) ? "" : etaClockText;
        }
    }

    function _resetRenderParts() {
        _gateTitleText = "";
        _gateDistanceText = "";
        _gateDistanceUnitText = "";
        _gateTimeText = "";
        _remainLeftLabelText = "REMAIN";
        _remainRightLabelText = "LEFT";
        _remainDistanceText = "";
        _remainDistanceUnitText = "";
        _leftTimeText = "";
        _paceLeftLabelText = "PACE";
        _paceRightLabelText = "ETA";
        _paceValueText = "";
        _paceUnitText = "";
        _etaValueText = "";
        _nowLabelText = "NOW";
        _nowDistanceText = "";
        _nowDistanceUnitText = "";
        _nowTimeText = "";
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
            " displayState=" + _diagValue(GateDisplayModel.getStateLabel(displayConfig)) +
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

    function _logLayoutDiag(dc, blockHeight, gateLabelY, gateValueY, remainLabelY, remainValueY, paceLabelY, paceValueY, nowLabelY, nowValueY, labelFont, unitFont, edgeGroupFont, mainGroupFont) {
        if (!LAYOUT_DEBUG_LOG) {
            return;
        }

        var line =
            "[GATE_LAYOUT_DIAG]" +
            " w=" + _diagValue(dc.getWidth()) +
            " h=" + _diagValue(dc.getHeight()) +
            " blockH=" + _diagValue(blockHeight) +
            " gateTitle=" + _diagValue(_gateTitleText) +
            " gateDist=" + _diagValue(_gateDistanceText) +
            " gateDistUnit=" + _diagValue(_gateDistanceUnitText) +
            " gateTime=" + _diagValue(_gateTimeText) +
            " remainLabel=" + _diagValue(_remainLeftLabelText) +
            " remainDist=" + _diagValue(_remainDistanceText) +
            " remainDistUnit=" + _diagValue(_remainDistanceUnitText) +
            " leftLabel=" + _diagValue(_remainRightLabelText) +
            " leftTime=" + _diagValue(_leftTimeText) +
            " paceLabel=" + _diagValue(_paceLeftLabelText) +
            " paceValue=" + _diagValue(_paceValueText) +
            " paceUnit=" + _diagValue(_paceUnitText) +
            " etaLabel=" + _diagValue(_paceRightLabelText) +
            " etaValue=" + _diagValue(_etaValueText) +
            " nowLabel=" + _diagValue(_nowLabelText) +
            " nowDist=" + _diagValue(_nowDistanceText) +
            " nowDistUnit=" + _diagValue(_nowDistanceUnitText) +
            " nowTime=" + _diagValue(_nowTimeText) +
            " yGateLabel=" + _diagValue(gateLabelY) +
            " yGateValue=" + _diagValue(gateValueY) +
            " yRemainLabel=" + _diagValue(remainLabelY) +
            " yRemainValue=" + _diagValue(remainValueY) +
            " yPaceLabel=" + _diagValue(paceLabelY) +
            " yPaceValue=" + _diagValue(paceValueY) +
            " yNowLabel=" + _diagValue(nowLabelY) +
            " yNowValue=" + _diagValue(nowValueY) +
            " labelFontH=" + _diagValue(Gfx.getFontHeight(labelFont)) +
            " labelFontA=" + _diagValue(Gfx.getFontAscent(labelFont)) +
            " labelFontD=" + _diagValue(Gfx.getFontDescent(labelFont)) +
            " unitFontH=" + _diagValue(Gfx.getFontHeight(unitFont)) +
            " unitFontA=" + _diagValue(Gfx.getFontAscent(unitFont)) +
            " unitFontD=" + _diagValue(Gfx.getFontDescent(unitFont)) +
            " edgeFontH=" + _diagValue(Gfx.getFontHeight(edgeGroupFont)) +
            " edgeFontA=" + _diagValue(Gfx.getFontAscent(edgeGroupFont)) +
            " edgeFontD=" + _diagValue(Gfx.getFontDescent(edgeGroupFont)) +
            " mainFontH=" + _diagValue(Gfx.getFontHeight(mainGroupFont)) +
            " mainFontA=" + _diagValue(Gfx.getFontAscent(mainGroupFont)) +
            " mainFontD=" + _diagValue(Gfx.getFontDescent(mainGroupFont));
        if (_lastLayoutDiagLine == line) {
            return;
        }
        _lastLayoutDiagLine = line;
        Sys.println(line);
    }

    function _resolveLabelY(blockY, blockHeight, labelHeight, valueHeight) {
        var labelValueGap = 1;
        var contentHeight = labelHeight + labelValueGap + valueHeight;
        return _resolveContentY(blockY, blockHeight, contentHeight);
    }

    function _resolveValueY(labelTopY, labelHeight) {
        return labelTopY + labelHeight + 1;
    }

    function _resolveContentY(blockY, blockHeight, contentHeight) {
        var contentTopY = blockY + Math.floor((blockHeight - contentHeight) / 2);
        if (contentTopY < blockY) {
            contentTopY = blockY;
        }
        return contentTopY;
    }

    function _resolveMaxTextHeight(dc, font, text1, text2) {
        var leftHeight = _measureTextHeight(dc, text1, font);
        var rightHeight = _measureTextHeight(dc, text2, font);
        if (leftHeight >= rightHeight) {
            return leftHeight;
        }
        return rightHeight;
    }

    function _measureTextHeight(dc, text, font) {
        if (text == null or text.length() == 0) {
            return 0;
        }
        var dimensions = dc.getTextDimensions(text, font);
        return dimensions[1];
    }

    function _measureLabelHeight(dc, font, text, bitmap) {
        if (bitmap != null) {
            return bitmap.getHeight();
        }
        return _measureTextHeight(dc, text, font);
    }

    function _resolveInlineIcon(labelText, expectedText, valueText, rezId, labelKind) {
        if (
            !USE_ICON_LABELS or
            labelText == null or
            valueText == null or
            labelText.length() == 0 or
            valueText.length() == 0 or
            !labelText.equals(expectedText)
        ) {
            if (ICON_DEBUG_LOG) {
                Sys.println(
                    "[GATE_ICON_DIAG] kind=" + labelKind +
                    " label=" + _diagValue(labelText) +
                    " value=" + _diagValue(valueText) +
                    " icon=disabled"
                );
            }
            return null;
        }

        var bitmap = Ui.loadResource(rezId);
        if (ICON_DEBUG_LOG) {
            var bitmapState = bitmap == null ? "null" : "loaded";
            Sys.println("[GATE_ICON_DIAG] kind=" + labelKind + " label=" + labelText + " value=" + valueText + " icon=" + bitmapState);
        }
        return bitmap;
    }

    function _resolveInlineMetricGroupFont(
        dc,
        preferredFont,
        textFallbackFont,
        unitFont,
        maxWidth,
        icon1,
        valueText1,
        unitText1,
        icon2,
        valueText2,
        unitText2,
        icon3,
        valueText3,
        unitText3,
        icon4,
        valueText4,
        unitText4
    ) {
        var font = preferredFont;
        if (
            _useTextValueFont(valueText1) or
            _useTextValueFont(valueText2) or
            _useTextValueFont(valueText3) or
            _useTextValueFont(valueText4)
        ) {
            font = textFallbackFont;
        }

        while (
            _measureInlineMetricBlockWidth(dc, icon1, valueText1, unitText1, font, unitFont) > maxWidth or
            _measureInlineMetricBlockWidth(dc, icon2, valueText2, unitText2, font, unitFont) > maxWidth or
            _measureInlineMetricBlockWidth(dc, icon3, valueText3, unitText3, font, unitFont) > maxWidth or
            _measureInlineMetricBlockWidth(dc, icon4, valueText4, unitText4, font, unitFont) > maxWidth
        ) {
            var nextFont = _shrinkNumberFont(font);
            if (nextFont == font) {
                return font;
            }
            font = nextFont;
        }
        return font;
    }

    function _resolveBitmapWidth(bitmap) {
        if (bitmap == null) {
            return 0;
        }
        return bitmap.getWidth();
    }

    function _resolveBitmapHeight(bitmap) {
        if (bitmap == null) {
            return 0;
        }
        return bitmap.getHeight();
    }

    function _measureInlineMetricBlockWidth(dc, bitmap, numberText, unitText, valueFont, unitFont) {
        if (numberText == null) {
            numberText = "";
        }
        if (unitText == null) {
            unitText = "";
        }

        var iconWidth = _resolveBitmapWidth(bitmap);
        var iconGap = iconWidth > 0 ? INLINE_ICON_GAP : 0;
        var valueWidth = dc.getTextWidthInPixels(numberText, valueFont);
        var unitWidth = dc.getTextWidthInPixels(unitText, unitFont);
        var unitGap = unitText.length() > 0 ? INLINE_VALUE_UNIT_GAP : 0;
        return iconWidth + iconGap + valueWidth + unitGap + unitWidth;
    }

    function _resolveInlineRowHeight(dc, valueFont, leftText, rightText, leftIcon, rightIcon) {
        var valueHeight = _resolveMaxTextHeight(dc, valueFont, leftText, rightText);
        var iconHeight = _maxInt(_resolveBitmapHeight(leftIcon), _resolveBitmapHeight(rightIcon));
        return _maxInt(valueHeight, iconHeight);
    }

    function _measureInlineMetricBlockHeight(dc, bitmap, numberText, valueFont) {
        return _maxInt(_resolveBitmapHeight(bitmap), _measureTextHeight(dc, numberText, valueFont));
    }

    function _newRect(left, top, width, height) {
        return [left, top, width, height];
    }

    function _rectLeft(rect) {
        return rect[0];
    }

    function _rectTop(rect) {
        return rect[1];
    }

    function _rectWidth(rect) {
        return rect[2];
    }

    function _rectHeight(rect) {
        return rect[3];
    }

    function _rectRight(rect) {
        return _rectLeft(rect) + _rectWidth(rect);
    }

    function _resolveFourValueGroupFont(
        dc,
        preferredFont,
        valueText1,
        unitText1,
        valueText2,
        unitText2,
        valueText3,
        unitText3,
        valueText4,
        unitText4,
        unitFont,
        maxWidth
    ) {
        var groupFont = preferredFont;
        groupFont = _smallerNumberFont(
            groupFont,
            _resolveValueFont(dc, preferredFont, valueText1, unitFont, unitText1, maxWidth)
        );
        groupFont = _smallerNumberFont(
            groupFont,
            _resolveValueFont(dc, preferredFont, valueText2, unitFont, unitText2, maxWidth)
        );
        groupFont = _smallerNumberFont(
            groupFont,
            _resolveValueFont(dc, preferredFont, valueText3, unitFont, unitText3, maxWidth)
        );
        groupFont = _smallerNumberFont(
            groupFont,
            _resolveValueFont(dc, preferredFont, valueText4, unitFont, unitText4, maxWidth)
        );
        return groupFont;
    }

    function _resolveValueFont(dc, preferredFont, numberText, unitFont, unitText, maxWidth) {
        if (_useTextValueFont(numberText)) {
            return Gfx.FONT_MEDIUM;
        }

        var font = preferredFont;
        while (_measureValueWidth(dc, font, numberText, unitFont, unitText) > maxWidth) {
            var nextFont = _shrinkNumberFont(font);
            if (nextFont == font) {
                return font;
            }
            font = nextFont;
        }
        return font;
    }

    function _useTextValueFont(numberText) {
        if (numberText == null) {
            return false;
        }
        return numberText.find("N") != null or numberText.find("OVER") != null;
    }

    function _measureValueWidth(dc, valueFont, numberText, unitFont, unitText) {
        if (numberText == null) {
            numberText = "";
        }
        if (unitText == null) {
            unitText = "";
        }

        var unitGap = unitText.length() > 0 ? 2 : 0;
        return dc.getTextWidthInPixels(numberText, valueFont) +
            unitGap +
            dc.getTextWidthInPixels(unitText, unitFont);
    }

    function _shrinkNumberFont(font) {
        if (font == Gfx.FONT_NUMBER_HOT) {
            return Gfx.FONT_NUMBER_MEDIUM;
        }
        if (font == Gfx.FONT_NUMBER_MEDIUM) {
            return Gfx.FONT_NUMBER_MILD;
        }
        if (font == Gfx.FONT_NUMBER_MILD) {
            return Gfx.FONT_MEDIUM;
        }
        if (font == Gfx.FONT_MEDIUM) {
            return Gfx.FONT_SMALL;
        }
        return font;
    }

    function _smallerNumberFont(leftFont, rightFont) {
        if (_numberFontRank(leftFont) <= _numberFontRank(rightFont)) {
            return leftFont;
        }
        return rightFont;
    }

    function _numberFontRank(font) {
        if (font == Gfx.FONT_NUMBER_HOT) {
            return 5;
        }
        if (font == Gfx.FONT_NUMBER_MEDIUM) {
            return 4;
        }
        if (font == Gfx.FONT_NUMBER_MILD) {
            return 3;
        }
        if (font == Gfx.FONT_MEDIUM) {
            return 2;
        }
        if (font == Gfx.FONT_SMALL) {
            return 1;
        }
        return 0;
    }

    function _drawValueWithUnitCentered(dc, centerX, y, valueFont, numberText, unitFont, unitText, color) {
        if (numberText == null) {
            numberText = "";
        }
        if (unitText == null) {
            unitText = "";
        }

        var numberWidth = dc.getTextWidthInPixels(numberText, valueFont);
        var unitWidth = dc.getTextWidthInPixels(unitText, unitFont);
        var unitGap = unitText.length() > 0 ? 2 : 0;
        var totalWidth = numberWidth + unitGap + unitWidth;
        var startX = centerX - Math.floor(totalWidth / 2);
        var rowHeight = Gfx.getFontHeight(valueFont);
        var unitY = y + Math.floor((rowHeight * 58) / 100) - Math.floor(Gfx.getFontHeight(unitFont) / 2);

        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.drawText(startX, y, valueFont, numberText, Gfx.TEXT_JUSTIFY_LEFT);
        if (unitText.length() > 0) {
            dc.drawText(startX + numberWidth + unitGap, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
        }
    }

    function _drawInlineMetricBlock(dc, cellRect, alignRight, bitmap, numberText, unitText, valueFont, unitFont, color, blockName) {
        if (numberText == null or numberText.length() == 0) {
            return;
        }
        if (unitText == null) {
            unitText = "";
        }

        var iconWidth = _resolveBitmapWidth(bitmap);
        var iconHeight = _resolveBitmapHeight(bitmap);
        var valueWidth = dc.getTextWidthInPixels(numberText, valueFont);
        var unitWidth = dc.getTextWidthInPixels(unitText, unitFont);
        var unitGap = unitText.length() > 0 ? INLINE_VALUE_UNIT_GAP : 0;
        var iconGap = iconWidth > 0 ? INLINE_ICON_GAP : 0;
        var contentWidth = iconWidth + iconGap + valueWidth + unitGap + unitWidth;
        var contentHeight = _measureInlineMetricBlockHeight(dc, bitmap, numberText, valueFont);
        var startX = alignRight ? (_rectRight(cellRect) - contentWidth) : _rectLeft(cellRect);
        var topY = _rectTop(cellRect) + Math.floor((_rectHeight(cellRect) - contentHeight) / 2);
        var iconY = topY + Math.floor((contentHeight - iconHeight) / 2);
        var valueY = topY + Math.floor((contentHeight - _measureTextHeight(dc, numberText, valueFont)) / 2);
        var unitY = valueY + Math.floor((Gfx.getFontHeight(valueFont) * 58) / 100) - Math.floor(Gfx.getFontHeight(unitFont) / 2);
        var textX = startX + iconWidth + iconGap;

        if (INLINE_CELL_DEBUG_DRAW) {
            _drawInlineCellBounds(dc, cellRect, alignRight);
        }
        if (INLINE_CELL_DEBUG_LOG) {
            _logInlineCellDiag(cellRect, blockName, contentWidth, iconWidth, valueWidth, unitWidth, valueFont, startX, alignRight);
        }

        if (bitmap != null) {
            dc.drawBitmap(startX, iconY, bitmap);
        }

        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.drawText(textX, valueY, valueFont, numberText, Gfx.TEXT_JUSTIFY_LEFT);
        if (unitText.length() > 0) {
            dc.drawText(textX + valueWidth + unitGap, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
        }
    }

    function _drawInlineCellBounds(dc, cellRect, alignRight) {
        var foreground = alignRight ? 0x606060 : 0x404040;
        dc.setColor(foreground, Gfx.COLOR_TRANSPARENT);
        dc.drawRectangle(_rectLeft(cellRect), _rectTop(cellRect), _rectWidth(cellRect), _rectHeight(cellRect));
    }

    function _logInlineCellDiag(cellRect, blockName, contentWidth, iconWidth, valueWidth, unitWidth, chosenFont, startX, alignRight) {
        Sys.println(
            "[GATE_INLINE_CELL]" +
            " block=" + blockName +
            " cellRect=" + _rectLeft(cellRect) + "," + _rectTop(cellRect) + "," + _rectWidth(cellRect) + "," + _rectHeight(cellRect) +
            " alignRight=" + _diagValue(alignRight) +
            " contentWidth=" + _diagValue(contentWidth) +
            " iconWidth=" + _diagValue(iconWidth) +
            " valueWidth=" + _diagValue(valueWidth) +
            " unitWidth=" + _diagValue(unitWidth) +
            " chosenFont=" + _fontName(chosenFont) +
            " startX=" + _diagValue(startX)
        );
    }

    function _fontName(font) {
        if (font == Gfx.FONT_NUMBER_HOT) {
            return "FONT_NUMBER_HOT";
        }
        if (font == Gfx.FONT_NUMBER_MEDIUM) {
            return "FONT_NUMBER_MEDIUM";
        }
        if (font == Gfx.FONT_NUMBER_MILD) {
            return "FONT_NUMBER_MILD";
        }
        if (font == Gfx.FONT_MEDIUM) {
            return "FONT_MEDIUM";
        }
        if (font == Gfx.FONT_SMALL) {
            return "FONT_SMALL";
        }
        if (font == Gfx.FONT_SYSTEM_XTINY) {
            return "FONT_SYSTEM_XTINY";
        }
        return "FONT_UNKNOWN";
    }

    function _drawIconValueWithUnitCentered(dc, centerX, topY, rowHeight, valueFont, numberText, unitFont, unitText, color, bitmap) {
        if (numberText == null) {
            numberText = "";
        }
        if (unitText == null) {
            unitText = "";
        }
        if (numberText.length() == 0) {
            return;
        }

        var numberWidth = dc.getTextWidthInPixels(numberText, valueFont);
        var unitWidth = dc.getTextWidthInPixels(unitText, unitFont);
        var unitGap = unitText.length() > 0 ? 2 : 0;
        var valueWidth = numberWidth + unitGap + unitWidth;
        var iconWidth = _resolveBitmapWidth(bitmap);
        var iconGap = iconWidth > 0 ? INLINE_ICON_GAP : 0;
        var totalWidth = iconWidth + iconGap + valueWidth;
        var startX = centerX - Math.floor(totalWidth / 2);
        var valueHeight = _measureTextHeight(dc, numberText, valueFont);
        var valueY = topY + Math.floor((rowHeight - valueHeight) / 2);
        var unitY = valueY + Math.floor((Gfx.getFontHeight(valueFont) * 58) / 100) - Math.floor(Gfx.getFontHeight(unitFont) / 2);

        if (bitmap != null) {
            var iconY = topY + Math.floor((rowHeight - bitmap.getHeight()) / 2);
            dc.drawBitmap(startX, iconY, bitmap);
        }

        var textX = startX + iconWidth + iconGap;
        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.drawText(textX, valueY, valueFont, numberText, Gfx.TEXT_JUSTIFY_LEFT);
        if (unitText.length() > 0) {
            dc.drawText(textX + numberWidth + unitGap, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
        }
    }

    function _drawCenteredLine(dc, centerX, y, font, text, color) {
        if (text == null or text.length() == 0) {
            return;
        }
        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.drawText(centerX, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function _drawLabelCentered(dc, centerX, y, font, text, color, bitmap) {
        _drawCenteredLine(dc, centerX, y, font, text, color);
    }

    function _maxInt(leftValue, rightValue) {
        if (leftValue >= rightValue) {
            return leftValue;
        }
        return rightValue;
    }

    function _minInt(leftValue, rightValue) {
        if (leftValue <= rightValue) {
            return leftValue;
        }
        return rightValue;
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
