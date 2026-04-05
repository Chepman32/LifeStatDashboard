import Foundation

enum LunivoLocalization {
    static func string(_ key: String, locale: Locale) -> String {
        if let supplemental = LunivoSupplementalTranslations.string(for: key, locale: locale) {
            return supplemental
        }

        let bundle = localizedBundle(for: locale)
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }

    static func formatted(_ key: String, locale: Locale, _ arguments: CVarArg...) -> String {
        let format = string(key, locale: locale)
        return String(format: format, locale: locale, arguments: arguments)
    }

    private static func localizedBundle(for locale: Locale) -> Bundle {
        let candidates = localizationCandidates(for: locale)

        for candidate in candidates {
            if let path = Bundle.main.path(forResource: candidate, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                return bundle
            }
        }

        return .main
    }

    private static func localizationCandidates(for locale: Locale) -> [String] {
        var candidates: [String] = []

        if !locale.identifier.isEmpty {
            candidates.append(locale.identifier)
            candidates.append(locale.identifier.replacingOccurrences(of: "_", with: "-"))
        }

        if let languageCode = locale.language.languageCode?.identifier {
            candidates.append(languageCode)
        }

        return Array(NSOrderedSet(array: candidates)) as? [String] ?? candidates
    }
}
