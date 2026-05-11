import Foundation

enum TradeMode: String, CaseIterable, Codable, Hashable {
    case sprint, standard, epic

    var title: String {
        switch self {
        case .sprint:   return "Sprint"
        case .standard: return "Standard"
        case .epic:     return "Epic"
        }
    }
    var span: String {
        switch self {
        case .sprint:   return "6 months"
        case .standard: return "1 year"
        case .epic:     return "10 years"
        }
    }
    var totalTime: String {
        switch self {
        case .sprint:   return "~45 sec"
        case .standard: return "~90 sec"
        case .epic:     return "~3 min"
        }
    }
    var ticks: Int {
        switch self {
        case .sprint:   return 26
        case .standard: return 52
        case .epic:     return 120
        }
    }
    var tickInterval: Double {
        switch self {
        case .sprint, .standard: return 1.7
        case .epic:              return 1.5
        }
    }
}

struct TradeAsset: Hashable, Identifiable {
    let id: String         // ticker
    let name: String
    let category: AssetCategory
    enum AssetCategory: String { case etf, bond, stock, crypto }
}

let UNIVERSE: [TradeAsset] = [
    TradeAsset(id: "VTI",   name: "Total US Market",      category: .etf),
    TradeAsset(id: "BND",   name: "US Bonds",             category: .bond),
    TradeAsset(id: "VXUS",  name: "International",        category: .etf),
    TradeAsset(id: "AAPL",  name: "Apple",                category: .stock),
    TradeAsset(id: "NVDA",  name: "NVIDIA",               category: .stock),
    TradeAsset(id: "TSLA",  name: "Tesla",                category: .stock),
    TradeAsset(id: "GOOGL", name: "Alphabet",             category: .stock),
    TradeAsset(id: "COIN",  name: "Coinbase",             category: .crypto),
]

struct RunSummary {
    let mode: TradeMode
    let startingCash: Double
    let finalValue: Double
    let finalReturn: Double
    let vtiReturn: Double
    let bestSingleSymbol: String
    let bestSingleReturn: Double
    let maxDrawdown: Double
    let assetsTouched: [String]
    let maxConcentration: Double
    let beatBenchmark: Bool
    let diversifierBadge: Bool
    let portfolioSeries: [Double]
    let vtiSeries: [Double]
}
