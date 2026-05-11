import Foundation

// One-row description of a supported region. id matches Locale identifier
// so NumberFormatter can pick up the right currency symbol + grouping.
struct AppLocale: Identifiable, Hashable {
    let id: String           // e.g. "en_US"
    let flag: String
    let country: String
    let currencyCode: String // ISO 4217
    let currencySymbol: String
}

extension AppLocale {
    static let all: [AppLocale] = [
        AppLocale(id: "en_US", flag: "🇺🇸", country: "United States", currencyCode: "USD", currencySymbol: "$"),
        AppLocale(id: "en_GB", flag: "🇬🇧", country: "United Kingdom", currencyCode: "GBP", currencySymbol: "£"),
        AppLocale(id: "en_CA", flag: "🇨🇦", country: "Canada", currencyCode: "CAD", currencySymbol: "CA$"),
        AppLocale(id: "fr_FR", flag: "🇪🇺", country: "Eurozone", currencyCode: "EUR", currencySymbol: "€"),
        AppLocale(id: "en_IN", flag: "🇮🇳", country: "India", currencyCode: "INR", currencySymbol: "₹"),
        AppLocale(id: "ja_JP", flag: "🇯🇵", country: "Japan", currencyCode: "JPY", currencySymbol: "¥"),
        AppLocale(id: "en_AU", flag: "🇦🇺", country: "Australia", currencyCode: "AUD", currencySymbol: "A$"),
        AppLocale(id: "es_MX", flag: "🇲🇽", country: "Mexico", currencyCode: "MXN", currencySymbol: "MX$"),
        AppLocale(id: "pt_BR", flag: "🇧🇷", country: "Brazil", currencyCode: "BRL", currencySymbol: "R$"),
        AppLocale(id: "zh_CN", flag: "🇨🇳", country: "China", currencyCode: "CNY", currencySymbol: "CN¥"),
    ]

    static let usa = all[0]

    static func find(_ id: String) -> AppLocale {
        all.first { $0.id == id } ?? .usa
    }
}

// Global "current" so any `Double.currency` access picks up the user's choice
// without threading the locale through every view.
enum AppCurrency {
    static var current: AppLocale = .usa
}
