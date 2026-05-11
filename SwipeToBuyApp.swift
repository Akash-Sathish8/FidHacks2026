import SwiftUI

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme Constants
struct Theme {
    static let lavender = Color(hex: "CDB4DB")
    static let palePink = Color(hex: "FFC8DD")
    static let hotPink = Color(hex: "FFAFCC") // SKIP
    static let skyBlue = Color(hex: "BDE0FE")
    static let brightBlue = Color(hex: "A2D2FF") // BUY
    static let ink = Color(hex: "2D2335")
    static let inkSoft = Color(hex: "5E5466")
}

// MARK: - Models
struct PurchaseCard: Identifiable, Codable {
    var id = UUID()
    let title: String
    let price: Int
    let type: PurchaseType
    let emoji: String
    
    enum PurchaseType: String, Codable {
        case want, need
    }
}

// MARK: - Data
let PURCHASE_DATA: [PurchaseCard] = [
    PurchaseCard(title: "Sephora Haul", price: 67, type: .want, emoji: "💄"),
    PurchaseCard(title: "Quick Lunch", price: 12, type: .need, emoji: "🥪"),
    PurchaseCard(title: "Coachella Ticket", price: 1200, type: .want, emoji: "🎡"),
    PurchaseCard(title: "Phone Bill", price: 55, type: .need, emoji: "📱"),
    PurchaseCard(title: "Matching Sweatset", price: 85, type: .want, emoji: "🧶"),
    PurchaseCard(title: "Gas for Car", price: 40, type: .need, emoji: "⛽"),
    PurchaseCard(title: "Rent Payment", price: 1400, type: .need, emoji: "🏠"),
    PurchaseCard(title: "Late Night Uber", price: 24, type: .want, emoji: "🚗"),
    PurchaseCard(title: "Weekly Groceries", price: 95, type: .need, emoji: "🛒"),
    PurchaseCard(title: "Spotify Premium", price: 11, type: .want, emoji: "🎵"),
    PurchaseCard(title: "MacBook Pro", price: 2000, type: .want, emoji: "💻"),
    PurchaseCard(title: "Student Loan", price: 300, type: .need, emoji: "🎓"),
    PurchaseCard(title: "Designer Shades", price: 350, type: .want, emoji: "🕶️"),
    PurchaseCard(title: "Health Insurance", price: 250, type: .need, emoji: "🏥"),
    PurchaseCard(title: "Car Repairs", price: 450, type: .need, emoji: "🔧"),
    PurchaseCard(title: "Dinner at Nobu", price: 250, type: .want, emoji: "🍱")
]

// MARK: - View Model
class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .input
    @Published var budgetInput: String = "2500"
    @Published var currentCards: [PurchaseCard] = []
    @Published var purchased: [PurchaseCard] = []
    @Published var swipedCount: Int = 0
    @Published var remainingBalance: Int = 0
    @Published var initialBudget: Int = 0
    
    // Persistence
    @AppStorage("saved_initial_budget") var savedInitial: Int = 0
    @AppStorage("saved_remaining") var savedRemaining: Int = 0
    @AppStorage("has_history") var hasHistory: Bool = false
    
    enum GameState {
        case input, playing, summary
    }
    
    func startGame(keepPrevious: Bool) {
        if keepPrevious {
            initialBudget = savedInitial
            remainingBalance = savedRemaining
        } else {
            let val = Int(budgetInput) ?? 2500
            initialBudget = min(val, 10000)
            remainingBalance = initialBudget
        }
        
        currentCards = PURCHASE_DATA.shuffled().prefix(10).reversed() // Reversed for ZStack
        purchased = []
        swipedCount = 0
        gameState = .playing
    }
    
    func handleSwipe(bought: Bool, card: PurchaseCard) {
        if bought {
            purchased.append(card)
            remainingBalance -= card.price
        }
        swipedCount += 1
        
        if swipedCount >= 10 {
            finishRound()
        }
    }
    
    private func finishRound() {
        savedInitial = initialBudget
        savedRemaining = remainingBalance
        hasHistory = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.gameState = .summary
        }
    }
    
    func resetGame() {
        hasHistory = false
        gameState = .input
    }
    
    var feedbackMessage: String {
        if remainingBalance < 0 { return "Budget bust! You're in debt. New Game recommended." }
        if remainingBalance < 800 { return "Danger Zone! You've got very little left for rent." }
        let skippedNeeds = PURCHASE_DATA.filter { $0.type == .need && !purchased.contains(where: { $0.id == $0.id }) }.count
        if skippedNeeds > 5 { return "Warning: You skipped essential needs to buy wants!" }
        return "Excellent control! You balanced your needs well."
    }
}

