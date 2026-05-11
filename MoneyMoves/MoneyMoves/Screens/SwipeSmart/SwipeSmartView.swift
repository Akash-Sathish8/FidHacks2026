import SwiftUI

// MARK: - Root view

struct SwipeSmartView: View {
    let onClose: () -> Void
    @EnvironmentObject var app: AppState
    @StateObject private var state = SwipeSmartState()

    var body: some View {
        ZStack {
            SSBackground()

            switch state.screen {
            case .splash:  SSSplashView(state: state, onClose: onClose)
            case .onboard: SSOnboardView(state: state)
            case .game:    SSGameView(state: state, onClose: onClose)
            case .death:   SSEndView(state: state, kind: .death, onClose: onClose)
            case .win:     SSEndView(state: state, kind: .win, onClose: onClose)
            }
        }
        .preferredColorScheme(.light)
        .onAppear { state.onAppear() }
    }
}

// MARK: - State

@MainActor
final class SwipeSmartState: ObservableObject {
    enum Screen: Equatable { case splash, onboard, game, death, win }

    @Published var screen: Screen = .splash
    @Published var name: String = ""
    @Published var stats: [SSStatKey: Int] = [.wallet: 50, .career: 50, .vibe: 50, .future: 50]
    @Published var cardIdx: Int = 0
    @Published var currentYear: Int = 1
    @Published var deadStat: SSStatKey? = nil
    @Published var fairyPayload: FairyPayload? = nil
    @Published var yearSplash: Int? = nil          // year shown
    @Published var statAnims: [SSStatKey: StatAnim] = [:]

    struct FairyPayload: Identifiable {
        let id = UUID()
        let label: String
        let body: String
    }
    struct StatAnim {
        let flashUp: Bool
        let delta: Int
        let stamp: Int   // unique to retrigger
    }

    func onAppear() {
        // no-op for now; could resume saved progress
    }

    func startGame() {
        screen = .game
        stats = [.wallet: 50, .career: 50, .vibe: 50, .future: 50]
        cardIdx = 0
        currentYear = 1
        deadStat = nil
        yearSplash = 1
        // Hide year splash after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeOut(duration: 0.35)) { self.yearSplash = nil }
        }
    }

    var currentCard: SSCard? {
        guard cardIdx < SS_DECK.count else { return nil }
        return SS_DECK[cardIdx]
    }

    private static var animStamp: Int = 0

    func choose(yes: Bool) {
        guard let card = currentCard else { return }
        let choice = yes ? card.yes : card.no
        // Apply deltas
        var newStats = stats
        for (key, delta) in choice.deltas {
            newStats[key] = max(0, min(100, (newStats[key] ?? 0) + delta))
            Self.animStamp += 1
            statAnims[key] = StatAnim(flashUp: delta >= 0, delta: delta, stamp: Self.animStamp)
        }
        withAnimation(.easeOut(duration: 0.45)) {
            stats = newStats
        }

        // Show fairy after a short beat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.fairyPayload = FairyPayload(label: choice.label, body: choice.fairy)
        }
    }

    func dismissFairy() {
        fairyPayload = nil
        // Check death
        if let dead = SSStatKey.allCases.first(where: { (stats[$0] ?? 100) <= 0 }) {
            deadStat = dead
            screen = .death
            return
        }
        // Advance
        cardIdx += 1
        if cardIdx >= SS_DECK.count {
            screen = .win
            return
        }
        // Year transition?
        if let next = currentCard, next.year != currentYear {
            currentYear = next.year
            yearSplash = next.year
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeOut(duration: 0.35)) { self.yearSplash = nil }
            }
        }
    }

    func playAgain() {
        screen = .splash
    }
}

// MARK: - Splash

