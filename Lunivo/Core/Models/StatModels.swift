import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case milestones
    case share
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .milestones: "Milestones"
        case .share: "Share"
        case .settings: "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .dashboard: "sparkles.rectangle.stack"
        case .milestones: "flag.2.crossed"
        case .share: "square.and.arrow.up"
        case .settings: "slider.horizontal.3"
        }
    }
}

enum StatCategory: String, CaseIterable, Codable, Identifiable {
    case body
    case time
    case space
    case life
    case absurd
    case milestones

    var id: String { rawValue }

    var title: String {
        switch self {
        case .body: "Body"
        case .time: "Time"
        case .space: "Space"
        case .life: "Life"
        case .absurd: "Absurd"
        case .milestones: "Milestones"
        }
    }

    var iconName: String {
        switch self {
        case .body: "waveform.path.ecg"
        case .time: "clock"
        case .space: "globe.americas"
        case .life: "figure.walk.motion"
        case .absurd: "theatermasks"
        case .milestones: "sparkles"
        }
    }
}

enum DerivationType: String, Codable {
    case exactFromTime
    case physicalConstant
    case lifestyleEstimate

    var title: String {
        switch self {
        case .exactFromTime: "Exact from time"
        case .physicalConstant: "Derived from physical constant"
        case .lifestyleEstimate: "Lifestyle estimate"
        }
    }
}

enum StatUnitStyle: Codable {
    case count
    case seconds
    case minutes
    case days
    case percent
    case kilometers
    case miles
    case hours
    case centimeters
    case inches
    case glasses
    case words
    case meals
}

enum StatVisualStyle: String, Codable {
    case pulse
    case orbit
    case lunar
    case horizon
    case stacked
    case editorial
}

struct LifeStatAlternate: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
}

struct Milestone: Identifiable, Hashable {
    let id: String
    let statID: String
    let title: String
    let value: String
    let targetValue: Double
    let estimatedDate: Date?
    let progress: Double
    let description: String
}

struct LifeStat: Identifiable, Hashable {
    let id: String
    let category: StatCategory
    let title: String
    let iconName: String
    let rawValue: Double
    let formattedValue: String
    let compactValue: String
    let unit: String
    let precisionStyle: StatUnitStyle
    let derivationType: DerivationType
    let shortDescription: String
    let wittyComparison: String
    let methodologySummary: String
    let alternateRepresentations: [LifeStatAlternate]
    let nextMilestones: [Milestone]
    let deltaPerSecond: Double
    let visualStyle: StatVisualStyle
    let highlight: Bool
    let estimated: Bool
}

struct AgeSummary: Hashable {
    let years: Int
    let months: Int
    let days: Int
    let totalDays: Int
    let yearsLabel: String
}

struct LifeSnapshot {
    let generatedAt: Date
    let ageSummary: AgeSummary
    let statsByCategory: [StatCategory: [LifeStat]]
    let tickerStats: [LifeStat]
    let closestMilestone: Milestone?
    let methodologySections: [MethodologySection]

    var allMilestones: [Milestone] {
        let sorted = statsByCategory.values.flatMap { stats in
            stats.flatMap(\.nextMilestones)
        }
        .sorted { lhs, rhs in
            switch (lhs.estimatedDate, rhs.estimatedDate) {
            case let (left?, right?):
                return left < right
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return lhs.targetValue < rhs.targetValue
            }
        }

        var seen = Set<String>()
        return sorted.filter { milestone in
            seen.insert(milestone.id).inserted
        }
    }
}

struct MethodologySection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let summary: String
    let rows: [MethodologyRow]
}

struct MethodologyRow: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let formula: String
    let derivationType: DerivationType
    let note: String
}
