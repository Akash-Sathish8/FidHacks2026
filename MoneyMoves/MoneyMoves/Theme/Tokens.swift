import SwiftUI

// Soft neo-futurism design tokens
// All colors, gradients, radii, and shadows for Money Moves.

enum Palette {
    static let cream      = Color(hex: 0xFDFBF7)
    static let creamDeep  = Color(hex: 0xF4EFE6)
    static let ink        = Color(hex: 0x1A1726)
    static let inkSoft    = Color(hex: 0x4A4459)
    static let inkMuted   = Color(hex: 0x8B8499)

    static let lavender      = Color(hex: 0xC4B5FD)
    static let lavenderDeep  = Color(hex: 0xA78BFA)
    static let lavenderSoft  = Color(hex: 0xEDE9FE)

    static let peach      = Color(hex: 0xFFD4B8)
    static let peachDeep  = Color(hex: 0xFF9E7D)
    static let peachSoft  = Color(hex: 0xFFF1E6)

    static let mint      = Color(hex: 0xB5E8D5)
    static let mintDeep  = Color(hex: 0x6FE3B3)
    static let mintSoft  = Color(hex: 0xE6FAF1)

    static let rose      = Color(hex: 0xF9C5D1)
    static let roseDeep  = Color(hex: 0xEA9AB2)
    static let roseSoft  = Color(hex: 0xFDECF1)

    static let sky      = Color(hex: 0xBEE3F8)
    static let skyDeep  = Color(hex: 0x7BC4F0)

    static let glass        = Color.white.opacity(0.55)
    static let glassBorder  = Color.white.opacity(0.7)

    // Semantic accents
    static let success = Color(hex: 0x0F8862)
}

enum Gradients {
    static let app = LinearGradient(
        colors: [Palette.cream, Color(hex: 0xF6EEF8), Color(hex: 0xEEF1FA)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let hero = LinearGradient(
        colors: [Palette.lavender, Palette.rose, Palette.peach],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let mintCard = LinearGradient(
        colors: [Palette.mint, Color(hex: 0xDCF7EB)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let lavenderCard = LinearGradient(
        colors: [Palette.lavender, Palette.lavenderSoft],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let peachCard = LinearGradient(
        colors: [Palette.rose, Palette.peach],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum Radius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 18
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let pill: CGFloat = 999
}

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

enum Typo {
    static let display     = Font.system(size: 40, weight: .bold).leading(.tight)
    static let h1          = Font.system(size: 30, weight: .bold)
    static let h2          = Font.system(size: 22, weight: .bold)
    static let h3          = Font.system(size: 18, weight: .semibold)
    static let body        = Font.system(size: 15, weight: .regular)
    static let bodyBold    = Font.system(size: 15, weight: .semibold)
    static let caption     = Font.system(size: 12, weight: .medium)
    static let labelSmall  = Font.system(size: 11, weight: .bold).width(.standard)
}

// Hex initializer
extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
