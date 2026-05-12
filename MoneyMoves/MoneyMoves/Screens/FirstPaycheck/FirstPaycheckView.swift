import SwiftUI

// MARK: - Root view + state

struct FirstPaycheckView: View {
    let onClose: () -> Void
    @StateObject private var state = FPGameState()

    var body: some View {
        ZStack(alignment: .top) {
            FPBackground()

            VStack(spacing: 0) {
                topBar
                Group {
                    switch state.phase {
                    case .offer:        FPOfferScreen(state: state)
                    case .negotiation:  FPNegotiationScreen(state: state)
                    case .breakdown:    FPBreakdownScreen(state: state)
                    case .budget:       FPBudgetScreen(state: state)
                    case .complete:     FPCompleteScreen(state: state, onClose: onClose)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(.light)
    }

    private var topBar: some View {
        HStack {
            Button(action: onClose) {
                Text("✕ Quit")
                    .font(FPFont.sans(12, weight: .semibold))
                    .foregroundStyle(FPPalette.inkMuted)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().stroke(FPPalette.inkMuted.opacity(0.3), lineWidth: 1))
            }.buttonStyle(.plain)
            Spacer()
            Text("FIRST PAYCHECK SHOCK")
                .font(FPFont.mono(10, weight: .bold))
                .tracking(2)
                .foregroundStyle(FPPalette.inkMuted)
            Spacer()
            Text("\(state.stepIndex)/5")
                .font(FPFont.mono(10, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(FPPalette.inkMuted)
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 10)
    }
}

@MainActor
final class FPGameState: ObservableObject {
    enum Phase: Equatable { case offer, negotiation, breakdown, budget, complete }
    @Published var phase: Phase = .offer

    let baseSalary: Int = 52_000
    @Published var finalSalary: Int = 52_000
    @Published var negotiationChoice: String = ""
    @Published var negotiationNarrative: String = ""

    // Withholding settings
    @Published var contribute401k: Double = 0.06   // 6% default
    @Published var didReveal: Bool = false

    // Budget allocations (percent of net, sum should ~= 1)
    @Published var pctRent: Double      = 0.32
    @Published var pctFood: Double      = 0.14
    @Published var pctTransport: Double = 0.10
    @Published var pctSave: Double      = 0.18
    @Published var pctFun: Double       = 0.14
    @Published var pctMisc: Double      = 0.12

    var stepIndex: Int {
        switch phase {
        case .offer: return 1
        case .negotiation: return 2
        case .breakdown: return 3
        case .budget: return 4
        case .complete: return 5
        }
    }

    // MARK: - Salary math

    var grossMonthly: Double { Double(finalSalary) / 12 }
    var contribution401kMonthly: Double { grossMonthly * contribute401k }
    var taxableMonthly: Double { grossMonthly - contribution401kMonthly }
    var federalTax: Double {
        // Simplified marginal-ish — flat 12% on first 47K, 22% above
        let yearlyTaxable = taxableMonthly * 12
        let firstBracket = min(yearlyTaxable, 47_000)
        let secondBracket = max(0, yearlyTaxable - 47_000)
        return (firstBracket * 0.12 + secondBracket * 0.22) / 12
    }
    var stateTax: Double { taxableMonthly * 0.05 }
    var fica: Double { taxableMonthly * 0.0765 }
    var healthInsurance: Double { 150 }
    var netMonthly: Double {
        max(0, grossMonthly - contribution401kMonthly - federalTax - stateTax - fica - healthInsurance)
    }
    var takeHomePct: Double { grossMonthly > 0 ? netMonthly / grossMonthly : 0 }

    var pctTotal: Double {
        pctRent + pctFood + pctTransport + pctSave + pctFun + pctMisc
    }
    var budgetGrade: (letter: String, notes: [String]) {
        var notes: [String] = []
        var score = 0

        let rentDollars = pctRent * netMonthly
        if pctRent <= 0.30 { score += 2; notes.append("Rent at \(Int(pctRent*100))% — under the 30% rule ✓") }
        else if pctRent <= 0.35 { score += 1; notes.append("Rent at \(Int(pctRent*100))% — borderline, watch lifestyle creep") }
        else { notes.append("Rent at \(Int(pctRent*100))% (\(rentDollars.fpCurrency)) — too heavy, you'll feel squeezed") }

        if pctSave >= 0.20 { score += 2; notes.append("Saving \(Int(pctSave*100))% — that's the move ✓") }
        else if pctSave >= 0.10 { score += 1; notes.append("Saving \(Int(pctSave*100))% — fine to start, climb toward 20%") }
        else { notes.append("Saving only \(Int(pctSave*100))% — your future self is texting you") }

        if abs(pctTotal - 1.0) < 0.05 { score += 1; notes.append("Total close to 100% ✓") }
        else if pctTotal > 1.05 { notes.append("You allocated \(Int(pctTotal*100))% — over budget") }
        else { notes.append("Only \(Int(pctTotal*100))% allocated — where's the rest going?") }

        if negotiationChoice != "" && finalSalary > baseSalary { score += 1; notes.append("Negotiated up to \(finalSalary.fpDollars) ✓") }

        let letter: String
        switch score {
        case 5...: letter = "A"
        case 4: letter = "B"
        case 3: letter = "C"
        default: letter = "D"
        }
        return (letter, notes)
    }

    func chooseNegotiation(_ choice: NegotiationOption) {
        switch choice {
        case .accept:
            finalSalary = baseSalary
            negotiationChoice = "accept"
            negotiationNarrative = "You accepted as-is. Comfortable, but your first salary anchors every raise after — it leaves money on the table over a career."
        case .politeCounter:
            finalSalary = 57_000
            negotiationChoice = "polite"
            negotiationNarrative = "They came back with $57K. Polite counters succeed most of the time — your salary just compounds 10% higher forever."
        case .boldCounter:
            finalSalary = 61_000
            negotiationChoice = "bold"
            negotiationNarrative = "Bold ask. They held firm at $61K, but you got it. Bigger swings work when you have leverage (other offers, niche skills)."
        }
        advance(to: .breakdown)
    }

    func advance(to phase: Phase) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            self.phase = phase
        }
    }
}

enum NegotiationOption { case accept, politeCounter, boldCounter }

// MARK: - Screen 1: Offer letter

struct FPOfferScreen: View {
    @ObservedObject var state: FPGameState

    var body: some View {
        ZStack {
            FPConfetti().padding(.top, -20)
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 10)

                    Text("CONGRATULATIONS")
                        .font(FPFont.mono(11, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(FPPalette.coral)

                    Text("You got the\noffer.")
                        .font(FPFont.serif(54, weight: .bold))
                        .foregroundStyle(FPPalette.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-6)

                    offerCard

                    Button {
                        state.advance(to: .negotiation)
                    } label: {
                        Text("Read more →")
                            .font(FPFont.sans(15, weight: .bold))
                            .foregroundStyle(FPPalette.cream)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Capsule().fill(FPPalette.ink))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var offerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("NovaCo")
                    .font(FPFont.serif(22, weight: .bold)).foregroundStyle(FPPalette.ink)
                Spacer()
                Text("OFFER")
                    .font(FPFont.mono(9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(FPPalette.coral)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(FPPalette.coralSoft))
            }
            Divider().background(FPPalette.inkMuted.opacity(0.3))

            row(label: "ROLE", value: "Junior Marketing Manager")
            row(label: "TEAM", value: "Growth")
            row(label: "START", value: "Mon, July 15")
            row(label: "SALARY", value: "$52,000 / year", highlight: true)
            row(label: "BENEFITS", value: "Health, 401(k) match (up to 6%)")

            Text("\"Dear Akash — we're thrilled to invite you to join NovaCo. We were genuinely impressed by your case study and your energy in the final round. Welcome to the team.\"")
                .font(FPFont.serif(14, weight: .regular).italic())
                .foregroundStyle(FPPalette.inkSoft)
                .padding(.top, 6)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(FPPalette.paper)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(FPPalette.gold.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: FPPalette.ink.opacity(0.12), radius: 24, x: 0, y: 12)
    }

    private func row(label: String, value: String, highlight: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).font(FPFont.mono(9, weight: .bold)).tracking(1.5)
                .foregroundStyle(FPPalette.inkMuted)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(highlight ? FPFont.serif(20, weight: .bold) : FPFont.sans(14, weight: .medium))
                .foregroundStyle(highlight ? FPPalette.coral : FPPalette.ink)
            Spacer()
        }
    }
}

// MARK: - Screen 2: Negotiation

struct FPNegotiationScreen: View {
    @ObservedObject var state: FPGameState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("MARKET CHECK")
                    .font(FPFont.mono(11, weight: .bold)).tracking(3)
                    .foregroundStyle(FPPalette.teal)
                Text("Want to\ncounter?")
                    .font(FPFont.serif(48, weight: .bold)).foregroundStyle(FPPalette.ink)
                    .lineSpacing(-4)
                Text("You looked it up: similar roles pay **$55K–$62K** in your city. The offer is $52K. What do you do?")
                    .font(FPFont.sans(15)).foregroundStyle(FPPalette.inkSoft)

                marketBarChart.padding(.vertical, 8)

                VStack(spacing: 10) {
                    optionCard(
                        tag: "SAFE",
                        title: "Accept the $52K offer",
                        subtitle: "No risk. Lowest growth.",
                        salary: 52_000,
                        tint: FPPalette.inkMuted
                    ) { state.chooseNegotiation(.accept) }

                    optionCard(
                        tag: "RECOMMENDED",
                        title: "Counter politely at $58K",
                        subtitle: "\"Based on market data for the role, I'd be more comfortable at $58K.\"",
                        salary: 57_000,
                        tint: FPPalette.teal
                    ) { state.chooseNegotiation(.politeCounter) }

                    optionCard(
                        tag: "BOLD",
                        title: "Counter aggressively at $65K",
                        subtitle: "Big swing — usually meets in the middle.",
                        salary: 61_000,
                        tint: FPPalette.coral
                    ) { state.chooseNegotiation(.boldCounter) }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24).padding(.top, 6)
        }
    }

    private var marketBarChart: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(FPPalette.inkMuted.opacity(0.15))
                    // Market range bar (55-62 → 0.55-0.78 of a 0-80K axis for visual)
                    let axisMax: CGFloat = 80_000
                    let lo = CGFloat(55_000) / axisMax
                    let hi = CGFloat(62_000) / axisMax
                    Capsule().fill(FPPalette.tealSoft)
                        .frame(width: geo.size.width * (hi - lo))
                        .offset(x: geo.size.width * lo)
                    // Offer pin
                    let offerPos = CGFloat(52_000) / axisMax
                    Circle().fill(FPPalette.coral)
                        .frame(width: 12, height: 12)
                        .offset(x: geo.size.width * offerPos - 6, y: 0)
                }
            }.frame(height: 14)
            HStack {
                Text("$0").font(FPFont.mono(9)).foregroundStyle(FPPalette.inkMuted)
                Spacer()
                Text("Offer $52K").font(FPFont.mono(9, weight: .bold)).foregroundStyle(FPPalette.coral)
                Spacer()
                Text("Market $55-62K").font(FPFont.mono(9, weight: .bold)).foregroundStyle(FPPalette.teal)
                Spacer()
                Text("$80K").font(FPFont.mono(9)).foregroundStyle(FPPalette.inkMuted)
            }
        }
    }

    private func optionCard(tag: String, title: String, subtitle: String,
                            salary: Int, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(tag).font(FPFont.mono(9, weight: .bold)).tracking(2)
                        .foregroundStyle(tint)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Capsule().fill(tint.opacity(0.12)))
                    Spacer()
                    Text("→\(salary.fpDollars)")
                        .font(FPFont.serif(18, weight: .bold))
                        .foregroundStyle(FPPalette.ink)
                }
                Text(title).font(FPFont.sans(15, weight: .bold)).foregroundStyle(FPPalette.ink)
                Text(subtitle).font(FPFont.sans(13)).foregroundStyle(FPPalette.inkSoft)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(FPPalette.paper)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(tint.opacity(0.4), lineWidth: 1)
                    )
            )
            .shadow(color: FPPalette.ink.opacity(0.08), radius: 12, x: 0, y: 6)
        }.buttonStyle(.plain)
    }
}

