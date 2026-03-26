import SwiftUI

enum LiftaTheme: String, Codable, CaseIterable, Identifiable {
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

    var preferredScheme: ColorScheme? {
        switch self {
        case .light, .solar:
            return .light
        case .dark, .mono:
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
                background: [Color(hex: 0x111214), Color(hex: 0x2A2C31), Color(hex: 0x555961)],
                textPrimary: Color.white,
                textSecondary: Color(hex: 0xD3D7DF),
                accent: Color(hex: 0xECEFF6),
                accentSecondary: Color(hex: 0x959BA7),
                cardFill: Color.white.opacity(0.12),
                cardStroke: Color.white.opacity(0.16),
                starColor: Color.white.opacity(0.4),
                glow: Color.white.opacity(0.2)
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
}
