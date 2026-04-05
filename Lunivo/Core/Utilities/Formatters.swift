import Foundation

enum LunivoNumberFormatter {
    static func exact(_ value: Double, locale: Locale, fractionDigits: Int = 0) -> String {
        value.formatted(
            .number
                .precision(.fractionLength(fractionDigits))
                .grouping(.automatic)
                .locale(locale)
        )
    }

    static func compact(_ value: Double, locale: Locale, fractionDigits: Int = 1) -> String {
        value.formatted(
            .number
                .notation(.compactName)
                .precision(.fractionLength(fractionDigits))
                .locale(locale)
        )
    }

    static func shareCompact(_ value: Double, locale: Locale, fractionDigits: Int = 1) -> String {
        guard let suffixes = shortCompactSuffixes(for: locale) else {
            return compact(value, locale: locale, fractionDigits: fractionDigits)
        }

        let absoluteValue = abs(value)
        let thresholds: [(value: Double, suffix: String)] = [
            (1_000_000_000_000, suffixes.trillion),
            (1_000_000_000, suffixes.billion),
            (1_000_000, suffixes.million),
            (1_000, suffixes.thousand)
        ]

        guard let match = thresholds.first(where: { absoluteValue >= $0.value }) else {
            let digits = value.rounded() == value ? 0 : fractionDigits
            return exact(value, locale: locale, fractionDigits: digits)
        }

        let scaledValue = value / match.value
        let digits: Int
        switch abs(scaledValue) {
        case 100...:
            digits = 0
        case 10...:
            digits = 1
        default:
            digits = fractionDigits
        }

        return "\(exact(scaledValue, locale: locale, fractionDigits: digits)) \(match.suffix)"
    }

    static func distance(_ value: Double, unitPreference: UnitPreference, locale: Locale) -> (String, String) {
        switch unitPreference {
        case .metric:
            return (compact(value, locale: locale), "km")
        case .imperial:
            return (compact(value * 0.621371, locale: locale), "mi")
        }
    }

    static func growth(_ value: Double, unitPreference: UnitPreference, locale: Locale) -> (String, String) {
        switch unitPreference {
        case .metric:
            let centimeters = value / 10
            return (exact(centimeters, locale: locale, fractionDigits: centimeters < 10 ? 1 : 0), "cm")
        case .imperial:
            let inches = value / 25.4
            return (exact(inches, locale: locale, fractionDigits: inches < 100 ? 1 : 0), "in")
        }
    }

    static func relativeDate(_ date: Date, locale: Locale) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: .now)
    }

    private struct CompactSuffixSet {
        let thousand: String
        let million: String
        let billion: String
        let trillion: String
    }

    private static func shortCompactSuffixes(for locale: Locale) -> CompactSuffixSet? {
        switch locale.language.languageCode?.identifier {
        case "ru":
            return CompactSuffixSet(thousand: "тыс.", million: "млн", billion: "млрд", trillion: "трлн")
        case "uk":
            return CompactSuffixSet(thousand: "тис.", million: "млн", billion: "млрд", trillion: "трлн")
        default:
            return nil
        }
    }
}

enum LunivoDateFormatter {
    static func medium(date: Date, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