struct SSSplashView: View {
    let state: SwipeSmartState
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onClose) {
                    Text("← Minigames").font(SSFont.mono(11, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(SSPalette.inkSoft)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().stroke(SSPalette.inkSoft.opacity(0.3), lineWidth: 1))
                }
                Spacer()
            }
            .padding(.horizontal, 24).padding(.top, 12)

            Spacer()

            VStack(spacing: 0) {
                Text("— A SMART MONEY MOVES GAME —")
                    .font(SSFont.mono(11, weight: .semibold))
                    .tracking(3)
                    .foregroundColor(SSPalette.gold)
                    .padding(.bottom, 18)

                (Text("Swipe").foregroundColor(SSPalette.forest)
                 + Text("\n")
                 + Text("Smart.").italic().foregroundColor(SSPalette.coral))
                    .font(SSFont.serif(96, weight: .light))
                    .multilineTextAlignment(.center)
                    .lineSpacing(-12)
                    .padding(.bottom, 20)

                Rectangle().fill(SSPalette.gold).frame(width: 60, height: 1)
                    .padding(.bottom, 30)

                Text("\"Four years. Four stats. One you, four years older — richer, wiser, or completely undone.\"")
                    .font(SSFont.serif(20, weight: .regular, italic: true))
                    .foregroundColor(SSPalette.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)

                HStack(spacing: 24) {
                    metaItem(value: "44", label: "Decisions")
                    metaItem(value: "4",  label: "Years")
                    metaItem(value: "∞",  label: "Outcomes")
                }
                .padding(.bottom, 36)
            }

            Spacer()

            Button {
                state.screen = .onboard
            } label: {
                HStack(spacing: 10) {
                    Text("Begin").font(SSFont.sans(14, weight: .semibold))
                    Text("→").font(.system(size: 18))
                }
                .foregroundColor(SSPalette.cream)
                .padding(.horizontal, 36).padding(.vertical, 18)
                .background(Capsule().fill(SSPalette.forest))
                .shadow(color: SSPalette.ink.opacity(0.18), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 48)
        }
    }

    private func metaItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(SSFont.mono(14, weight: .semibold)).foregroundColor(SSPalette.forest)
            Text(label.uppercased()).font(SSFont.mono(10, weight: .medium))
                .tracking(2).foregroundColor(SSPalette.inkSoft)
        }
    }
}

// MARK: - Onboard (name input)

struct SSOnboardView: View {
    @ObservedObject var state: SwipeSmartState
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 14) {
                Text("BEFORE WE BEGIN")
                    .font(SSFont.mono(11, weight: .semibold))
                    .tracking(3).foregroundColor(SSPalette.gold)
                    .padding(.bottom, 6)
                (Text("What should we\ncall you, ").foregroundColor(SSPalette.forest)
                 + Text("darling?").italic().foregroundColor(SSPalette.coral))
                    .font(SSFont.serif(48, weight: .light))
                    .multilineTextAlignment(.center)
                Text("Your fairy godmother is on her way. She'd like to know your name first.")
                    .font(SSFont.serif(15, weight: .regular))
                    .foregroundColor(SSPalette.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            VStack(spacing: 4) {
                TextField("your name", text: $state.name)
                    .font(SSFont.serif(28, weight: .light))
                    .foregroundColor(SSPalette.forest)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()
                    .focused($nameFocused)
                Rectangle().fill(SSPalette.forest).frame(height: 1.5)
            }
            .padding(.horizontal, 48).padding(.top, 40)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    state.screen = .splash
                } label: {
                    Text("Back").font(SSFont.sans(13, weight: .semibold))
                        .foregroundColor(SSPalette.forest)
                        .padding(.horizontal, 28).padding(.vertical, 16)
                        .background(Capsule().stroke(SSPalette.forest, lineWidth: 1))
                }.buttonStyle(.plain)

                Button {
                    if state.name.trimmingCharacters(in: .whitespaces).isEmpty {
                        state.name = "friend"
                    }
                    state.startGame()
                } label: {
                    HStack(spacing: 8) {
                        Text("Start").font(SSFont.sans(13, weight: .semibold))
                        Text("→").font(.system(size: 16))
                    }
                    .foregroundColor(SSPalette.cream)
                    .padding(.horizontal, 28).padding(.vertical, 16)
                    .background(Capsule().fill(SSPalette.forest))
                }.buttonStyle(.plain)
            }
            .padding(.bottom, 48)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { nameFocused = true }
        }
    }
}

