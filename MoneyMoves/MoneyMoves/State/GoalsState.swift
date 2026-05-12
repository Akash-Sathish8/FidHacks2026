import Foundation

// MARK: - Spending categories

struct SpendCategory: Identifiable, Codable, Hashable {
    var id: String          // stable key
    var emoji: String
    var name: String
    var monthlyAverage: Double    // user's historical average
    var thisMonth: Double = 0     // current month actual spend

    var saved: Double { max(0, monthlyAverage - thisMonth) }
    var fractionSpent: Double {
        guard monthlyAverage > 0 else { return 0 }
        return min(1.5, thisMonth / monthlyAverage)
    }
}

extension SpendCategory {
    static let seed: [SpendCategory] = [
        .init(id: "food",          emoji: "🛒", name: "Food & groceries", monthlyAverage: 400, thisMonth: 280),
        .init(id: "subs",          emoji: "📺", name: "Subscriptions",    monthlyAverage: 80,  thisMonth: 55),
        .init(id: "transport",     emoji: "🚌", name: "Transport",        monthlyAverage: 150, thisMonth: 110),
        .init(id: "entertainment", emoji: "🎟️", name: "Entertainment",    monthlyAverage: 120, thisMonth: 145),
        .init(id: "shopping",      emoji: "🛍", name: "Shopping",         monthlyAverage: 200, thisMonth: 90),
        .init(id: "coffee",        emoji: "☕", name: "Coffee + drinks",   monthlyAverage: 60,  thisMonth: 38),
    ]
}

// MARK: - Savings goals

struct SavingGoal: Identifiable, Codable, Hashable {
    var id: String
    var emoji: String
    var name: String
    var target: Double
    var current: Double = 0
    var monthlyTarget: Double = 0       // how much the user commits to put in / month
    var isActive: Bool = false

    var fraction: Double {
        guard target > 0 else { return 0 }
        return min(1, current / target)
    }
    var percent: Int { Int((fraction * 100).rounded()) }
    var remaining: Double { max(0, target - current) }

    /// Months until goal is hit at the committed monthly pace.
    /// Returns nil when monthlyTarget is 0 (treat as "no schedule").
    var monthsToGoal: Int? {
        guard monthlyTarget > 0 else { return nil }
        if remaining <= 0 { return 0 }
        return max(1, Int(ceil(remaining / monthlyTarget)))
    }

    /// Human-readable countdown — e.g. "7 mo", "2 yrs · 4 mo", "—"
    var paceLabel: String {
        guard let months = monthsToGoal else { return "—" }
        if months == 0 { return "Goal hit ✓" }
        if months < 12 { return "\(months) mo to go" }
        let years = months / 12
        let leftover = months % 12
        if leftover == 0 { return "\(years) yr\(years == 1 ? "" : "s") to go" }
        return "\(years) yr\(years == 1 ? "" : "s") · \(leftover) mo"
    }
}

extension SavingGoal {
    // No more demo goals — the user creates their first real goal during
    // onboarding via GoalSetupView, then adds more via AddGoalSheet.
    static let seed: [SavingGoal] = []
}

// MARK: - A single deposit event so we can show "+$X to your dream car"

struct GoalDeposit: Identifiable, Codable, Hashable {
    let id: UUID
    let goalId: String
    let amount: Double
    let date: Date
    let sourceCategoryId: String?      // nil if manual

    init(id: UUID = UUID(), goalId: String, amount: Double, date: Date = Date(), sourceCategoryId: String? = nil) {
        self.id = id
        self.goalId = goalId
        self.amount = amount
        self.date = date
        self.sourceCategoryId = sourceCategoryId
    }
}
