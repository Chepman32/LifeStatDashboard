import Foundation
import SwiftUI

enum UnitPreference: String, Codable, CaseIterable, Identifiable {
    case metric
    case imperial

    var id: String { rawValue }

    var title: String {
        switch self {
        case .metric: "Metric"
        case .imperial: "Imperial"
        }
    }

    func localizedTitle(locale: Locale) -> String {
        LunivoLocalization.string(title, locale: locale)
    }
}

enum MotionPreference: String, Codable, CaseIterable, Identifiable {
    case full
    case reduced
    case respectSystem

    var id: String { rawValue }

    var title: String {
        switch self {
        case .full: "Full"
        case .reduced: "Reduced"
        case .respectSystem: "Respect System"
        }
    }

    func localizedTitle(locale: Locale) -> String {
        LunivoLocalization.string(title, locale: locale)
    }
}

enum DisplayDensity: String, Codable, CaseIterable, Identifiable {
    case calm
    case detailed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm: "Calm"
        case .detailed: "Detailed"
        }
    }

    func localizedTitle(locale: Locale) -> String {
        LunivoLocalization.string(title, locale: locale)
    }
}

enum LiveTickerVisibility: String, Codable, CaseIterable, Identifiable {
    case always
    case compact
    case hidden

    var id: String { rawValue }

    var title: String {
        switch self {
        case .always: "Always"
        case .compact: "Compact"
        case .hidden: "Hidden"
        }
    }

    func localizedTitle(locale: Locale) -> String {
        LunivoLocalization.string(title, locale: locale)
    }
}

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case english
    case chineseSimplified
    case japanese
    case korean
    case german
    case french
    case spanish
    case portuguese
    case arabic
    case russian
    case italian
    case dutch
    case turkish
    case thai
    case vietnamese
    case indonesian
    case polish
    case ukrainian
    case hindi
    case hebrew
    case swedish
    case norwegian
    case danish
    case finnish
    case czech
    case hungarian
    case romanian
    case greek
    case malay
    case filipino

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .english: "English"
        case .chineseSimplified: "简体中文"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .german: "Deutsch"
        case .french: "Français"
        case .spanish: "Español (México)"
        case .portuguese: "Português (Brasil)"
        case .arabic: "العربية"
        case .russian: "Русский"
        case .ukrainian: "Українська"
        case .italian: "Italiano"
        case .dutch: "Nederlands"
        case .turkish: "Türkçe"
        case .thai: "ไทย"
        case .vietnamese: "Tiếng Việt"
        case .indonesian: "Bahasa Indonesia"
        case .polish: "Polski"
        case .hindi: "हिन्दी"
        case .hebrew: "עברית"
        case .swedish: "Svenska"
        case .norwegian: "Norsk"
        case .danish: "Dansk"
        case .finnish: "Suomi"
        case .czech: "Čeština"
        case .hungarian: "Magyar"
        case .romanian: "Română"
        case .greek: "Ελληνικά"
        case .malay: "Bahasa Melayu"
        case .filipino: "Filipino"
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            Locale.autoupdatingCurrent
        case .english: Locale(identifier: "en")
        case .chineseSimplified: Locale(identifier: "zh-Hans")
        case .japanese: Locale(identifier: "ja")
        case .korean: Locale(identifier: "ko")
        case .german: Locale(identifier: "de")
        case .french: Locale(identifier: "fr")
        case .spanish: Locale(identifier: "es-MX")
        case .portuguese: Locale(identifier: "pt-BR")
        case .arabic: Locale(identifier: "ar")
        case .russian: Locale(identifier: "ru")
        case .italian: Locale(identifier: "it")
        case .dutch: Locale(identifier: "nl")
        case .turkish: Locale(identifier: "tr")
        case .thai: Locale(identifier: "th")
        case .vietnamese: Locale(identifier: "vi")
        case .indonesian: Locale(identifier: "id")
        case .polish: Locale(identifier: "pl")
        case .ukrainian: Locale(identifier: "uk")
        case .hindi: Locale(identifier: "hi")
        case .hebrew: Locale(identifier: "he")
        case .swedish: Locale(identifier: "sv")
        case .norwegian: Locale(identifier: "nb")
        case .danish: Locale(identifier: "da")
        case .finnish: Locale(identifier: "fi")
        case .czech: Locale(identifier: "cs")
        case .hungarian: Locale(identifier: "hu")
        case .romanian: Locale(identifier: "ro")
        case .greek: Locale(identifier: "el")
        case .malay: Locale(identifier: "ms")
        case .filipino: Locale(identifier: "fil")
        }
    }

    func localizedTitle(locale: Locale) -> String {
        switch self {
        case .system:
            LunivoLocalization.string(title, locale: locale)
        default:
            title
        }
    }
}

struct UserProfile: Codable, Equatable {
    var birthDate: Date
    var hasBirthTime: Bool
    var unitPreference: UnitPreference
    var selectedTheme: LunivoTheme
    var motionPreference: MotionPreference
    var displayDensity: DisplayDensity
    var liveTickerVisibility: LiveTickerVisibility
    var liveTickerAutoCycle: Bool
    var liveTickerInterval: Double
    var backgroundIntensity: Double
    var largeTextMode: Bool
    var showMethodologyInShare: Bool
    var showEstimatedTagsInShare: Bool

    static let `default` = UserProfile(
        birthDate: Calendar.current.date(byAdding: .year, value: -28, to: .now) ?? .now,
        hasBirthTime: false,
        unitPreference: .metric,
        selectedTheme: .dark,
        motionPreference: .respectSystem,
        displayDensity: .detailed,
        liveTickerVisibility: .always,
        liveTickerAutoCycle: true,
        liveTickerInterval: 4,
        backgroundIntensity: 0.85,
        largeTextMode: false,
        showMethodologyInShare: true,
        showEstimatedTagsInShare: true
    )

    var effectiveBirthDate: Date {
        guard !hasBirthTime else { return birthDate }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate)
        return calendar.date(from: DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: 12
        )) ?? birthDate
    }

    var isValidBirthDate: Bool {
        effectiveBirthDate <= .now && effectiveBirthDate >= Calendar.current.date(byAdding: .year, value: -130, to: .now)!
    }
}