// MARK: - Main View
struct SwipeToBuyView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Theme.palePink, Theme.skyBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.3)
                .ignoresSafeArea()
            
            // Side Flashes
            HStack(spacing: 0) {
                Theme.brightBlue
                    .opacity(dragOffset.width < 0 ? Double(min(abs(dragOffset.width) / 150, 0.4)) : 0)
                Theme.hotPink
                    .opacity(dragOffset.width > 0 ? Double(min(abs(dragOffset.width) / 150, 0.4)) : 0)
            }
            .ignoresSafeArea()
            
            VStack {
                if viewModel.gameState == .input {
                    inputScreen
                } else if viewModel.gameState == .playing {
                    gameScreen
                }
            }
            .padding()
            
            if viewModel.gameState == .summary {
                summaryModal
            }
        }
    }
    
    // MARK: - Subviews
    var inputScreen: some View {
        VStack(spacing: 24) {
            Text("Financial Swipe")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            
            if viewModel.hasHistory {
                VStack(alignment: .leading, spacing: 8) {
                    Text("LAST SESSION")
                        .font(.caption.bold())
                        .foregroundColor(Theme.lavender)
                    HStack {
                        Text("Budget Left:")
                        Spacer()
                        Text("$\(viewModel.savedRemaining)")
                            .bold()
                    }
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(18)
            }
            
            VStack {
                Text("Set Your Budget")
                    .font(.headline)
                    .foregroundColor(Theme.inkSoft)
                
                HStack {
                    Text("$")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Theme.lavender)
                    TextField("2500", text: $viewModel.budgetInput)
                        .keyboardType(.numberPad)
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .fixedSize()
                }
                .padding(.bottom, 8)
                .border(Theme.lavender, width: 3, edges: [.bottom])
                
                Text("Maximum $10,000")
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 32)
            
            VStack(spacing: 12) {
                Button(action: { viewModel.startGame(keepPrevious: false) }) {
                    Text("Start Simulation")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.lavender)
                        .clipShape(Capsule())
                }
                
                if viewModel.hasHistory {
                    Button(action: { viewModel.startGame(keepPrevious: true) }) {
                        Text("Continue Last Budget")
                            .font(.headline)
                            .foregroundColor(Theme.lavender)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .overlay(Capsule().stroke(Theme.lavender, lineWidth: 2))
                    }
                }
            }
        }
        .padding(32)
        .background(VisualEffectBlur(blurStyle: .systemMaterialLight))
        .cornerRadius(32)
        .shadow(color: Theme.lavender.opacity(0.2), radius: 20)
    }
    
    var gameScreen: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("BUDGET LEFT")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    Text("$\(viewModel.remainingBalance)")
                        .font(.title2.bold())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("PROGRESS")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    Text("\(viewModel.swipedCount)/10")
                        .font(.title2.bold())
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            ZStack {
                ForEach(viewModel.currentCards) { card in
                    CardView(card: card, onSwipe: { bought in
                        viewModel.handleSwipe(bought: bought, card: card)
                    }, dragOffset: $dragOffset)
                }
            }
            .frame(height: 400)
            
            Spacer()
            
            Text("← Swipe LEFT to BUY | Swipe RIGHT to SKIP →")
                .font(.caption.bold())
                .foregroundColor(Theme.inkSoft)
                .padding(.bottom, 20)
        }
    }
    
    var summaryModal: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { }
            
            VStack(spacing: 24) {
                Text("Round Complete!")
                    .font(.title.bold())
                
                VStack(spacing: 12) {
                    summaryRow(label: "Bought", value: "\(viewModel.purchased.count) items")
                    summaryRow(label: "Wants", value: "\(viewModel.purchased.filter { $0.type == .want }.count)")
                    summaryRow(label: "Needs", value: "\(viewModel.purchased.filter { $0.type == .need }.count)")
                    
                    Divider()
                    
                    summaryRow(label: "Remaining", value: "$\(viewModel.remainingBalance)", color: viewModel.remainingBalance < 800 ? Theme.hotPink : Theme.ink)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("COACH INSIGHTS")
                        .font(.caption2.bold())
                        .foregroundColor(Theme.lavender)
                    Text(viewModel.feedbackMessage)
                        .font(.subheadline)
                        .foregroundColor(Theme.ink)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.skyBlue.opacity(0.2))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.lavender, lineWidth: 1))
                
                VStack(spacing: 12) {
                    Button(action: { viewModel.startGame(keepPrevious: true) }) {
                        Text("Keep Playing")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.lavender)
                            .clipShape(Capsule())
                    }
                    
                    Button(action: { viewModel.resetGame() }) {
                        Text("New Game (Fresh Start)")
                            .bold()
                            .foregroundColor(Theme.lavender)
                            .padding()
                    }
                }
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(32)
            .padding(24)
        }
    }
    
    func summaryRow(label: String, value: String, color: Color = Theme.ink) -> some View {
        HStack {
            Text(label)
                .foregroundColor(Theme.inkSoft)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(color)
        }
    }
}

