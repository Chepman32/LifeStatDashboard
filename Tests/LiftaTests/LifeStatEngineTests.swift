import XCTest
@testable import Lifta

final class LifeStatEngineTests: XCTestCase {
    func testSecondsLivedMatchesExactElapsedTime() {
        let calendar = Calendar(identifier: .gregorian)
        let birthDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: 0, minute: 0))!
        let now = calendar.date(from: DateComponents(year: 2000, month: 1, day: 2, hour: 0, minute: 0))!

        var profile = UserProfile.default
        profile.birthDate = birthDate
        profile.hasBirthTime = true

        let snapshot = LifeStatEngine().snapshot(profile: profile, now: now)
        let seconds = snapshot.statsByCategory[.time]?.first(where: { $0.id == "seconds-lived" })

        XCTAssertNotNil(seconds)
        XCTAssertEqual(seconds?.rawValue ?? 0, 86_400, accuracy: 0.001)
    }

    func testEarthOrbitProgressStaysWithinBounds() {
        var profile = UserProfile.default
        profile.birthDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 1994, month: 6, day: 11))!
        profile.hasBirthTime = false

        let snapshot = LifeStatEngine().snapshot(profile: profile, now: .now)
        let orbit = snapshot.statsByCategory[.space]?.first(where: { $0.id == "birthday-progress" })

        XCTAssertNotNil(orbit)
        XCTAssertGreaterThanOrEqual(orbit?.rawValue ?? -1, 0)
        XCTAssertLessThanOrEqual(orbit?.rawValue ?? 101, 100)
    }

    func testMilestonesAreGeneratedInAscendingTargets() {
        var profile = UserProfile.default
        profile.birthDate = Calendar(identifier: .gregorian).date(byAdding: .year, value: -25, to: .now)!

        let snapshot = LifeStatEngine().snapshot(profile: profile, now: .now)
        let stat = snapshot.statsByCategory[.body]?.first(where: { $0.id == "heartbeats" })

        XCTAssertNotNil(stat)
        let targets = stat?.nextMilestones.map(\.targetValue) ?? []
        XCTAssertEqual(targets, targets.sorted())
        XCTAssertEqual(targets.count, 3)
    }
}
