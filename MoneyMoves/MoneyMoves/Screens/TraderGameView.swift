import SwiftUI

// Synthetic but plausible market history for a hackathon demo.
// In production, swap in real OHLC data via MarketData.json bundled in the app.

struct TraderGameView: View {
    let mode: TradeMode
    let startingCash: Double
    let onClose: () -> Void

    @EnvironmentObject var app: AppState
    @State private var engine: TraderEngine
    @State private var timer: Timer?
    @State private var showTradeSheet: String? = nil
    @State private var showResult: Bool = false

    init(mode: TradeMode, startingCash: Double, onClose: @escaping () -> Void) {
        self.mode = mode
        self.startingCash = startingCash
        self.onClose = onClose
        _engine = State(initialValue: TraderEngine(mode: mode, startingCash: startingCash))
    }

    var body: some View {
        GradientBackground {
            VStack(alignment: .leading, spacing: Spacing.md) {
                header

                hudCard

                Text("Assets")
                    .font(Typo.h3)
                    .foregroundStyle(Palette.ink)
                    .padding(.top, Spacing.sm)

                ScrollView {
                    VStack(spacing: Spacing.sm) {
                        ForEach(engine.universe) { asset in
                            AssetRow(asset: asset, engine: engine) {
                                showTradeSheet = asset.id
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.xxl)
        }
        .onAppear { startTicking() }
        .onDisappear { timer?.invalidate() }
        .onChange(of: showTradeSheet) { _, newValue in
            if newValue != nil {
                // Pause the run while the player is deciding.
                timer?.invalidate()
                timer = nil
            } else if !showResult {
                startTicking()
            }
        }
        .sheet(item: Binding(get: { showTradeSheet.map { TickerRef(id: $0) } },
                              set: { _ in showTradeSheet = nil })) { ref in
            TradeSheet(symbol: ref.id, engine: $engine) {
                showTradeSheet = nil
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showResult) {
            TraderResultView(summary: engine.finalize(), onDone: {
                showResult = false
                onClose()
            })
        }
    }

    private var header: some View {
        HStack {
            Button(action: { timer?.invalidate(); onClose() }) {
                Text("Quit")
                    .font(Typo.bodyBold).foregroundStyle(Palette.ink)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Capsule().fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(Palette.glassBorder, lineWidth: 1)))
            }.buttonStyle(.plain)
            Spacer()
            Text("\(mode.title) · \(min(engine.gameTickIdx + 1, mode.ticks))/\(mode.ticks)")
                .font(Typo.caption).foregroundStyle(Palette.inkMuted)
        }
    }

    private var hudCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow(text: "Portfolio value")
                Text(engine.portfolioValue.currency)
                    .font(Typo.display).foregroundStyle(Palette.ink)
                HStack(spacing: Spacing.lg) {
                    statChip(label: "Return", value: engine.totalReturn.percent,
                             color: engine.totalReturn >= 0 ? Palette.success : Palette.roseDeep)
                    statChip(label: "Cash", value: engine.cash.currency, color: Palette.ink)
                }

                PortfolioChart(series: engine.portfolioHistory, startingCash: startingCash)
                    .frame(height: 90)
                    .padding(.top, 4)
            }
        }
    }

    private func statChip(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased()).font(.system(size: 10, weight: .bold)).tracking(1.0).foregroundStyle(Palette.inkMuted)
            Text(value).font(Typo.bodyBold).foregroundStyle(color)
        }
    }

    private func startTicking() {
        timer?.invalidate()
        // Fast first tick (600ms) then mode cadence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            tick()
            timer = Timer.scheduledTimer(withTimeInterval: mode.tickInterval, repeats: true) { _ in
                tick()
            }
        }
    }

    private func tick() {
        let cont = engine.advance()
        if !cont {
            timer?.invalidate()
            showResult = true
        }
    }
}

struct TickerRef: Identifiable { let id: String }

// MARK: - Asset row
struct AssetRow: View {
    let asset: TradeAsset
    let engine: TraderEngine
    let onTap: () -> Void

