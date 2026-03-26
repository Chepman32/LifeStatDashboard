import Foundation

final class PersistenceController {
    private enum Keys {
        static let profile = "lifta.profile"
        static let completedOnboarding = "lifta.completedOnboarding"
        static let favoriteMilestones = "lifta.favoriteMilestones"
        static let language = "lifta.language"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadProfile() -> UserProfile {
        guard let data = defaults.data(forKey: Keys.profile),
              let profile = try? decoder.decode(UserProfile.self, from: data) else {
            return .default
        }
        return profile
    }

    func saveProfile(_ profile: UserProfile) {
        if let data = try? encoder.encode(profile) {
            defaults.set(data, forKey: Keys.profile)
        }
    }

    func hasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: Keys.completedOnboarding)
    }

    func setCompletedOnboarding(_ completed: Bool) {
        defaults.set(completed, forKey: Keys.completedOnboarding)
    }

    func loadFavoriteMilestoneIDs() -> [String] {
        defaults.stringArray(forKey: Keys.favoriteMilestones) ?? []
    }

    func saveFavoriteMilestoneIDs(_ ids: [String]) {
        defaults.set(ids, forKey: Keys.favoriteMilestones)
    }

    func loadLanguage() -> AppLanguage {
        guard let rawValue = defaults.string(forKey: Keys.language),
              let language = AppLanguage(rawValue: rawValue) else {
            return .english
        }
        return language
    }

    func saveLanguage(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: Keys.language)
    }

    func reset() {
        defaults.removeObject(forKey: Keys.profile)
        defaults.removeObject(forKey: Keys.completedOnboarding)
        defaults.removeObject(forKey: Keys.favoriteMilestones)
        defaults.removeObject(forKey: Keys.language)
    }
}
