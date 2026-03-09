using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using CoachUtils;

module RenderUtils {
    function getSizeClass(minDim, largeThreshold, smallThreshold) {
        if (minDim >= largeThreshold) {
            return 2; // large
        }
        if (minDim <= smallThreshold) {
            return 0; // small
        }
        return 1; // medium
    }

    function getCardBgBitmapSmall(
        cardVariant,
        warmupVariant,
        actionPushVariant,
        actionHoldVariant,
        actionEaseVariant,
        fuelSoonVariant,
        fuelNowVariant,
        recoveryVariant,
        hrWarningVariant,
        bgWarmup,
        bgActionPush,
        bgActionHold,
        bgFuelSoon,
        bgFuelNow,
        bgHrWarning
    ) {
        if (cardVariant == warmupVariant) {
            return bgWarmup;
        }
        if (cardVariant == actionPushVariant) {
            return bgActionPush;
        }
        if (cardVariant == actionHoldVariant) {
            return bgActionHold;
        }
        if (cardVariant == actionEaseVariant) {
            return bgActionPush;
        }
        if (cardVariant == fuelSoonVariant) {
            return bgFuelSoon;
        }
        if (cardVariant == fuelNowVariant) {
            return bgFuelNow;
        }
        if (cardVariant == recoveryVariant) {
            return bgFuelSoon;
        }
        if (cardVariant == hrWarningVariant) {
            return bgHrWarning;
        }
        return bgActionHold;
    }

    function getBitmapWidth(bitmap) {
        if (bitmap == null) {
            return 0;
        }
        try {
            return bitmap.getWidth();
        } catch (e) {
            return 0;
        }
    }

    function getBitmapHeight(bitmap) {
        if (bitmap == null) {
            return 0;
        }
        try {
            return bitmap.getHeight();
        } catch (e) {
            return 0;
        }
    }

    function getCardBorderColor(
        cardVariant,
        warmupVariant,
        actionPushVariant,
        actionEaseVariant,
        fuelSoonVariant,
        fuelNowVariant,
        recoveryVariant,
        hrWarningVariant
    ) {
        if (cardVariant == warmupVariant) {
            return 0x56728F;
        }
        if (cardVariant == actionPushVariant) {
            return 0x4C7898;
        }
        if (cardVariant == actionEaseVariant) {
            return 0x7F694F;
        }
        if (cardVariant == fuelSoonVariant) {
            return 0x926E49;
        }
        if (cardVariant == fuelNowVariant) {
            return 0xA14B58;
        }
        if (cardVariant == recoveryVariant) {
            return 0x4F7480;
        }
        if (cardVariant == hrWarningVariant) {
            return 0x97554A;
        }
        return 0x516684;
    }

    function getCardGradientTopColor(
        cardVariant,
        warmupVariant,
        actionPushVariant,
        actionEaseVariant,
        fuelSoonVariant,
        fuelNowVariant,
        recoveryVariant,
        hrWarningVariant
    ) {
        if (cardVariant == warmupVariant) {
            return 0x315B7D;
        }
        if (cardVariant == actionPushVariant) {
            return 0x275778;
        }
        if (cardVariant == actionEaseVariant) {
            return 0x5E4B36;
        }
        if (cardVariant == fuelSoonVariant) {
            return 0x70543A;
        }
        if (cardVariant == fuelNowVariant) {
            return 0x883744;
        }
        if (cardVariant == recoveryVariant) {
            return 0x2D5A66;
        }
        if (cardVariant == hrWarningVariant) {
            return 0x7B342F;
        }
        return 0x274A6A;
    }

