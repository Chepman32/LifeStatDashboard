import Foundation

enum LunivoLocalization {
    static func string(_ key: String, locale: Locale) -> String {
        if let supplemental = LunivoSupplementalTranslations.string(for: key, locale: locale) {
            return supplemental
        }
        return String(localized: String.LocalizationValue(stringLiteral: key), locale: locale)
    }

    static func formatted(_ key: String, locale: Locale, _ arguments: CVarArg...) -> String {
        let format = string(key, locale: locale)
        return String(format: format, locale: locale, arguments: arguments)
    }
}
