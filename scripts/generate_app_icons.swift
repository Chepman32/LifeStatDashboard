import AppKit

let projectRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputRoots = [
    projectRoot.appendingPathComponent("Lunivo/Resources/AppIcons"),
    projectRoot.appendingPathComponent("Lunivo/Resources/Assets.xcassets/AppIcon.appiconset")
]
let sourceImage = CommandLine.arguments.dropFirst().first.flatMap { path in
    NSImage(contentsOfFile: path)
}

let sizes: [(name: String, points: CGFloat)] = [
    ("Icon-20@2x.png", 40),
    ("Icon-20@3x.png", 60),
    ("Icon-29@2x.png", 58),
    ("Icon-29@3x.png", 87),
    ("Icon-40@2x.png", 80),
    ("Icon-40@3x.png", 120),
    ("Icon-60@2x.png", 120),
    ("Icon-60@3x.png", 180),
    ("Icon-76@2x.png", 152),
    ("Icon-83.5@2x.png", 167),
    ("Icon-1024.png", 1024)
]

func renderBundledImage(_ image: NSImage, size: CGFloat) -> Data {
    let pixelSize = Int(size.rounded())
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fatalError("Unable to create bitmap")
    }

    bitmap.size = NSSize(width: size, height: size)
    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fatalError("Unable to create graphics context")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.imageInterpolation = .high

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let sourceSize = image.size
    let edge = min(sourceSize.width, sourceSize.height)
    let sourceRect = NSRect(
        x: (sourceSize.width - edge) / 2,
        y: (sourceSize.height - edge) / 2,
        width: edge,
        height: edge
    )
    image.draw(in: rect, from: sourceRect, operation: .copy, fraction: 1)

    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Unable to encode PNG")
    }
    return png
}

func renderFallbackIcon(size: CGFloat) -> Data {
    let pixelSize = Int(size.rounded())
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fatalError("Unable to create bitmap")
    }

    bitmap.size = NSSize(width: size, height: size)
    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fatalError("Unable to create graphics context")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let background = NSColor(calibratedRed: 10 / 255, green: 13 / 255, blue: 28 / 255, alpha: 1)
    background.setFill()
    NSBezierPath(roundedRect: rect, xRadius: size * 0.23, yRadius: size * 0.23).fill()

    let center = CGPoint(x: rect.midX, y: rect.midY)
    let ringRect = rect.insetBy(dx: size * 0.18, dy: size * 0.18)

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 57 / 255, green: 218 / 255, blue: 242 / 255, alpha: 1),
        NSColor(calibratedRed: 119 / 255, green: 87 / 255, blue: 255 / 255, alpha: 1)
    ])!
    gradient.draw(in: NSBezierPath(roundedRect: ringRect, xRadius: ringRect.width / 2, yRadius: ringRect.height / 2), angle: -35)

    let ring = NSBezierPath(ovalIn: ringRect)
    ring.lineWidth = size * 0.06
    NSColor.white.withAlphaComponent(0.96).setStroke()
    ring.stroke()

    let innerGlow = NSBezierPath(ovalIn: rect.insetBy(dx: size * 0.31, dy: size * 0.31))
    NSColor(calibratedRed: 80 / 255, green: 214 / 255, blue: 235 / 255, alpha: 0.28).setFill()
    innerGlow.fill()

    let columnRect = NSRect(x: rect.midX - size * 0.042, y: rect.minY + size * 0.19, width: size * 0.084, height: size * 0.48)
    let columnPath = NSBezierPath(roundedRect: columnRect, xRadius: size * 0.042, yRadius: size * 0.042)
    NSColor.white.setFill()
    columnPath.fill()

    let dotRadius = size * 0.09
    let orbitAngle = CGFloat.pi * 0.82
    let orbitRadius = ringRect.width / 2
    let dotCenter = CGPoint(
        x: center.x + cos(orbitAngle) * orbitRadius,
        y: center.y + sin(orbitAngle) * orbitRadius
    )
    let dotRect = NSRect(
        x: dotCenter.x - dotRadius / 2,
        y: dotCenter.y - dotRadius / 2,
        width: dotRadius,
        height: dotRadius
    )
    NSColor(calibratedRed: 1, green: 195 / 255, blue: 87 / 255, alpha: 1).setFill()
    NSBezierPath(ovalIn: dotRect).fill()

    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Unable to encode PNG")
    }
    return png
}

for outputRoot in outputRoots {
    try FileManager.default.createDirectory(at: outputRoot, withIntermediateDirectories: true)
}

for item in sizes {
    let png = if let sourceImage {
        renderBundledImage(sourceImage, size: item.points)
    } else {
        renderFallbackIcon(size: item.points)
    }

    for outputRoot in outputRoots {
        try png.write(to: outputRoot.appendingPathComponent(item.name))
    }
}
