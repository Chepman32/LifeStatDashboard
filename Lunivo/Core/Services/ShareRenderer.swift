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
}

enum ShareRatio: String, CaseIterable, Identifiable {
    case square
    case story
    case poster
    case wallpaper

    var id: String { rawValue }

    var size: CGSize {
        switch self {
        case .square: CGSize(width: 1080, height: 1080)
        case .story: CGSize(width: 1080, height: 1920)
        case .poster: CGSize(width: 1440, height: 1920)
        case .wallpaper: CGSize(width: 1290, height: 2796)
        }
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
}
