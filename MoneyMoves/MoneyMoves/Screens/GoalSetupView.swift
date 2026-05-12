import SwiftUI

// Onboarding step right after BuddyPicker. Captures the user's first real
// savings goal + monthly commitment, then drops them into the main app
// with that goal active.

struct GoalSetupView: View {
    @EnvironmentObject var app: AppState

    @State private var emoji: String = "🚗"
    @State private var name: String = ""
    @State private var targetText: String = ""
    @State private var monthlyText: String = ""

    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case name, target, monthly }

    private let emojiChoices: [String] = ["🚗", "✈️", "🎓", "🏠", "💍", "✨"]

    private var target: Double {
        Double(targetText.filter("0123456789".contains)) ?? 0
    }
    private var monthly: Double {
        Double(monthlyText.filter("0123456789".contains)) ?? 0
    }

    private var monthsPreview: Int? {
        guard target > 0, monthly > 0 else { return nil }
        return max(1, Int(ceil(target / monthly)))
    }
    private var paceLine: String {
        guard let m = monthsPreview else {
            if target > 0 && monthly == 0 { return "Pick a monthly amount to see your timeline." }
            if monthly > 0 && target == 0 { return "Set a target so we can chart it." }
            return "Choose a target and a monthly amount."
        }
        if m < 12 { return "~\(m) months to reach it at this pace." }
        let years = m / 12
        let leftover = m % 12
        if leftover == 0 { return "~\(years) year\(years == 1 ? "" : "s") at this pace." }
        return "~\(years) year\(years == 1 ? "" : "s") and \(leftover) mo at this pace."
    }
    private var canContinue: Bool { !name.isEmpty && target > 0 }

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    Eyebrow(text: "Your first money move")
                    Text(headline)
                        .font(Typo.display)
                        .foregroundStyle(Palette.ink)
                    Text("Pick something you actually want. A trip, a car, a deposit, a quiet emergency fund — anything. Your buddy will help you get there.")
                        .font(Typo.body)
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.bottom, Spacing.sm)

                    emojiPicker

                    GlassCard {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            labeledField(label: "Name it",
                                         placeholder: "Dream car",
                                         text: $name,
                                         field: .name,
                                         keyboard: .default)
                            Divider().background(Palette.glassBorder)
                            currencyField(label: "Target amount",
                                          placeholder: "25,000",
                                          text: $targetText,
                                          field: .target)
                            Divider().background(Palette.glassBorder)
                            currencyField(label: "Monthly contribution",
                                          placeholder: "300",
                                          text: $monthlyText,
                                          field: .monthly)
                        }
                    }

                    pacePreview

                    Spacer().frame(height: Spacing.md)

                    GradientButton(title: canContinue ? "Set this goal" : "Add a name + target") {
                        commitAndContinue()
                    }
                    .opacity(canContinue ? 1 : 0.55)
                    .disabled(!canContinue)

                    Button {
                        skipForNow()
                    } label: {
                        Text("I'll set this later")
                            .font(Typo.caption)
                            .foregroundStyle(Palette.inkMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }.buttonStyle(.plain)

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxxl)
            }
        }
    }

    private var headline: String {
        let n = app.user.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if n.isEmpty {
            return "What are you\nsaving toward?"
        }
        return "What are you\nsaving toward, \(n)?"
    }

    // MARK: - Emoji picker

    private var emojiPicker: some View {
        HStack(spacing: 10) {
            ForEach(emojiChoices, id: \.self) { e in
                Button {
                    emoji = e
                } label: {
                    Text(e)
                        .font(.system(size: 30))
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(emoji == e ? Palette.lavenderSoft : Color.white.opacity(0.55))
                                .overlay(
                                    Circle()
                                        .stroke(emoji == e ? Palette.lavenderDeep : Palette.glassBorder,
                                                lineWidth: emoji == e ? 2 : 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Inputs

    @ViewBuilder
    private func labeledField(label: String,
                              placeholder: String,
                              text: Binding<String>,
                              field: Field,
                              keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold)).tracking(1.2)
                .foregroundStyle(Palette.inkMuted)
            TextField(placeholder, text: text)
                .font(Typo.bodyBold)
                .foregroundStyle(Palette.ink)
                .focused($focusedField, equals: field)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
        }
    }

    @ViewBuilder
    private func currencyField(label: String,
                               placeholder: String,
                               text: Binding<String>,
                               field: Field) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold)).tracking(1.2)
                .foregroundStyle(Palette.inkMuted)
            HStack(spacing: 4) {
                Text(AppCurrency.current.currencySymbol)
                    .font(Typo.bodyBold)
                    .foregroundStyle(Palette.inkMuted)
                TextField(placeholder, text: text)
                    .font(Typo.bodyBold)
                    .foregroundStyle(Palette.ink)
                    .focused($focusedField, equals: field)
                    .keyboardType(.numberPad)
                    .onChange(of: text.wrappedValue) { _, newVal in
                        let digits = newVal.filter { $0.isNumber }
                        if digits != newVal { text.wrappedValue = digits }
                    }
            }
        }
    }

    // MARK: - Pace preview

    private var pacePreview: some View {
        HStack(spacing: 10) {
            Image(systemName: monthsPreview != nil ? "clock.fill" : "info.circle.fill")
                .foregroundStyle(monthsPreview != nil ? Palette.lavenderDeep : Palette.inkMuted)
            Text(paceLine)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Palette.inkSoft)
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(Palette.lavenderSoft.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .stroke(Palette.glassBorder, lineWidth: 1)
                )
        )
    }

    // MARK: - Actions

    private func commitAndContinue() {
        let goal = SavingGoal(
            id: UUID().uuidString,
            emoji: emoji,
            name: name,
            target: target,
            current: 0,
            monthlyTarget: monthly,
            isActive: true
        )
        app.addGoal(goal)
        app.setActiveGoal(goal.id)
        app.route = .main
    }

    private func skipForNow() {
        // Make sure they leave onboarding with SOMETHING active so GoalsView
        // doesn't look broken on first visit.
        let stub = SavingGoal(
            id: UUID().uuidString,
            emoji: "✨",
            name: "Saving for the future",
            target: 1000,
            current: 0,
            monthlyTarget: 50,
            isActive: true
        )
        app.addGoal(stub)
        app.setActiveGoal(stub.id)
        app.route = .main
    }
}

#Preview {
    GoalSetupView().environmentObject(AppState())
}
