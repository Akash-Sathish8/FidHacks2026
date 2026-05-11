import Foundation

struct Quest: Identifiable, Hashable {
    let id: String
    let title: String
    let blurb: String
    let category: Category
    let xp: Int
    let coins: Int
    let lesson: [String]      // 3-5 short coach messages

    enum Category: String, Hashable {
        case paycheck, budgeting, investing, negotiation, credit, saving
        var emoji: String {
            switch self {
            case .paycheck:    return "💸"
            case .budgeting:   return "📊"
            case .investing:   return "📈"
            case .negotiation: return "🤝"
            case .credit:      return "💳"
            case .saving:      return "🐷"
            }
        }
    }
}

let QUESTS: [Quest] = [
    Quest(id: "paycheck", title: "Read your first paycheck",
          blurb: "Federal, state, FICA — where does it go?",
          category: .paycheck, xp: 60, coins: 30,
          lesson: [
            "Your gross is the sticker price — what you negotiated. Net is what hits your bank.",
            "FICA (7.65%) funds Social Security + Medicare. You can't avoid it but you'll see it forever.",
            "Federal + state income tax depend on your W-4. Too few withholdings = surprise bill in April.",
            "Pre-tax deductions (401k, HSA, health premiums) come OUT of gross BEFORE taxes — that's the magic of pre-tax saving.",
            "Action: open your last pay stub right now and find each line. You'll never look at a salary number the same way."
          ]),
    Quest(id: "budget-50-30-20", title: "The 50/30/20 starter budget",
          blurb: "Simple split: needs, wants, save.",
          category: .budgeting, xp: 80, coins: 40,
          lesson: [
            "50% needs (rent, food, transport, insurance), 30% wants, 20% save/invest. That's it.",
            "If 50% can't cover your needs — your fixed costs are too high. Roommate, cheaper area, transit.",
            "The 20% is sacred. It's the lever between you and your future self.",
            "Pro move: automate it. The day you get paid, 20% leaves before you can spend it.",
            "Action: pick a free tracker (Notion / Apple Numbers / your bank's tool) and log this month."
          ]),
    Quest(id: "first-roth", title: "Open a Roth IRA",
          blurb: "Tax-free growth. Best account in your 20s.",
          category: .investing, xp: 120, coins: 60,
          lesson: [
            "Roth IRA = pay tax NOW, grow tax-free, withdraw tax-free in retirement.",
            "Your tax rate at 22 (probably 12-22%) is likely lower than at 60. So Roth wins for most students.",
            "Limit is $7,000/year (2025). Even $50/month started at 22 = ~$200k at 65 at 7% returns.",
            "Open it at Fidelity / Schwab / Vanguard. Free, takes 10 min. Pick a target-date fund and forget.",
            "Action: bookmark the IRA application page. Even if you don't contribute today — you'll have the muscle memory."
          ]),
    Quest(id: "salary-anchor", title: "Anchor your salary ask",
          blurb: "The number you say first wins the room.",
          category: .negotiation, xp: 100, coins: 50,
          lesson: [
            "When recruiters ask 'what's your expectation' — they're betting you'll undersell.",
            "Counter: 'Based on the role and market data, I'd expect $X.' Pick X from levels.fyi for your level.",
            "Anchor high but defensible. Going 10-15% over their likely offer leaves room for both sides to feel good.",
            "If they offer below — silence. Then 'Can you walk me through how you got to that number?' Don't accept on the call.",
            "Action: practice your one-sentence anchor out loud. The words have to feel rehearsed."
          ]),
    Quest(id: "credit-myth", title: "The credit score myth",
          blurb: "What helps, what doesn't, what they don't tell you.",
          category: .credit, xp: 70, coins: 35,
          lesson: [
            "Credit score isn't about being responsible with money. It's about predictably paying lenders back.",
            "Biggest factor: payment history (35%). Never miss a payment. Even one 30-day late = -100 points.",
            "Second biggest: utilization (30%). Keep balances under 30% of your credit limit. 10% is even better.",
            "Closing old cards = bad (shortens average age). Asking for a higher limit = good (lowers utilization).",
            "Action: check your free FICO score (CreditKarma / Experian). Note your highest two factors and what's dragging you."
          ]),
    Quest(id: "emergency-fund", title: "Build a 3-month buffer",
          blurb: "The dumbest, most powerful financial move.",
          category: .saving, xp: 90, coins: 45,
          lesson: [
            "An emergency fund is the difference between a setback and a spiral.",
            "Target: 3 months of bare-minimum expenses (rent + food + insurance, no nights out).",
            "Keep it in a high-yield savings account (Ally / Marcus / Apple Card Savings). 4-5% currently.",
            "Don't invest it. Returns don't matter — accessibility does. Liquid = first month, growth = later money.",
            "Action: pick the bank, calculate your number, set up a $50/week auto-transfer. You'll get there."
          ]),
]

// MARK: - Squad members
struct SquadMember: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let bestReturn: Double
    let badges: [String]
}

let SQUAD: [SquadMember] = [
    SquadMember(id: "maya",  name: "Maya",  emoji: "🌸", bestReturn: 0.42, badges: ["diversifier", "streak-30"]),
    SquadMember(id: "priya", name: "Priya", emoji: "🌿", bestReturn: 0.31, badges: ["diversifier"]),
    SquadMember(id: "zoe",   name: "Zoe",   emoji: "🌊", bestReturn: 0.18, badges: []),
    SquadMember(id: "lena",  name: "Lena",  emoji: "🍯", bestReturn: -0.05, badges: ["streak-7"]),
]

// MARK: - Watchlist
struct WatchAsset: Identifiable, Hashable {
    let id: String
    let name: String
    let price: Double
    let change: Double   // pct
    let series: [Double] // sparkline
}

let WATCHLIST: [WatchAsset] = [
    WatchAsset(id: "VTI",   name: "Total US Market",
               price: 245.18, change: 0.012,
               series: [240, 241, 239, 242, 243, 245]),
    WatchAsset(id: "BND",   name: "US Bonds",
               price: 73.40, change: 0.002,
               series: [73, 73.2, 73.1, 73.3, 73.4, 73.4]),
    WatchAsset(id: "AAPL",  name: "Apple",
               price: 178.92, change: -0.008,
               series: [180, 179, 181, 180, 179, 178.92]),
    WatchAsset(id: "NVDA",  name: "NVIDIA",
               price: 412.55, change: 0.034,
               series: [395, 401, 398, 405, 410, 412.55]),
    WatchAsset(id: "TSLA",  name: "Tesla",
               price: 244.18, change: -0.021,
               series: [255, 250, 248, 246, 247, 244.18]),
    WatchAsset(id: "VXUS",  name: "International",
               price: 58.74, change: 0.006,
               series: [58, 58.2, 58.4, 58.5, 58.7, 58.74]),
]

// MARK: - Buddy accessories
struct Accessory: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let cost: Int
}

let ACCESSORIES: [Accessory] = [
    Accessory(id: "crown",    name: "Tiny crown",  emoji: "👑", cost: 100),
    Accessory(id: "scarf",    name: "Cozy scarf",  emoji: "🧣", cost: 60),
    Accessory(id: "glasses",  name: "Bookish specs", emoji: "👓", cost: 80),
    Accessory(id: "balloon",  name: "Balloon",     emoji: "🎈", cost: 40),
    Accessory(id: "rose",     name: "Single rose", emoji: "🌹", cost: 50),
    Accessory(id: "donut",    name: "Donut",       emoji: "🍩", cost: 30),
]