// MARK: - Game

struct SSGameView: View {
    @ObservedObject var state: SwipeSmartState
    let onClose: () -> Void
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                topBar
                hud.padding(.horizontal, 16).padding(.bottom, 6)
                cardArea
                choiceButtons.padding(.horizontal, 16).padding(.bottom, 18)
            }

            // Year splash overlay
            if let year = state.yearSplash {
                yearOverlay(year)
                    .transition(.opacity)
            }

            // Fairy overlay
            if let payload = state.fairyPayload {
                fairyOverlay(payload: payload)
                    .transition(.opacity)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                onClose()
            } label: {
                Text("Quit").font(SSFont.mono(10, weight: .semibold)).tracking(2)
                    .foregroundColor(SSPalette.inkSoft)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().stroke(SSPalette.inkSoft.opacity(0.3), lineWidth: 1))
            }.buttonStyle(.plain)
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(SSPalette.gold).frame(width: 6, height: 6)
                Text("Year \(state.currentYear) · \(SS_YEAR_NAMES[state.currentYear])")
                    .font(SSFont.mono(10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(SSPalette.inkSoft)
            }
            Spacer()
            Text(String(format: "%02d / %02d", state.cardIdx + 1, SS_DECK.count))
                .font(SSFont.mono(10, weight: .medium))
                .tracking(1.5)
                .foregroundColor(SSPalette.inkSoft)
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 14)
    }

    private var hud: some View {
        HStack(spacing: 8) {
            ForEach(SSStatKey.allCases, id: \.self) { key in
                SSStatTile(key: key,
                           value: state.stats[key] ?? 0,
                           anim: state.statAnims[key])
            }
        }
    }

    private var cardArea: some View {
        GeometryReader { geo in
            ZStack {
                // Behind cards
                if state.cardIdx + 2 < SS_DECK.count {
                    SSCardView(card: SS_DECK[state.cardIdx + 2], idx: state.cardIdx + 3, behind: 2)
                }
                if state.cardIdx + 1 < SS_DECK.count {
                    SSCardView(card: SS_DECK[state.cardIdx + 1], idx: state.cardIdx + 2, behind: 1)
                }
                // Top card with drag
                if let card = state.currentCard {
                    SSCardView(card: card, idx: state.cardIdx + 1, behind: 0,
                               dragOffset: dragOffset)
                        .offset(x: dragOffset.width, y: abs(dragOffset.width) * 0.05)
                        .rotationEffect(.degrees(Double(dragOffset.width) * 0.06))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let dy = value.translation.height
                                    let dx = value.translation.width
                                    if abs(dy) > abs(dx) * 1.5 && abs(dy) > 30 { return }
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    let dx = value.translation.width
                                    let threshold: CGFloat = 110
                                    if dx > threshold {
                                        flyOff(direction: 1, geo: geo)
                                    } else if dx < -threshold {
                                        flyOff(direction: -1, geo: geo)
                                    } else {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                            dragOffset = .zero
                                        }
                                    }
                                }
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func flyOff(direction: Int, geo: GeometryProxy) {
        let target = CGFloat(direction) * (geo.size.width + 200)
        withAnimation(.easeIn(duration: 0.35)) {
            dragOffset = CGSize(width: target, height: 80)
        }
        // After fly-off animation, register the choice and reset offset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            state.choose(yes: direction > 0)
            dragOffset = .zero
        }
    }

    private var choiceButtons: some View {
        HStack(spacing: 10) {
            choiceButton(label: "← swipe left",
                         title: state.currentCard?.no.label ?? "",
                         color: SSPalette.danger) {
                flyOffFromButton(direction: -1)
            }
            choiceButton(label: "swipe right →",
                         title: state.currentCard?.yes.label ?? "",
                         color: SSPalette.forest) {
                flyOffFromButton(direction: 1)
            }
        }
    }

    private func flyOffFromButton(direction: Int) {
        let target = CGFloat(direction) * 600
        withAnimation(.easeIn(duration: 0.35)) {
            dragOffset = CGSize(width: target, height: 80)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            state.choose(yes: direction > 0)
            dragOffset = .zero
        }
    }

    private func choiceButton(label: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label.uppercased())
                    .font(SSFont.mono(9, weight: .medium))
                    .tracking(2)
                    .foregroundColor(SSPalette.inkSoft)
                Text(title).font(SSFont.serif(18, weight: .regular, italic: true))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(SSPalette.paper)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(SSPalette.forest.opacity(0.15), lineWidth: 1)
                    )
            )
            .shadow(color: SSPalette.ink.opacity(0.12), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private func yearOverlay(_ year: Int) -> some View {
        ZStack {
            SSPalette.forest.ignoresSafeArea()
            VStack(spacing: 14) {
                Text("Year \(year) of 4")
                    .font(SSFont.mono(11, weight: .semibold))
                    .tracking(4)
                    .foregroundColor(SSPalette.gold)
                Text(SS_YEAR_NAMES[year])
                    .font(SSFont.serif(80, weight: .light, italic: true))
                    .foregroundColor(SSPalette.cream)
                Text(SS_YEAR_SUBS[year])
                    .font(SSFont.serif(18, weight: .regular, italic: true))
                    .foregroundColor(SSPalette.goldLight)
                    .padding(.top, 6)
            }
        }
    }

    private func fairyOverlay(payload: SwipeSmartState.FairyPayload) -> some View {
        ZStack {
            SSPalette.ink.opacity(0.4).ignoresSafeArea()
                .onTapGesture { state.dismissFairy() }

            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                HStack(spacing: 8) {
                    Rectangle().fill(SSPalette.gold).frame(width: 24, height: 1)
                    Text("YOUR FAIRY GODMOTHER")
                        .font(SSFont.mono(10, weight: .semibold)).tracking(3)
                        .foregroundColor(SSPalette.gold)
                    Rectangle().fill(SSPalette.gold).frame(width: 24, height: 1)
                }
                .padding(.bottom, 8)

                (Text("\"You chose ").foregroundColor(SSPalette.forest)
                 + Text(payload.label).italic().foregroundColor(SSPalette.coral)
                 + Text(".\"").foregroundColor(SSPalette.forest))
                    .font(SSFont.serif(22, weight: .light, italic: true))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 16)

                SSText(payload.body, size: 17)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28).padding(.bottom, 24)

                Button { state.dismissFairy() } label: {
                    Text("Continue")
                        .font(SSFont.sans(13, weight: .semibold))
                        .foregroundColor(SSPalette.cream)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(SSPalette.forest))
                }.buttonStyle(.plain).padding(.horizontal, 24)
                Spacer().frame(height: 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(SSPalette.paper)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(SSPalette.gold.opacity(0.4), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .shadow(color: SSPalette.ink.opacity(0.35), radius: 24, y: 20)
        }
    }
}

