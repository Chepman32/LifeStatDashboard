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
}

enum DisplayDensity: String, Codable, CaseIterable, Identifiable {
    case calm
    case detailed

    var id: String { rawValue }
}

enum LiveTickerVisibility: String, Codable, CaseIterable, Identifiable {
    case always
    case compact
    case hidden

    var id: String { rawValue }
}

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english
    case russian
    case german
    case french
    case spanish
    case portuguese
    case japanese
    case korean
    case chineseSimplified
    case ukrainian

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .russian: "Русский"
        case .german: "Deutsch"
        case .french: "Français"
        case .spanish: "Español"
        case .portuguese: "Português"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .chineseSimplified: "简体中文"
        case .ukrainian: "Українська"
        }
    }

    var locale: Locale {
        switch self {
        case .english: Locale(identifier: "en")
        case .russian: Locale(identifier: "ru")
        case .german: Locale(identifier: "de")
        case .french: Locale(identifier: "fr")
        case .spanish: Locale(identifier: "es")
        case .portuguese: Locale(identifier: "pt")
        case .japanese: Locale(identifier: "ja")
        case .korean: Locale(identifier: "ko")
        case .chineseSimplified: Locale(identifier: "zh-Hans")
        case .ukrainian: Locale(identifier: "uk")
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