// MARK: - Card View
struct CardView: View {
    let card: PurchaseCard
    var onSwipe: (Bool) -> Void
    @Binding var dragOffset: CGSize
    @State private var offset: CGSize = .zero
    @State private var isRemoved = false
    
    var body: some View {
        if !isRemoved {
            ZStack(alignment: .topLeading) {
                // The Card
                VStack(spacing: 20) {
                    Text(card.emoji)
                        .font(.system(size: 80))
                    Text(card.title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    Text("$\(card.price)")
                        .font(.system(size: 44, weight: .black))
                        .foregroundColor(Theme.lavender)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(32)
                .shadow(color: Color.black.opacity(0.1), radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Theme.palePink, lineWidth: 1)
                )
                
                // Labels
                Text("BUY")
                    .font(.title.black())
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.brightBlue, lineWidth: 4))
                    .foregroundColor(Theme.brightBlue)
                    .rotationEffect(.degrees(-15))
                    .opacity(offset.width < 0 ? Double(min(abs(offset.width) / 100, 1)) : 0)
                    .padding(24)
                
                Text("SKIP")
                    .font(.title.black())
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.hotPink, lineWidth: 4))
                    .foregroundColor(Theme.hotPink)
                    .rotationEffect(.degrees(15))
                    .opacity(offset.width > 0 ? Double(min(abs(offset.width) / 100, 1)) : 0)
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        dragOffset = gesture.translation
                    }
                    .onEnded { _ in
                        if abs(offset.width) > 150 {
                            let bought = offset.width < 0
                            withAnimation(.spring()) {
                                offset.width = offset.width > 0 ? 1000 : -1000
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isRemoved = true
                                onSwipe(bought)
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = .zero
                                dragOffset = .zero
                            }
                        }
                    }
            )
        }
    }
}

// MARK: - Helpers
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension View {
    func border(_ color: Color, width: CGFloat, edges: [Edge]) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat { rect.minX }
            var y: CGFloat { rect.minY }
            var w: CGFloat { rect.width }
            var h: CGFloat { rect.height }
            switch edge {
            case .top: path.addRect(CGRect(x: x, y: y, width: w, height: width))
            case .bottom: path.addRect(CGRect(x: x, y: y + h - width, width: w, height: width))
            case .leading: path.addRect(CGRect(x: x, y: y, width: width, height: h))
            case .trailing: path.addRect(CGRect(x: x + w - width, y: y, width: width, height: h))
            }
        }
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeToBuyView()
    }
}