// MARK: - Stat tile

struct SSStatTile: View {
    let key: SSStatKey
    let value: Int
    let anim: SwipeSmartState.StatAnim?

    @State private var flash: Bool = false
    @State private var deltaShown: Int? = nil
    @State private var lastStamp: Int = 0

    var status: TileStatus {
        if value <= 20 { return .danger }
        if value <= 35 { return .warn }
        return .normal
    }

    enum TileStatus { case normal, warn, danger }

    var body: some View {
        VStack(spacing: 4) {
            Text(key.icon).font(.system(size: 18))
            Text(key.label.uppercased())
                .font(SSFont.mono(8.5, weight: .medium)).tracking(2)
                .foregroundColor(SSPalette.inkSoft)
            Text("\(value)")
                .font(SSFont.serif(22, weight: .regular))
                .foregroundColor(SSPalette.forest)
                .monospacedDigit()
            barView
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8).padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(flashColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
        .overlay(alignment: .topTrailing) {
            if let d = deltaShown {
                Text((d > 0 ? "+" : "") + "\(d)")
                    .font(SSFont.mono(11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Capsule().fill(d >= 0 ? SSPalette.forest : SSPalette.danger))
                    .offset(x: 2, y: -6)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .scaleEffect(flash ? 1.05 : 1)
        .animation(.easeOut(duration: 0.25), value: flash)
        .onChange(of: anim?.stamp ?? 0) { _, newStamp in
            guard let a = anim, newStamp != lastStamp else { return }
            lastStamp = newStamp
            flash = true
            deltaShown = a.delta
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation { flash = false }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { deltaShown = nil }
            }
        }
    }

    private var flashColor: Color {
        if flash {
            return (anim?.flashUp ?? true) ? SSPalette.upBg : SSPalette.downBg
        }
        switch status {
        case .danger: return SSPalette.dangerBg
        case .warn:   return SSPalette.warnBg
        case .normal: return SSPalette.paper
        }
    }
    private var borderColor: Color {
        switch status {
        case .danger: return SSPalette.danger
        case .warn:   return SSPalette.coral
        case .normal: return SSPalette.forest.opacity(0.1)
        }
    }

    private var barView: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2).fill(SSPalette.forest.opacity(0.08))
                RoundedRectangle(cornerRadius: 2)
                    .fill(barFillColor)
                    .frame(width: geo.size.width * CGFloat(value) / 100)
            }
        }
        .frame(height: 3)
        .padding(.top, 4)
    }
    private var barFillColor: Color {
        switch status {
        case .danger: return SSPalette.danger
        case .warn:   return SSPalette.coral
        case .normal: return SSPalette.forest
        }
    }
}