// MARK: - Screen 3: Paycheck Shock

struct FPBreakdownScreen: View {
    @ObservedObject var state: FPGameState
    @State private var revealedSteps: Int = 0

    private var steps: [(label: String, amount: Double, color: Color)] {
        [
            ("401(k) contribution (\(Int(state.contribute401k * 100))%)", state.contribution401kMonthly, FPPalette.teal),
            ("Federal income tax", state.federalTax, FPPalette.coral),
            ("State income tax", state.stateTax, FPPalette.coral),
            ("FICA (Social Security + Medicare)", state.fica, FPPalette.coral),
            ("Health insurance", state.healthInsurance, FPPalette.coral),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("YOUR FIRST PAYCHECK")
                    .font(FPFont.mono(11, weight: .bold)).tracking(3)
                    .foregroundStyle(FPPalette.coral)
                Text("Gross monthly")
                    .font(FPFont.sans(13)).foregroundStyle(FPPalette.inkSoft)
                Text(state.grossMonthly.fpCurrency)
                    .font(FPFont.serif(54, weight: .bold)).foregroundStyle(FPPalette.ink)
                Text(state.negotiationNarrative)
                    .font(FPFont.serif(14, weight: .regular).italic())
                    .foregroundStyle(FPPalette.inkSoft)

                contributionSlider

                VStack(spacing: 0) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        let item = steps[i]
                        deductionRow(label: item.label, amount: item.amount, color: item.color,
                                     visible: revealedSteps > i)
                        if i < steps.count - 1 {
                            Divider().background(FPPalette.inkMuted.opacity(0.2))
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(FPPalette.paper)
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(FPPalette.inkMuted.opacity(0.2), lineWidth: 1))
                )
                .padding(.top, 4)

                if revealedSteps >= steps.count {
                    netRevealCard.transition(.scale.combined(with: .opacity))
                }

                Spacer().frame(height: 8)

                if revealedSteps < steps.count {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            revealedSteps += 1
                        }
                    } label: {
                        Text(revealedSteps == 0 ? "Reveal deductions  →" : "Next  →")
                            .font(FPFont.sans(15, weight: .bold)).foregroundStyle(FPPalette.cream)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Capsule().fill(FPPalette.ink))
                    }.buttonStyle(.plain)
                } else {
                    Button {
                        state.didReveal = true
                        state.advance(to: .budget)
                    } label: {
                        Text("Now budget it  →")
                            .font(FPFont.sans(15, weight: .bold)).foregroundStyle(FPPalette.cream)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Capsule().fill(FPPalette.coral))
                    }.buttonStyle(.plain)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24).padding(.top, 6)
        }
    }

    private var contributionSlider: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("401(K) CONTRIBUTION").font(FPFont.mono(10, weight: .bold)).tracking(2)
                    .foregroundStyle(FPPalette.teal)
                Spacer()
                Text("\(Int(state.contribute401k * 100))%")
                    .font(FPFont.serif(18, weight: .bold)).foregroundStyle(FPPalette.ink)
            }
            Slider(value: $state.contribute401k, in: 0...0.15, step: 0.01)
                .tint(FPPalette.teal)
            Text("NovaCo matches up to 6%. Below 6% = you're declining a raise.")
                .font(FPFont.sans(11)).foregroundStyle(FPPalette.inkMuted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(FPPalette.tealSoft.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(FPPalette.teal.opacity(0.4), lineWidth: 1))
        )
    }

    private func deductionRow(label: String, amount: Double, color: Color, visible: Bool) -> some View {
        HStack {
            Text(label).font(FPFont.sans(13, weight: .medium)).foregroundStyle(FPPalette.ink)
            Spacer()
            Text(visible ? "−\(amount.fpCurrency)" : "—")
                .font(FPFont.mono(14, weight: .bold))
                .foregroundStyle(visible ? color : FPPalette.inkMuted.opacity(0.4))
        }
        .padding(.vertical, 10)
        .opacity(visible ? 1 : 0.55)
    }

    private var netRevealCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("YOU TAKE HOME")
                .font(FPFont.mono(10, weight: .bold)).tracking(2)
                .foregroundStyle(FPPalette.teal)
            Text(state.netMonthly.fpCurrency)
                .font(FPFont.serif(48, weight: .bold)).foregroundStyle(FPPalette.teal)
                .contentTransition(.numericText())
            let dropPct = Int((1 - state.takeHomePct) * 100)
            Text("That's **\(dropPct)% less** than the gross. Welcome to paycheck shock.")
                .font(FPFont.serif(14, weight: .regular).italic())
                .foregroundStyle(FPPalette.inkSoft)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(FPPalette.tealSoft)
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(FPPalette.teal, lineWidth: 2))
        )
        .padding(.top, 8)
    }
}

