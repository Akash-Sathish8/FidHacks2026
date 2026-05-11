import Foundation

enum SBPurchaseType: String, Codable { case need, want }

struct SBPurchaseCard: Identifiable, Hashable, Codable {
    let id = UUID()
    let title: String
    let price: Int
    let type: SBPurchaseType
    let emoji: String

    enum CodingKeys: String, CodingKey { case title, price, type, emoji }
}

let SB_DECK: [SBPurchaseCard] = [
    .init(title: "Sephora Haul",      price: 67,   type: .want, emoji: "💄"),
    .init(title: "Quick Lunch",       price: 12,   type: .need, emoji: "🥪"),
    .init(title: "Coachella Ticket",  price: 1200, type: .want, emoji: "🎡"),
    .init(title: "Phone Bill",        price: 55,   type: .need, emoji: "📱"),
    .init(title: "Matching Sweatset", price: 85,   type: .want, emoji: "🧶"),
    .init(title: "Gas for Car",       price: 40,   type: .need, emoji: "⛽"),
    .init(title: "Concert Merch",     price: 45,   type: .want, emoji: "👕"),
    .init(title: "Rent Payment",      price: 1400, type: .need, emoji: "🏠"),
    .init(title: "Late Night Uber",   price: 24,   type: .want, emoji: "🚗"),
    .init(title: "Weekly Groceries",  price: 95,   type: .need, emoji: "🛒"),
    .init(title: "Spotify Premium",   price: 11,   type: .want, emoji: "🎵"),
    .init(title: "Electric Bill",     price: 120,  type: .need, emoji: "⚡"),
    .init(title: "New Sneakers",      price: 110,  type: .want, emoji: "👟"),
    .init(title: "Gym Membership",    price: 45,   type: .need, emoji: "💪"),
    .init(title: "Coffee Run",        price: 7,    type: .want, emoji: "☕"),
    .init(title: "Car Insurance",     price: 150,  type: .need, emoji: "🛡️"),
    .init(title: "Movie Night",       price: 35,   type: .want, emoji: "🍿"),
    .init(title: "Water Bill",        price: 30,   type: .need, emoji: "🚰"),
    .init(title: "Skincare Bundle",   price: 95,   type: .want, emoji: "🧴"),
    .init(title: "Vitamins",          price: 25,   type: .need, emoji: "💊"),
    .init(title: "Designer Purse",    price: 850,  type: .want, emoji: "👜"),
    .init(title: "Internet Bill",     price: 70,   type: .need, emoji: "🌐"),
    .init(title: "Dinner at Nobu",    price: 250,  type: .want, emoji: "🍱"),
    .init(title: "MacBook Pro",       price: 2000, type: .want, emoji: "💻"),
    .init(title: "Student Loan",      price: 300,  type: .need, emoji: "🎓"),
    .init(title: "Grocery Club",      price: 10,   type: .need, emoji: "💳"),
    .init(title: "Designer Shades",   price: 350,  type: .want, emoji: "🕶️"),
    .init(title: "Health Insurance",  price: 250,  type: .need, emoji: "🏥"),
    .init(title: "Vegas Weekend",     price: 800,  type: .want, emoji: "🎲"),
    .init(title: "Haircut & Style",   price: 120,  type: .want, emoji: "💇"),
    .init(title: "Dog Food",          price: 60,   type: .need, emoji: "🐕"),
    .init(title: "Vet Visit",         price: 150,  type: .need, emoji: "🩺"),
    .init(title: "Monthly Bus Pass",  price: 80,   type: .need, emoji: "🚌"),
    .init(title: "Arcade Night",      price: 40,   type: .want, emoji: "🕹️"),
    .init(title: "Vinyl Record",      price: 50,   type: .want, emoji: "📻"),
    .init(title: "House Plant",       price: 25,   type: .want, emoji: "🌿"),
    .init(title: "Car Repairs",       price: 450,  type: .need, emoji: "🔧"),
    .init(title: "Laundry Soap",      price: 15,   type: .need, emoji: "🧼"),
    .init(title: "Oral Care Kit",     price: 20,   type: .need, emoji: "🪥"),
    .init(title: "Fancy Cocktail",    price: 18,   type: .want, emoji: "🍸"),
    .init(title: "Subscription Box",  price: 45,   type: .want, emoji: "📦"),
    .init(title: "Parking Ticket",    price: 75,   type: .need, emoji: "🎫"),
]

// MARK: - Persisted history

struct SBHistory: Codable, Equatable {
    var initialBudget: Int
    var remaining: Int
    var spent: Int

    private static let key = "sb.budget.history.v1"

    static func load() -> SBHistory? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let h = try? JSONDecoder().decode(SBHistory.self, from: data) else { return nil }
        return h
    }
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: SBHistory.key)
        }
    }
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
