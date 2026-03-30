import SwiftUI

struct CosmicBackgroundView: View {
    let theme: LunivoTheme
    let intensity: Double
    let animate: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 24, paused: !animate)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let palette = theme.palette
            let isLight = theme == .light || theme == .solar
            let blendColor = isLight ? Color.white : Color.black
            let gradientColors = palette.background.map { blendColor.blended(with: $0, amount: intensity) }

            ZStack {
                LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)

                Canvas { context, size in
                    for index in 0..<120 {
                        let x = normalized(seed: index * 13 + 7) * size.width
                        let y = normalized(seed: index * 29 + 11) * size.height
                        let radius = 0.9 + normalized(seed: index * 17 + 3) * 1.9
                        let opacityBase = 0.12 + normalized(seed: index * 19 + 5) * 0.55
                        let twinkle = 0.35 + 0.65 * (0.5 + 0.5 * sin(t * 0.9 + Double(index)))
                        let opacity = opacityBase * twinkle * intensity
                        let rect = CGRect(x: x, y: y, width: radius, height: radius)
                        context.fill(Path(ellipseIn: rect), with: .color(palette.starColor.opacity(opacity)))
                    }
                }

                GeometryReader { proxy in
                    let size = proxy.size
                    Circle()
                        .fill(palette.glow)
                        .blur(radius: 80)
                        .frame(width: size.width * 0.52, height: size.width * 0.52)
                        .offset(x: sin(t * 0.14) * 40 - 60, y: -size.height * 0.2)

                    Circle()
                        .fill(palette.accent.opacity(0.18))
                        .blur(radius: 100)
                        .frame(width: size.width * 0.55, height: size.width * 0.55)
                        .offset(x: size.width * 0.22 + cos(t * 0.11) * 30, y: size.height * 0.24)

                    Circle()
                        .strokeBorder(palette.cardStroke.opacity(0.3), lineWidth: 1)
                        .frame(width: size.width * 1.1, height: size.width * 1.1)
                        .offset(x: size.width * 0.35, y: -size.height * 0.1 + cos(t * 0.08) * 16)
                }
                .allowsHitTesting(false)

                Rectangle()
                    .fill(.black.opacity(theme == .light || theme == .solar ? 0.02 : 0.12))
                    .blendMode(.multiply)
            }
            .overlay(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 999)
                    .fill(.white.opacity(0.06))
                    .frame(width: 220, height: 220)
                    .blur(radius: 70)
                    .offset(x: 40, y: -70)
            }
        }
    }

    private func normalized(seed: Int) -> CGFloat {
        let x = sin(Double(seed) * 12.9898) * 43758.5453
        return CGFloat(x - floor(x))
    }
}
