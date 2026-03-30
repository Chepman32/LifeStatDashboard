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
