import SwiftUI

enum LiftaTypography {
    static func hero(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func display(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func body(_ size: CGFloat = 17, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func editorial(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .custom(editorialFace(for: weight), size: size)
    }

    private static func editorialFace(for weight: Font.Weight) -> String {
        switch weight {
        case .bold, .heavy, .black, .semibold:
            return "HelveticaNeue-Bold"
        case .medium:
            return "HelveticaNeue-Medium"
        default:
            return "HelveticaNeue"
        }
    }
}
