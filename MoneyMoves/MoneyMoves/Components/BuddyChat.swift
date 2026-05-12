import SwiftUI

// MARK: - Floating chat button (lives as an overlay on MainTabView)

struct BuddyChatButton: View {
    @EnvironmentObject var app: AppState
    @State private var showChat: Bool = false
    @State private var pulseScale: CGFloat = 1

    private var buddyEmoji: String {
        switch app.user.buddyId {
        case "fox":   return "🦊"
        case "otter": return "🦦"
        case "cat":   return "🐱"
        default:      return "✨"
        }
    }

    var body: some View {
        Button { showChat = true } label: {
            ZStack {
                // Subtle outer ring that gently pulses
                Circle()
                    .stroke(Palette.lavenderDeep.opacity(0.25), lineWidth: 2)
                    .frame(width: 60, height: 60)
                    .scaleEffect(pulseScale)
                    .opacity(2 - pulseScale)
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(Circle().stroke(Palette.glassBorder, lineWidth: 1))
                    .frame(width: 52, height: 52)
                    .shadow(color: Palette.lavenderDeep.opacity(0.3), radius: 14, x: 0, y: 6)
                Text(buddyEmoji).font(.system(size: 30))
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: false)) {
                pulseScale = 1.3
            }
        }
        .sheet(isPresented: $showChat) {
            BuddyChatView().environmentObject(app)
        }
    }
}

// MARK: - Chat message model

struct ChatMsg: Identifiable, Equatable {
    enum Role: Equatable { case user, buddy }
    let id = UUID()
    let role: Role
    let text: String
    let date: Date = Date()
}

// MARK: - Chat sheet

struct BuddyChatView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [ChatMsg] = []
    @State private var draft: String = ""
    @State private var thinking: Bool = false
    @FocusState private var inputFocused: Bool

    private var buddyEmoji: String {
        switch app.user.buddyId {
        case "fox":   return "🦊"
        case "otter": return "🦦"
        case "cat":   return "🐱"
        default:      return "✨"
        }
    }
    private var buddyName: String {
        switch app.user.buddyId {
        case "fox":   return "Fox"
        case "otter": return "Otter"
        case "cat":   return "Cat"
        default:      return "Buddy"
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [Palette.cream, Color(hex: 0xF6EEF8), Color(hex: 0xEEF1FA)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                messagesList
                Divider()
                inputBar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            if messages.isEmpty {
                // Slight delay so the chat sheet's slide-up animation finishes before
                // the first bubble pops in — feels more alive.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let opener = "Hi \(app.user.name.isEmpty ? "there" : app.user.name)! I'm your money buddy. What can I help with?"
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        messages.append(ChatMsg(role: .buddy, text: opener))
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Gradients.hero).frame(width: 44, height: 44)
                Text(buddyEmoji).font(.system(size: 24))
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("\(buddyName) — your money buddy").font(Typo.bodyBold).foregroundStyle(Palette.ink)
                HStack(spacing: 4) {
                    Circle().fill(Palette.success).frame(width: 6, height: 6)
                    Text("online")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Palette.inkMuted)
                }
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Palette.inkMuted.opacity(0.6))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(messages) { msg in
                        MessageBubble(msg: msg, buddyEmoji: buddyEmoji)
                            .id(msg.id)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.85).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                    }
                    if thinking {
                        TypingIndicator(buddyEmoji: buddyEmoji)
                            .id("typing")
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    // Bottom anchor for scroll
                    Color.clear.frame(height: 4).id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: thinking) { _, isThinking in
                if isThinking {
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Ask me anything…", text: $draft, axis: .vertical)
                    .focused($inputFocused)
                    .lineLimit(1...4)
                    .autocorrectionDisabled(false)
                    .onSubmit { send() }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(Capsule().stroke(Palette.glassBorder, lineWidth: 1))
            )

            Button(action: send) {
                ZStack {
                    Circle().fill(canSend ? Palette.lavenderDeep : Palette.inkMuted.opacity(0.4))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .disabled(!canSend)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !thinking
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            messages.append(ChatMsg(role: .user, text: text))
        }
        withAnimation { thinking = true }
        // Mock think time — feels less robotic than instant
        let delay = Double.random(in: 0.7...1.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let reply = ChatBot.respond(to: text)
            withAnimation(.easeInOut) { thinking = false }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                messages.append(ChatMsg(role: .buddy, text: reply))
            }
        }
    }
}

// MARK: - Message bubble

struct MessageBubble: View {
    let msg: ChatMsg
    let buddyEmoji: String

    var body: some View {
        if msg.role == .user {
            HStack(alignment: .bottom, spacing: 6) {
                Spacer(minLength: 40)
                Text(msg.text)
                    .font(Typo.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Palette.lavenderDeep)
                    )
                    .frame(maxWidth: 280, alignment: .trailing)
            }
        } else {
            HStack(alignment: .bottom, spacing: 6) {
                ZStack {
                    Circle().fill(Gradients.hero).frame(width: 28, height: 28)
                    Text(buddyEmoji).font(.system(size: 16))
                }
                Text(msg.text)
                    .font(Typo.body)
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Palette.glassBorder, lineWidth: 1)
                            )
                    )
                    .frame(maxWidth: 280, alignment: .leading)
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Typing indicator

