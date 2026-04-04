import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
final class AppModel: ObservableObject {
    @Published var profile: UserProfile
    @Published var snapshot: LifeSnapshot
    @Published var selectedTab: AppTab = .dashboard
    @Published var selectedStat: LifeStat?
    @Published var isShowingSplash = true
    @Published var hasCompletedOnboarding: Bool
    @Published var favoriteMilestoneIDs: [String]
    @Published var preferredLanguage: AppLanguage

    var locale: Locale { preferredLanguage.locale }

    private let persistence = PersistenceController()
    private let engine = LifeStatEngine()
    private var tickerTask: Task<Void, Never>?

    init(now: Date = .now) {
        let storedProfile = persistence.loadProfile()
        let language = persistence.loadLanguage()
        self.profile = storedProfile
        self.preferredLanguage = language
        self.hasCompletedOnboarding = persistence.hasCompletedOnboarding()
        self.favoriteMilestoneIDs = Self.deduplicatedIDs(persistence.loadFavoriteMilestoneIDs())
        self.snapshot = engine.snapshot(profile: storedProfile, now: now, language: language)
        self.favoriteMilestoneIDs = Self.deduplicatedIDs(
            self.favoriteMilestoneIDs.filter { id in
                self.snapshot.allMilestones.contains(where: { $0.id == id })
            }
        )

        startTicker()
    }

    deinit {
        tickerTask?.cancel()
    }

    func startTicker() {
        tickerTask?.cancel()
        tickerTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.refresh()
                let interval = self?.effectiveMotion == .full ? 0.5 : 1.0
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }

    func completeOnboarding(with profile: UserProfile) {
        withAnimation(.spring(duration: 0.8, bounce: 0.2)) {
            self.profile = profile
            self.hasCompletedOnboarding = true
            self.selectedTab = .dashboard
        }
        HapticsManager.shared.impact(.medium)
        persistence.saveProfile(profile)
        persistence.setCompletedOnboarding(true)
        refresh()
    }

    func updateProfile(_ update: (inout UserProfile) -> Void) {
        update(&profile)
        persistence.saveProfile(profile)
        refresh()
    }

    func updateLanguage(_ language: AppLanguage) {
        preferredLanguage = language
        persistence.saveLanguage(language)
        refresh()
    }

    func refresh(now: Date = .now) {
        snapshot = engine.snapshot(profile: profile, now: now, language: preferredLanguage)
        favoriteMilestoneIDs = Self.deduplicatedIDs(
            favoriteMilestoneIDs.filter { id in
                snapshot.allMilestones.contains(where: { $0.id == id })
            }
        )
        persistence.saveFavoriteMilestoneIDs(favoriteMilestoneIDs)
    }

    func resetAll() {
        persistence.reset()
        let fresh = UserProfile.default
        profile = fresh
        preferredLanguage = .system
        hasCompletedOnboarding = false
        favoriteMilestoneIDs = []
        snapshot = engine.snapshot(profile: fresh, now: .now, language: .system)
    }

    func toggleFavoriteMilestone(_ milestoneID: String) {
        if let index = favoriteMilestoneIDs.firstIndex(of: milestoneID) {
            favoriteMilestoneIDs.remove(at: index)
        } else {
            favoriteMilestoneIDs.insert(milestoneID, at: 0)
        }
        favoriteMilestoneIDs = Self.deduplicatedIDs(favoriteMilestoneIDs)
        persistence.saveFavoriteMilestoneIDs(favoriteMilestoneIDs)
    }

    func moveFavoriteMilestones(from offsets: IndexSet, to destination: Int) {
        favoriteMilestoneIDs.move(fromOffsets: offsets, toOffset: destination)
        favoriteMilestoneIDs = Self.deduplicatedIDs(favoriteMilestoneIDs)
        persistence.saveFavoriteMilestoneIDs(favoriteMilestoneIDs)
    }

    var favoriteMilestones: [Milestone] {
        let byID = snapshot.allMilestones.reduce(into: [String: Milestone]()) { partialResult, milestone in
            partialResult[milestone.id] = milestone
        }
        return favoriteMilestoneIDs.compactMap { byID[$0] }
    }

    var effectiveMotion: MotionPreference {
        switch profile.motionPreference {
        case .respectSystem:
            return UIAccessibility.isReduceMotionEnabled ? .reduced : .full
        default:
            return profile.motionPreference
        }
    }

    private static func deduplicatedIDs(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        return ids.filter { seen.insert($0).inserted }
    }
}