    function getCardGradientBottomColor(
        cardVariant,
        warmupVariant,
        actionPushVariant,
        actionEaseVariant,
        fuelSoonVariant,
        fuelNowVariant,
        recoveryVariant,
        hrWarningVariant
    ) {
        if (cardVariant == warmupVariant) {
            return 0x182F47;
        }
        if (cardVariant == actionPushVariant) {
            return 0x16324B;
        }
        if (cardVariant == actionEaseVariant) {
            return 0x2E2418;
        }
        if (cardVariant == fuelSoonVariant) {
            return 0x3D2D20;
        }
        if (cardVariant == fuelNowVariant) {
            return 0x461925;
        }
        if (cardVariant == recoveryVariant) {
            return 0x183640;
        }
        if (cardVariant == hrWarningVariant) {
            return 0x401B18;
        }
        return 0x182E45;
    }

    function getCardGradientMidColor(
        cardVariant,
        warmupVariant,
        actionPushVariant,
        actionEaseVariant,
        fuelSoonVariant,
        fuelNowVariant,
        recoveryVariant,
        hrWarningVariant
    ) {
        if (cardVariant == warmupVariant) {
            return 0x244767;
        }
        if (cardVariant == actionPushVariant) {
            return 0x204765;
        }
        if (cardVariant == actionEaseVariant) {
            return 0x463726;
        }
        if (cardVariant == fuelSoonVariant) {
            return 0x594230;
        }
        if (cardVariant == fuelNowVariant) {
            return 0x6A2835;
        }
        if (cardVariant == recoveryVariant) {
            return 0x234A56;
        }
        if (cardVariant == hrWarningVariant) {
            return 0x5C2722;
        }
        return 0x22415F;
    }

    function getCardSheenColor(
        cardVariant,
        warmupVariant,
        actionPushVariant,
        actionEaseVariant,
        fuelSoonVariant,
        fuelNowVariant,
        recoveryVariant,
        hrWarningVariant
    ) {
        if (cardVariant == warmupVariant) {
            return 0x7FA8D0;
        }
        if (cardVariant == actionPushVariant) {
            return 0x7CAED6;
        }
        if (cardVariant == actionEaseVariant) {
            return 0xB08A61;
        }
        if (cardVariant == fuelSoonVariant) {
            return 0xC39A70;
        }
        if (cardVariant == fuelNowVariant) {
            return 0xD97983;
        }
        if (cardVariant == recoveryVariant) {
            return 0x79AAB9;
        }
        if (cardVariant == hrWarningVariant) {
            return 0xCE8476;
        }
        return 0x779DC1;
    }

    function getCardAccentColor(
        cardVariant,
        warmupVariant,
        actionPushVariant,
        actionEaseVariant,
        fuelSoonVariant,
        fuelNowVariant,
        recoveryVariant,
        hrWarningVariant
    ) {
        if (cardVariant == warmupVariant) {
            return 0x9ED7FF;
        }
        if (cardVariant == actionPushVariant) {
            return 0x9CD8FF;
        }
        if (cardVariant == actionEaseVariant) {
            return 0xF1CC95;
        }
        if (cardVariant == fuelSoonVariant) {
            return 0xFFD29A;
        }
        if (cardVariant == fuelNowVariant) {
            return 0xFFC2B0;
        }
        if (cardVariant == recoveryVariant) {
            return 0x9DE5EE;
        }
        if (cardVariant == hrWarningVariant) {
            return 0xFFB99B;
        }
        return 0xA9D0F8;
    }

    function getCardTopBandColor(
        cardVariant,
        warmupVariant,
        actionPushVariant,
        actionEaseVariant,
        fuelSoonVariant,
        fuelNowVariant,
        recoveryVariant,
        hrWarningVariant
    ) {
        if (cardVariant == warmupVariant) {
            return 0x6EAED8;
        }
        if (cardVariant == actionPushVariant) {
            return 0x6ABCE3;
        }
        if (cardVariant == actionEaseVariant) {
            return 0xC39A6E;
        }
        if (cardVariant == fuelSoonVariant) {
            return 0xD7AA76;
        }
        if (cardVariant == fuelNowVariant) {
            return 0xD96E7E;
        }
        if (cardVariant == recoveryVariant) {
            return 0x63B9C8;
        }
        if (cardVariant == hrWarningVariant) {
            return 0xD97B6A;
        }
        return 0x6AA3CF;
    }