// MARK: - Screen 4: Budget split

struct FPBudgetScreen: View {
    @ObservedObject var state: FPGameState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("MONTHLY BUDGET")
                    .font(FPFont.mono(11, weight: .bold)).tracking(3)
                    .foregroundStyle(FPPalette.coral)
                Text("Split your\n\(state.netMonthly.fpCurrency).")
                    .font(FPFont.serif(48, weight: .bold)).foregroundStyle(FPPalette.ink)
                    .lineSpacing(-4)
                Text("Sliders move the slice. Try to land at 100% with at least 20% to save+invest.")
                    .font(FPFont.sans(14)).foregroundStyle(FPPalette.inkSoft)

                pieView.padding(.vertical, 8)

                VStack(spacing: 10) {
                    sliderRow(emoji: "🏠", label: "Rent",      pct: $state.pctRent,      tint: FPPalette.coral)
                    sliderRow(emoji: "🛒", label: "Food",      pct: $state.pctFood,      tint: FPPalette.gold)
                    sliderRow(emoji: "🚌", label: "Transport", pct: $state.pctTransport, tint: FPPalette.inkMuted)
                    sliderRow(emoji: "🐷", label: "Save+Invest", pct: $state.pctSave,    tint: FPPalette.teal)
                    sliderRow(emoji: "🎟️", label: "Fun",       pct: $state.pctFun,       tint: FPPalette.coral.opacity(0.7))
                    sliderRow(emoji: "✨", label: "Misc",      pct: $state.pctMisc,      tint: FPPalette.gold.opacity(0.7))
                }

