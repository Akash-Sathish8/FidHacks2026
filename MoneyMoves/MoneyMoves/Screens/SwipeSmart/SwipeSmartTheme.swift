import SwiftUI

// Self-contained palette + type for the SwipeSmart mini-game.
// Intentionally different from the rest of the app — warm paper aesthetic,
// not the soft neo-futurism used in the main shell.

enum SSPalette {
    static let cream      = Color(hex: 0xF4EFE3)
    static let cream2     = Color(hex: 0xECE5D3)
    static let paper      = Color(hex: 0xFBF7EC)
    static let forest     = Color(hex: 0x1E3A2E)
    static let forest2    = Color(hex: 0x2A4A3A)
    static let gold       = Color(hex: 0xB89855)
    static let goldLight  = Color(hex: 0xD4B97A)
    static let coral      = Color(hex: 0xD4654A)
    static let rose       = Color(hex: 0xC77985)
    static let ink        = Color(hex: 0x1A1814)
    static let inkSoft    = Color(hex: 0x4A453E)
    static let danger     = Color(hex: 0xB23B2B)

    static let dangerBg   = Color(hex: 0xFAE2DD)
    static let warnBg     = Color(hex: 0xFAEDE7)
    static let upBg       = Color(hex: 0xE8F0E2)
    static let downBg     = Color(hex: 0xF5DAD3)
}

enum SSFont {
    // Use SF system serif (.serif design) — close enough to Fraunces on iOS,
    // no font bundling needed for the hackathon demo.
    static func serif(_ size: CGFloat, weight: Font.Weight = .light, italic: Bool = false) -> Font {
        var f = Font.system(size: size, weight: weight, design: .serif)
        if italic { f = f.italic() }
        return f
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }
    static func sans(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        Font.system(size: size, weight: weight, design: .default)
    }
}

// Background — cream wash with subtle radial tints (the "paper" feel)
struct SSBackground: View {
    var body: some View {
        ZStack {
            SSPalette.cream.ignoresSafeArea()
            RadialGradient(colors: [SSPalette.gold.opacity(0.06), .clear],
                           center: UnitPoint(x: 0.2, y: 0.3),
                           startRadius: 5, endRadius: 380)
                .ignoresSafeArea()
            RadialGradient(colors: [SSPalette.forest.opacity(0.04), .clear],
                           center: UnitPoint(x: 0.8, y: 0.7),
                           startRadius: 5, endRadius: 360)
                .ignoresSafeArea()
        }
    }
}
