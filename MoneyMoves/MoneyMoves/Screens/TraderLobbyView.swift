import SwiftUI

struct TraderLobbyView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var startingBalance: Double = 10_000
    @State private var balanceText: String = "10000"
    @State private var activeMode: TradeMode? = nil

    private let presets: [Double] = [100, 1_000, 10_000, 100_000]

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 4) {
                                Text("←").font(.system(size: 18, weight: .semibold))
                                Text("Minigames").font(Typo.bodyBold)
                            }
                            .foregroundStyle(Palette.ink)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Capsule().fill(.ultraThinMaterial)
                                .overlay(Capsule().stroke(Palette.glassBorder, lineWidth: 1)))
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }

                    Eyebrow(text: "Paper trading")
                    Text("Time Travel\nTrader.")
                        .font(Typo.display)
                        .foregroundStyle(Palette.ink)
                    Text("Rewind real market history. Compress months into minutes. Try to beat the diversified baseline.")
                        .font(Typo.body)
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.sm)

                    balanceCard

                    VStack(spacing: Spacing.md) {
                        ForEach(TradeMode.allCases, id: \.self) { mode in
                            ModeCard(mode: mode, best: app.tradeBests[mode]) {
                                activeMode = mode
                            }
                        }
                    }

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xxxl)
            }
        }
        .fullScreenCover(item: Binding(get: { activeMode.map { ModeRef(mode: $0) } },
                                       set: { _ in activeMode = nil })) { ref in
            TraderGameView(mode: ref.mode, startingCash: startingBalance) {
                activeMode = nil
            }
        }
    }

    private var balanceCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Eyebrow(text: "Starting balance")
                HStack(spacing: Spacing.sm) {
                    Text(AppCurrency.current.currencySymbol).font(Typo.h1).foregroundStyle(Palette.ink)
                    TextField("10000", text: $balanceText)
                        .keyboardType(.numberPad)
                        .font(Typo.h1)
                        .foregroundStyle(Palette.ink)
                        .onChange(of: balanceText) { _, newValue in
                            if let n = Double(newValue.filter("0123456789".contains)) {
                                startingBalance = min(max(n, 1), 100_000_000)
                            }
                        }
                }

                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { v in
                        Button {
                            startingBalance = v
                            balanceText = String(Int(v))
                        } label: {
                            Text(formatPreset(v))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(startingBalance == v ? .white : Palette.ink)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(startingBalance == v ? Palette.lavenderDeep : Color.white.opacity(0.6))
                                        .overlay(Capsule().stroke(Palette.glassBorder, lineWidth: 1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func formatPreset(_ v: Double) -> String {
        let sym = AppCurrency.current.currencySymbol
        if v >= 1000 { return "\(sym)\(Int(v/1000))k" }
        return "\(sym)\(Int(v))"
    }
}

struct ModeRef: Identifiable { let id = UUID(); let mode: TradeMode }

struct ModeCard: View {
    let mode: TradeMode
    let best: AppState.TradeBest?
    let onTap: () -> Void

    var gradient: LinearGradient {
        switch mode {
        case .sprint:   return Gradients.peachCard
        case .standard: return Gradients.lavenderCard
        case .epic:     return Gradients.mintCard
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.lg) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(gradient)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Text(mode == .sprint ? "⏱" : (mode == .standard ? "📈" : "🌅"))
                            .font(.system(size: 32))
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: mode.totalTime, color: Palette.inkMuted)
                    Text(mode.title).font(Typo.h2).foregroundStyle(Palette.ink)
                    Text("\(mode.span) of real market history")
                        .font(Typo.body).foregroundStyle(Palette.inkSoft)
                    if let b = best {
                        Text("Best: \(b.finalReturn.percent)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Palette.success)
                            .padding(.top, 2)
                    } else {
                        Text("No personal best yet").font(Typo.caption).foregroundStyle(Palette.inkMuted)
                    }
                }
                Spacer()
                Text("→").font(.system(size: 22, weight: .bold)).foregroundStyle(Palette.ink)
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .stroke(Palette.glassBorder, lineWidth: 1))
            )
            .shadow(color: Palette.ink.opacity(0.08), radius: 24, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }
}

extension Double {
    var percent: String {
        let pct = self * 100
        return String(format: "%+.1f%%", pct)
    }
    var currency: String {
        let loc = AppCurrency.current
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.locale = Locale(identifier: loc.id)
        fmt.maximumFractionDigits = 0   // whole-dollar display, matches existing UX
        if let s = fmt.string(from: NSNumber(value: self)) { return s }
        return loc.currencySymbol + String(Int(self.rounded()))
    }
}

#Preview {
    TraderLobbyView().environmentObject(AppState())
}
