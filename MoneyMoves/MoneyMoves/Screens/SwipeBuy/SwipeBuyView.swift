import SwiftUI

// MARK: - Root view

struct SwipeBuyView: View {
    let onClose: () -> Void
    @StateObject private var state = SwipeBuyState()

    var body: some View {
        ZStack {
            SBBackground()

            switch state.screen {
            case .input: SBInputView(state: state, onClose: onClose)
            case .game:  SBGameView(state: state, onClose: onClose)
            }
        }
        .preferredColorScheme(.light)
        .overlay {
            if state.showSummary {
                SBSummaryOverlay(state: state, onClose: onClose)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - State

@MainActor
final class SwipeBuyState: ObservableObject {
    enum Screen: Equatable { case input, game }

    @Published var screen: Screen = .input
    @Published var initialBudget: Int = 2500
    @Published var remaining: Int = 2500
    @Published var queue: [SBPurchaseCard] = []
    @Published var purchased: [SBPurchaseCard] = []
    @Published var skipped: [SBPurchaseCard] = []
    @Published var swipedCount: Int = 0
    @Published var history: SBHistory? = nil
    @Published var showSummary: Bool = false

    init() {
        history = SBHistory.load()
    }

    var totalCards: Int { 10 }
    var roundSpent: Int { purchased.reduce(0) { $0 + $1.price } }
    var budgetLeft: Int { remaining - roundSpent }

    func startGame(keepPrevious: Bool) {
        if keepPrevious, let h = history {
            initialBudget = h.initialBudget
            remaining = h.remaining
        }
        // remaining is already set from the input view's text binding when !keepPrevious
        let shuffled = SB_DECK.shuffled().prefix(totalCards)
        queue = Array(shuffled)
        purchased = []
        skipped = []
        swipedCount = 0
        screen = .game
    }

    func swipe(buy: Bool) {
        guard let card = queue.first else { return }
        queue.removeFirst()
        if buy { purchased.append(card) } else { skipped.append(card) }
        swipedCount += 1
        if swipedCount >= totalCards {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.showSummary = true
                }
                self.persistHistory()
            }
        }
    }

    private func persistHistory() {
        let totalSpentAllRounds = (initialBudget - remaining) + roundSpent
        let finalRemaining = remaining - roundSpent
        let h = SBHistory(initialBudget: initialBudget, remaining: finalRemaining, spent: totalSpentAllRounds)
        h.save()
        history = h
    }

    func newGame() {
        SBHistory.clear()
        history = nil
        showSummary = false
        screen = .input
    }
    func continuePlaying() {
        guard let h = history else { return newGame() }
        initialBudget = h.initialBudget
        remaining = h.remaining
        showSummary = false
        startGame(keepPrevious: true)
    }

    // Coach feedback rules from the source HTML
    func feedback() -> String {
        let wants = purchased.filter { $0.type == .want }.count
        let allRoundNeeds = (purchased + skipped).filter { $0.type == .need }.count
        let boughtNeeds = purchased.filter { $0.type == .need }.count
        let skippedNeeds = max(0, allRoundNeeds - boughtNeeds)
        let finalRemaining = budgetLeft

        if finalRemaining < 0 { return "Budget bust! You're in debt. New Game recommended to reset your strategy." }
        if finalRemaining < 800 { return "Danger Zone! You've got very little left for essentials. Try to be stricter in the next round." }
        if skippedNeeds > 0 { return "Warning: You skipped essential needs to buy wants. That's a high-risk habit!" }
        if wants > 5 { return "Spending spree! You bought a lot of luxuries. Try to cut back on 'wants' next time." }
        return "Excellent control! You balanced your needs and kept a healthy cushion."
    }
}

// MARK: - Input screen

struct SBInputView: View {
    @ObservedObject var state: SwipeBuyState
    let onClose: () -> Void
    @State private var budgetText: String = "2500"
    @FocusState private var budgetFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Top: back button
            HStack {
                Button(action: onClose) {
                    Text("← Minigames")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(SBPalette.inkSoft)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().stroke(SBPalette.inkSoft.opacity(0.3), lineWidth: 1))
                }.buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 24).padding(.top, 12)

            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                Text("Financial Swipe")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(SBPalette.ink)
                    .padding(.bottom, 8)
                Text("Set your budget for this round.")
                    .font(.system(size: 15))
                    .foregroundColor(SBPalette.inkSoft)
                    .padding(.bottom, 24)

                if let h = state.history {
                    historyBox(h: h).padding(.bottom, 24)
                }

                budgetInput.padding(.bottom, 32)

                VStack(spacing: 12) {
                    Button {
                        let v = max(1, min(10_000, Int(budgetText) ?? 2500))
                        state.initialBudget = v
                        state.remaining = v
                        state.startGame(keepPrevious: false)
                    } label: {
                        Text("Start Simulation")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Capsule().fill(SBPalette.lavender))
                            .shadow(color: SBPalette.lavender.opacity(0.4), radius: 12, y: 4)
                    }.buttonStyle(.plain)

                    if state.history != nil {
                        Button {
                            state.continuePlaying()
                        } label: {
                            Text("Continue Last Budget")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(SBPalette.lavender)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .overlay(Capsule().stroke(SBPalette.lavender, lineWidth: 2))
                                )
                        }.buttonStyle(.plain)
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(SBPalette.glassBorder, lineWidth: 1)
                    )
            )
            .shadow(color: SBPalette.lavender.opacity(0.2), radius: 24, y: 12)
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func historyBox(h: SBHistory) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LAST SESSION")
                .font(.system(size: 12, weight: .bold))
                .tracking(1)
                .foregroundColor(SBPalette.lavender)
                .padding(.bottom, 4)
            historyRow(label: "Starting Budget:", value: "$\(h.initialBudget)")
            historyRow(label: "Total Spent:",     value: "$\(h.spent)")
            historyRow(label: "Remaining:",       value: "$\(h.remaining)")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(SBPalette.lavender, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                )
        )
    }
    private func historyRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(SBPalette.inkSoft)
            Spacer()
            Text(value).font(.system(size: 14, weight: .bold)).foregroundColor(SBPalette.ink)
        }
    }

    private var budgetInput: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 6) {
                Text("$")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(SBPalette.lavender)
                TextField("2500", text: $budgetText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundColor(SBPalette.ink)
                    .focused($budgetFocused)
                    .frame(maxWidth: 180)
                    .onChange(of: budgetText) { _, newValue in
                        // strip non-digits + clamp 0-10000
                        let digits = newValue.filter { $0.isNumber }
                        let n = min(10_000, Int(digits) ?? 0)
                        if digits != newValue || (n != Int(digits) && !digits.isEmpty) {
                            budgetText = n == 0 ? "" : String(n)
                        }
                    }
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(SBPalette.lavender).frame(height: 3).offset(y: 8)
            }
            Text("Maximum $10,000")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundColor(SBPalette.inkMuted)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Game screen

struct SBGameView: View {
    @ObservedObject var state: SwipeBuyState
    let onClose: () -> Void
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            // Side flashes (under everything)
            HStack(spacing: 0) {
                SBPalette.brightBlue
                    .opacity(min(1, max(0, -dragOffset.width / 150)) * 0.5)
                SBPalette.hotPink
                    .opacity(min(1, max(0, dragOffset.width / 150)) * 0.5)
            }
            .ignoresSafeArea()
            .animation(.easeOut(duration: 0.18), value: dragOffset)

            VStack(spacing: 0) {
                topBar
                statsHeader.padding(.horizontal, 24).padding(.bottom, 24)
                cardStack
                swipeHint.padding(.bottom, 20)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: onClose) {
                Text("Quit")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SBPalette.inkSoft)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().stroke(SBPalette.inkSoft.opacity(0.3), lineWidth: 1))
            }.buttonStyle(.plain)
            Spacer()
        }
        .padding(.horizontal, 24).padding(.top, 12)
    }

    private var statsHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("BUDGET LEFT")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundColor(SBPalette.inkMuted)
                Text("$\(state.budgetLeft)")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(state.budgetLeft < 0 ? SBPalette.hotPink : SBPalette.ink)
                    .contentTransition(.numericText())
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("PROGRESS")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundColor(SBPalette.inkMuted)
                Text("\(state.swipedCount)/\(state.totalCards)")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(SBPalette.ink)
                    .contentTransition(.numericText())
            }
        }
    }

    private var cardStack: some View {
        ZStack {
            // 2 behind cards
            ForEach(Array(state.queue.dropFirst().prefix(2).enumerated()), id: \.element.id) { idx, card in
                SBPurchaseCardView(card: card, dragOffset: .zero, showOverlay: false)
                    .scaleEffect(idx == 0 ? 0.96 : 0.92)
                    .offset(y: idx == 0 ? 8 : 16)
                    .opacity(idx == 0 ? 0.7 : 0.45)
                    .allowsHitTesting(false)
                    .zIndex(Double(-idx))
            }
            // Top card with drag
            if let top = state.queue.first {
                SBPurchaseCardView(card: top, dragOffset: dragOffset, showOverlay: true)
                    .offset(x: dragOffset.width, y: 0)
                    .rotationEffect(.degrees(Double(dragOffset.width) / 20))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = CGSize(width: value.translation.width, height: 0)
                            }
                            .onEnded { value in
                                let dx = value.translation.width
                                if dx < -120 {
                                    flyOff(buy: true)
                                } else if dx > 120 {
                                    flyOff(buy: false)
                                } else {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    .zIndex(10)
                    .transition(.identity)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: 420)
    }

    private func flyOff(buy: Bool) {
        let dir: CGFloat = buy ? -1 : 1
        withAnimation(.easeIn(duration: 0.3)) {
            dragOffset = CGSize(width: dir * 600, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            state.swipe(buy: buy)
            dragOffset = .zero
        }
    }

    private var swipeHint: some View {
        Text("← swipe LEFT to BUY · swipe RIGHT to SKIP →")
            .font(.system(size: 12, weight: .heavy))
            .tracking(1)
            .foregroundColor(SBPalette.ink.opacity(0.7))
    }
}

// MARK: - Card view

struct SBPurchaseCardView: View {
    let card: SBPurchaseCard
    var dragOffset: CGSize
    var showOverlay: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(SBPalette.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(SBPalette.palePink, lineWidth: 1)
                )

            VStack(spacing: 16) {
                Text(card.emoji)
                    .font(.system(size: 84))
                    .shadow(color: SBPalette.lavender.opacity(0.3), radius: 8, y: 4)
                Text(card.title)
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(SBPalette.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                Text("$\(card.price)")
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundColor(SBPalette.lavender)
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 380)
        .shadow(color: SBPalette.lavender.opacity(0.25), radius: 24, y: 12)
        .overlay(alignment: .top) {
            if showOverlay {
                HStack {
                    overlayLabel("BUY", color: SBPalette.brightBlue, rotation: -15)
                        .opacity(min(1, max(0, -dragOffset.width / 150)))
                    Spacer()
                    overlayLabel("SKIP", color: SBPalette.hotPink, rotation: 15)
                        .opacity(min(1, max(0, dragOffset.width / 150)))
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
    }

    private func overlayLabel(_ text: String, color: Color, rotation: Double) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .black))
            .foregroundColor(color)
            .padding(.horizontal, 20).padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(color, lineWidth: 3)
            )
            .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Summary overlay

struct SBSummaryOverlay: View {
    @ObservedObject var state: SwipeBuyState
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color(white: 0.18).opacity(0.6).ignoresSafeArea()
                .background(.ultraThinMaterial)

            ScrollView {
                VStack(spacing: 0) {
                    Text("Round Complete!")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(SBPalette.ink)
                        .padding(.bottom, 28)

                    summaryRows.padding(.bottom, 24)

                    feedbackCard.padding(.bottom, 28)

                    VStack(spacing: 12) {
                        Button {
                            state.newGame()
                        } label: {
                            Text("New Game (Fresh Start)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 18)
                                .background(Capsule().fill(SBPalette.lavender))
                        }.buttonStyle(.plain)

                        Button {
                            state.continuePlaying()
                        } label: {
                            Text("Keep Playing")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(SBPalette.lavender)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .overlay(Capsule().stroke(SBPalette.lavender, lineWidth: 2))
                                )
                        }.buttonStyle(.plain)

                        Button {
                            onClose()
                        } label: {
                            Text("Back to minigames")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(SBPalette.inkMuted)
                                .padding(.top, 4)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(36)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(SBPalette.lavender, lineWidth: 2)
                        )
                )
                .frame(maxWidth: 360)
                .padding(24)
            }
        }
    }

    private var summaryRows: some View {
        let wants = state.purchased.filter { $0.type == .want }.count
        let needs = state.purchased.filter { $0.type == .need }.count
        let roundSpent = state.roundSpent
        let finalRemaining = state.budgetLeft
        return VStack(spacing: 10) {
            row("Round Items:",  "\(state.purchased.count) bought")
            row("Wants:",        "\(wants)   |   Needs: \(needs)")
            Rectangle().fill(SBPalette.skyBlue.opacity(0.3))
                .frame(height: 2).padding(.vertical, 8)
            row("Total Spent:",  "$\(roundSpent)")
            row("Budget Left:",  "$\(finalRemaining)",
                valueColor: finalRemaining < 800 ? SBPalette.hotPink : SBPalette.ink)
        }
    }

    private func row(_ label: String, _ value: String, valueColor: Color = SBPalette.ink) -> some View {
        HStack {
            Text(label).font(.system(size: 17)).foregroundColor(SBPalette.inkSoft)
            Spacer()
            Text(value).font(.system(size: 17, weight: .heavy)).foregroundColor(valueColor)
        }
    }

    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("COACH INSIGHTS")
                .font(.system(size: 14, weight: .heavy))
                .tracking(1.5)
                .foregroundColor(SBPalette.lavender)
            Text(state.feedback())
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(SBPalette.ink)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(SBPalette.skyBlue)
                .overlay(alignment: .leading) {
                    Rectangle().fill(SBPalette.lavender).frame(width: 5)
                }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
