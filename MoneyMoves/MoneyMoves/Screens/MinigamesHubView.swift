import SwiftUI

struct MinigamesHubView: View {
    @State private var showTraderLobby: Bool = false
    @State private var showSwipeSmart: Bool = false   // wired to the Reigns-style MoneyMoves game
    @State private var showSwipeBuy: Bool = false     // wired to the budget swipe SwipeSmart game
    @State private var showFirstPaycheck: Bool = false
    @State private var comingSoonName: String? = nil

    private let games: [Game] = [
        Game(id: .swipe,  tag: "Spending reflex", title: "SwipeSmart",
             desc: "Swipe left to buy, right to skip. Stay inside your budget for 10 cards.",
             gradient: Gradients.peachCard, glyphTint: Color(hex: 0xB33A6B), ready: true),
        Game(id: .moves,  tag: "Life sim", title: "MoneyMoves",
             desc: "Swipe through 4 years of college money moves. 4 stats, 44 decisions.",
             gradient: Gradients.lavenderCard, glyphTint: Color(hex: 0x6D4FD4), ready: true),
        Game(id: .paycheck, tag: "First job", title: "First Paycheck Shock",
             desc: "Get the offer. Negotiate. Watch taxes eat your gross. Budget the rest.",
             gradient: LinearGradient(colors: [Color(hex: 0xFFE3D8), Color(hex: 0xFCF7EE)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
             glyphTint: Color(hex: 0xFF7B5F), ready: true),
        Game(id: .market, tag: "Investing", title: "Market Games",
             desc: "Rewind real market history. Compress months into seconds. Beat the benchmark.",
             gradient: Gradients.mintCard, glyphTint: Palette.success, ready: true),
    ]

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Budget Bloom")
                    Text("Minigames.")
                        .font(Typo.display)
                        .foregroundStyle(Palette.ink)
                    Text("Three quick ways to practice your first money moves.")
                        .font(Typo.body)
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.md)

                    VStack(spacing: Spacing.md) {
                        ForEach(games) { game in
                            GameCard(game: game) {
                                switch game.id {
                                case .market:   showTraderLobby = true
                                case .moves:    showSwipeSmart = true
                                case .swipe:    showSwipeBuy = true
                                case .paycheck: showFirstPaycheck = true
                                }
                            }
                        }
                    }

                    Text("FidHacks 2026")
                        .font(Typo.caption)
                        .foregroundStyle(Palette.inkMuted)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Spacing.xl)

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
        .sheet(isPresented: $showTraderLobby) {
            TraderLobbyView()
                .environmentObject(AppState.shared)
        }
        .fullScreenCover(isPresented: $showSwipeSmart) {
            SwipeSmartView { showSwipeSmart = false }
                .environmentObject(AppState.shared)
        }
        .fullScreenCover(isPresented: $showSwipeBuy) {
            SwipeBuyView { showSwipeBuy = false }
        }
        .fullScreenCover(isPresented: $showFirstPaycheck) {
            FirstPaycheckView { showFirstPaycheck = false }
        }
        .alert("Coming soon",
               isPresented: Binding(get: { comingSoonName != nil }, set: { if !$0 { comingSoonName = nil } })) {
            Button("OK", role: .cancel) { comingSoonName = nil }
        } message: {
            Text("\(comingSoonName ?? "This game") is in the lab. Stay tuned.")
        }
    }
}

// MARK: - Game model + card

struct Game: Identifiable {
    enum Id: String { case swipe, moves, paycheck, market }
    let id: Id
    let tag: String
    let title: String
    let desc: String
    let gradient: LinearGradient
    let glyphTint: Color
    let ready: Bool
}

