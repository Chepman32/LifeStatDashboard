import CoreHaptics
import UIKit

@MainActor
final class HapticsManager {
    static let shared = HapticsManager()

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    var enabled = true

    private init() {}

    func prepare() {
        [light, medium, soft].forEach { $0.prepare() }
        selection.prepare()
        notification.prepare()
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard enabled else { return }
        switch style {
        case .light:
            light.impactOccurred()
        case .medium:
            medium.impactOccurred()
        case .soft:
            soft.impactOccurred()
        default:
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }

    func selectionChanged() {
        guard enabled else { return }
        selection.selectionChanged()
    }

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard enabled else { return }
        notification.notificationOccurred(type)
    }
}
