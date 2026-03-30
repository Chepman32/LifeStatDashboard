import SwiftUI

enum LunivoTheme: String, Codable, CaseIterable, Identifiable {
    case light
    case dark
    case solar
    case mono

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .solar: "Solar"
        case .mono: "Mono"
        }
    }

    func localizedTitle(locale: Locale) -> String {
        LunivoLocalization.string(title, locale: locale)
    }

    var preferredScheme: ColorScheme? {
        switch self {
        case .light, .solar, .mono:
            return .light
        case .dark:
            return .dark
        }
    }

    var palette: ThemePalette {
        switch self {
        case .light:
            ThemePalette(
                background: [Color(hex: 0xF6F8FF), Color(hex: 0xDDE9FF), Color(hex: 0xE8DFFF)],
                textPrimary: Color(hex: 0x12131A),
                textSecondary: Color(hex: 0x5A6070),
                accent: Color(hex: 0x4A78FF),
                accentSecondary: Color(hex: 0x8D6BFF),
                cardFill: Color.white.opacity(0.62),
                cardStroke: Color.white.opacity(0.72),
                starColor: Color(hex: 0x3D4B87).opacity(0.55),
                glow: Color(hex: 0x8D6BFF).opacity(0.26)
            )
        case .dark:
            ThemePalette(
                background: [Color(hex: 0x060913), Color(hex: 0x111A32), Color(hex: 0x191028)],
                textPrimary: Color.white,
                textSecondary: Color(hex: 0xA3B1D0),
                accent: Color(hex: 0x39DAF2),
                accentSecondary: Color(hex: 0x7357FF),
                cardFill: Color.white.opacity(0.10),
                cardStroke: Color.white.opacity(0.12),
                starColor: Color.white.opacity(0.66),
                glow: Color(hex: 0x39DAF2).opacity(0.24)
            )
        case .solar:
            ThemePalette(
                background: [Color(hex: 0xFFF7E5), Color(hex: 0xFFD9A6), Color(hex: 0xF6B86D)],
                textPrimary: Color(hex: 0x42290D),
                textSecondary: Color(hex: 0x7B5B35),
                accent: Color(hex: 0xDA8A00),
                accentSecondary: Color(hex: 0xE8733A),
                cardFill: Color.white.opacity(0.44),
                cardStroke: Color.white.opacity(0.54),
                starColor: Color(hex: 0x7B5B35).opacity(0.28),
                glow: Color(hex: 0xE8733A).opacity(0.22)
            )
        case .mono:
            ThemePalette(
                background: [Color(hex: 0xF4F4F1), Color(hex: 0xE6E6E1), Color(hex: 0xD6D6D0)],
                textPrimary: Color(hex: 0x1D1D1B),
                textSecondary: Color(hex: 0x686863),
                accent: Color(hex: 0x7A7A74),
                accentSecondary: Color(hex: 0xB2B2AB),
                cardFill: Color.white.opacity(0.56),
                cardStroke: Color.white.opacity(0.74),
                starColor: Color(hex: 0x6E6E68).opacity(0.22),
                glow: Color.white.opacity(0.42)
            )
        }
    }
}

struct ThemePalette {
    let background: [Color]
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let accentSecondary: Color
    let cardFill: Color
    let cardStroke: Color
    let starColor: Color
    let glow: Color

    var listRowBackground: Color {
        background.first.map { $0.opacity(0.55) } ?? cardFill
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    func blended(with other: Color, amount: Double) -> Color {
        #if canImport(UIKit)
        let clampedAmount = min(max(amount, 0), 1)
        let base = UIColor(self)
        let overlay = UIColor(other)

        var baseRed: CGFloat = 0
        var baseGreen: CGFloat = 0
        var baseBlue: CGFloat = 0
        var baseAlpha: CGFloat = 0
        var overlayRed: CGFloat = 0
        var overlayGreen: CGFloat = 0
        var overlayBlue: CGFloat = 0
        var overlayAlpha: CGFloat = 0

        guard base.getRed(&baseRed, green: &baseGreen, blue: &baseBlue, alpha: &baseAlpha),
              overlay.getRed(&overlayRed, green: &overlayGreen, blue: &overlayBlue, alpha: &overlayAlpha) else {
            return other.opacity(clampedAmount)
        }

        return Color(
            .sRGB,
            red: Double(baseRed + (overlayRed - baseRed) * clampedAmount),
            green: Double(baseGreen + (overlayGreen - baseGreen) * clampedAmount),
            blue: Double(baseBlue + (overlayBlue - baseBlue) * clampedAmount),
            opacity: Double(baseAlpha + (overlayAlpha - baseAlpha) * clampedAmount)
        )
        #else
        return other.opacity(amount)
        #endif
    }
}
