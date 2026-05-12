import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var route: Route = .splash
    @Published var user: User = User()
    @Published var tradeBests: [TradeMode: TradeBest] = [:]
    @Published var categories: [SpendCategory] = SpendCategory.seed
    @Published var goals: [SavingGoal] = SavingGoal.seed
    @Published var deposits: [GoalDeposit] = []
    @Published var lastDepositToast: String? = nil

    init() {
        load()
    }

    enum Route: Equatable {
        case splash, login, buddyPicker, goalSetup, main
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
        var connectedBank: String? = nil       // "Chase", "Bank of America", etc.
        var bankConnectedAt: Date? = nil
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

    func setName(_ name: String) {
        user.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
    }

    func setBuddyId(_ id: String) {
        user.buddyId = id
        save()
    }

    // MARK: - Bank connection (mock)
    // Real path: integrate Plaid Link iOS SDK → present OAuth → exchange public_token
    // for access_token via backend → poll /transactions endpoint. For the hackathon
    // demo, we mock the success state and import realistic transactions into categories.

    func connectBank(_ name: String) {
        user.connectedBank = name
        user.bankConnectedAt = Date()
        // Pretend the bank has shipped a month of transactions across our categories.
        // We add them into thisMonth, simulating "imported real transactions."
        let seed: [(String, Double)] = [
            ("food",          18.42),
            ("food",          24.99),
            ("food",          61.30),
            ("coffee",        4.75),
            ("coffee",        5.40),
            ("transport",     32.00),
            ("transport",     12.50),
            ("subs",          14.99),
            ("subs",          5.99),
            ("entertainment", 22.00),
            ("shopping",      48.50),
        ]
        for (catId, amt) in seed {
            if let idx = categories.firstIndex(where: { $0.id == catId }) {
                categories[idx].thisMonth += amt
            }
        }
        save()
    }

    func disconnectBank() {
        user.connectedBank = nil
        user.bankConnectedAt = nil
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

    // MARK: - Goals + spending

    var activeGoal: SavingGoal? {
        goals.first(where: { $0.isActive })
    }

    /// Log a new expense. Adjusts `thisMonth` for the category; if the category
    /// is still under its monthly average AFTER the log, no auto-deposit fires.
    /// If the user spent LESS than the average for the month at the time of logging,
    /// a delta is applied to the active goal (cinematic "you got closer" feedback).
    func logExpense(categoryId: String, amount: Double) {
        guard amount > 0,
              let idx = categories.firstIndex(where: { $0.id == categoryId }) else { return }

        let before = categories[idx].thisMonth
        categories[idx].thisMonth += amount

        // If they're STILL under their average after this purchase, top up
        // the active goal by what's left of the monthly cushion not yet "consumed."
        // We award only the incremental cushion gained (not the full delta) so each
        // expense has a small honest effect.
        let avg = categories[idx].monthlyAverage
        let cushionBefore = max(0, avg - before)
        let cushionAfter  = max(0, avg - categories[idx].thisMonth)
        let consumed = cushionBefore - cushionAfter
        // Negative-consumed (=they went over budget) shouldn't add to goal
        _ = consumed

        save()
    }

    /// "End of month" reconciliation — sums per-category savings and deposits
    /// them into the active goal. Use this when the user taps "Apply to goal."
    @discardableResult
    func reconcileMonthlySavings() -> Double {
        guard let idx = goals.firstIndex(where: { $0.isActive }) else { return 0 }
        let totalSaved = categories.reduce(0) { $0 + $1.saved }
        if totalSaved > 0 {
            goals[idx].current = min(goals[idx].target, goals[idx].current + totalSaved)
            let dep = GoalDeposit(goalId: goals[idx].id, amount: totalSaved)
            deposits.insert(dep, at: 0)
            let pct = goals[idx].percent
            lastDepositToast = "+\(Int(totalSaved.rounded())) → \(pct)% of \(goals[idx].name)"
            save()
        }
        // Reset month
        for i in categories.indices { categories[i].thisMonth = 0 }
        save()
        return totalSaved
    }

    func setActiveGoal(_ id: String) {
        for i in goals.indices { goals[i].isActive = goals[i].id == id }
        save()
    }

    func addGoal(_ goal: SavingGoal) {
        goals.append(goal)
        save()
    }

    func removeGoal(_ id: String) {
        goals.removeAll { $0.id == id }
        if goals.first(where: { $0.isActive }) == nil, !goals.isEmpty {
            goals[0].isActive = true
        }
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
        user = User()
        tradeBests = [:]
        categories = SpendCategory.seed
        goals = SavingGoal.seed
        deposits = []
        route = .splash
        AppCurrency.current = AppLocale.find(user.localeId)
        save()
    }

    // MARK: - Persistence (UserDefaults via JSON)

    private let userKey = "mm.user.v1"
    private let bestsKey = "mm.bests.v1"
    private let routeKey = "mm.route.v1"
    private let goalsKey = "mm.goals.v1"
    private let catsKey  = "mm.cats.v1"
    private let depKey   = "mm.deposits.v1"

    private func save() {
        let d = UserDefaults.standard
        if let data = try? JSONEncoder().encode(user) { d.set(data, forKey: userKey) }
        if let data = try? JSONEncoder().encode(tradeBests) { d.set(data, forKey: bestsKey) }
        if let data = try? JSONEncoder().encode(goals) { d.set(data, forKey: goalsKey) }
        if let data = try? JSONEncoder().encode(categories) { d.set(data, forKey: catsKey) }
        if let data = try? JSONEncoder().encode(deposits) { d.set(data, forKey: depKey) }
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
        if let data = d.data(forKey: goalsKey),
           let g = try? JSONDecoder().decode([SavingGoal].self, from: data) {
            goals = g
        }
        if let data = d.data(forKey: catsKey),
           let c = try? JSONDecoder().decode([SpendCategory].self, from: data) {
            categories = c
        }
        if let data = d.data(forKey: depKey),
           let dep = try? JSONDecoder().decode([GoalDeposit].self, from: data) {
            deposits = dep
        }
        AppCurrency.current = AppLocale.find(user.localeId)
        // Older builds defaulted empty names to "Friend" — strip that so
        // the home greeting either shows the real name or falls back to "Hi there."
        if user.name == "Friend" { user.name = "" }
        // Buddy slot used to be called "otter" and rendered as 🦦. We replaced
        // that slot with the hand-drawn bunny artwork; migrate older saves.
        if user.buddyId == "otter" { user.buddyId = "bunny" }
        if d.string(forKey: routeKey) == "main", user.buddyId != nil {
            route = .main
        }
    }
}
