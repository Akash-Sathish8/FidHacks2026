import SwiftUI

struct MoneyView: View {
    @EnvironmentObject var app: AppState
    @State private var showFutureSelf: Bool = false

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Watchlist")
                    Text("Money.").font(Typo.display).foregroundStyle(Palette.ink)
                    Text("Track real names. Then practice trading in Market Games.")
                        .font(Typo.body).foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.sm)

                    futureSelfCard

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