                totalBar.padding(.top, 8)

                Button {
                    state.advance(to: .complete)
                } label: {
                    Text("See how you did  →")
                        .font(FPFont.sans(15, weight: .bold)).foregroundStyle(FPPalette.cream)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Capsule().fill(FPPalette.ink))
                }.buttonStyle(.plain)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24).padding(.top, 6)
        }
    }

    private var pieView: some View {
        let slices: [(Double, Color)] = [
            (state.pctRent,      FPPalette.coral),
            (state.pctFood,      FPPalette.gold),
            (state.pctTransport, FPPalette.inkMuted),
            (state.pctSave,      FPPalette.teal),
            (state.pctFun,       FPPalette.coral.opacity(0.7)),
            (state.pctMisc,      FPPalette.gold.opacity(0.7)),
        ]
        let total = max(0.001, slices.reduce(0) { $0 + $1.0 })
        return ZStack {
            ForEach(0..<slices.count, id: \.self) { i in
                let preceding = slices[0..<i].reduce(0) { $0 + $1.0 }
                let start = preceding / total
                let end = (preceding + slices[i].0) / total
                PieSlice(start: start, end: end)
                    .fill(slices[i].1)
            }
            Circle().fill(FPPalette.cream).frame(width: 110, height: 110)
            VStack(spacing: 0) {
                Text("\(Int(state.pctTotal * 100))%")
                    .font(FPFont.serif(28, weight: .bold))
                    .foregroundStyle(state.pctTotal > 1.0 ? FPPalette.coral : FPPalette.ink)
                Text("allocated")
                    .font(FPFont.mono(9, weight: .semibold)).tracking(1.2)
                    .foregroundStyle(FPPalette.inkMuted)
            }
        }
        .frame(width: 200, height: 200)
        .frame(maxWidth: .infinity)
    }

    private func sliderRow(emoji: String, label: String, pct: Binding<Double>, tint: Color) -> some View {
        HStack(spacing: 12) {
            Text(emoji).font(.system(size: 22)).frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(label).font(FPFont.sans(13, weight: .semibold)).foregroundStyle(FPPalette.ink)
                    Spacer()
                    Text("\(Int(pct.wrappedValue * 100))%  ·  \((pct.wrappedValue * state.netMonthly).fpCurrency)")
                        .font(FPFont.mono(11, weight: .semibold)).foregroundStyle(FPPalette.inkSoft)
                }
                Slider(value: pct, in: 0...0.6, step: 0.01).tint(tint)
            }
        }
    }

    private var totalBar: some View {
        let over = state.pctTotal > 1.05
        let under = state.pctTotal < 0.95
        return HStack {
            Image(systemName: over ? "exclamationmark.circle.fill" :
                              under ? "info.circle.fill" : "checkmark.circle.fill")
                .foregroundStyle(over ? FPPalette.danger : under ? FPPalette.gold : FPPalette.teal)
            Text(over   ? "Over by \(Int((state.pctTotal - 1) * 100))% — trim something."
                : under ? "\(Int((1 - state.pctTotal) * 100))% unallocated — where does it go?"
                       : "Total close to 100% — looks great.")
                .font(FPFont.sans(12, weight: .semibold)).foregroundStyle(FPPalette.ink)
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(FPPalette.paper)
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(FPPalette.inkMuted.opacity(0.25), lineWidth: 1))
        )
    }
}

