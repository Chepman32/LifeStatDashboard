import XCTest
@testable import Lifta

final class PersistenceControllerTests: XCTestCase {
    func testProfileRoundTrip() {
        let suiteName = "PersistenceControllerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let persistence = PersistenceController(defaults: defaults)
        var profile = UserProfile.default
        profile.selectedTheme = .solar
        profile.unitPreference = .imperial

        persistence.saveProfile(profile)

        XCTAssertEqual(persistence.loadProfile(), profile)
    }

    func testLanguageRoundTrip() {
        let suiteName = "PersistenceControllerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let persistence = PersistenceController(defaults: defaults)
        persistence.saveLanguage(.japanese)

        XCTAssertEqual(persistence.loadLanguage(), .japanese)
    }
}