struct TypingIndicator: View {
    let buddyEmoji: String
    @State private var phase: Int = 0
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ZStack {
                Circle().fill(Gradients.hero).frame(width: 28, height: 28)
                Text(buddyEmoji).font(.system(size: 16))
            }
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Palette.inkMuted.opacity(phase == i ? 1 : 0.35))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Palette.glassBorder, lineWidth: 1)
                    )
            )
            Spacer(minLength: 40)
        }
        .onReceive(timer) { _ in
            phase = (phase + 1) % 3
        }
    }
}

// MARK: - Mock chatbot
// Keyword-based responses. Swap to real Claude later by replacing respond(to:)
// with an async URLSession call to api.anthropic.com (needs API key + backend
// for key storage). Mock works offline, no rate limits, demo-safe.

enum ChatBot {
    static func respond(to message: String) -> String {
        let m = message.lowercased()

        if matches(m, ["save", "saving", "savings", "emergency fund"]) {
            return "Easy win: automate it. The money you don't see is money you don't spend. Even $50/month into a high-yield savings account starts the habit, and a 3-month buffer turns most emergencies into inconveniences."
        }
        if matches(m, ["invest", "investing", "stock", "stocks", "etf", "index"]) {
            return "Start with a target-date fund or a total-market ETF like VTI. Boring is the cheat code — 10% historical annual returns, no stock-picking stress. Pick a slice of every paycheck and forget it."
        }
        if matches(m, ["roth", "ira"]) {
            return "Roth IRA = your superpower in your 20s. You pay tax now (when you earn less) and never again. Even $50/month started at 22 grows to roughly $200K by 65 at 7%. Open one at Fidelity or Schwab — 10 minutes."
        }
        if matches(m, ["401", "401k", "match"]) {
            return "If your employer matches 401(k) contributions, max the match. That's a 100% instant return — refusing it is leaving free money on the table. Default contribution is usually 0% — don't accept the default."
        }
        if matches(m, ["budget", "spending", "track"]) {
            return "Try the 50/30/20 rule: 50% needs, 30% wants, 20% save. Use the Money tab here to track categories — once you see where it actually goes, fixing it gets way easier."
        }
        if matches(m, ["credit", "score", "card"]) {
            return "Two big levers: never miss a payment (35% of your score), and keep your balance under 30% of the limit (30% of your score). Auto-pay the minimum so you never get burned. Closing old cards hurts more than people think."
        }
        if matches(m, ["debt", "loan", "loans"]) {
            return "Two strategies: avalanche (highest APR first — saves more) or snowball (smallest balance first — feels more motivating). Both work. Pick whichever you'll actually stick with."
        }
        if matches(m, ["salary", "negotiate", "negotiation", "offer", "raise"]) {
            return "Always counter. 'Best and final' is a script — most polite counters succeed. Anchor with market data (levels.fyi, Glassdoor, Payscale). Your first salary anchors every raise after, so this one matters most."
        }
        if matches(m, ["car", "vehicle", "auto"]) {
            return "Cars are wealth-killers — insurance, gas, repairs, depreciation. If you really need one, used + reliable (Honda, Toyota) + paid in cash beats new + financed every time."
        }
        if matches(m, ["house", "home", "mortgage", "rent"]) {
            return "Rule of thumb: spend under 30% of take-home on housing. If you can split rent for a year or two early in your career, the savings rate that buys is hard to recreate later."
        }
        if matches(m, ["tax", "taxes"]) {
            return "Pre-tax contributions (401k, HSA, traditional IRA) lower this year's tax bill. Roth contributions don't, but grow tax-free. Don't skip your W-4 — it controls how much gets withheld."
        }
        if matches(m, ["goal", "goals", "track"]) {
            return "Set one BIG goal and one small one. Big keeps you motivated, small gives you wins. Open the Money tab → Goals to see how your category cushion auto-flows into whatever goal you pick."
        }
        if matches(m, ["help", "what can you do", "what do you do"]) {
            return "I can talk through saving, investing, budgeting, credit, salary negotiation, debt, big purchases, goals — pretty much any money thing on your mind. What's on yours?"
        }
        if matches(m, ["hi", "hello", "hey", "yo"]) {
            return "Hey! I'm here for whatever's on your mind — money moves, future stuff, life stuff that touches money. What's up?"
        }

        return "Tell me more — are you thinking about saving, investing, budgeting, a big purchase, or something else? The more specific you get, the better I can help."
    }

    private static func matches(_ haystack: String, _ needles: [String]) -> Bool {
        needles.contains { haystack.contains($0) }
    }
}
