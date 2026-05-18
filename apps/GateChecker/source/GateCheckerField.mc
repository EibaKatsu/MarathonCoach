using Toybox.Graphics as Gfx;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using GateAidSelector;
using GateCurrentPace;
using GateDisplayModel;
using GateDistanceUtils;
using GateNextSelector;
using GatePaceJudge;
using GateRaceData;
using GateRemainingDistance;
using GateRequiredPace;
using GateRemainingTime;

class GateCheckerField extends Ui.DataField {
    const CODE_DEBUG_LOG = false;
    const LAYOUT_DEBUG_LOG = false;
    const FONT_DEBUG_LOG = false;
    const PRESTART_DEBUG_LOG = false;
    const AID_DEBUG_LOG = false;
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
    const STACKED_LABEL_VALUE_GAP = 0;
    const STACKED_CELL_HORIZONTAL_INSET = 4;
    const AID_STACKED_CELL_HORIZONTAL_INSET = 12;
    const AID_STACKED_VERTICAL_OFFSET = 0;
    const AID_LABEL_TOP_PADDING = 6;
    const AID_VALUE_UNIT_TIGHT_GAP = 0;
    const AID_BOTTOM_PADDING = 2;
    const GATE_TEXT_SAFE_MARGIN = 12;
    const AID_TEXT_SAFE_MARGIN = 12;
    const TO_GATE_LABEL_TEXT = "TO GATE";
    const TO_NEXT_AID_LABEL_TEXT = "TO NEXT AID";
    const GATE_HEADER_VALUE_GAP = 2;
    const LAYOUT_TOP_PERCENT = 6;
    const LAYOUT_BOTTOM_PERCENT = 94;
    const LAYOUT_SIDE_PADDING_PERCENT = 4;
    const LAYOUT_CENTER_GAP_PERCENT = 4;
    const SECTION_DIVIDER_GAP = 0;
    const SECTION_DIVIDER_INSET_PERCENT = 10;
    const LABEL_ANCHOR_INNER_RATIO_PERCENT = 30;

    var _singleText = "CONFIG ERROR";
    var _line1Text = "";
    var _line2Text = "";
    var _line3LeftText = "";
    var _line3RightText = "";
    var _line3LeftColor = Gfx.COLOR_WHITE;
    var _line4Text = "";
    var _gateTitleText = "GATE";
    var _gateLeftLabelText = "GATE";
    var _gateRightLabelText = "TO GATE";
    var _gateSummaryText = "";
    var _gateDistanceText = "";
    var _gateDistanceUnitText = "";
    var _gateTimeText = "";
    var _gateRemainLeftLabelText = "";
    var _gateRemainRightLabelText = "";
    var _gateRemainDistanceText = "";
    var _gateRemainDistanceUnitText = "";
    var _gateLeftTimeText = "";
    var _remainMergedText = "";
    var _aidTitleText = "TO NEXT AID";
    var _aidRightLabelText = "";
    var _aidDistanceText = "";
    var _aidDistanceUnitText = "";
    var _aidRemainDistanceText = "--";
    var _aidRemainDistanceUnitText = "";
    var _currentPaceConfig = null;
    var _lastCodeDiagLine = null;
    var _lastLayoutDiagLine = null;
    var _lastFontDiagLine = null;
    var _lastPreStartDiagLine = null;
    var _lastAidDiagLine = null;
    var _displayState = GateDisplayModel.STATE_CODE_ERROR;

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

        _logPreStartDiag(
            "onUpdate",
            "displayState=" + _diagValue(_displayState) +
            " singleText=" + _diagText(_singleText) +
            " width=" + _diagValue(dc.getWidth()) +
            " height=" + _diagValue(dc.getHeight())
        );

        if (_shouldRenderPreStartSplash()) {
            _drawPreStartSplash(dc, centerX, centerY);
            return;
        }

        if (_singleText != null and _singleText.length() > 0) {
            _drawCenteredLine(dc, centerX, centerY - Math.floor(singleStateRowHeight / 2), singleStateFont, _singleText, Gfx.COLOR_WHITE, false);
            return;
        }

        var layoutTop = Math.floor((dc.getHeight() * LAYOUT_TOP_PERCENT) / 100);
        var layoutBottom = Math.floor((dc.getHeight() * LAYOUT_BOTTOM_PERCENT) / 100);
        var layoutHeight = layoutBottom - layoutTop;
        var outerPadding = _maxInt(2, Math.floor((dc.getWidth() * LAYOUT_SIDE_PADDING_PERCENT) / 100));
        var centerGap = _maxInt(4, Math.floor((dc.getWidth() * LAYOUT_CENTER_GAP_PERCENT) / 100));
        var contentWidth = dc.getWidth() - (outerPadding * 2);
        var columnWidth = Math.floor((contentWidth - centerGap) / 2);
        var leftCellWidth = columnWidth;
        var rightCellLeft = outerPadding + columnWidth + centerGap;
        var rightCellWidth = columnWidth;
        var primaryContentHeight = layoutHeight - SECTION_DIVIDER_HEIGHT - SECTION_DIVIDER_GAP;
        var gateBlockHeight = Math.floor(primaryContentHeight / 3);
        var remainBlockHeight = Math.floor(primaryContentHeight / 3);
        var aidBlockHeight = primaryContentHeight - gateBlockHeight - remainBlockHeight;
        var gateBlockY = layoutTop;
        var remainBlockY = gateBlockY + gateBlockHeight;
        var dividerY = remainBlockY + remainBlockHeight + Math.floor(SECTION_DIVIDER_GAP / 2);
        var aidBlockY = dividerY + SECTION_DIVIDER_HEIGHT + (SECTION_DIVIDER_GAP - Math.floor(SECTION_DIVIDER_GAP / 2));
        var gateBlockRect = _newRect(outerPadding, gateBlockY, contentWidth, gateBlockHeight);
        var gateTitlePreferredFont = Gfx.FONT_XTINY;
        var gateTitleFont = _resolveSingleLineTextFont(
            dc,
            gateTitlePreferredFont,
            _gateTitleText,
            _rectWidth(gateBlockRect),
            _rectHeight(gateBlockRect)
        );
        var gateTitleHeight = _measureTextHeight(dc, _gateTitleText, gateTitleFont);
        var gateValueRowTop = gateBlockY + gateTitleHeight + GATE_HEADER_VALUE_GAP;
        var gateValueRowHeight = gateBlockHeight - gateTitleHeight - GATE_HEADER_VALUE_GAP;
        if (gateValueRowHeight < 1) {
            gateValueRowTop = gateBlockY;
            gateValueRowHeight = gateBlockHeight;
        }
        var gateLeftRect = _newRect(outerPadding, gateValueRowTop, leftCellWidth, gateValueRowHeight);
        var gateRightRect = _newRect(rightCellLeft, gateValueRowTop, rightCellWidth, gateValueRowHeight);
        var remainMergedRect = _newRect(outerPadding, remainBlockY, contentWidth, remainBlockHeight);
        var remainLeftRect = _newRect(outerPadding, remainBlockY, leftCellWidth, remainBlockHeight);
        var remainRightRect = _newRect(rightCellLeft, remainBlockY, rightCellWidth, remainBlockHeight);
        var aidMergedRect = _newRect(outerPadding, aidBlockY, contentWidth, aidBlockHeight);
        var aidRenderRect = _offsetRectVertically(
            _insetRectHorizontally(aidMergedRect, AID_STACKED_CELL_HORIZONTAL_INSET),
            AID_STACKED_VERTICAL_OFFSET
        );
        var gateLeftValueFont = _resolveValueFont(
            dc,
            Gfx.FONT_NUMBER_HOT,
            "",
            _gateDistanceText,
            unitFont,
            _gateDistanceUnitText,
            labelFont,
            _safeStackedCellWidthWithExtraMargin(gateLeftRect, GATE_TEXT_SAFE_MARGIN),
            _rectHeight(gateLeftRect)
        );
        var gateRightValueFont = _resolveValueFont(
            dc,
            Gfx.FONT_NUMBER_HOT,
            "",
            _gateTimeText,
            unitFont,
            "",
            labelFont,
            _safeStackedCellWidthWithExtraMargin(gateRightRect, GATE_TEXT_SAFE_MARGIN),
            _rectHeight(gateRightRect)
        );
        var gateSharedValueFont = _smallerNumberFont(gateLeftValueFont, gateRightValueFont);
        var remainLeftValueFont = _resolveStackedRowValueFont(
            dc,
            GATE_FACT_MAX_VALUE_FONT,
            remainLeftRect,
            labelFont,
            _gateRemainLeftLabelText,
            _gateRemainDistanceText,
            unitFont,
            _gateRemainDistanceUnitText
        );
        var remainRightValueFont = _resolveRemainingTimeValueFont(
            dc,
            Gfx.FONT_NUMBER_HOT,
            remainRightRect,
            labelFont,
            _gateRemainRightLabelText,
            _gateLeftTimeText,
            unitFont
        );
        var aidValueFont = _resolveAidRowValueFont(
            dc,
            AID_FACT_MAX_VALUE_FONT,
            aidRenderRect,
            labelFont,
            _aidTitleText,
            _aidRemainDistanceText,
            unitFont,
            _aidRemainDistanceUnitText
        );