struct GameCard: View {
    let game: Game
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(game.gradient)
                        .frame(width: 88, height: 88)
                    glyph
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.tag.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(Palette.inkMuted)
                    Text(game.title).font(Typo.h2).foregroundStyle(Palette.ink)
                    Text(game.desc)
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .foregroundStyle(Palette.inkSoft)
                    Text(game.ready ? "Play now  →" : "Coming soon")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(game.ready ? Palette.success : Palette.inkMuted)
                        .padding(.top, 2)
                }
                Spacer()
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                            .stroke(Palette.glassBorder, lineWidth: 1)
                    )
            )
            .shadow(color: Palette.ink.opacity(0.08), radius: 24, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var glyph: some View {
        switch game.id {
        case .swipe:    SwipeGlyph(tint: game.glyphTint)
        case .moves:    MovesGlyph(tint: game.glyphTint)
        case .paycheck: PaycheckGlyph(tint: game.glyphTint)
        case .market:   MarketGlyph()
        }
    }
}

struct PaycheckGlyph: View {
    let tint: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.white)
                .frame(width: 52, height: 30)
                .overlay(
                    VStack(alignment: .leading, spacing: 3) {
                        Rectangle().fill(tint.opacity(0.4)).frame(width: 32, height: 2)
                        Rectangle().fill(tint.opacity(0.3)).frame(width: 22, height: 2)
                        Rectangle().fill(tint.opacity(0.3)).frame(width: 28, height: 2)
                    }
                    .padding(.leading, 8),
                    alignment: .leading
                )
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                .rotationEffect(.degrees(-6))
            Text("$")
                .font(.system(size: 26, weight: .heavy, design: .serif))
                .foregroundStyle(tint)
                .offset(x: 14, y: 12)
        }
        .frame(width: 70, height: 56)
    }
}

// MARK: - Glyphs

struct SwipeGlyph: View {
    let tint: Color
    var body: some View {
        ZStack {
            card.rotationEffect(.degrees(-10)).offset(x: -12, y: 6).opacity(0.6)
            card.opacity(0.85)
            card
                .rotationEffect(.degrees(10))
                .offset(x: 12, y: -6)
                .overlay(Text("$").font(.system(size: 22, weight: .bold)).foregroundStyle(tint)
                            .rotationEffect(.degrees(10)).offset(x: 12, y: -6))
        }
        .frame(width: 70, height: 70)
    }
    private var card: some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(.white)
            .frame(width: 40, height: 54)
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

struct MovesGlyph: View {
    let tint: Color
    var body: some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: 8, y: 56))
                p.addQuadCurve(to: CGPoint(x: 36, y: 40), control: CGPoint(x: 20, y: 12))
                p.addQuadCurve(to: CGPoint(x: 64, y: 18), control: CGPoint(x: 50, y: 30))
            }
            .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            ForEach([(12.0, 54.0), (34.0, 40.0), (52.0, 30.0), (64.0, 18.0)], id: \.0) { pt in
                Circle().fill(tint).frame(width: 10, height: 10).offset(x: pt.0 - 36, y: pt.1 - 36)
            }
        }
        .frame(width: 72, height: 72)
    }
}

struct MarketGlyph: View {
    private let points: [CGPoint] = [
        CGPoint(x: 0, y: 45), CGPoint(x: 15, y: 38), CGPoint(x: 25, y: 42),
        CGPoint(x: 40, y: 22), CGPoint(x: 55, y: 30), CGPoint(x: 70, y: 14),
        CGPoint(x: 90, y: 22), CGPoint(x: 105, y: 8), CGPoint(x: 120, y: 12),
    ]

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 120
            let sy = geo.size.height / 60
            let scaled = points.map { CGPoint(x: $0.x * sx, y: $0.y * sy) }

            ZStack {
                Path { p in
                    p.move(to: scaled[0])
                    for pt in scaled.dropFirst() { p.addLine(to: pt) }
                    p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    p.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [Palette.mintDeep.opacity(0.6), Palette.mintDeep.opacity(0)],
                                     startPoint: .top, endPoint: .bottom))

                Path { p in
                    p.move(to: scaled[0])
                    for pt in scaled.dropFirst() { p.addLine(to: pt) }
                }
                .stroke(Palette.success, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: 56, height: 28)
    }
}

// Singleton hook for sheet previews; the real app provides via environmentObject upstream.
extension AppState {
    static let shared = AppState()
}

#Preview {
    MinigamesHubView().environmentObject(AppState())
}
