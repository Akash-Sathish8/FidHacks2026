import SwiftUI

struct MoneyView: View {
    @EnvironmentObject var app: AppState
    @State private var showFutureSelf: Bool = false
    @State private var showGoals: Bool = false
    @State private var showBankConnect: Bool = false

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Money")
                    Text("Money.").font(Typo.display).foregroundStyle(Palette.ink)
                    Text("Track goals, watch names, project your future self.")
                        .font(Typo.body).foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.sm)

                    bankCard
                    goalsCard
                    futureSelfCard

                    Text("Watchlist").font(Typo.h2).foregroundStyle(Palette.ink)
                        .padding(.top, Spacing.md)

                    VStack(spacing: Spacing.sm) {
                        ForEach(WATCHLIST) { asset in
                            WatchlistRow(asset: asset)
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, Spacing.xl)
            }
        }
        .sheet(isPresented: $showFutureSelf) {
            FutureSelfView(onClose: { showFutureSelf = false })
        }
        .fullScreenCover(isPresented: $showGoals) {
            GoalsView { showGoals = false }
                .environmentObject(app)
        }
        .sheet(isPresented: $showBankConnect) {
            BankConnectView { showBankConnect = false }
                .environmentObject(app)
        }
    }

    @ViewBuilder
    private var bankCard: some View {
        if let bank = app.user.connectedBank {
            // Connected state
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle().fill(Palette.success.opacity(0.18)).frame(width: 44, height: 44)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Palette.success)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(bank) connected").font(Typo.bodyBold).foregroundStyle(Palette.ink)
                    Text("Syncing transactions in the background")
                        .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                }
                Spacer()
                Button { app.disconnectBank() } label: {
                    Text("Disconnect")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.roseDeep)
                }.buttonStyle(.plain)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .stroke(Palette.success.opacity(0.3), lineWidth: 1))
            )
        } else {
            // Not connected state — entry point
            Button { showBankConnect = true } label: {
                HStack(spacing: Spacing.md) {
                    ZStack {
                        Circle().fill(Palette.lavenderSoft).frame(width: 44, height: 44)
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Palette.lavenderDeep)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Connect your bank")
                            .font(Typo.bodyBold).foregroundStyle(Palette.ink)
                        Text("Auto-import transactions into your categories")
                            .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                    }
                    Spacer()
                    Text("→").font(.system(size: 20, weight: .bold)).foregroundStyle(Palette.ink)
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .stroke(Palette.glassBorder, lineWidth: 1))
                )
            }.buttonStyle(.plain)
        }
    }

    private var goalsCard: some View {
        let active = app.activeGoal
        let savedThisMonth = app.categories.reduce(0) { $0 + $1.saved }
        return Button { showGoals = true } label: {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.md) {
                    Text(active?.emoji ?? "🎯").font(.system(size: 36))
                    VStack(alignment: .leading, spacing: 2) {
                        Eyebrow(text: "Saving for")
                        Text(active?.name ?? "Set a goal")
                            .font(Typo.h3).foregroundStyle(Palette.ink)
                        if let g = active {
                            Text("\(g.percent)% there  ·  \(g.remaining.currency) to go")
                                .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                            if g.monthlyTarget > 0 {
                                Text("\(g.monthlyTarget.currency)/mo · \(g.paceLabel)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Palette.lavenderDeep)
                            }
                        }
                    }
                    Spacer()
                    Text("→").font(.system(size: 20, weight: .bold)).foregroundStyle(Palette.ink)
                }
                if let g = active {
                    ProgressBar(value: g.fraction).frame(height: 10)
                }
                if savedThisMonth > 0 {
                    Text("+\(savedThisMonth.currency) cushion this month — tap to apply")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Palette.success)
                        .padding(.top, 4)
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .stroke(Palette.glassBorder, lineWidth: 1))
            )
            .shadow(color: Palette.lavenderDeep.opacity(0.2), radius: 28, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }

    private var futureSelfCard: some View {
        Button { showFutureSelf = true } label: {
            HStack(spacing: Spacing.lg) {
                ZStack {
                    Circle().fill(Gradients.hero).frame(width: 64, height: 64)
                    Text("✦").font(.system(size: 32)).foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Eyebrow(text: "Compound interest")
                    Text("Meet your future self.")
                        .font(Typo.h3).foregroundStyle(Palette.ink)
                    Text("See what $50/mo at 22 becomes at 65.")
                        .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                }
                Spacer()
                Text("→").font(.system(size: 20, weight: .bold)).foregroundStyle(Palette.ink)
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .stroke(Palette.glassBorder, lineWidth: 1))
            )
            .shadow(color: Palette.lavenderDeep.opacity(0.2), radius: 28, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }
}

struct WatchlistRow: View {
    let asset: WatchAsset

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.id).font(Typo.bodyBold).foregroundStyle(Palette.ink)
                Text(asset.name).font(Typo.caption).foregroundStyle(Palette.inkMuted)
            }
            Spacer()
            MiniSparkline(values: asset.series).frame(width: 70, height: 28)
            VStack(alignment: .trailing, spacing: 2) {
                Text(asset.price.currency).font(Typo.bodyBold).foregroundStyle(Palette.ink)
                Text(asset.change.percent)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(asset.change >= 0 ? Palette.success : Palette.roseDeep)
            }.frame(width: 90, alignment: .trailing)
        }
        .padding(.horizontal, Spacing.md).padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(Palette.glassBorder, lineWidth: 1))
        )
    }
}

// MARK: - Future Self compound interest view

struct FutureSelfView: View {
    let onClose: () -> Void
    @State private var monthly: Double = 100
    @State private var rate: Double = 0.07
    @State private var startAge: Double = 22
    private let endAge: Double = 65

    var futureValue: Double {
        let n = endAge - startAge
        let years = Int(n)
        // Future value of an annuity, monthly compounding
        let i = rate / 12
        let p = monthly
        let m = years * 12
        return p * ((pow(1 + i, Double(m)) - 1) / i)
    }

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack {
                        Button("Close", action: onClose).foregroundStyle(Palette.lavenderDeep)
                        Spacer()
                    }

                    Eyebrow(text: "Future self")
                    Text("Compound\ninterest is wild.")
                        .font(Typo.display).foregroundStyle(Palette.ink)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("At age \(Int(endAge))")
                                .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                            Text(futureValue.currency)
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(Palette.lavenderDeep)
                            Text("If you invest \(monthly.currency) per month from \(Int(startAge)) at \(Int(rate*100))%/yr returns.")
                                .font(Typo.caption).foregroundStyle(Palette.inkSoft)
                        }
                    }

                    sliderCard(label: "Monthly investment", valueLabel: monthly.currency,
                               value: $monthly, range: 25...1000, step: 25)
                    sliderCard(label: "Annual return",
                               valueLabel: "\(Int(rate*100))%",
                               value: $rate, range: 0.03...0.12, step: 0.005)
                    sliderCard(label: "Starting age",
                               valueLabel: String(Int(startAge)),
                               value: $startAge, range: 18...40, step: 1)

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
            }
        }
    }

    private func sliderCard(label: String, valueLabel: String,
                            value: Binding<Double>, range: ClosedRange<Double>,
                            step: Double) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Eyebrow(text: label, color: Palette.inkMuted)
                    Spacer()
                    Text(valueLabel).font(Typo.bodyBold).foregroundStyle(Palette.ink)
                }
                Slider(value: value, in: range, step: step).tint(Palette.lavenderDeep)
            }
        }
    }
}

#Preview {
    MoneyView().environmentObject(AppState())
}
