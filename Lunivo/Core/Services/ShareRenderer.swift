import AVFoundation
import SwiftUI
import UIKit

enum ShareTemplate: String, CaseIterable, Identifiable {
    case heroNumber
    case cosmicComparison
    case multiCard
    case orbitPoster
    case minimalMono

    var id: String { rawValue }

    var title: String {
        switch self {
        case .heroNumber: "Hero Number"
        case .cosmicComparison: "Cosmic Comparison"
        case .multiCard: "Multi-Card Stack"
        case .orbitPoster: "Orbit Poster"
        case .minimalMono: "Minimal Mono"
        }
    }

    func localizedTitle(locale: Locale) -> String {
        LunivoLocalization.string(title, locale: locale)
    }
}

enum ShareRatio: String, CaseIterable, Identifiable {
    case square
    case story
    case poster
    case wallpaper

    var id: String { rawValue }

    var title: String {
        switch self {
        case .square: "Square"
        case .story: "Story"
        case .poster: "Poster"
        case .wallpaper: "Wallpaper"
        }
    }

    func localizedTitle(locale: Locale) -> String {
        LunivoLocalization.string(title, locale: locale)
    }

    var size: CGSize {
        switch self {
        case .square: CGSize(width: 1080, height: 1080)
        case .story: CGSize(width: 1080, height: 1920)
        case .poster: CGSize(width: 1440, height: 1920)
        case .wallpaper: CGSize(width: 1290, height: 2796)
        }
    }
}

enum ShareExportKind: String, CaseIterable, Identifiable {
    case image
    case slideshowVideo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .image: "Image"
        case .slideshowVideo: "Slideshow Video"
        }
    }

    func localizedTitle(locale: Locale) -> String {
        LunivoLocalization.string(title, locale: locale)
    }
}

struct ShareRenderConfiguration {
    var template: ShareTemplate
    var ratio: ShareRatio
    var theme: LunivoTheme
    var includeMethodology: Bool
    var includeEstimateTag: Bool
}

enum ShareRenderer {
    @MainActor
    static func image(for stats: [LifeStat], configuration: ShareRenderConfiguration) -> UIImage? {
        let renderer = ImageRenderer(content:
            ShareCanvasView(stats: stats, configuration: configuration)
                .frame(width: configuration.ratio.size.width, height: configuration.ratio.size.height)
        )
        renderer.scale = 1
        return renderer.uiImage
    }

    static func slideshowVideo(for stats: [LifeStat], configuration: ShareRenderConfiguration) async -> URL? {
        let slideshowConfiguration = slideshowConfiguration(from: configuration)
        let slideImages = await MainActor.run {
            stats.compactMap { stat in
                image(for: [stat], configuration: slideshowConfiguration)
            }
        }

        guard !slideImages.isEmpty else { return nil }

        return await Task.detached(priority: .userInitiated) {
            encodeVideo(from: slideImages, canvasSize: slideshowConfiguration.ratio.size)
        }.value
    }

    private static func slideshowConfiguration(from configuration: ShareRenderConfiguration) -> ShareRenderConfiguration {
        guard configuration.template == .multiCard else { return configuration }
        var adjustedConfiguration = configuration
        adjustedConfiguration.template = .heroNumber
        return adjustedConfiguration
    }

    private static func encodeVideo(from images: [UIImage], canvasSize: CGSize, fps: Int32 = 12, secondsPerSlide: Double = 1.4) -> URL? {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("lunivo-share-\(UUID().uuidString)")
            .appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: outputURL)

        do {
            let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            let outputSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: Int(canvasSize.width),
                AVVideoHeightKey: Int(canvasSize.height)
            ]
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
            input.expectsMediaDataInRealTime = false

            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: input,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                    kCVPixelBufferWidthKey as String: Int(canvasSize.width),
                    kCVPixelBufferHeightKey as String: Int(canvasSize.height)
                ]
            )

            guard writer.canAdd(input) else { return nil }
            writer.add(input)

            guard writer.startWriting() else { return nil }
            writer.startSession(atSourceTime: .zero)

            let framesPerSlide = max(1, Int(round(secondsPerSlide * Double(fps))))
            var frameIndex: Int64 = 0

            for image in images {
                for _ in 0..<framesPerSlide {
                    while !input.isReadyForMoreMediaData {
                        Thread.sleep(forTimeInterval: 0.005)
                    }

                    guard let pixelBuffer = makePixelBuffer(from: image, canvasSize: canvasSize, pool: adaptor.pixelBufferPool) else {
                        continue
                    }

                    let presentationTime = CMTime(value: frameIndex, timescale: fps)
                    guard adaptor.append(pixelBuffer, withPresentationTime: presentationTime) else {
                        break
                    }
                    frameIndex += 1
                }
            }

            input.markAsFinished()

            let semaphore = DispatchSemaphore(value: 0)
            writer.finishWriting {
                semaphore.signal()
            }
            semaphore.wait()

            guard writer.status == .completed else {
                try? FileManager.default.removeItem(at: outputURL)
                return nil
            }

            return outputURL
        } catch {
            return nil
        }
    }

    private static func makePixelBuffer(from image: UIImage, canvasSize: CGSize, pool: CVPixelBufferPool?) -> CVPixelBuffer? {
        let width = Int(canvasSize.width)
        let height = Int(canvasSize.height)

        var maybeBuffer: CVPixelBuffer?
        if let pool {
            CVPixelBufferPoolCreatePixelBuffer(nil, pool, &maybeBuffer)
        } else {
            CVPixelBufferCreate(
                kCFAllocatorDefault,
                width,
                height,
                kCVPixelFormatType_32ARGB,
                nil,
                &maybeBuffer
            )
        }

        guard let pixelBuffer = maybeBuffer else { return nil }
        guard let cgImage = image.cgImage else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }

        context.clear(CGRect(origin: .zero, size: canvasSize))
        context.draw(cgImage, in: CGRect(origin: .zero, size: canvasSize))
        return pixelBuffer
    }
}
