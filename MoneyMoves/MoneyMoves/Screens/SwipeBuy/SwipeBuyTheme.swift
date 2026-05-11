import SwiftUI

// Self-contained palette + helpers for the SwipeSmart (budget swipe) mini-game.
// Pastel: lavender / pink / sky-blue per the source HTML.

enum SBPalette {
    static let lavender   = Color(hex: 0xCDB4DB)   // primary accent
    static let palePink   = Color(hex: 0xFFC8DD)
    static let hotPink    = Color(hex: 0xFFAFCC)   // SKIP
    static let skyBlue    = Color(hex: 0xBDE0FE)
    static let brightBlue = Color(hex: 0xA2D2FF)   // BUY

    static let cream      = Color(hex: 0xFCF9FF)
    static let ink        = Color(hex: 0x2D2335)
    static let inkSoft    = Color(hex: 0x5E5466)
    static let inkMuted   = Color(hex: 0x8E8499)

    static let glass        = Color.white.opacity(0.65)
    static let glassBorder  = Color.white.opacity(0.8)
    static let cardSurface  = Color.white
    static let cardBorder   = palePink
}

struct SBBackground: View {
    var body: some View {
        ZStack {
            SBPalette.cream.ignoresSafeArea()
            LinearGradient(colors: [SBPalette.palePink.opacity(0.3), SBPalette.skyBlue.opacity(0.3)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
    }
}