// MARK: - Card view

struct SSCardView: View {
    let card: SSCard
    let idx: Int
    let behind: Int             // 0=top, 1, 2
    var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(SSPalette.paper)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(SSPalette.gold.opacity(0.25), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("M.M. " + String(format: "%02d", idx))
                        .font(SSFont.mono(9, weight: .medium)).tracking(2)
                        .foregroundColor(SSPalette.gold)
                    Spacer()
                }
                .padding(.horizontal, 26).padding(.top, 22)

                Text("Year \(card.year) · \(SS_YEAR_NAMES[card.year])")
                    .font(SSFont.mono(9, weight: .medium)).tracking(2)
                    .foregroundColor(SSPalette.inkSoft)
                    .padding(.horizontal, 26).padding(.top, 8)

                Text(card.scene.uppercased())
                    .font(SSFont.mono(10, weight: .semibold)).tracking(2)
                    .foregroundColor(SSPalette.coral)
                    .padding(.horizontal, 26).padding(.top, 16)

                SSText(card.body, size: 22)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 26).padding(.top, 14)

                Spacer(minLength: 0)

                HStack {
                    Text("← " + card.no.label.uppercased())
                        .font(SSFont.mono(10, weight: .semibold)).tracking(1.8)
                        .foregroundColor(SSPalette.danger)
                    Spacer()
                    Text(card.yes.label.uppercased() + " →")
                        .font(SSFont.mono(10, weight: .semibold)).tracking(1.8)
                        .foregroundColor(SSPalette.forest)
                }
                .padding(.horizontal, 22).padding(.bottom, 22).padding(.top, 14)
                .overlay(alignment: .top) {
                    Rectangle().fill(SSPalette.forest.opacity(0.2))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .frame(maxWidth: 340)
        .aspectRatio(3 / 4.4, contentMode: .fit)
        .shadow(color: SSPalette.ink.opacity(0.25), radius: 28, x: 0, y: 16)
        .scaleEffect(behind == 0 ? 1 : (behind == 1 ? 0.94 : 0.88))
        .offset(y: behind == 0 ? 0 : (behind == 1 ? 14 : 26))
        .opacity(behind == 0 ? 1 : (behind == 1 ? 0.55 : 0.25))
        .overlay {
            if behind == 0 {
                stampOverlay
            }
        }
    }

    private var stampOverlay: some View {
        let yesOpacity = max(0, min(1, dragOffset.width / 90))
        let noOpacity  = max(0, min(1, -dragOffset.width / 90))
        return ZStack {
            // YES stamp (right side)
            HStack {
                Spacer()
                Text(card.yes.label.uppercased())
                    .font(SSFont.serif(36, weight: .light, italic: true))
                    .foregroundColor(SSPalette.forest)
                    .padding(.horizontal, 14).padding(.vertical, 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(SSPalette.forest, lineWidth: 2)
                    )
                    .rotationEffect(.degrees(8))
                    .opacity(yesOpacity)
                    .padding(.trailing, 18)
            }
            .padding(.top, 36)
            // NO stamp (left side)
            HStack {
                Text(card.no.label.uppercased())
                    .font(SSFont.serif(36, weight: .light, italic: true))
                    .foregroundColor(SSPalette.danger)
                    .padding(.horizontal, 14).padding(.vertical, 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(SSPalette.danger, lineWidth: 2)
                    )
                    .rotationEffect(.degrees(-8))
                    .opacity(noOpacity)
                    .padding(.leading, 18)
                Spacer()
            }
            .padding(.top, 36)
        }
    }
}

