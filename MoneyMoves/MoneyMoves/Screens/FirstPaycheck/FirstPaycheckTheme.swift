import SwiftUI

// Local palette for First Paycheck Shock — warm editorial.
// Cream / coral / teal, intentionally separate from the main app's lavender system.

enum FPPalette {
    static let cream      = Color(hex: 0xFCF7EE)
    static let creamDeep  = Color(hex: 0xF3EBD9)
    static let paper      = Color(hex: 0xFFFDF7)
    static let coral      = Color(hex: 0xFF7B5F)
    static let coralSoft  = Color(hex: 0xFFE3D8)
    static let teal       = Color(hex: 0x3DA89F)
    static let tealSoft   = Color(hex: 0xCDEAE7)
    static let ink        = Color(hex: 0x1B2E2A)
    static let inkSoft    = Color(hex: 0x4F605C)
    static let inkMuted   = Color(hex: 0x8A968F)
    static let gold       = Color(hex: 0xD4A24C)
    static let danger     = Color(hex: 0xC0392B)
}

enum FPFont {
    // DM Serif Display + DM Sans aren't bundled — use SF system serif & rounded as the
    // closest stand-ins. Same warm editorial feel.
    static func serif(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        Font.system(size: size, weight: weight, design: .serif)
    }
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }
}

struct FPBackground: View {
    var body: some View {
        ZStack {
            FPPalette.cream.ignoresSafeArea()
            RadialGradient(colors: [FPPalette.coral.opacity(0.06), .clear],
                           center: UnitPoint(x: 0.85, y: 0.1),
                           startRadius: 5, endRadius: 360).ignoresSafeArea()
            RadialGradient(colors: [FPPalette.teal.opacity(0.06), .clear],
                           center: UnitPoint(x: 0.15, y: 0.95),
                           startRadius: 5, endRadius: 360).ignoresSafeArea()
        }
    }
}

// MARK: - Confetti particle layer

struct FPConfetti: View {
    let count: Int
    let pieces: [Piece]

    init(count: Int = 80) {
        self.count = count
        self.pieces = (0..<count).map { _ in Piece.random() }
    }

    struct Piece: Identifiable {
        let id = UUID()
        let xPercent: CGFloat
        let color: Color
        let delay: Double
        let duration: Double
        let rotation: Double
        let isCircle: Bool
        static func random() -> Piece {
            Piece(
                xPercent: CGFloat.random(in: 0...1),
                color: [FPPalette.coral, FPPalette.teal, FPPalette.gold, FPPalette.coralSoft].randomElement()!,
                delay: Double.random(in: 0...0.4),
                duration: Double.random(in: 2.4...3.6),
                rotation: Double.random(in: -360...360),
                isCircle: Bool.random()
            )
        }
    }

    @State private var animate: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { p in
                    Group {
                        if p.isCircle {
                            Circle().fill(p.color).frame(width: 8, height: 8)
                        } else {
                            RoundedRectangle(cornerRadius: 1).fill(p.color)
                                .frame(width: 6, height: 12)
                        }
                    }
                    .position(x: p.xPercent * geo.size.width,
                              y: animate ? geo.size.height + 40 : -20)
                    .rotationEffect(.degrees(animate ? p.rotation : 0))
                    .opacity(animate ? 0 : 1)
                    .animation(.easeIn(duration: p.duration).delay(p.delay), value: animate)
                }
            }
            .onAppear { animate = true }
            .allowsHitTesting(false)
        }
    }
}
