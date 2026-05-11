import SwiftUI

struct TraderResultView: View {
    let summary: RunSummary
    let onDone: () -> Void
    @EnvironmentObject var app: AppState

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxl)

                    Eyebrow(text: summary.beatBenchmark ? "You beat the market" : "Nice run")
                    Text(summary.beatBenchmark ? "Well played." : "Solid attempt.")
                        .font(Typo.display).foregroundStyle(Palette.ink)
                    Text(coachLine)
                        .font(Typo.body).foregroundStyle(Palette.inkSoft)

                    GlassCard {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            row(label: "Your portfolio",
                                value: summary.finalReturn.percent,
                                detail: summary.finalValue.currency,
                                tint: summary.finalReturn >= 0 ? Palette.success : Palette.roseDeep)
                            Divider()
                            row(label: "VTI buy & hold",
                                value: summary.vtiReturn.percent,
                                detail: nil,
                                tint: Palette.ink)
                            Divider()
                            row(label: "Best single (\(summary.bestSingleSymbol))",
                                value: summary.bestSingleReturn.percent,
                                detail: nil,
                                tint: Palette.lavenderDeep)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Eyebrow(text: "Diversification")
                            HStack {
                                Text("Assets touched").font(Typo.body).foregroundStyle(Palette.inkSoft)
                                Spacer()
                                Text("\(summary.assetsTouched.count)")
                                    .font(Typo.bodyBold).foregroundStyle(Palette.ink)
                            }
                            HStack {
                                Text("Max concentration").font(Typo.body).foregroundStyle(Palette.inkSoft)
                                Spacer()
                                Text(String(format: "%.0f%%", summary.maxConcentration * 100))
                                    .font(Typo.bodyBold).foregroundStyle(Palette.ink)
                            }
                            HStack {
                                Text("Max drawdown").font(Typo.body).foregroundStyle(Palette.inkSoft)
                                Spacer()
                                Text(String(format: "%.1f%%", summary.maxDrawdown * 100))
                                    .font(Typo.bodyBold).foregroundStyle(Palette.roseDeep)
                            }

                            if summary.diversifierBadge {
                                HStack(spacing: 6) {
                                    Text("✨").font(.system(size: 14))
                                    Text("Diversifier badge earned")
                                        .font(Typo.caption).foregroundStyle(Palette.lavenderDeep)
                                }.padding(.top, 4)
                            }
                        }
                    }

                    GradientButton(title: "Play again") {
                        if summary.beatBenchmark { app.addCoins(100); app.addXP(200) } else { app.addXP(50) }
                        if summary.diversifierBadge { app.addCoins(50) }
                        app.recordTradeBest(mode: summary.mode,
                                            finalReturn: summary.finalReturn,
                                            diversifier: summary.diversifierBadge)
                        onDone()
                    }
                    .padding(.top, Spacing.md)

                    Button("Back to minigames", action: onDone)
                        .font(Typo.caption)
                        .foregroundStyle(Palette.inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
    }

    private var coachLine: String {
        if summary.beatBenchmark && summary.diversifierBadge {
            return "Diversified across \(summary.assetsTouched.count) assets AND beat the market. That's the move."
        }
        if summary.beatBenchmark && summary.maxConcentration > 0.6 {
            return "You beat VTI by \(((summary.finalReturn - summary.vtiReturn) * 100).rounded(.toNearestOrEven).int)%, but you were \(Int(summary.maxConcentration*100))% in one name — that's a coin flip, not a strategy."
        }
        if summary.beatBenchmark {
            return "Nice work. You beat the market by \(((summary.finalReturn - summary.vtiReturn) * 100).rounded(.toNearestOrEven).int)%."
        }
        return "VTI did better this run. Try spreading bets next time — diversification cuts drawdown without giving up much upside."
    }

    private func row(label: String, value: String, detail: String?, tint: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(Typo.body).foregroundStyle(Palette.inkSoft)
                if let d = detail { Text(d).font(Typo.caption).foregroundStyle(Palette.inkMuted) }
            }
            Spacer()
            Text(value).font(Typo.h3).foregroundStyle(tint)
        }
    }
}

private extension Double {
    var int: Int { Int(self) }
}