        _drawGateHeaderMetricRow(
            dc,
            gateBlockRect,
            gateTitleFont,
            _gateTitleText,
            gateLeftRect,
            gateRightRect,
            unitFont,
            gateSharedValueFont,
            _gateDistanceText,
            _gateDistanceUnitText,
            _gateTimeText,
            Gfx.COLOR_WHITE
        );
        if (_remainMergedText.length() > 0) {
            var remainMergedFont = _resolveSingleLineTextFont(
                dc,
                Gfx.FONT_MEDIUM,
                _remainMergedText,
                _safeStackedCellWidth(remainMergedRect),
                _rectHeight(remainMergedRect)
            );
            _drawCenteredCompactInfoBlock(dc, remainMergedRect, labelFont, "", remainMergedFont, _remainMergedText, Gfx.COLOR_WHITE);
        } else {
            _drawStackedMetricBlockAligned(
                dc,
                remainLeftRect,
                true,
                labelFont,
                _gateRemainLeftLabelText,
                remainLeftValueFont,
                _gateRemainDistanceText,
                unitFont,
                _gateRemainDistanceUnitText,
                Gfx.COLOR_WHITE,
                false
            );
            _drawRemainingTimeMetricBlockAligned(
                dc,
                remainRightRect,
                false,
                labelFont,
                _gateRemainRightLabelText,
                remainRightValueFont,
                _gateLeftTimeText,
                unitFont,
                Gfx.COLOR_WHITE,
                true
            );
        }

        var hasAidBlock = _aidTitleText.length() > 0 or _aidRightLabelText.length() > 0 or _aidDistanceText.length() > 0 or _aidRemainDistanceText.length() > 0;
        if (hasAidBlock) {
            _drawSectionDivider(dc, dividerY, dc.getWidth());
            _drawStackedMetricBlockCentered(
                dc,
                aidRenderRect,
                labelFont,
                _aidTitleText,
                aidValueFont,
                _aidRemainDistanceText,
                unitFont,
                _aidRemainDistanceUnitText,
                Gfx.COLOR_WHITE
            );
        }

