import Foundation

// Generates plausible random-walk price histories for the universe.
// Each run, prices restart from a deterministic-but-randomized base
// so the same demo doesn't always repeat. Real OHLC ingestion is a v2.

struct AssetPosition {
    var shares: Double = 0
    var avgCost: Double = 0
}

struct TraderEngine {
    let mode: TradeMode
    let startingCash: Double

    private(set) var universe: [TradeAsset]
    private(set) var priceSeries: [String: [Double]]
    private(set) var currentTick: Int = 0
    let prerollLen: Int = 5
    private(set) var cash: Double
    private(set) var holdings: [String: AssetPosition] = [:]
    private(set) var portfolioHistory: [Double]
    private(set) var assetsTouched: Set<String> = []
    private var peakValue: Double
    private var maxDrawdown: Double = 0

    init(mode: TradeMode, startingCash: Double) {
        self.mode = mode
        self.startingCash = startingCash
        self.cash = startingCash
        self.peakValue = startingCash
        self.portfolioHistory = [startingCash]

        // Filter universe per-mode. Epic is the longest; we include all for the demo
        // and rely on generation length matching ticks + preroll.
        self.universe = UNIVERSE
        let totalTicks = mode.ticks + prerollLen
        var series: [String: [Double]] = [:]
        for asset in universe {
            series[asset.id] = Self.generateSeries(
                ticks: totalTicks,
                volatility: Self.vol(for: asset),
                drift: Self.drift(for: asset),
                base: Self.base(for: asset)
            )
        }
        self.priceSeries = series
        self.currentTick = prerollLen
    }

    // Game-relative tick (0-based, in the playable window)
    var gameTickIdx: Int { currentTick - prerollLen }
    var gameTickCount: Int { mode.ticks }

    func currentPrice(_ symbol: String) -> Double {
        priceSeries[symbol]?[safe: currentTick] ?? 0
    }
    func previousPrice(_ symbol: String) -> Double {
        priceSeries[symbol]?[safe: currentTick - 1] ?? currentPrice(symbol)
    }
    func recentPrices(_ symbol: String, count: Int) -> [Double] {
        guard let series = priceSeries[symbol] else { return [] }
        let lo = max(0, currentTick - count + 1)
        return Array(series[lo...currentTick])
    }

    var portfolioValue: Double {
        var v = cash
        for (sym, pos) in holdings { v += pos.shares * currentPrice(sym) }
        return v
    }
    var totalReturn: Double {
        (portfolioValue - startingCash) / startingCash
    }

    // Returns false when run is complete.
    mutating func advance() -> Bool {
        let endIdx = prerollLen + mode.ticks - 1
        if currentTick >= endIdx { return false }
        currentTick += 1
        let v = portfolioValue
        portfolioHistory.append(v)
        if v > peakValue { peakValue = v }
        let dd = peakValue > 0 ? (peakValue - v) / peakValue : 0
        if dd > maxDrawdown { maxDrawdown = dd }
        return true
    }

    mutating func buy(_ symbol: String, dollars: Double) {
        let p = currentPrice(symbol)
        guard p > 0 else { return }
        let spend = min(dollars, cash)
        let shares = spend / p
        guard shares > 0 else { return }
        let prev = holdings[symbol] ?? AssetPosition()
        let totalShares = prev.shares + shares
        let avg = (prev.shares * prev.avgCost + shares * p) / totalShares
        holdings[symbol] = AssetPosition(shares: totalShares, avgCost: avg)
        cash -= spend
        assetsTouched.insert(symbol)
    }
    mutating func sell(_ symbol: String, dollars: Double) {
        let p = currentPrice(symbol)
        guard p > 0, var pos = holdings[symbol], pos.shares > 0 else { return }
        let sharesWanted = min(dollars / p, pos.shares)
        guard sharesWanted > 0 else { return }
        cash += sharesWanted * p
        pos.shares -= sharesWanted
        if pos.shares < 1e-9 { holdings.removeValue(forKey: symbol) }
        else { holdings[symbol] = pos }
    }

    func finalize() -> RunSummary {
        let playable = Array(portfolioHistory.dropFirst())  // skip initial baseline
        let finalValue = portfolioValue
        let vtiSeries = priceSeries["VTI"]?.dropFirst(prerollLen).map { $0 } ?? []
        let vtiStart = vtiSeries.first ?? 1
        let vtiEnd   = vtiSeries.last ?? vtiStart
        let vtiReturn = (vtiEnd - vtiStart) / max(vtiStart, 1)
        let vtiPortfolio = vtiSeries.map { (Double($0) / vtiStart) * startingCash }

        // Best single asset
        var bestSym = "VTI"
        var bestRet = vtiReturn
        for asset in universe {
            guard let s = priceSeries[asset.id]?.dropFirst(prerollLen) else { continue }
            let first = s.first ?? 1
            let last  = s.last ?? first
            let r = (last - first) / max(first, 1)
            if r > bestRet { bestRet = r; bestSym = asset.id }
        }

        // Max concentration (final tick)
        let totalEnd = finalValue
        var maxConcentration: Double = 0
        for (sym, pos) in holdings {
            let value = pos.shares * currentPrice(sym)
            let pct = totalEnd > 0 ? value / totalEnd : 0
            if pct > maxConcentration { maxConcentration = pct }
        }

        let touched = Array(assetsTouched)
        let diversifier = touched.count >= 4
        let finalReturn = (finalValue - startingCash) / startingCash

        return RunSummary(
            mode: mode,
            startingCash: startingCash,
            finalValue: finalValue,
            finalReturn: finalReturn,
            vtiReturn: vtiReturn,
            bestSingleSymbol: bestSym,
            bestSingleReturn: bestRet,
            maxDrawdown: maxDrawdown,
            assetsTouched: touched,
            maxConcentration: maxConcentration,
            beatBenchmark: finalReturn > vtiReturn,
            diversifierBadge: diversifier,
            portfolioSeries: playable,
            vtiSeries: vtiPortfolio
        )
    }

    // MARK: - Random walk helpers

    private static func generateSeries(ticks: Int, volatility: Double, drift: Double, base: Double) -> [Double] {
        var out: [Double] = []
        var p = base
        for _ in 0..<ticks {
            let shock = Double.random(in: -volatility...volatility) + drift
            p *= (1 + shock)
            out.append(max(p, 0.01))
        }
        return out
    }

    private static func vol(for asset: TradeAsset) -> Double {
        switch asset.category {
        case .bond:   return 0.005
        case .etf:    return 0.020
        case .stock:  return 0.045
        case .crypto: return 0.080
        }
    }
    private static func drift(for asset: TradeAsset) -> Double {
        switch asset.category {
        case .bond:   return 0.0008
        case .etf:    return 0.0020
        case .stock:  return 0.0028
        case .crypto: return 0.0035
        }
    }
    private static func base(for asset: TradeAsset) -> Double {
        switch asset.id {
        case "VTI":   return 220
        case "BND":   return 78
        case "VXUS":  return 58
        case "AAPL":  return 175
        case "NVDA":  return 380
        case "TSLA":  return 240
        case "GOOGL": return 160
        case "COIN":  return 80
        default:      return 100
        }
    }
}

extension Array {
    subscript(safe idx: Int) -> Element? {
        indices.contains(idx) ? self[idx] : nil
    }
}
