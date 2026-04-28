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
    const USE_ICON_LABELS = false;
    const ICON_DEBUG_LOG = false;
    const INLINE_CELL_DEBUG_LOG = false;
    const INLINE_CELL_DEBUG_DRAW = false;
    const INLINE_ICON_GAP = 4;
    const INLINE_VALUE_UNIT_GAP = 1;
    const INLINE_ICON_SIZE = 20;
    const SECTION_DIVIDER_COLOR = 0xA8FF33;
    const SECTION_DIVIDER_HEIGHT = 2;
    const GATE_FACT_MAX_VALUE_FONT = Gfx.FONT_NUMBER_MILD;
    const AID_FACT_MAX_VALUE_FONT = Gfx.FONT_NUMBER_MILD;

    var _singleText = "CODE ERROR";
    var _line1Text = "";
    var _line2Text = "";
    var _line3LeftText = "";
    var _line3RightText = "";
    var _line3LeftColor = Gfx.COLOR_WHITE;
    var _line4Text = "";
    var _gateLeftLabelText = "GATE";
    var _gateRightLabelText = "CUT";
    var _gateDistanceText = "";
    var _gateDistanceUnitText = "";
    var _gateTimeText = "";
    var _gateRemainLeftLabelText = "REMAIN";
    var _gateRemainRightLabelText = "LEFT";
    var _gateRemainDistanceText = "";
    var _gateRemainDistanceUnitText = "";
    var _gateLeftTimeText = "";
    var _aidTitleText = "AID";
    var _aidRightLabelText = "TO AID";
    var _aidDistanceText = "--";
    var _aidDistanceUnitText = "";
    var _aidRemainDistanceText = "--";
    var _aidRemainDistanceUnitText = "";
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
        var unitFont = Gfx.FONT_SYSTEM_XTINY;
        var singleStateFont = Gfx.FONT_SMALL;
        var singleStateRowHeight = Gfx.getFontHeight(singleStateFont);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        if (_singleText != null and _singleText.length() > 0) {
            dc.drawText(centerX, centerY - Math.floor(singleStateRowHeight / 2), singleStateFont, _singleText, Gfx.TEXT_JUSTIFY_CENTER);
            return;
        }

        var layoutTop = Math.floor((dc.getHeight() * 11) / 100);
        var layoutBottom = Math.floor((dc.getHeight() * 88) / 100);
        var layoutHeight = layoutBottom - layoutTop;
        var edgeBlockHeight = Math.floor(layoutHeight / 3);
        var mainBlockHeight = Math.floor(layoutHeight / 3);
        var aidBlockHeight = layoutBottom - layoutTop - edgeBlockHeight - mainBlockHeight;
        var gateBlockY = layoutTop;
        var remainBlockY = gateBlockY + edgeBlockHeight;
        var aidBlockY = remainBlockY + mainBlockHeight;
        var outerPadding = Math.floor((dc.getWidth() * 7) / 100);
        var centerGap = Math.floor((dc.getWidth() * 6) / 100);
        var leftCellWidth = centerX - Math.floor(centerGap / 2) - outerPadding;
        var rightCellLeft = centerX + Math.floor(centerGap / 2);
        var rightCellWidth = (dc.getWidth() - outerPadding) - rightCellLeft;
        var gateLeftRect = _newRect(outerPadding, gateBlockY, leftCellWidth, edgeBlockHeight);
        var gateRightRect = _newRect(rightCellLeft, gateBlockY, rightCellWidth, edgeBlockHeight);
        var gateRemainLeftRect = _newRect(outerPadding, remainBlockY, leftCellWidth, mainBlockHeight);
        var gateRemainRightRect = _newRect(rightCellLeft, remainBlockY, rightCellWidth, mainBlockHeight);
        var aidLeftRect = _newRect(outerPadding, aidBlockY, leftCellWidth, aidBlockHeight);
        var aidRightRect = _newRect(rightCellLeft, aidBlockY, rightCellWidth, aidBlockHeight);
        var gateRemainSectionRect = _newRect(outerPadding, remainBlockY, dc.getWidth() - (outerPadding * 2), mainBlockHeight);
        var columnMaxWidth = Math.floor((dc.getWidth() * 41) / 100);
        var gateLeftValueFont = _resolveValueFont(
            dc,
            GATE_FACT_MAX_VALUE_FONT,
            _gateDistanceText,
            unitFont,
            _gateDistanceUnitText,
            columnMaxWidth
        );
        var gateRightValueFont = _resolveValueFont(
            dc,
            GATE_FACT_MAX_VALUE_FONT,
            _gateTimeText,
            unitFont,
            "",
            columnMaxWidth
        );
        var gateFactGroupFont = _smallerNumberFont(gateLeftValueFont, gateRightValueFont);
        var gateRemainGroupFont = _resolveRemainGroupFont(
            dc,
            Gfx.FONT_NUMBER_MEDIUM,
            unitFont,
            _minInt(_rectWidth(gateRemainLeftRect), _rectWidth(gateRemainRightRect)),
            null,
            _gateRemainDistanceText,
            _gateRemainDistanceUnitText,
            null,
            _gateLeftTimeText
        );
        var aidLeftValueFont = _resolveValueFont(
            dc,
            AID_FACT_MAX_VALUE_FONT,
            _aidDistanceText,
            unitFont,
            _aidDistanceUnitText,
            _rectWidth(aidLeftRect)
        );
        var aidRightValueFont = _resolveValueFont(
            dc,
            AID_FACT_MAX_VALUE_FONT,
            _aidRemainDistanceText,
            unitFont,
            _aidRemainDistanceUnitText,
            _rectWidth(aidRightRect)
        );
        var aidFactGroupFont = _smallerNumberFont(
            aidLeftValueFont,
            aidRightValueFont
        );
        var detailFactGroupFont = _smallerNumberFont(gateRemainGroupFont, aidFactGroupFont);
        _drawStackedMetricBlockCentered(dc, gateLeftRect, labelFont, _gateLeftLabelText, gateFactGroupFont, _gateDistanceText, unitFont, _gateDistanceUnitText, Gfx.COLOR_WHITE);
        _drawStackedMetricBlockCentered(dc, gateRightRect, labelFont, _gateRightLabelText, gateFactGroupFont, _gateTimeText, unitFont, "", Gfx.COLOR_WHITE);

        var renderMainSingleValue = _gateRemainLeftLabelText.length() == 0 and _gateRemainRightLabelText.length() == 0 and _gateLeftTimeText.length() == 0;
        if (renderMainSingleValue) {
            var mainSingleFont = _resolveValueFont(
                dc,
                Gfx.FONT_MEDIUM,
                _gateRemainDistanceText,
                unitFont,
                _gateRemainDistanceUnitText,
                _rectWidth(gateRemainSectionRect)
            );
            var mainSingleHeight = _measureTextHeight(dc, _gateRemainDistanceText, mainSingleFont);
            var mainSingleY = _resolveContentY(remainBlockY, mainBlockHeight, mainSingleHeight);
            _drawValueWithUnitCentered(dc, centerX, mainSingleY, mainSingleFont, _gateRemainDistanceText, unitFont, _gateRemainDistanceUnitText, Gfx.COLOR_WHITE);
        } else {
            _drawStackedMetricBlockCentered(dc, gateRemainLeftRect, labelFont, _gateRemainLeftLabelText, detailFactGroupFont, _gateRemainDistanceText, unitFont, _gateRemainDistanceUnitText, Gfx.COLOR_WHITE);
            _drawStackedMetricBlockCentered(dc, gateRemainRightRect, labelFont, _gateRemainRightLabelText, detailFactGroupFont, _gateLeftTimeText, unitFont, "", Gfx.COLOR_WHITE);
        }

        var hasAidBlock = _aidTitleText.length() > 0 or _aidRightLabelText.length() > 0 or _aidDistanceText.length() > 0 or _aidRemainDistanceText.length() > 0;
        if (hasAidBlock) {
            _drawSectionDivider(dc, aidBlockY, dc.getWidth());
            _drawStackedMetricBlockCentered(dc, aidLeftRect, labelFont, _aidTitleText, detailFactGroupFont, _aidDistanceText, unitFont, _aidDistanceUnitText, Gfx.COLOR_WHITE);
            _drawStackedMetricBlockCentered(dc, aidRightRect, labelFont, _aidRightLabelText, detailFactGroupFont, _aidRemainDistanceText, unitFont, _aidRemainDistanceUnitText, Gfx.COLOR_WHITE);
        }

        _logLayoutDiag(dc, layoutHeight, gateBlockY, remainBlockY, aidBlockY, edgeBlockHeight, mainBlockHeight, aidBlockHeight, labelFont, unitFont, gateFactGroupFont, detailFactGroupFont);
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

        if (state == GateDisplayModel.STATE_ALL_PASSED) {
            _gateLeftLabelText = Ui.loadResource(Rez.Strings.Last);
            _gateRightLabelText = "CUT";
            var gates = GateCodeDecoder.getGates(decodeConfig);
            if (gates.size() > 0) {
                var lastGate = gates[gates.size() - 1];
                _gateDistanceText = GateDistanceUtils.formatCompactDistanceTenthKmValue(
                    GateCodeDecoder.getGateDistanceTenthKm(lastGate)
                );
                _gateTimeText = GateDistanceUtils.formatCloseTime(
                    GateCodeDecoder.getGateCloseHour(lastGate),
                    GateCodeDecoder.getGateCloseMinute(lastGate)
                );
            }
            _gateRemainLeftLabelText = "";
            _gateRemainRightLabelText = "";
            _gateRemainDistanceText = Ui.loadResource(Rez.Strings.AllPassed);
            _gateRemainDistanceUnitText = "";
            _gateLeftTimeText = "";
            _aidTitleText = "";
            _aidRightLabelText = "";
            _aidDistanceText = "";
            _aidRemainDistanceText = "";
            return;
        }

        var nextGate = GateNextSelector.getNextGate(nextGateConfig);
        var remainingDistanceKm = GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig);
        if (nextGate != null) {
            _gateLeftLabelText = _formatGateLabel(GateNextSelector.getNextIndex(nextGateConfig));
            _gateRightLabelText = "CUT";
            _gateDistanceText = GateDistanceUtils.formatCompactDistanceTenthKmValue(
                GateCodeDecoder.getGateDistanceTenthKm(nextGate)
            );
            _gateDistanceUnitText = "";
            _gateTimeText = GateDistanceUtils.formatCloseTime(
                GateCodeDecoder.getGateCloseHour(nextGate),
                GateCodeDecoder.getGateCloseMinute(nextGate)
            );

            _aidTitleText = "AID";
            _aidRightLabelText = "TO AID";
            _aidDistanceText = GateDistanceUtils.formatCompactDistanceTenthKmValue(
                GateCodeDecoder.getGateDistanceTenthKm(nextGate)
            );
            _aidDistanceUnitText = "";
        }

        _gateRemainDistanceText = GateDistanceUtils.formatCompactDistanceKmValue(remainingDistanceKm);
        _gateRemainDistanceUnitText = "";
        _gateLeftTimeText = GateRemainingTime.formatRemainingDuration(
            GateRemainingTime.getRemainingSec(remainingTimeConfig)
        );
        _aidRemainDistanceText = GateDistanceUtils.formatCompactDistanceKmValue(remainingDistanceKm);
        _aidRemainDistanceUnitText = "";

        if (state == GateDisplayModel.STATE_OVER) {
            _gateRemainRightLabelText = "LATE";
            return;
        }
    }

    function _resetRenderParts() {
        _gateLeftLabelText = "GATE";
        _gateRightLabelText = "CUT";
        _gateDistanceText = "";
        _gateDistanceUnitText = "";
        _gateTimeText = "";
        _gateRemainLeftLabelText = "REMAIN";
        _gateRemainRightLabelText = "LEFT";
        _gateRemainDistanceText = "";
        _gateRemainDistanceUnitText = "";
        _gateLeftTimeText = "";
        _aidTitleText = "AID";
        _aidRightLabelText = "TO AID";
        _aidDistanceText = "--";
        _aidDistanceUnitText = "";
        _aidRemainDistanceText = "--";
        _aidRemainDistanceUnitText = "";
    }

    function _formatGateLabel(index) {
        if (index == null or index < 0) {
            return "GATE";
        }

        return "G" + (index + 1).format("%d");
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

    function _logLayoutDiag(dc, blockHeight, gateBlockY, remainBlockY, aidBlockY, gateBlockHeight, remainBlockHeight, aidBlockHeight, labelFont, unitFont, edgeGroupFont, mainGroupFont) {
        if (!LAYOUT_DEBUG_LOG) {
            return;
        }

        var line =
            "[GATE_LAYOUT_DIAG]" +
            " w=" + _diagValue(dc.getWidth()) +
            " h=" + _diagValue(dc.getHeight()) +
            " blockH=" + _diagValue(blockHeight) +
            " gateLeftLabel=" + _diagValue(_gateLeftLabelText) +
            " gateRightLabel=" + _diagValue(_gateRightLabelText) +
            " gateDist=" + _diagValue(_gateDistanceText) +
            " gateDistUnit=" + _diagValue(_gateDistanceUnitText) +
            " gateTime=" + _diagValue(_gateTimeText) +
            " gateRemainLabel=" + _diagValue(_gateRemainLeftLabelText) +
            " gateRemainDist=" + _diagValue(_gateRemainDistanceText) +
            " gateRemainDistUnit=" + _diagValue(_gateRemainDistanceUnitText) +
            " gateLeftLabel=" + _diagValue(_gateRemainRightLabelText) +
            " gateLeftTime=" + _diagValue(_gateLeftTimeText) +
            " aidTitle=" + _diagValue(_aidTitleText) +
            " aidDist=" + _diagValue(_aidDistanceText) +
            " aidDistUnit=" + _diagValue(_aidDistanceUnitText) +
            " aidRemainDist=" + _diagValue(_aidRemainDistanceText) +
            " aidRemainDistUnit=" + _diagValue(_aidRemainDistanceUnitText) +
            " yGateBlock=" + _diagValue(gateBlockY) +
            " yRemainBlock=" + _diagValue(remainBlockY) +
            " yAidBlock=" + _diagValue(aidBlockY) +
            " hGateBlock=" + _diagValue(gateBlockHeight) +
            " hRemainBlock=" + _diagValue(remainBlockHeight) +
            " hAidBlock=" + _diagValue(aidBlockHeight) +
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

    function _resolveCenteredStackGap(containerHeight, topHeight, bottomHeight) {
        var freeSpace = containerHeight - topHeight - bottomHeight;
        if (freeSpace <= 0) {
            return 0;
        }
        return Math.floor(freeSpace / 3);
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

    function _resolveRemainGroupFont(dc, preferredFont, unitFont, maxWidth, leftIcon, leftText, leftUnitText, rightIcon, rightText) {
        var reservedIconWidth = _maxInt(_resolveBitmapWidth(leftIcon), _resolveBitmapWidth(rightIcon));
        if (reservedIconWidth > 0) {
            reservedIconWidth += INLINE_ICON_GAP;
        }

        var safeMaxWidth = maxWidth - reservedIconWidth;
        if (safeMaxWidth < 1) {
            safeMaxWidth = 1;
        }

        var leftFont = _resolveValueFont(dc, preferredFont, leftText, unitFont, leftUnitText, safeMaxWidth);
        var rightFont = _resolveValueFont(dc, preferredFont, rightText, unitFont, "", safeMaxWidth);
        return _smallerNumberFont(leftFont, rightFont);
    }

    function _resolveBitmapWidth(bitmap) {
        if (bitmap == null) {
            return 0;
        }
        return INLINE_ICON_SIZE;
    }

    function _resolveBitmapHeight(bitmap) {
        if (bitmap == null) {
            return 0;
        }
        return INLINE_ICON_SIZE;
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

    function _measureLabeledValueRowWidth(dc, labelFont, labelText, valueFont, valueText) {
        if (valueText == null) {
            valueText = "";
        }
        if (labelText == null) {
            labelText = "";
        }

        var valueWidth = dc.getTextWidthInPixels(valueText, valueFont);
        if (labelText.length() == 0) {
            return valueWidth;
        }

        var labelWidth = dc.getTextWidthInPixels(labelText, labelFont);
        return labelWidth + INLINE_ICON_GAP + valueWidth;
    }

    function _measureLabeledValueRowHeight(dc, labelFont, labelText, valueFont, valueText) {
        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureTextHeight(dc, valueText, valueFont);
        return _maxInt(labelHeight, valueHeight);
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

    function _rectCenterX(rect) {
        return _rectLeft(rect) + Math.floor(_rectWidth(rect) / 2);
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

    function _resolveLabeledValueFont(dc, preferredFont, textFallbackFont, labelFont, labelText, valueText, maxWidth) {
        if (valueText == null or valueText.length() == 0) {
            return preferredFont;
        }

        var font = preferredFont;
        if (_useTextValueFont(valueText)) {
            font = textFallbackFont;
        }

        while (_measureLabeledValueRowWidth(dc, labelFont, labelText, font, valueText) > maxWidth) {
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
        return numberText.find("N") != null or
            numberText.find("OVER") != null or
            numberText.find("ALL") != null or
            numberText.find("WAIT") != null or
            numberText.find("CODE") != null;
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

    function _drawValueWithUnitAligned(dc, cellRect, alignRight, y, valueFont, numberText, unitFont, unitText, color) {
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
        var startX = alignRight ? (_rectRight(cellRect) - totalWidth) : _rectLeft(cellRect);
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

    function _drawStackedMetricBlockCentered(dc, cellRect, labelFont, labelText, valueFont, valueText, unitFont, unitText, color) {
        if ((labelText == null or labelText.length() == 0) and (valueText == null or valueText.length() == 0)) {
            return;
        }

        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureTextHeight(dc, valueText, valueFont);
        var sectionGap = _resolveCenteredStackGap(_rectHeight(cellRect), labelHeight, valueHeight);
        var labelY = _rectTop(cellRect) + sectionGap;
        var valueY = _rectTop(cellRect) + (sectionGap * 2) + labelHeight;
        var centerX = _rectCenterX(cellRect);

        _drawCenteredLine(dc, centerX, labelY, labelFont, labelText, color);
        _drawValueWithUnitCentered(dc, centerX, valueY, valueFont, valueText, unitFont, unitText, color);
    }

    function _drawStackedMetricBlockAligned(dc, cellRect, alignRight, labelFont, labelText, valueFont, valueText, unitFont, unitText, color) {
        if ((labelText == null or labelText.length() == 0) and (valueText == null or valueText.length() == 0)) {
            return;
        }

        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureTextHeight(dc, valueText, valueFont);
        var sectionGap = _resolveCenteredStackGap(_rectHeight(cellRect), labelHeight, valueHeight);
        var labelY = _rectTop(cellRect) + sectionGap;
        var valueY = _rectTop(cellRect) + (sectionGap * 2) + labelHeight;

        _drawAlignedLine(dc, cellRect, alignRight, labelY, labelFont, labelText, color);
        _drawValueWithUnitAligned(dc, cellRect, alignRight, valueY, valueFont, valueText, unitFont, unitText, color);
    }

    function _drawLabeledValueRowCentered(dc, rowRect, labelFont, labelText, valueFont, valueText, color) {
        if (valueText == null or valueText.length() == 0) {
            return;
        }
        if (labelText == null) {
            labelText = "";
        }

        var valueWidth = dc.getTextWidthInPixels(valueText, valueFont);
        var labelWidth = dc.getTextWidthInPixels(labelText, labelFont);
        var labelGap = labelText.length() > 0 ? INLINE_ICON_GAP : 0;
        var totalWidth = labelWidth + labelGap + valueWidth;
        var startX = _rectLeft(rowRect) + Math.floor((_rectWidth(rowRect) - totalWidth) / 2);
        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureTextHeight(dc, valueText, valueFont);
        var labelY = _rectTop(rowRect) + Math.floor((_rectHeight(rowRect) - labelHeight) / 2);
        var valueY = _rectTop(rowRect) + Math.floor((_rectHeight(rowRect) - valueHeight) / 2);

        dc.setColor(color, Gfx.COLOR_BLACK);
        if (labelText.length() > 0) {
            dc.drawText(startX, labelY, labelFont, labelText, Gfx.TEXT_JUSTIFY_LEFT);
        }
        dc.drawText(startX + labelWidth + labelGap, valueY, valueFont, valueText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _drawInlineCellBounds(dc, cellRect, alignRight) {
        var foreground = alignRight ? 0x606060 : 0x404040;
        dc.setColor(foreground, Gfx.COLOR_TRANSPARENT);
        dc.drawRectangle(_rectLeft(cellRect), _rectTop(cellRect), _rectWidth(cellRect), _rectHeight(cellRect));
    }

    function _drawSectionDivider(dc, aidBlockY, screenWidth) {
        var dividerInset = Math.floor((screenWidth * 16) / 100);
        var dividerWidth = screenWidth - (dividerInset * 2);
        var dividerY = aidBlockY - SECTION_DIVIDER_HEIGHT - 3;
        dc.setColor(SECTION_DIVIDER_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(dividerInset, dividerY, dividerWidth, SECTION_DIVIDER_HEIGHT);
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
            var iconY = topY + Math.floor((rowHeight - _resolveBitmapHeight(bitmap)) / 2);
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

    function _drawAlignedLine(dc, cellRect, alignRight, y, font, text, color) {
        if (text == null or text.length() == 0) {
            return;
        }

        var anchorX = alignRight ? _rectRight(cellRect) : _rectLeft(cellRect);
        var justify = alignRight ? Gfx.TEXT_JUSTIFY_RIGHT : Gfx.TEXT_JUSTIFY_LEFT;
        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.drawText(anchorX, y, font, text, justify);
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