        _logLayoutDiag(
            dc,
            layoutHeight,
            gateBlockY,
            remainBlockY,
            aidBlockY,
            dividerY,
            gateBlockHeight,
            remainBlockHeight,
            aidBlockHeight,
            SECTION_DIVIDER_HEIGHT,
            labelFont,
            unitFont,
            gateRightValueFont,
            remainRightValueFont
        );
        _logFontDiag(
            dc,
            gateLeftRect,
            gateRightRect,
            remainLeftRect,
            remainRightRect,
            aidRenderRect,
            aidRenderRect,
            gateSharedValueFont,
            gateSharedValueFont,
            remainLeftValueFont,
            remainRightValueFont,
            aidValueFont,
            aidValueFont
        );
    }

    function _loadViewState(info) {
        if (!GateRaceData.hasResolvedRaceCode()) {
            _displayState = GateDisplayModel.STATE_CODE_ERROR;
            _singleText = Ui.loadResource(Rez.Strings.CheckAppSettings);
            _line1Text = "";
            _line2Text = "";
            _line3LeftText = "";
            _line3RightText = "";
            _line3LeftColor = Gfx.COLOR_WHITE;
            _line4Text = "";
            _resetRenderParts();
            return;
        }

        var currentDistanceKm = GateDistanceUtils.extractElapsedDistanceKm(info);
        if (currentDistanceKm == null) {
            _displayState = GateDisplayModel.STATE_WAIT_DIST;
            _singleText = Ui.loadResource(Rez.Strings.WaitDist);
            _line1Text = "";
            _line2Text = "";
            _line3LeftText = "";
            _line3RightText = "";
            _line3LeftColor = Gfx.COLOR_WHITE;
            _line4Text = "";
            return;
        }

        var gates = GateRaceData.getGates();
        var aids = GateRaceData.getAids();
        var nextGateConfig = GateNextSelector.newDefaultConfig();
        var nextAidConfig = GateAidSelector.newDefaultConfig();
        var remainingDistanceConfig = GateRemainingDistance.newDefaultConfig();
        var aidRemainingDistanceConfig = GateRemainingDistance.newDefaultConfig();
        var paceJudgeConfig = GatePaceJudge.newDefaultConfig();
        var requiredPaceConfig = GateRequiredPace.newDefaultConfig();
        var remainingTimeConfig = GateRemainingTime.newDefaultConfig();
        _currentPaceConfig = GateCurrentPace.updateCurrentPace(_currentPaceConfig, info, currentDistanceKm);
        nextGateConfig = GateNextSelector.selectNextGate(gates, currentDistanceKm);
        nextAidConfig = GateAidSelector.selectNextAid(aids, currentDistanceKm);

        if (GateNextSelector.hasNextGate(nextGateConfig)) {
            var nextGate = GateNextSelector.getNextGate(nextGateConfig);
            remainingDistanceConfig = GateRemainingDistance.computeRemainingDistance(
                currentDistanceKm,
                GateRaceData.getGateDistanceKm(nextGate)
            );
            remainingTimeConfig = GateRemainingTime.computeRemainingTime(
                GateRaceData.getGateCutoffDayOffset(nextGate),
                GateRaceData.getGateCutoffMinuteOfDay(nextGate)
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
        if (GateAidSelector.hasNextAid(nextAidConfig)) {
            aidRemainingDistanceConfig = GateRemainingDistance.computeRemainingDistance(
                currentDistanceKm,
                GateRaceData.getAidDistanceKm(GateAidSelector.getNextAid(nextAidConfig))
            );
        }
        var displayConfig = GateDisplayModel.buildDisplayModel(
            gates,
            nextGateConfig,
            remainingDistanceConfig,
            requiredPaceConfig,
            remainingTimeConfig,
            _currentPaceConfig,
            currentDistanceKm
        );
        _displayState = GateDisplayModel.getState(displayConfig);
        _singleText = GateDisplayModel.getSingleText(displayConfig);
        _line1Text = GateDisplayModel.getLine1(displayConfig);
        _line2Text = GateDisplayModel.getLine2(displayConfig);
        _line3LeftText = GateDisplayModel.getLine3Left(displayConfig);
        _line3RightText = GateDisplayModel.getLine3Right(displayConfig);
        _line3LeftColor = GateDisplayModel.getLine3LeftColor(displayConfig);
        _line4Text = GateDisplayModel.getLine4(displayConfig);
        _refreshRenderPartsFromCore(
            displayConfig,
            gates,
            nextGateConfig,
            nextAidConfig,
            remainingDistanceConfig,
            aidRemainingDistanceConfig,
            remainingTimeConfig,
            _currentPaceConfig,
            currentDistanceKm
        );
        _logCodeDiag(
            gates,
            aids,
            nextGateConfig,
            nextAidConfig,
            remainingDistanceConfig,
            aidRemainingDistanceConfig,
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

    function _refreshRenderPartsFromCore(displayConfig, gates, nextGateConfig, nextAidConfig, remainingDistanceConfig, aidRemainingDistanceConfig, remainingTimeConfig, currentPaceConfig, currentDistanceKm) {
        _resetRenderParts();

        var state = GateDisplayModel.getState(displayConfig);

        if (state == GateDisplayModel.STATE_ALL_PASSED) {
            _gateTitleText = Ui.loadResource(Rez.Strings.Last);
            _gateLeftLabelText = Ui.loadResource(Rez.Strings.Last);
            _gateRightLabelText = TO_GATE_LABEL_TEXT;
            if (gates != null and gates instanceof Lang.Array and gates.size() > 0) {
                var lastGate = gates[gates.size() - 1];
                var lastGateDisplayParts = GateRaceData.getGateDisplayParts(lastGate);
                _gateDistanceText = lastGateDisplayParts[0];
                _gateDistanceUnitText = lastGateDisplayParts[1];
                _gateTimeText = GateDistanceUtils.formatCloseTime(
                    GateRaceData.getGateCloseHour(lastGate),
                    GateRaceData.getGateCloseMinute(lastGate)
                );
            }
            _gateSummaryText = _buildGateSummaryText();
            _gateRemainLeftLabelText = TO_GATE_LABEL_TEXT;
            _gateRemainRightLabelText = Ui.loadResource(Rez.Strings.RemainLabel);
            _gateRemainDistanceText = "--";
            _gateRemainDistanceUnitText = "";
            _gateLeftTimeText = "";
            _remainMergedText = Ui.loadResource(Rez.Strings.AllPassed);
            _refreshAidRenderParts(nextAidConfig, aidRemainingDistanceConfig);
            return;
        }

        _gateRemainLeftLabelText = TO_GATE_LABEL_TEXT;
        _gateRemainRightLabelText = Ui.loadResource(Rez.Strings.RemainLabel);
        _remainMergedText = "";
        var nextGate = GateNextSelector.getNextGate(nextGateConfig);
        var remainingDistanceKm = GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig);
        if (nextGate != null) {
            var nextGateDisplayParts = GateRaceData.getGateDisplayParts(nextGate);
            _gateTitleText = _formatGateLabel(GateNextSelector.getNextIndex(nextGateConfig));
            _gateLeftLabelText = _formatGateLabel(GateNextSelector.getNextIndex(nextGateConfig));
            _gateRightLabelText = TO_GATE_LABEL_TEXT;
            _gateDistanceText = nextGateDisplayParts[0];
            _gateDistanceUnitText = nextGateDisplayParts[1];
            _gateTimeText = GateDistanceUtils.formatCloseTime(
                GateRaceData.getGateCloseHour(nextGate),
                GateRaceData.getGateCloseMinute(nextGate)
            );
            _gateSummaryText = _buildGateSummaryText();
        }

        var gateRemainDistanceParts = GateDistanceUtils.formatCompactDistanceParts(remainingDistanceKm);
        _gateRemainDistanceText = gateRemainDistanceParts[0];
        _gateRemainDistanceUnitText = gateRemainDistanceParts[1];
        _gateLeftTimeText = _formatGateRemainingTimeValue(GateRemainingTime.getRemainingSec(remainingTimeConfig));
        _refreshAidRenderParts(nextAidConfig, aidRemainingDistanceConfig);
    }

    function _refreshAidRenderParts(nextAidConfig, aidRemainingDistanceConfig) {
        _aidTitleText = TO_NEXT_AID_LABEL_TEXT;
        _aidRightLabelText = "";
        if (!GateAidSelector.hasNextAid(nextAidConfig)) {
            _aidDistanceText = "";
            _aidDistanceUnitText = "";
            _aidRemainDistanceText = "--";
            _aidRemainDistanceUnitText = "";
            return;
        }

        var aidRemainDistanceParts = GateDistanceUtils.formatCompactDistanceParts(
            GateRemainingDistance.getRemainingDistanceKm(aidRemainingDistanceConfig)
        );
        _aidDistanceText = "";
        _aidDistanceUnitText = "";
        _aidRemainDistanceText = aidRemainDistanceParts[0];
        _aidRemainDistanceUnitText = aidRemainDistanceParts[1];
    }

    function _resetRenderParts() {
        _gateTitleText = Ui.loadResource(Rez.Strings.GateLabel);
        _gateLeftLabelText = Ui.loadResource(Rez.Strings.GateLabel);
        _gateRightLabelText = TO_GATE_LABEL_TEXT;
        _gateSummaryText = "";
        _gateDistanceText = "";
        _gateDistanceUnitText = "";
        _gateTimeText = "";
        _gateRemainLeftLabelText = TO_GATE_LABEL_TEXT;
        _gateRemainRightLabelText = Ui.loadResource(Rez.Strings.RemainLabel);
        _gateRemainDistanceText = "";
        _gateRemainDistanceUnitText = "";
        _gateLeftTimeText = "";
        _remainMergedText = "";
        _aidTitleText = TO_NEXT_AID_LABEL_TEXT;
        _aidRightLabelText = "";
        _aidDistanceText = "";
        _aidDistanceUnitText = "";
        _aidRemainDistanceText = "--";
        _aidRemainDistanceUnitText = "";
    }

    function _formatGateLabel(index) {
        if (index == null or index < 0) {
            return "GATE";
        }

        return "GATE" + (index + 1).format("%d");
    }

    function _buildGateSummaryText() {
        var summary = "";
        if (_gateDistanceText != null) {
            summary += _gateDistanceText;
        }
        if (_gateDistanceUnitText != null) {
            summary += _gateDistanceUnitText;
        }
        if (_gateTimeText != null and _gateTimeText.length() > 0) {
            if (summary.length() > 0) {
                summary += " / ";
            }
            summary += _gateTimeText;
        }
        return summary;
    }

    function _formatGateRemainingTimeValue(remainingSec) {
        if (remainingSec == null) {
            return "--:--";
        }

        var absSec = remainingSec;
        if (absSec < 0) {
            absSec = -absSec;
        }

        var totalMinutes = Math.floor((absSec + 59) / 60);
        var hourPart = Math.floor(totalMinutes / 60);
        var minPart = totalMinutes - (hourPart * 60);
        var remainingText = hourPart.format("%d") + "h" + minPart.format("%02d");
        if (remainingSec >= 0) {
            return remainingText;
        }
        return "-" + remainingText;
    }

    function _logCodeDiag(gates, aids, nextGateConfig, nextAidConfig, remainingDistanceConfig, aidRemainingDistanceConfig, paceJudgeConfig, requiredPaceConfig, remainingTimeConfig, currentPaceConfig, displayConfig, currentDistanceKm, singleText, line1Text, line2Text, line3LeftText, line3RightText, line4Text) {
        if (!CODE_DEBUG_LOG) {
            return;
        }

        var firstGateSummary = "none";
        if (gates != null and gates instanceof Lang.Array and gates.size() > 0) {
            firstGateSummary = GateRaceData.formatGateSummary(gates[0]);
        }

        var nextGateSummary = "none";
        var nextGate = GateNextSelector.getNextGate(nextGateConfig);
        if (nextGate != null) {
            nextGateSummary = GateRaceData.formatGateSummary(nextGate);
        }

        var nextAidSummary = "none";
        if (GateAidSelector.hasNextAid(nextAidConfig)) {
            var nextAid = GateAidSelector.getNextAid(nextAidConfig);
            nextAidSummary = GateRaceData.getAidDisplayValue(nextAid) + GateRaceData.getAidDisplayUnit(nextAid);
        }

        var gateCount = 0;
        if (gates != null and gates instanceof Lang.Array) {
            gateCount = gates.size();
        }
        var aidCount = 0;
        if (aids != null and aids instanceof Lang.Array) {
            aidCount = aids.size();
        }

        var line =
            "[GATE_RACE_DIAG]" +
            " raceId=" + _diagValue(GateRaceData.getRaceId()) +
            " requestedRaceCode=" + _diagValue(GateRaceData.getRequestedRaceCode()) +
            " selectedRaceCode=" + _diagValue(GateRaceData.getSelectedRaceCode()) +
            " selectedCourseId=" + _diagValue(GateRaceData.getSelectedCourseId()) +
            " raceReason=" + _diagValue(GateRaceData.getSelectedRaceReason()) +
            " gateCount=" + _diagValue(gateCount) +
            " aidCount=" + _diagValue(aidCount) +
            " firstGate=" + _diagValue(firstGateSummary) +
            " currentDistanceKm=" + _diagValue(currentDistanceKm) +
            " nextReason=" + _diagValue(GateNextSelector.getReason(nextGateConfig)) +
            " nextIndex=" + _diagValue(GateNextSelector.getNextIndex(nextGateConfig)) +
            " nextGate=" + _diagValue(nextGateSummary) +
            " nextAidReason=" + _diagValue(GateAidSelector.getReason(nextAidConfig)) +
            " nextAid=" + _diagValue(nextAidSummary) +
            " remainDistReason=" + _diagValue(GateRemainingDistance.getReason(remainingDistanceConfig)) +
            " remainDistKm=" + _diagValue(GateRemainingDistance.getRemainingDistanceKm(remainingDistanceConfig)) +
            " aidRemainDistKm=" + _diagValue(GateRemainingDistance.getRemainingDistanceKm(aidRemainingDistanceConfig)) +
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

    function _diagText(value) {
        if (value == null) {
            return "null";
        }

        var text = value.toString();
        return "\"" + text + "\"(" + text.length().format("%d") + ")";
    }

    function _isJapaneseAppName() {
        var appName = Ui.loadResource(Rez.Strings.AppName);
        return appName != null and appName.equals("関門ガイド");
    }

    function _logLayoutDiag(dc, blockHeight, gateBlockY, remainBlockY, aidBlockY, footerBlockY, gateBlockHeight, remainBlockHeight, aidBlockHeight, footerBlockHeight, labelFont, unitFont, edgeGroupFont, mainGroupFont) {
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
            " yFooterBlock=" + _diagValue(footerBlockY) +
            " hGateBlock=" + _diagValue(gateBlockHeight) +
            " hRemainBlock=" + _diagValue(remainBlockHeight) +
            " hAidBlock=" + _diagValue(aidBlockHeight) +
            " hFooterBlock=" + _diagValue(footerBlockHeight) +
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

    function _logFontDiag(
        dc,
        gateLeftRect,
        gateRightRect,
        remainLeftRect,
        remainRightRect,
        aidLeftRect,
        aidRightRect,
        gateLeftValueFont,
        gateRightValueFont,
        remainLeftValueFont,
        remainRightValueFont,
        aidLeftValueFont,
        aidRightValueFont
    ) {
        if (!FONT_DEBUG_LOG) {
            return;
        }

        var line =
            "[GATE_FONT_DIAG]" +
            " gateLeftFont=" + _fontName(gateLeftValueFont) +
            " gateRightFont=" + _fontName(gateRightValueFont) +
            " remainLeftFont=" + _fontName(remainLeftValueFont) +
            " remainRightFont=" + _fontName(remainRightValueFont) +
            " aidLeftFont=" + _fontName(aidLeftValueFont) +
            " aidRightFont=" + _fontName(aidRightValueFont) +
            " gateLeftRect=" + _rectLeft(gateLeftRect) + "," + _rectTop(gateLeftRect) + "," + _rectWidth(gateLeftRect) + "," + _rectHeight(gateLeftRect) +
            " gateRightRect=" + _rectLeft(gateRightRect) + "," + _rectTop(gateRightRect) + "," + _rectWidth(gateRightRect) + "," + _rectHeight(gateRightRect) +
            " remainLeftRect=" + _rectLeft(remainLeftRect) + "," + _rectTop(remainLeftRect) + "," + _rectWidth(remainLeftRect) + "," + _rectHeight(remainLeftRect) +
            " remainRightRect=" + _rectLeft(remainRightRect) + "," + _rectTop(remainRightRect) + "," + _rectWidth(remainRightRect) + "," + _rectHeight(remainRightRect) +
            " aidLeftRect=" + _rectLeft(aidLeftRect) + "," + _rectTop(aidLeftRect) + "," + _rectWidth(aidLeftRect) + "," + _rectHeight(aidLeftRect) +
            " aidRightRect=" + _rectLeft(aidRightRect) + "," + _rectTop(aidRightRect) + "," + _rectWidth(aidRightRect) + "," + _rectHeight(aidRightRect) +
            " gateLeftText=" + _diagValue(_gateDistanceText) +
            " gateRightText=" + _diagValue(_gateRemainDistanceText) +
            " remainLeftText=" + _diagValue(_gateTimeText) +
            " remainRightText=" + _diagValue(_gateLeftTimeText) +
            " aidLeftText=" + _diagValue(_aidDistanceText) +
            " aidRightText=" + _diagValue(_aidRemainDistanceText);
        if (_lastFontDiagLine == line) {
            return;
        }
        _lastFontDiagLine = line;
        Sys.println(line);
    }

    function _shouldRenderPreStartSplash() {
        if (_displayState == GateDisplayModel.STATE_WAIT_DIST) {
            return true;
        }
        if (_displayState != GateDisplayModel.STATE_CODE_ERROR) {
            return false;
        }
        return GateRaceData.isRaceCodeMissing() or GateRaceData.isRaceCodeNotFound();
    }

    function _drawPreStartSplash(dc, centerX, centerY) {
        var appName = Ui.loadResource(Rez.Strings.AppName);
        var raceName = _resolveLocalizedRaceName();
        var courseName = _resolveLocalizedCourseName();
        var statusText = _singleText;
        var maxWidth = _resolvePreStartMaxWidth(dc);
        var appNameFont = _resolvePreStartTextFont(dc, _resolvePreStartPreferredFont(appName, Gfx.FONT_SMALL), appName, maxWidth);
        var raceNameFont = _resolvePreStartTextFont(dc, _resolvePreStartPreferredFont(raceName, Gfx.FONT_XTINY), raceName, maxWidth);
        var courseNameFont = _resolvePreStartTextFont(dc, _resolvePreStartPreferredFont(courseName, Gfx.FONT_SYSTEM_XTINY), courseName, maxWidth);
        var statusFont = Gfx.FONT_SYSTEM_XTINY;
        var appNameLines = _wrapTextLines(dc, appName, appNameFont, maxWidth);
        var raceNameLines = _wrapTextLines(dc, raceName, raceNameFont, maxWidth);
        var courseNameLines = _wrapTextLines(dc, courseName, courseNameFont, maxWidth);
        var appNameHeight = _measureWrappedTextHeight(dc, appNameLines, appNameFont);
        var raceNameHeight = _measureWrappedTextHeight(dc, raceNameLines, raceNameFont);
        var courseNameHeight = _measureWrappedTextHeight(dc, courseNameLines, courseNameFont);
        var statusHeight = _measureTextHeight(dc, statusText, statusFont);
        var topGap = 4;
        var courseGap = 3;
        var bottomGap = 10;
        var totalHeight = appNameHeight + topGap + raceNameHeight + courseGap + courseNameHeight + bottomGap + statusHeight;
        var topY = centerY - Math.floor(totalHeight / 2);
        var appNameY = topY;
        var raceNameY = appNameY + appNameHeight + topGap;
        var courseNameY = raceNameY + raceNameHeight + courseGap;
        var statusY = courseNameY + courseNameHeight + bottomGap;
        _logPreStartDiag(
            "layout",
            "appName=" + _diagText(appName) +
            " appFont=" + _fontName(appNameFont) +
            " appLines=" + _diagValue(appNameLines.size()) +
            " raceName=" + _diagText(raceName) +
            " raceFont=" + _fontName(raceNameFont) +
            " raceLines=" + _diagValue(raceNameLines.size()) +
            " courseName=" + _diagText(courseName) +
            " courseFont=" + _fontName(courseNameFont) +
            " courseLines=" + _diagValue(courseNameLines.size()) +
            " status=" + _diagText(statusText) +
            " statusFont=" + _fontName(statusFont) +
            " maxWidth=" + _diagValue(maxWidth) +
            " totalHeight=" + _diagValue(totalHeight) +
            " centerX=" + _diagValue(centerX) +
            " centerY=" + _diagValue(centerY)
        );

        _drawWrappedPreStartLines(dc, centerX, appNameY, appNameLines, appNameFont, Gfx.COLOR_WHITE);
        _drawWrappedPreStartLines(dc, centerX, raceNameY, raceNameLines, raceNameFont, Gfx.COLOR_WHITE);
        _drawWrappedPreStartLines(dc, centerX, courseNameY, courseNameLines, courseNameFont, Gfx.COLOR_WHITE);
        _logPreStartDiag(
            "draw.status",
            "text=" + _diagText(statusText) +
            " font=" + _fontName(statusFont) +
            " y=" + _diagValue(statusY)
        );
        _drawPreStartLine(dc, centerX, statusY, statusFont, statusText, Gfx.COLOR_WHITE);
    }

    function _resolvePreStartTextFont(dc, preferredFont, text, maxWidth) {
        var font = preferredFont;
        while (_measureTextWidth(dc, text, font) > maxWidth) {
            var nextFont = _shrinkTextFont(font);
            if (nextFont == font) {
                return font;
            }
            font = nextFont;
        }
        return font;
    }

    function _resolvePreStartPreferredFont(text, preferredFont) {
        if (_isJapaneseAppName()) {
            return Gfx.FONT_SYSTEM_XTINY;
        }
        return preferredFont;
    }

    function _resolveLocalizedRaceName() {
        if (GateRaceData.isRaceCodeMissing() or GateRaceData.isRaceCodeNotFound()) {
            return Ui.loadResource(Rez.Strings.RaceCodeLabel);
        }
        var appName = Ui.loadResource(Rez.Strings.AppName);
        if (appName != null and appName.equals("関門ガイド")) {
            return GateRaceData.getRaceNameJpn();
        }
        return GateRaceData.getRaceNameEng();
    }

    function _resolveLocalizedCourseName() {
        if (GateRaceData.isRaceCodeMissing()) {
            return Ui.loadResource(Rez.Strings.RaceCodeNotSet);
        }
        if (GateRaceData.isRaceCodeNotFound()) {
            return Ui.loadResource(Rez.Strings.RaceCodeNotFound);
        }
        var appName = Ui.loadResource(Rez.Strings.AppName);
        if (appName != null and appName.equals("関門ガイド")) {
            return GateRaceData.getPreStartCourseNameJpn();
        }
        return GateRaceData.getPreStartCourseNameEng();
    }

    function _resolvePreStartMaxWidth(dc) {
        var safeWidth = Math.floor((dc.getWidth() * 68) / 100);
        if (safeWidth < 1) {
            return dc.getWidth();
        }
        return safeWidth;
    }

    function _wrapTextLines(dc, text, font, maxWidth) {
        if (text == null or text.length() == 0) {
            return [""];
        }
        if (_measureTextWidth(dc, text, font) <= maxWidth) {
            return [text];
        }

        var lines = [];
        var currentLine = "";
        for (var i = 0; i < text.length(); i += 1) {
            var ch = text.substring(i, i + 1);
            var nextLine = currentLine + ch;
            if (currentLine.length() > 0 and _measureTextWidth(dc, nextLine, font) > maxWidth) {
                lines.add(currentLine);
                currentLine = ch;
            } else {
                currentLine = nextLine;
            }
        }
        if (currentLine.length() > 0) {
            lines.add(currentLine);
        }
        return lines;
    }

    function _measureWrappedTextHeight(dc, lines, font) {
        if (lines == null or lines.size() <= 0) {
            return 0;
        }

        var lineHeight = _measureTextHeight(dc, "A", font);
        return lineHeight * lines.size();
    }

    function _drawWrappedCenteredLines(dc, centerX, topY, lines, font, color) {
        if (lines == null or lines.size() <= 0) {
            return;
        }

        var lineHeight = _measureTextHeight(dc, "A", font);
        for (var i = 0; i < lines.size(); i += 1) {
            _logPreStartDiag(
                "draw.line",
                "index=" + _diagValue(i) +
                " text=" + _diagText(lines[i]) +
                " font=" + _fontName(font) +
                " width=" + _diagValue(_measureTextWidth(dc, lines[i], font)) +
                " centerX=" + _diagValue(centerX) +
                " y=" + _diagValue(topY + (lineHeight * i))
            );
            _drawCenteredLine(dc, centerX, topY + (lineHeight * i), font, lines[i], color, false);
        }
    }

    function _drawWrappedPreStartLines(dc, centerX, topY, lines, font, color) {
        if (lines == null or lines.size() <= 0) {
            return;
        }

        var lineHeight = _measureTextHeight(dc, "A", font);
        for (var i = 0; i < lines.size(); i += 1) {
            _drawPreStartLine(dc, centerX, topY + (lineHeight * i), font, lines[i], color);
        }
    }

    function _drawPreStartLine(dc, centerX, y, font, text, color) {
        if (text == null or text.length() == 0) {
            return;
        }

        var leftX = centerX - Math.floor(_measureTextWidth(dc, text, font) / 2);
        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.drawText(leftX, y, font, text, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function _resolveLabelY(blockY, blockHeight, labelHeight, valueHeight) {
        var labelValueGap = STACKED_LABEL_VALUE_GAP;
        var contentHeight = labelHeight + labelValueGap + valueHeight;
        return _resolveContentY(blockY, blockHeight, contentHeight);
    }

    function _resolveValueY(labelTopY, labelHeight) {
        return labelTopY + labelHeight + STACKED_LABEL_VALUE_GAP;
    }

    function _resolveGateSummaryFont(dc, preferredFont, labelFont, labelText, summaryText, maxWidth, maxHeight) {
        var font = preferredFont;
        while (
            _measureTextWidth(dc, summaryText, font) > maxWidth or
            !_fitsStackedTextHeight(dc, labelFont, labelText, font, summaryText, maxHeight)
        ) {
            var nextFont = _shrinkTextFont(font);
            if (nextFont == font) {
                return font;
            }
            font = nextFont;
        }
        return font;
    }

    function _resolveSingleLineTextFont(dc, preferredFont, text, maxWidth, maxHeight) {
        var font = preferredFont;
        while (
            _measureTextWidth(dc, text, font) > maxWidth or
            _measureTextHeight(dc, text, font) > maxHeight
        ) {
            var nextFont = _shrinkTextFont(font);
            if (nextFont == font) {
                return font;
            }
            font = nextFont;
        }
        return font;
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

    function _measureTextWidth(dc, text, font) {
        if (text == null or text.length() == 0) {
            return 0;
        }
        return dc.getTextWidthInPixels(text, font);
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

    function _insetRectHorizontally(rect, inset) {
        var nextInset = inset;
        if (nextInset == null or nextInset < 0) {
            nextInset = 0;
        }

        var nextWidth = _rectWidth(rect) - (nextInset * 2);
        if (nextWidth < 1) {
            nextWidth = 1;
        }
        return [_rectLeft(rect) + nextInset, _rectTop(rect), nextWidth, _rectHeight(rect)];
    }

    function _offsetRectVertically(rect, offset) {
        var nextOffset = offset;
        if (nextOffset == null) {
            nextOffset = 0;
        }
        return [_rectLeft(rect), _rectTop(rect) + nextOffset, _rectWidth(rect), _rectHeight(rect)];
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

    function _resolveStackedRowValueFont(dc, preferredFont, cellRect, labelFont, labelText, valueText, unitFont, unitText) {
        return _resolveValueFont(
            dc,
            preferredFont,
            labelText,
            valueText,
            unitFont,
            unitText,
            labelFont,
            _safeStackedCellWidth(cellRect),
            _rectHeight(cellRect)
        );
    }

    function _resolveAidRowValueFont(dc, preferredFont, cellRect, labelFont, labelText, valueText, unitFont, unitText) {
        return _resolveValueFont(
            dc,
            preferredFont,
            labelText,
            valueText,
            unitFont,
            unitText,
            labelFont,
            _safeStackedCellWidthWithExtraMargin(cellRect, AID_TEXT_SAFE_MARGIN),
            _rectHeight(cellRect)
        );
    }

    function _resolveRemainingTimeValueFont(dc, preferredFont, cellRect, labelFont, labelText, valueText, unitFont) {
        var timeParts = _splitRemainingTimeParts(valueText);
        if (timeParts == null) {
            return _resolveStackedRowValueFont(dc, preferredFont, cellRect, labelFont, labelText, valueText, unitFont, "");
        }

        var font = preferredFont;
        while (
            _measureRemainingTimeValueWidth(dc, font, timeParts, unitFont) > _safeStackedCellWidth(cellRect) or
            !_fitsStackedRemainingTimeHeight(dc, labelFont, labelText, font, timeParts, unitFont, _rectHeight(cellRect))
        ) {
            var nextFont = _shrinkNumberFont(font);
            if (nextFont == font) {
                return font;
            }
            font = nextFont;
        }
        return font;
    }

    function _resolveValueFont(dc, preferredFont, labelText, numberText, unitFont, unitText, labelFont, maxWidth, maxHeight) {
        if (_useTextValueFont(numberText)) {
            preferredFont = Gfx.FONT_MEDIUM;
        }

        var font = preferredFont;
        while (
            _measureValueWidth(dc, font, numberText, unitFont, unitText) > maxWidth or
            !_fitsStackedMetricHeight(dc, labelFont, labelText, font, numberText, maxHeight)
        ) {
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
        if (numberText == null or numberText.length() == 0) {
            return false;
        }
        var allowedChars = "0123456789.:-+ ";
        for (var i = 0; i < numberText.length(); i += 1) {
            var ch = numberText.substring(i, i + 1);
            if (allowedChars.find(ch) == null) {
                return true;
            }
        }
        return false;
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

    function _measureRemainingTimeValueWidth(dc, valueFont, timeParts, unitFont) {
        if (timeParts == null) {
            return 0;
        }

        return _measureTextWidth(dc, timeParts[0], valueFont) +
            _measureTextWidth(dc, timeParts[1], unitFont) +
            _measureTextWidth(dc, timeParts[2], valueFont);
    }

    function _measureRemainingTimeValueHeight(dc, valueFont, timeParts, unitFont) {
        if (timeParts == null) {
            return 0;
        }

        var valueHeight = _maxInt(
            _measureTextHeight(dc, timeParts[0], valueFont),
            _measureTextHeight(dc, timeParts[2], valueFont)
        );
        return _maxInt(valueHeight, _measureTextHeight(dc, timeParts[1], unitFont));
    }

    function _fitsStackedMetricHeight(dc, labelFont, labelText, valueFont, valueText, maxHeight) {
        if (maxHeight == null or maxHeight < 1) {
            return true;
        }

        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureTextHeight(dc, valueText, valueFont);
        return (labelHeight + STACKED_LABEL_VALUE_GAP + valueHeight) <= maxHeight;
    }

    function _fitsStackedTextHeight(dc, labelFont, labelText, valueFont, valueText, maxHeight) {
        return _fitsStackedMetricHeight(dc, labelFont, labelText, valueFont, valueText, maxHeight);
    }

    function _fitsStackedRemainingTimeHeight(dc, labelFont, labelText, valueFont, timeParts, unitFont, maxHeight) {
        if (maxHeight == null or maxHeight < 1) {
            return true;
        }

        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureRemainingTimeValueHeight(dc, valueFont, timeParts, unitFont);
        return (labelHeight + STACKED_LABEL_VALUE_GAP + valueHeight) <= maxHeight;
    }

    function _safeStackedCellWidth(cellRect) {
        var safeWidth = _rectWidth(cellRect) - STACKED_CELL_HORIZONTAL_INSET;
        if (safeWidth < 1) {
            return 1;
        }
        return safeWidth;
    }

    function _safeStackedCellWidthWithExtraMargin(cellRect, extraMargin) {
        var safeWidth = _safeStackedCellWidth(cellRect);
        var margin = extraMargin;
        if (margin == null or margin < 0) {
            margin = 0;
        }
        safeWidth -= margin;
        if (safeWidth < 1) {
            return 1;
        }
        return safeWidth;
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

    function _shrinkTextFont(font) {
        if (font == Gfx.FONT_MEDIUM) {
            return Gfx.FONT_SMALL;
        }
        if (font == Gfx.FONT_SMALL) {
            return Gfx.FONT_XTINY;
        }
        if (font == Gfx.FONT_XTINY) {
            return Gfx.FONT_SYSTEM_XTINY;
        }
        return font;
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

    function _drawValueWithUnitAligned(dc, cellRect, alignRight, y, valueFont, numberText, unitFont, unitText, color, boldText) {
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

        _drawTextWithOptionalBold(dc, startX, y, valueFont, numberText, Gfx.TEXT_JUSTIFY_LEFT, color, boldText);
        if (unitText.length() > 0) {
            _drawTextWithOptionalBold(dc, startX + numberWidth + unitGap, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT, color, boldText);
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
        var labelY = _resolveLabelY(_rectTop(cellRect), _rectHeight(cellRect), labelHeight, valueHeight);
        var valueY = _resolveValueY(labelY, labelHeight);
        var centerX = _rectCenterX(cellRect);

        _drawCenteredLine(dc, centerX, labelY, labelFont, labelText, color, false);
        _drawValueWithUnitCentered(dc, centerX, valueY, valueFont, valueText, unitFont, unitText, color);
    }

    function _drawStackedMetricBlockAligned(dc, cellRect, alignRight, labelFont, labelText, valueFont, valueText, unitFont, unitText, color, boldText) {
        if ((labelText == null or labelText.length() == 0) and (valueText == null or valueText.length() == 0)) {
            return;
        }

        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureTextHeight(dc, valueText, valueFont);
        var labelY = _resolveLabelY(_rectTop(cellRect), _rectHeight(cellRect), labelHeight, valueHeight);
        var valueY = _resolveValueY(labelY, labelHeight);
        var labelAnchorX = _resolveInnerLabelAnchorX(cellRect, alignRight);

        _drawCenteredLine(dc, labelAnchorX, labelY, labelFont, labelText, color, boldText);
        _drawValueWithUnitAligned(dc, cellRect, alignRight, valueY, valueFont, valueText, unitFont, unitText, color, boldText);
    }

    function _drawRemainingTimeMetricBlockAligned(dc, cellRect, alignRight, labelFont, labelText, valueFont, valueText, unitFont, color, boldText) {
        if ((labelText == null or labelText.length() == 0) and (valueText == null or valueText.length() == 0)) {
            return;
        }

        var timeParts = _splitRemainingTimeParts(valueText);
        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = timeParts == null ? _measureTextHeight(dc, valueText, valueFont) : _measureRemainingTimeValueHeight(dc, valueFont, timeParts, unitFont);
        var labelY = _resolveLabelY(_rectTop(cellRect), _rectHeight(cellRect), labelHeight, valueHeight);
        var valueY = _resolveValueY(labelY, labelHeight);
        var labelAnchorX = _resolveInnerLabelAnchorX(cellRect, alignRight);

        _drawCenteredLine(dc, labelAnchorX, labelY, labelFont, labelText, color, boldText);
        _drawRemainingTimeValueAligned(dc, cellRect, alignRight, valueY, valueFont, valueText, unitFont, color, boldText);
    }

    function _resolveAidUnitY(dc, cellRect, unitFont, unitText) {
        if (unitText == null or unitText.length() == 0) {
            return _rectTop(cellRect) + _rectHeight(cellRect);
        }
        return _rectTop(cellRect) + _rectHeight(cellRect) - _measureTextHeight(dc, unitText, unitFont) - AID_BOTTOM_PADDING;
    }

    function _drawBottomUnitAligned(dc, cellRect, alignRight, unitFont, unitText, color, boldText) {
        if (unitText == null or unitText.length() == 0) {
            return;
        }

        var unitWidth = dc.getTextWidthInPixels(unitText, unitFont);
        var unitX = alignRight ? (_rectRight(cellRect) - unitWidth) : _rectLeft(cellRect);
        var unitY = _resolveAidUnitY(dc, cellRect, unitFont, unitText);
        _drawTextWithOptionalBold(dc, unitX, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT, color, boldText);
    }

    function _drawAidMetricBlockAligned(dc, cellRect, alignRight, labelFont, labelText, valueFont, valueText, unitFont, unitText, color, boldText) {
        if ((labelText == null or labelText.length() == 0) and (valueText == null or valueText.length() == 0)) {
            return;
        }

        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureTextHeight(dc, valueText, valueFont);
        var labelY = _resolveLabelY(_rectTop(cellRect), _rectHeight(cellRect), labelHeight, valueHeight);
        var valueY = _resolveValueY(labelY, labelHeight);
        _drawAlignedLine(dc, cellRect, alignRight, labelY, labelFont, labelText, color);
        _drawAidValueWithUnitAligned(dc, cellRect, alignRight, valueY, valueFont, valueText, unitFont, unitText, color, boldText);
    }

    function _drawAidValueWithUnitAligned(dc, cellRect, alignRight, y, valueFont, numberText, unitFont, unitText, color, boldText) {
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
        if (boldText) {
            dc.drawText(startX + 1, y, valueFont, numberText, Gfx.TEXT_JUSTIFY_LEFT);
        }
        if (unitText.length() > 0) {
            var unitX = startX + numberWidth + unitGap;
            dc.drawText(unitX, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
            if (boldText) {
                dc.drawText(unitX + 1, unitY, unitFont, unitText, Gfx.TEXT_JUSTIFY_LEFT);
            }
        }
    }

    function _resolveInnerLabelAnchorX(cellRect, alignRight) {
        if (alignRight) {
            return _rectLeft(cellRect) + Math.floor((_rectWidth(cellRect) * (100 - LABEL_ANCHOR_INNER_RATIO_PERCENT)) / 100);
        }
        return _rectLeft(cellRect) + Math.floor((_rectWidth(cellRect) * LABEL_ANCHOR_INNER_RATIO_PERCENT) / 100);
    }

    function _logAidDiag(dc, cellRect, alignRight, labelText, valueText, unitText, labelFont, valueFont, unitFont, labelY, valueY, unitY) {
        if (!AID_DEBUG_LOG) {
            return;
        }

        var line =
            "[GATE_AID_DIAG]" +
            " alignRight=" + _diagValue(alignRight) +
            " rect=" + _rectLeft(cellRect) + "," + _rectTop(cellRect) + "," + _rectWidth(cellRect) + "," + _rectHeight(cellRect) +
            " label=" + _diagValue(labelText) +
            " value=" + _diagValue(valueText) +
            " unit=" + _diagValue(unitText) +
            " labelFont=" + _fontName(labelFont) +
            " valueFont=" + _fontName(valueFont) +
            " unitFont=" + _fontName(unitFont) +
            " labelY=" + _diagValue(labelY) +
            " valueY=" + _diagValue(valueY) +
            " unitY=" + _diagValue(unitY) +
            " screenH=" + _diagValue(dc.getHeight());
        if (_lastAidDiagLine == line) {
            return;
        }
        _lastAidDiagLine = line;
        Sys.println(line);
    }

    function _drawTextAligned(dc, cellRect, alignRight, y, font, text, color, boldText) {
        if (text == null or text.length() == 0) {
            return;
        }

        var textWidth = dc.getTextWidthInPixels(text, font);
        var textX = alignRight ? (_rectRight(cellRect) - textWidth) : _rectLeft(cellRect);
        _drawTextWithOptionalBold(dc, textX, y, font, text, Gfx.TEXT_JUSTIFY_LEFT, color, boldText);
    }

    function _drawRemainingTimeValueAligned(dc, cellRect, alignRight, y, valueFont, valueText, unitFont, color, boldText) {
        var timeParts = _splitRemainingTimeParts(valueText);
        if (timeParts == null) {
            _drawTextAligned(dc, cellRect, alignRight, y, valueFont, valueText, color, boldText);
            return;
        }

        var leftWidth = _measureTextWidth(dc, timeParts[0], valueFont);
        var unitWidth = _measureTextWidth(dc, timeParts[1], unitFont);
        var rightWidth = _measureTextWidth(dc, timeParts[2], valueFont);
        var totalWidth = leftWidth + unitWidth + rightWidth;
        var startX = alignRight ? (_rectRight(cellRect) - totalWidth) : _rectLeft(cellRect);
        var unitY = y + Math.floor((Gfx.getFontHeight(valueFont) * 58) / 100) - Math.floor(Gfx.getFontHeight(unitFont) / 2);

        _drawTextWithOptionalBold(dc, startX, y, valueFont, timeParts[0], Gfx.TEXT_JUSTIFY_LEFT, color, boldText);
        _drawTextWithOptionalBold(dc, startX + leftWidth, unitY, unitFont, timeParts[1], Gfx.TEXT_JUSTIFY_LEFT, color, boldText);
        _drawTextWithOptionalBold(dc, startX + leftWidth + unitWidth, y, valueFont, timeParts[2], Gfx.TEXT_JUSTIFY_LEFT, color, boldText);
    }

    function _drawTwoColumnMetricRow(
        dc,
        leftRect,
        rightRect,
        labelFont,
        unitFont,
        leftLabelText,
        leftValueFont,
        leftValueText,
        leftUnitText,
        rightLabelText,
        rightValueFont,
        rightValueText,
        rightUnitText,
        color
    ) {
        _drawStackedMetricBlockAligned(dc, leftRect, true, labelFont, leftLabelText, leftValueFont, leftValueText, unitFont, leftUnitText, color, false);
        _drawStackedMetricBlockAligned(dc, rightRect, false, labelFont, rightLabelText, rightValueFont, rightValueText, unitFont, rightUnitText, color, true);
    }

    function _drawGateHeaderMetricRow(dc, gateBlockRect, titleFont, titleText, leftRect, rightRect, unitFont, valueFont, leftValueText, leftUnitText, rightValueText, color) {
        if (titleText != null and titleText.length() > 0) {
            _drawCenteredLine(dc, _rectCenterX(gateBlockRect), _rectTop(gateBlockRect), titleFont, titleText, color, false);
        }
        _drawValueWithUnitAligned(dc, leftRect, true, _resolveCenteredValueY(dc, leftRect, valueFont, leftValueText), valueFont, leftValueText, unitFont, leftUnitText, color, false);
        _drawTextAligned(dc, rightRect, false, _resolveCenteredValueY(dc, rightRect, valueFont, rightValueText), valueFont, rightValueText, color, true);
    }

    function _drawTwoColumnAidMetricRow(
        dc,
        leftRect,
        rightRect,
        labelFont,
        unitFont,
        leftLabelText,
        leftValueFont,
        leftValueText,
        leftUnitText,
        rightLabelText,
        rightValueFont,
        rightValueText,
        rightUnitText,
        color
    ) {
        _drawAidMetricBlockAligned(dc, leftRect, true, labelFont, leftLabelText, leftValueFont, leftValueText, unitFont, leftUnitText, color, false);
        _drawAidMetricBlockAligned(dc, rightRect, false, labelFont, rightLabelText, rightValueFont, rightValueText, unitFont, rightUnitText, color, true);
    }

    function _drawCenteredCompactInfoBlock(dc, cellRect, labelFont, labelText, valueFont, valueText, color) {
        if ((labelText == null or labelText.length() == 0) and (valueText == null or valueText.length() == 0)) {
            return;
        }

        var labelHeight = _measureTextHeight(dc, labelText, labelFont);
        var valueHeight = _measureTextHeight(dc, valueText, valueFont);
        var labelY = _resolveLabelY(_rectTop(cellRect), _rectHeight(cellRect), labelHeight, valueHeight);
        var valueY = _resolveValueY(labelY, labelHeight);
        var centerX = _rectCenterX(cellRect);

        _drawCenteredLine(dc, centerX, labelY, labelFont, labelText, color, false);
        _drawCenteredLine(dc, centerX, valueY, valueFont, valueText, color, false);
    }

    function _resolveCenteredValueY(dc, cellRect, valueFont, valueText) {
        return _rectTop(cellRect) + Math.floor((_rectHeight(cellRect) - _measureTextHeight(dc, valueText, valueFont)) / 2);
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

    function _drawSectionDivider(dc, dividerY, screenWidth) {
        var dividerInset = Math.floor((screenWidth * SECTION_DIVIDER_INSET_PERCENT) / 100);
        var dividerWidth = screenWidth - (dividerInset * 2);
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
        if (font == Gfx.FONT_XTINY) {
            return "FONT_XTINY";
        }
        if (font == Gfx.FONT_SYSTEM_XTINY) {
            return "FONT_SYSTEM_XTINY";
        }
        return "FONT_UNKNOWN";
    }

    function _logPreStartDiag(stage, line) {
        if (!PRESTART_DEBUG_LOG) {
            return;
        }

        var formatted = "[GATE_PRESTART] stage=" + stage + " " + line;
        if (_lastPreStartDiagLine == formatted) {
            return;
        }
        _lastPreStartDiagLine = formatted;
        Sys.println(formatted);
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

    function _drawCenteredLine(dc, centerX, y, font, text, color, boldText) {
        if (text == null or text.length() == 0) {
            return;
        }
        if (boldText == null) {
            boldText = false;
        }
        _drawTextWithOptionalBold(dc, centerX, y, font, text, Gfx.TEXT_JUSTIFY_CENTER, color, boldText);
    }

    function _drawTextWithOptionalBold(dc, anchorX, y, font, text, justify, color, boldText) {
        if (text == null or text.length() == 0) {
            return;
        }

        var resolvedX = _resolveJustifiedTextX(dc, anchorX, font, text, justify);
        var resolvedJustify = _resolveSafeJustify(justify);
        dc.setColor(color, Gfx.COLOR_BLACK);
        dc.drawText(resolvedX, y, font, text, resolvedJustify);
        if (boldText) {
            dc.drawText(resolvedX + 1, y, font, text, resolvedJustify);
        }
    }

    function _resolveJustifiedTextX(dc, anchorX, font, text, justify) {
        if (justify == Gfx.TEXT_JUSTIFY_CENTER) {
            return anchorX - Math.floor(_measureTextWidth(dc, text, font) / 2);
        }
        if (justify == Gfx.TEXT_JUSTIFY_RIGHT) {
            return anchorX - _measureTextWidth(dc, text, font);
        }
        return anchorX;
    }

    function _resolveSafeJustify(justify) {
        if (justify == Gfx.TEXT_JUSTIFY_CENTER or justify == Gfx.TEXT_JUSTIFY_RIGHT) {
            return Gfx.TEXT_JUSTIFY_LEFT;
        }
        return justify;
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
        _drawCenteredLine(dc, centerX, y, font, text, color, false);
    }

    function _splitRemainingTimeParts(valueText) {
        if (valueText == null or valueText.length() == 0) {
            return null;
        }

        var unitIndex = valueText.find("h");
        if (unitIndex == null or unitIndex <= 0 or unitIndex >= (valueText.length() - 1)) {
            return null;
        }

        return [
            valueText.substring(0, unitIndex),
            "h",
            valueText.substring(unitIndex + 1, valueText.length())
        ];
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