    function getCardTextColor(cardVariant) {
        return Gfx.COLOR_WHITE;
    }

    function resolveCardFont(sizeClass, cardLineCount) {
        if (sizeClass == 0) {
            if (cardLineCount <= 1) {
                return Gfx.FONT_SMALL;
            }
            if (cardLineCount == 2) {
                return Gfx.FONT_TINY;
            }
            return Gfx.FONT_XTINY;
        }

        if (sizeClass == 2) {
            if (cardLineCount <= 1) {
                // Large layout card width is still narrow; medium often overflows with CJK text.
                return Gfx.FONT_SMALL;
            }
            if (cardLineCount == 2) {
                return Gfx.FONT_SMALL;
            }
            return Gfx.FONT_TINY;
        }

        if (cardLineCount <= 1) {
            return Gfx.FONT_SMALL;
        }
        if (cardLineCount == 2) {
            return Gfx.FONT_SMALL;
        }
        return Gfx.FONT_TINY;
    }

    function adjustCardFontForSingleLineLimit(font, cardLineCount, cardLines as Lang.Array) {
        if (cardLineCount != 1 or cardLines.size() <= 0 or cardLines[0] == null) {
            return font;
        }

        var line = cardLines[0].toString();
        if (line.length() <= 0) {
            return font;
        }

        var limit = 7;
        if (containsNonAscii(line)) {
            limit = 4;
        }

        if (line.length() >= limit) {
            return shrinkCardFont(font);
        }
        return font;
    }

    function shrinkCardFont(font) {
        if (font == Gfx.FONT_MEDIUM) {
            return Gfx.FONT_SMALL;
        }
        if (font == Gfx.FONT_SMALL) {
            return Gfx.FONT_TINY;
        }
        if (font == Gfx.FONT_TINY) {
            return Gfx.FONT_XTINY;
        }
        return Gfx.FONT_XTINY;
    }

    function containsNonAscii(text) as Lang.Boolean {
        if (text == null) {
            return false;
        }

        var chars = text.toString().toCharArray();
        if (!(chars instanceof Lang.Array)) {
            return false;
        }
        for (var i = 0; i < chars.size(); i += 1) {
            var ch = chars[i];
            if (ch != null and ch instanceof Lang.Char and ch.toNumber() > 127) {
                return true;
            }
        }
        return false;
    }

    function resolveCardLineGap(cardLineCount, fontH, areaH) {
        if (cardLineCount <= 1) {
            return 0;
        }

        var desiredGap = 1;
        if (cardLineCount == 2) {
            desiredGap = clamp(fontH / 3, 2, 8);
        } else {
            desiredGap = clamp(fontH / 5, 1, 5);
        }

        var maxGap = max((areaH - (fontH * cardLineCount)) / (cardLineCount - 1), 1);
        if (desiredGap > maxGap) {
            desiredGap = maxGap;
        }
        return desiredGap;
    }

    function resolveCardFontToFit(dc as Gfx.Dc, sizeClass, cardLines as Lang.Array, textAreaW, textAreaH) {
        var candidates = [];
        if (sizeClass == 2) {
            candidates = [Gfx.FONT_MEDIUM, Gfx.FONT_SMALL, Gfx.FONT_TINY, Gfx.FONT_XTINY];
        } else if (sizeClass == 0) {
            candidates = [Gfx.FONT_SMALL, Gfx.FONT_TINY, Gfx.FONT_XTINY];
        } else {
            candidates = [Gfx.FONT_SMALL, Gfx.FONT_TINY, Gfx.FONT_XTINY];
        }

        for (var i = 0; i < candidates.size(); i += 1) {
            var font = candidates[i];
            if (isCardTextFit(dc, font, cardLines, textAreaW, textAreaH)) {
                return font;
            }
        }

        return candidates[candidates.size() - 1];
    }