// MARK: - Screen 5: Complete

struct FPCompleteScreen: View {
    @ObservedObject var state: FPGameState
    let onClose: () -> Void

    var body: some View {
        ZStack {
            FPConfetti(count: 50).padding(.top, -20)
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 10)
                    Text("YOU'RE READY")
                        .font(FPFont.mono(11, weight: .bold)).tracking(3)
                        .foregroundStyle(FPPalette.coral)
                    Text("Grade: \(state.budgetGrade.letter)")
                        .font(FPFont.serif(64, weight: .bold))
                        .foregroundStyle(FPPalette.ink)

                    summaryCard

                    notesCard

                    VStack(spacing: 10) {
                        Button {
                            state.advance(to: .offer)
                        } label: {
                            Text("Play again").font(FPFont.sans(15, weight: .bold))
                                .foregroundStyle(FPPalette.cream)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(FPPalette.ink))
                        }.buttonStyle(.plain)

                        Button(action: onClose) {
                            Text("Done").font(FPFont.sans(14, weight: .semibold))
                                .foregroundStyle(FPPalette.ink)
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .background(Capsule().stroke(FPPalette.ink, lineWidth: 1))
                        }.buttonStyle(.plain)
                    }
                    .padding(.top, 6)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            row(label: "Final salary",    value: state.finalSalary.fpDollars)
            row(label: "Gross / month",   value: state.grossMonthly.fpCurrency)
            row(label: "Net take-home",   value: state.netMonthly.fpCurrency, accent: true)
            row(label: "Saving rate",     value: "\(Int(state.pctSave * 100))% of net")
            row(label: "Rent rate",       value: "\(Int(state.pctRent * 100))% of net")
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(FPPalette.paper)
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(FPPalette.gold.opacity(0.4), lineWidth: 1))
        )
    }

    private func row(label: String, value: String, accent: Bool = false) -> some View {
        HStack {
            Text(label).font(FPFont.sans(13)).foregroundStyle(FPPalette.inkSoft)
            Spacer()
            Text(value).font(accent ? FPFont.serif(20, weight: .bold) : FPFont.sans(14, weight: .bold))
                .foregroundStyle(accent ? FPPalette.coral : FPPalette.ink)
        }
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coach notes").font(FPFont.mono(10, weight: .bold)).tracking(2)
                .foregroundStyle(FPPalette.teal)
            ForEach(state.budgetGrade.notes, id: \.self) { note in
                HStack(alignment: .top, spacing: 8) {
                    Text("·").font(FPFont.serif(18, weight: .bold)).foregroundStyle(FPPalette.coral)
                    Text(note).font(FPFont.sans(13)).foregroundStyle(FPPalette.ink)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(FPPalette.tealSoft.opacity(0.5))
        )
    }
}

// MARK: - Pie slice + helpers

struct PieSlice: Shape {
    let start: Double  // 0...1
    let end: Double
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startAngle = Angle.degrees(start * 360 - 90)
        let endAngle = Angle.degrees(end * 360 - 90)
        p.move(to: center)
        p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        p.closeSubpath()
        return p
    }
}

private extension Double {
    var fpCurrency: String {
        let n = Int(self.rounded())
        let s = String(n)
        var out = ""
        for (i, ch) in s.reversed().enumerated() {
            if i > 0 && i % 3 == 0 { out.append(",") }
            out.append(ch)
        }
        return "$" + String(out.reversed())
    }
}

private extension Int {
    var fpDollars: String {
        let s = String(self)
        var out = ""
        for (i, ch) in s.reversed().enumerated() {
            if i > 0 && i % 3 == 0 { out.append(",") }
            out.append(ch)
        }
        return "$" + String(out.reversed())
    }
}
