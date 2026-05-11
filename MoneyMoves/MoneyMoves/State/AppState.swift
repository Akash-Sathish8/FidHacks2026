import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var route: Route = .splash
    @Published var user: User = User()
    @Published var tradeBests: [TradeMode: TradeBest] = [:]

    init() {
        load()
    }

    enum Route: Equatable {
        case splash, login, buddyPicker, main
    }

    struct User: Codable {
        var name: String = ""
        var email: String = ""
        var localeId: String = "en_US"
        var buddyId: String? = nil
        var coins: Int = 240
        var xp: Int = 80
        var level: Int = 2
        var streak: Int = 3
        var completedQuests: Set<String> = []
        var ownedAccessories: Set<String> = []
        var equippedAccessory: String? = nil
    }

    struct TradeBest: Codable, Equatable {
        let finalReturn: Double
        let date: Date
        let diversifierBadge: Bool
    }

    // MARK: - Actions

    func setLocale(_ locale: AppLocale) {
        user.localeId = locale.id
        AppCurrency.current = locale
        save()
    }

    func addCoins(_ n: Int) { user.coins += n; save() }
    func addXP(_ n: Int) {
        user.xp += n
        while user.xp >= xpForNextLevel() {
            user.xp -= xpForNextLevel()
            user.level += 1
        }
        save()
    }
    func xpForNextLevel() -> Int { 200 + user.level * 50 }

    func completeQuest(_ id: String) {
        user.completedQuests.insert(id)
        save()
    }

    func recordTradeBest(mode: TradeMode, finalReturn: Double, diversifier: Bool) {
        let prev = tradeBests[mode]?.finalReturn ?? -.infinity
        if finalReturn > prev {
            tradeBests[mode] = TradeBest(finalReturn: finalReturn, date: Date(), diversifierBadge: diversifier)
            save()
        }
    }

    func resetForNewSession() {
        // Used for splash → login if user signs out. Not exposed in UI yet.
        user = User()
        tradeBests = [:]
        route = .splash
        save()
    }

    // MARK: - Persistence (UserDefaults via JSON)

    private let userKey = "mm.user.v1"
    private let bestsKey = "mm.bests.v1"
    private let routeKey = "mm.route.v1"

    private func save() {
        let d = UserDefaults.standard
        if let data = try? JSONEncoder().encode(user) { d.set(data, forKey: userKey) }
        if let data = try? JSONEncoder().encode(tradeBests) { d.set(data, forKey: bestsKey) }
        // Route is session-state, but persist past-splash so relaunch doesn't reset.
        if route == .main { d.set("main", forKey: routeKey) }
    }

    private func load() {
        let d = UserDefaults.standard
        if let data = d.data(forKey: userKey),
           let u = try? JSONDecoder().decode(User.self, from: data) {
            user = u
        }
        if let data = d.data(forKey: bestsKey),
           let b = try? JSONDecoder().decode([TradeMode: TradeBest].self, from: data) {
            tradeBests = b
        }
        AppCurrency.current = AppLocale.find(user.localeId)
        if d.string(forKey: routeKey) == "main", user.buddyId != nil {
            route = .main
        }
    }
}