    function isCardTextFit(dc as Gfx.Dc, font, cardLines as Lang.Array, textAreaW, textAreaH) as Lang.Boolean {
        if (textAreaW <= 0 or textAreaH <= 0) {
            return false;
        }

        var lineCount = cardLines.size();
        var fontH = dc.getFontHeight(font);
        var minTotalH = fontH * lineCount;
        if (lineCount > 1) {
            minTotalH += (lineCount - 1);
        }
        if (minTotalH > textAreaH) {
            return false;
        }

        for (var i = 0; i < lineCount; i += 1) {
            var line = "";
            if (cardLines[i] != null) {
                line = cardLines[i].toString();
            }
            var lineW = dc.getTextWidthInPixels(line, font);
            // Keep headroom for bold stroke around text.
            if ((lineW + 2) > textAreaW) {
                return false;
            }
        }

        return true;
    }

    function fillRoundedGradient(dc as Gfx.Dc, x, y, width, height, corner, topColor, midColor, bottomColor) {
        dc.setColor(bottomColor, Gfx.COLOR_BLACK);
        dc.fillRoundedRectangle(x, y, width, height, corner);

        var innerX = x + 1;
        var innerY = y + 1;
        var innerW = width - 2;
        var innerH = height - 2;
        if (innerW < 2 or innerH < 2) {
            return;
        }

        var topH = clamp((innerH * 38) / 100, 2, innerH - 1);
        var midY = innerY + topH;
        var midH = clamp((innerH * 34) / 100, 2, innerH - topH);
        var maxMidH = innerH - topH;
        if (midH > maxMidH) {
            midH = maxMidH;
        }
        if (midH < 1) {
            midH = 1;
        }

        dc.setColor(topColor, Gfx.COLOR_BLACK);
        dc.fillRectangle(innerX, innerY, innerW, topH);
        dc.setColor(midColor, Gfx.COLOR_BLACK);
        dc.fillRectangle(innerX, midY, innerW, midH);
    }

    function drawCardSmallTextBold(dc as Gfx.Dc, x, y, font, text, textColor) {
        // Outline + dual white pass gives readable text on bright/saturated cards.
        dc.setColor(0x131A25, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x - 1, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(x + 1, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, y - 1, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, y + 1, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(x + 1, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawUpTriangleMarker(dc as Gfx.Dc, centerX, tipY, halfWidth, height) {
        var markerHeight = max(height, 1);
        var markerHalfWidth = max(halfWidth, 1);
        for (var row = 0; row < markerHeight; row += 1) {
            var span = Math.floor((markerHalfWidth * (row + 1)) / markerHeight);
            if (span < 1) {
                span = 1;
            }
            dc.drawLine(centerX - span, tipY + row, centerX + span, tipY + row);
        }
    }

    function getHeartRateZoneGaugeColor(zoneNumber, zoneColor1, zoneColor2, zoneColor3, zoneColor4, zoneColor5) {
        if (zoneNumber <= 1) {
            return zoneColor1;
        }
        if (zoneNumber == 2) {
            return zoneColor2;
        }
        if (zoneNumber == 3) {
            return zoneColor3;
        }
        if (zoneNumber == 4) {
            return zoneColor4;
        }
        return zoneColor5;
    }

    function resolveHeartRateGaugeRatioFallback(heartRate, minHr, maxHr) {
        if (heartRate == null) {
            return 0.5;
        }
        if (maxHr <= minHr) {
            return 0.5;
        }
        return clamp(((heartRate - minHr) * 1.0) / ((maxHr - minHr) * 1.0), 0.0, 1.0);
    }

    function min(a, b) {
        return CoachUtils.min(a, b);
    }

    function max(a, b) {
        return CoachUtils.max(a, b);
    }

    function clamp(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }
}
