#!/usr/bin/swift

import AppKit
import Foundation

struct RaceIconSpec {
    let releaseDir: String
    let place: String
    let year: String
}

let fileManager = FileManager.default
let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let baseImageURL = currentDirectory.appendingPathComponent("apps/GateChecker/assets/RunToCoal_Image.png")
let releasesRootURL = currentDirectory.appendingPathComponent("apps/GateChecker/releases")

guard let baseImage = NSImage(contentsOf: baseImageURL) else {
    fputs("Failed to read base image at \(baseImageURL.path)\n", stderr)
    exit(1)
}

let canvasSize = NSSize(width: 500, height: 500)

func color(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> NSColor {
    NSColor(calibratedRed: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}

func parseArguments() -> RaceIconSpec {
    let arguments = Array(CommandLine.arguments.dropFirst())
    guard arguments.count == 3 else {
        fputs("Usage: generate_release_icons.swift <race_key> <place_label> <year>\n", stderr)
        exit(1)
    }
    return RaceIconSpec(releaseDir: arguments[0], place: arguments[1], year: arguments[2])
}

func bestFont(startSize: CGFloat, minSize: CGFloat, maxWidth: CGFloat, text: String, weight: NSFont.Weight) -> NSFont {
    var size = startSize
    while size >= minSize {
        if let font = NSFont.systemFont(ofSize: size, weight: weight) as NSFont? {
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let width = ceil((text as NSString).size(withAttributes: attributes).width)
            if width <= maxWidth {
                return font
            }
        }
        size -= 1
    }
    return NSFont.systemFont(ofSize: minSize, weight: weight)
}

func drawBadge(text: String, origin: CGPoint, maxTextWidth: CGFloat, fillColor: NSColor, textColor: NSColor, startFontSize: CGFloat, minFontSize: CGFloat, weight: NSFont.Weight) {
    let font = bestFont(startSize: startFontSize, minSize: minFontSize, maxWidth: maxTextWidth, text: text, weight: weight)
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left

    let shadow = NSShadow()
    shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.30)
    shadow.shadowBlurRadius = 6
    shadow.shadowOffset = NSSize(width: 0, height: -1)

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: textColor,
        .paragraphStyle: paragraph,
        .shadow: shadow,
    ]

    let textSize = (text as NSString).size(withAttributes: attributes)
    let horizontalPadding: CGFloat = 18
    let verticalPadding: CGFloat = 10
    let badgeRect = CGRect(
        x: origin.x,
        y: origin.y,
        width: ceil(textSize.width) + horizontalPadding * 2,
        height: ceil(textSize.height) + verticalPadding * 2
    )

    let badgePath = NSBezierPath(roundedRect: badgeRect, xRadius: 18, yRadius: 18)
    fillColor.setFill()
    badgePath.fill()

    let textRect = CGRect(
        x: badgeRect.minX + horizontalPadding,
        y: badgeRect.minY + verticalPadding - 1,
        width: ceil(textSize.width),
        height: ceil(textSize.height)
    )
    (text as NSString).draw(in: textRect, withAttributes: attributes)
}

func renderIcon(spec: RaceIconSpec) throws -> Int {
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize.width),
        pixelsHigh: Int(canvasSize.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )

    guard let bitmap else {
        throw NSError(domain: "generate_release_icons", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to allocate bitmap"])
    }

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        NSGraphicsContext.restoreGraphicsState()
        throw NSError(domain: "generate_release_icons", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create graphics context"])
    }

    NSGraphicsContext.current = context
    context.imageInterpolation = .high

    baseImage.draw(in: CGRect(origin: .zero, size: canvasSize))

    drawBadge(
        text: spec.place,
        origin: CGPoint(x: 24, y: 430),
        maxTextWidth: 220,
        fillColor: color(red: 5, green: 23, blue: 71, alpha: 0.78),
        textColor: .white,
        startFontSize: 42,
        minFontSize: 24,
        weight: .bold
    )

    let yearFont = bestFont(startSize: 54, minSize: 34, maxWidth: 150, text: spec.year, weight: .heavy)
    let yearAttributes: [NSAttributedString.Key: Any] = [
        .font: yearFont,
        .foregroundColor: color(red: 255, green: 220, blue: 48, alpha: 1.0),
    ]
    let yearWidth = ceil((spec.year as NSString).size(withAttributes: yearAttributes).width)
    drawBadge(
        text: spec.year,
        origin: CGPoint(x: 500 - yearWidth - 36 - 36, y: 28),
        maxTextWidth: 150,
        fillColor: color(red: 5, green: 23, blue: 71, alpha: 0.78),
        textColor: color(red: 255, green: 220, blue: 48, alpha: 1.0),
        startFontSize: 54,
        minFontSize: 34,
        weight: .heavy
    )

    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "generate_release_icons", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to encode PNG"])
    }

    let outputURL = releasesRootURL
        .appendingPathComponent(spec.releaseDir)
        .appendingPathComponent("RunToCoal_Image.png")
    try pngData.write(to: outputURL, options: .atomic)
    return pngData.count
}

let spec = parseArguments()

do {
    let size = try renderIcon(spec: spec)
    print("\(spec.releaseDir): \(size) bytes")
} catch {
    fputs("Failed for \(spec.releaseDir): \(error.localizedDescription)\n", stderr)
    exit(1)
}