    var body: some View {
        let price  = engine.currentPrice(asset.id)
        let prev   = engine.previousPrice(asset.id)
        let change = prev > 0 ? (price - prev) / prev : 0
        let shares = engine.holdings[asset.id]?.shares ?? 0

        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(asset.id).font(Typo.bodyBold).foregroundStyle(Palette.ink)
                    Text(asset.name).font(Typo.caption).foregroundStyle(Palette.inkMuted)
                }
                Spacer()
                MiniSparkline(values: engine.recentPrices(asset.id, count: 6))
                    .frame(width: 70, height: 28)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price.currency).font(Typo.bodyBold).foregroundStyle(Palette.ink)
                    Text(change.percent)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(change >= 0 ? Palette.success : Palette.roseDeep)
                    if shares > 0 {
                        Text("\(String(format: "%.2f", shares)) sh")
                            .font(.system(size: 11)).foregroundStyle(Palette.lavenderDeep)
                    }
                }.frame(width: 90, alignment: .trailing)
            }
            .padding(.horizontal, Spacing.md).padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .stroke(Palette.glassBorder, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sparkline
struct MiniSparkline: View {
    let values: [Double]
    var body: some View {
        GeometryReader { geo in
            if let mn = values.min(), let mx = values.max(), mx > mn {
                Path { p in
                    for (i, v) in values.enumerated() {
                        let x = geo.size.width * CGFloat(i) / CGFloat(max(values.count - 1, 1))
                        let y = geo.size.height * (1 - CGFloat((v - mn) / (mx - mn)))
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                        else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(values.last! >= values.first! ? Palette.success : Palette.roseDeep,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Portfolio chart
struct PortfolioChart: View {
    let series: [Double]
    let startingCash: Double
    var body: some View {
        GeometryReader { geo in
            if series.count > 1, let mn = series.min(), let mx = series.max() {
                let range = max(mx - mn, 1)
                Path { p in
                    for (i, v) in series.enumerated() {
                        let x = geo.size.width * CGFloat(i) / CGFloat(max(series.count - 1, 1))
                        let y = geo.size.height * (1 - CGFloat((v - mn) / range))
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                        else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(Palette.lavenderDeep,
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Trade sheet
struct TradeSheet: View {
    let symbol: String
    @Binding var engine: TraderEngine
    let onClose: () -> Void
    @State private var dollarAmount: Double = 0
    @State private var mode: SheetMode = .buy
    @State private var didSeedAmount: Bool = false

    enum SheetMode { case buy, sell }

    var body: some View {
        let price = engine.currentPrice(symbol)
        let cash  = engine.cash
        let owned = engine.holdings[symbol]?.shares ?? 0
        let ownedValue = owned * price
        let maxDollars: Double = (mode == .buy ? cash : ownedValue).rounded(.down)

        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(symbol).font(Typo.h2).foregroundStyle(Palette.ink)
                            Text("Price: \(price.currency)")
                                .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                        }
                        Spacer()
                        Button(action: onClose) {
                            Text("Done")
                                .font(Typo.bodyBold)
                                .foregroundStyle(Palette.lavenderDeep)
                        }
                    }

                    Picker("", selection: $mode) {
                        Text("Buy").tag(SheetMode.buy)
                        Text("Sell").tag(SheetMode.sell)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: mode) { _, _ in
                        seedAmount(cash: cash, ownedValue: ownedValue)
                    }

                    // Position context
                    HStack(spacing: Spacing.lg) {
                        contextChip(label: "CASH", value: cash.currency)
                        contextChip(label: "HOLDING",
                                    value: owned > 0 ? "\(String(format: "%.2f", owned)) sh" : "—")
                        contextChip(label: "MAX",
                                    value: maxDollars > 0 ? maxDollars.currency : "$0")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(dollarAmount.currency)
                            .font(Typo.display)
                            .foregroundStyle(Palette.ink)
                            .contentTransition(.numericText())
                        Slider(value: $dollarAmount, in: 0...max(maxDollars, 1))
                            .tint(mode == .buy ? Palette.success : Palette.roseDeep)
                            .disabled(maxDollars <= 0)
                        Text(mode == .buy
                             ? "Buys \(String(format: "%.2f", price > 0 ? dollarAmount/price : 0)) shares"
                             : "Sells \(String(format: "%.2f", price > 0 ? dollarAmount/price : 0)) shares")
                            .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                    }
                    .padding(.top, Spacing.sm)

                    // Quick presets
                    HStack(spacing: 8) {
                        ForEach([0.25, 0.5, 1.0], id: \.self) { pct in
                            Button {
                                dollarAmount = (maxDollars * pct).rounded(.down)
                            } label: {
                                Text(pct == 1.0 ? "MAX" : "\(Int(pct * 100))%")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Palette.ink)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.6))
                                            .overlay(Capsule().stroke(Palette.glassBorder, lineWidth: 1))
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(maxDollars <= 0)
                        }
                        Spacer()
                    }

                    Button {
                        let amt = min(dollarAmount, maxDollars)
                        if mode == .buy { engine.buy(symbol, dollars: amt) }
                        else { engine.sell(symbol, dollars: amt) }
                        onClose()
                    } label: {
                        Text("\(mode == .buy ? "Buy" : "Sell") \(dollarAmount.currency)")
                            .font(Typo.bodyBold).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Capsule().fill(mode == .buy ? Palette.success : Palette.roseDeep))
                    }
                    .disabled(dollarAmount <= 0 || maxDollars <= 0)
                    .opacity((dollarAmount <= 0 || maxDollars <= 0) ? 0.4 : 1)
                    .buttonStyle(.plain)
                    .padding(.top, Spacing.sm)

                    if maxDollars <= 0 {
                        Text(mode == .buy ? "No cash to buy with." : "You don't own any \(symbol).")
                            .font(Typo.caption)
                            .foregroundStyle(Palette.inkMuted)
                            .frame(maxWidth: .infinity)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
            .onAppear {
                if !didSeedAmount {
                    seedAmount(cash: cash, ownedValue: ownedValue)
                    didSeedAmount = true
                }
            }
        }
    }

    private func seedAmount(cash: Double, ownedValue: Double) {
        // Default the slider to 25% of available so Buy isn't disabled by default.
        let cap = (mode == .buy ? cash : ownedValue).rounded(.down)
        guard cap > 0 else { dollarAmount = 0; return }
        dollarAmount = (cap * 0.25).rounded(.down)
    }

    private func contextChip(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 10, weight: .bold)).tracking(1.0)
                .foregroundStyle(Palette.inkMuted)
            Text(value).font(Typo.bodyBold).foregroundStyle(Palette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Palette.glassBorder, lineWidth: 1))
        )
    }
}