// MARK: - End screen

struct SSEndView: View {
    @ObservedObject var state: SwipeSmartState
    let kind: Kind
    let onClose: () -> Void

    enum Kind { case death, win }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 40)

                Text(eyebrow.uppercased())
                    .font(SSFont.mono(11, weight: .semibold)).tracking(3)
                    .foregroundColor(kind == .death ? SSPalette.danger : SSPalette.gold)

                title

                Text(subline)
                    .font(SSFont.serif(18, weight: .regular, italic: true))
                    .foregroundColor(SSPalette.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                          spacing: 10) {
                    ForEach(SSStatKey.allCases, id: \.self) { key in
                        endStatTile(key)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                summaryCard
                    .padding(.horizontal, 24)

                HStack(spacing: 10) {
                    Button {
                        state.playAgain()
                    } label: {
                        Text("Play again").font(SSFont.sans(13, weight: .semibold))
                            .foregroundColor(SSPalette.cream)
                            .padding(.horizontal, 26).padding(.vertical, 14)
                            .background(Capsule().fill(SSPalette.forest))
                    }.buttonStyle(.plain)
                    Button {
                        onClose()
                    } label: {
                        Text("Done").font(SSFont.sans(13, weight: .semibold))
                            .foregroundColor(SSPalette.forest)
                            .padding(.horizontal, 26).padding(.vertical, 14)
                            .background(Capsule().stroke(SSPalette.forest, lineWidth: 1))
                    }.buttonStyle(.plain)
                }
                .padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private var eyebrow: String {
        switch kind {
        case .death: return "Game Over · \(SS_YEAR_NAMES[state.currentYear]) Year"
        case .win:   return "Senior Year · Complete"
        }
    }

    private var title: some View {
        Group {
            switch kind {
            case .death:
                let dead = state.deadStat ?? .wallet
                (Text("Your ").foregroundColor(SSPalette.forest)
                 + Text(dead.label.lowercased()).italic().foregroundColor(SSPalette.coral)
                 + Text(" ran out.").foregroundColor(SSPalette.forest))
                    .font(SSFont.serif(48, weight: .light))
                    .multilineTextAlignment(.center)
            case .win:
                (Text("You made it,\n").foregroundColor(SSPalette.forest)
                 + Text(state.name).italic().foregroundColor(SSPalette.coral)
                 + Text(".").foregroundColor(SSPalette.forest))
                    .font(SSFont.serif(48, weight: .light))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
    }

    private var subline: String {
        switch kind {
        case .death:
            return deathSub(state.deadStat ?? .wallet)
        case .win:
            return winSub()
        }
    }

    private func deathSub(_ key: SSStatKey) -> String {
        switch key {
        case .wallet: return "You spent yourself into a corner. It happens to almost everyone — once."
        case .career: return "Your career capital dried up. The good news: it rebuilds faster than you think."
        case .vibe:   return "Burnout came for you. No paycheck is worth this."
        case .future: return "Future-you sent a postcard. It said: 'please start saving.'"
        }
    }

    private func winSub() -> String {
        let total = SSStatKey.allCases.reduce(0) { $0 + (state.stats[$1] ?? 0) }
        if total >= 280 { return "You didn't just survive college. You graduated rich, sharp, well, and ready." }
        if total >= 220 { return "Solid run. You leave college with the foundation most people spend a decade rebuilding." }
        if total >= 160 { return "You made it through. Bruised, smarter, and three good decisions away from thriving." }
        return "Senior year, by the skin of your teeth. The best financial education comes from the mistakes you survived."
    }

    private func endStatTile(_ key: SSStatKey) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(key.icon) \(key.label.uppercased())")
                .font(SSFont.mono(9, weight: .medium)).tracking(2)
                .foregroundColor(SSPalette.inkSoft)
            Text("\(state.stats[key] ?? 0)")
                .font(SSFont.serif(26, weight: .regular))
                .foregroundColor(SSPalette.forest)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(SSPalette.paper)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(SSPalette.forest.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var summaryCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Rectangle().fill(SSPalette.gold).frame(width: 18, height: 1)
                Text("A NOTE FROM YOUR FAIRY GODMOTHER")
                    .font(SSFont.mono(9, weight: .semibold)).tracking(3)
                    .foregroundColor(SSPalette.gold)
                Rectangle().fill(SSPalette.gold).frame(width: 18, height: 1)
            }
            SSText(summaryText, size: 16)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(SSPalette.paper)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(SSPalette.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var summaryText: String {
        let name = state.name.isEmpty ? "friend" : state.name
        switch kind {
        case .death:
            switch state.deadStat ?? .wallet {
            case .wallet: return "\(name), the average American 22-year-old carries *$3,300* in credit card debt. You weren't unlucky — you were just unguided. Try again: split every paycheck, audit subscriptions, and remember: *'no'* is a financial tool."
            case .career: return "\(name), careers aren't sprints. The internships you skip and the negotiations you avoid compound just like investments do. Next run: take the harder internship, counter the offer, go to one networking thing."
            case .vibe:   return "\(name), burnout is a financial disaster, not a personality flaw. Therapy, gym, friends, and time off aren't luxuries — they're protection. Build the rest of your life around the cost of *not* falling apart."
            case .future: return "\(name), future-you isn't abstract — she's the woman buying a house at 32, retiring at 60, or panicking at 45. Roth at 19, 401(k) match always, never cosign. The future is built on three or four boring decisions."
            }
        case .win:
            let sorted = SSStatKey.allCases.sorted { (state.stats[$0] ?? 0) > (state.stats[$1] ?? 0) }
            let best = sorted.first ?? .future
            let worst = sorted.last ?? .vibe
            let future = state.stats[.future] ?? 0
            let wallet = state.stats[.wallet] ?? 0
            let projection = Int(Double(future) * 10000 * (1 + Double(wallet) / 200))
            let fmt = NumberFormatter()
            fmt.numberStyle = .decimal
            let projStr = fmt.string(from: NSNumber(value: projection)) ?? "0"
            return "Strongest: *\(best.label)* at \(state.stats[best] ?? 0). Watch: *\(worst.label)* at \(state.stats[worst] ?? 0). If your *Future* stat were a 401(k) balance compounded 40 years at 7%, you'd retire with roughly *$\(projStr)*. \(name), the real game starts now — and you already know the rules."
        }
    }
}
