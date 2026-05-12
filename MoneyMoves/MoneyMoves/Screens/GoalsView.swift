import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var app: AppState
    let onClose: () -> Void
    @State private var showLogSheet: Bool = false
    @State private var showAddGoal: Bool = false
    @State private var toast: String? = nil

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    header

                    if let g = app.activeGoal { activeGoalCard(g) }

                    categoriesSection
                    monthlyReconciliation
                    otherGoalsSection
                    depositsHistory
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.lg)
            }
        }
        .overlay(alignment: .top) {
            if let msg = toast {
                Text(msg)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(Palette.lavenderDeep))
                    .foregroundStyle(.white)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogExpenseSheet()
                .environmentObject(app)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showAddGoal) {
            AddGoalSheet()
                .environmentObject(app)
                .presentationDetents([.medium])
        }
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                HStack(spacing: 4) {
                    Text("←").font(.system(size: 18, weight: .semibold))
                    Text("Money").font(Typo.bodyBold)
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Capsule().fill(.ultraThinMaterial)
                    .overlay(Capsule().stroke(Palette.glassBorder, lineWidth: 1)))
            }.buttonStyle(.plain)
            Spacer()
        }
    }

    // MARK: - Active goal hero

    private func activeGoalCard(_ goal: SavingGoal) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Eyebrow(text: "ACTIVE GOAL")
            HStack(spacing: Spacing.md) {
                Text(goal.emoji).font(.system(size: 56))
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.name).font(Typo.h1).foregroundStyle(Palette.ink)
                    Text("\(goal.current.currency) of \(goal.target.currency)")
                        .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                }
            }
            ProgressBar(value: goal.fraction)
                .frame(height: 14)
            HStack {
                Text("\(goal.percent)% there")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.lavenderDeep)
                Spacer()
                Text("\(goal.remaining.currency) to go")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Palette.inkSoft)
            }
            if goal.monthlyTarget > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11, weight: .semibold))
                    Text("\(goal.monthlyTarget.currency) / mo · \(goal.paceLabel)")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Palette.lavenderDeep)
                .padding(.top, 2)
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .stroke(Palette.lavenderDeep.opacity(0.3), lineWidth: 1.5)
                )
        )
        .shadow(color: Palette.lavenderDeep.opacity(0.2), radius: 24, x: 0, y: 12)
    }

    // MARK: - Categories

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("This month").font(Typo.h2).foregroundStyle(Palette.ink)
                Spacer()
                Button {
                    showLogSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Log").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Palette.lavenderDeep)
                }
                .buttonStyle(.plain)
            }
            VStack(spacing: 8) {
                ForEach(app.categories) { cat in
                    CategoryRow(category: cat)
                }
            }
        }
    }

    // MARK: - Reconcile button (apply savings to goal)

    private var monthlyReconciliation: some View {
        let saved = app.categories.reduce(0) { $0 + $1.saved }
        return GlassCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Eyebrow(text: "Cushion this month")
                HStack(alignment: .firstTextBaseline) {
                    Text(saved.currency)
                        .font(Typo.display)
                        .foregroundStyle(saved > 0 ? Palette.success : Palette.inkMuted)
                    Spacer()
                }
                Text("That's the difference between your monthly averages and what you've spent so far. Tap below to move it into \(app.activeGoal?.name ?? "your goal").")
                    .font(Typo.caption).foregroundStyle(Palette.inkSoft)

                Button {
                    let amt = app.reconcileMonthlySavings()
                    if amt > 0 {
                        if let goalName = app.activeGoal?.name {
                            let pct = app.activeGoal?.percent ?? 0
                            showToast("You're \(pct)% closer to \(goalName).")
                        }
                    } else {
                        showToast("No cushion to deposit this month.")
                    }
                } label: {
                    Text("Apply \(saved.currency) to goal")
                        .font(Typo.bodyBold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Capsule().fill(saved > 0 ? Palette.lavenderDeep : Palette.inkMuted))
                }
                .disabled(saved <= 0 || app.activeGoal == nil)
                .opacity(saved > 0 ? 1 : 0.5)
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Other goals

    private var otherGoalsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Your goals").font(Typo.h2).foregroundStyle(Palette.ink)
                Spacer()
                Button {
                    showAddGoal = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Palette.lavenderDeep)
                }
                .buttonStyle(.plain)
            }
            VStack(spacing: 10) {
                ForEach(app.goals) { goal in
                    GoalRow(goal: goal) {
                        app.setActiveGoal(goal.id)
                        showToast("\(goal.emoji) \(goal.name) is now your active goal.")
                    }
                }
            }
        }
    }

    // MARK: - Recent deposits

    private var depositsHistory: some View {
        Group {
            if !app.deposits.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Recent deposits").font(Typo.h2).foregroundStyle(Palette.ink)
                    VStack(spacing: 8) {
                        ForEach(app.deposits.prefix(5)) { d in
                            depositRow(d)
                        }
                    }
                }
            }
        }
    }

    private func depositRow(_ d: GoalDeposit) -> some View {
        let goal = app.goals.first { $0.id == d.goalId }
        return HStack {
            Text(goal?.emoji ?? "💰").font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text("+\(d.amount.currency) → \(goal?.name ?? "goal")")
                    .font(Typo.bodyBold).foregroundStyle(Palette.ink)
                Text(d.date.formatted(date: .abbreviated, time: .omitted))
                    .font(Typo.caption).foregroundStyle(Palette.inkMuted)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.md).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(Palette.glassBorder, lineWidth: 1))
        )
    }

    private func showToast(_ s: String) {
        withAnimation(.easeInOut(duration: 0.2)) { toast = s }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.25)) { toast = nil }
        }
    }
}

// MARK: - Category row

struct CategoryRow: View {
    let category: SpendCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: Spacing.md) {
                Text(category.emoji).font(.system(size: 24))
                VStack(alignment: .leading, spacing: 1) {
                    Text(category.name).font(Typo.bodyBold).foregroundStyle(Palette.ink)
                    Text("Avg \(category.monthlyAverage.currency)")
                        .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text(category.thisMonth.currency)
                        .font(Typo.bodyBold)
                        .foregroundStyle(category.thisMonth > category.monthlyAverage ? Palette.roseDeep : Palette.ink)
                    if category.saved > 0 {
                        Text("+\(category.saved.currency) saved")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.success)
                    } else if category.thisMonth > category.monthlyAverage {
                        Text("over by \((category.thisMonth - category.monthlyAverage).currency)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.roseDeep)
                    } else {
                        Text("on track")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.inkMuted)
                    }
                }
            }
            ProgressBar(value: category.fractionSpent, tint: barTint).frame(height: 8)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(Palette.glassBorder, lineWidth: 1))
        )
    }

    private var barTint: Color {
        if category.thisMonth > category.monthlyAverage { return Palette.roseDeep }
        if category.fractionSpent > 0.8 { return Palette.peachDeep }
        return Palette.success
    }
}

// MARK: - Goal row

struct GoalRow: View {
    let goal: SavingGoal
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: Spacing.md) {
                    Text(goal.emoji).font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.name).font(Typo.h3).foregroundStyle(Palette.ink)
                        Text("\(goal.current.currency) of \(goal.target.currency)")
                            .font(Typo.caption).foregroundStyle(Palette.inkMuted)
                    }
                    Spacer()
                    Text("\(goal.percent)%")
                        .font(Typo.h3).foregroundStyle(goal.isActive ? Palette.lavenderDeep : Palette.inkMuted)
                }
                ProgressBar(value: goal.fraction,
                            tint: goal.isActive ? Palette.lavenderDeep : Palette.lavender)
                    .frame(height: 8)
                HStack(spacing: 8) {
                    if goal.monthlyTarget > 0 {
                        Label("\(goal.monthlyTarget.currency)/mo", systemImage: "calendar")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.inkSoft)
                    }
                    Text("·").font(.system(size: 11))
                        .foregroundStyle(Palette.inkMuted)
                        .opacity(goal.monthlyTarget > 0 ? 1 : 0)
                    Text(goal.paceLabel)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Palette.inkSoft)
                    Spacer()
                    if goal.isActive {
                        Text("ACTIVE").font(.system(size: 10, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(Palette.lavenderDeep)
                    } else {
                        Text("Tap to set active").font(Typo.caption).foregroundStyle(Palette.inkMuted)
                    }
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .stroke(goal.isActive ? Palette.lavenderDeep : Palette.glassBorder,
                                lineWidth: goal.isActive ? 2 : 1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress bar

struct ProgressBar: View {
    let value: Double          // 0...1+
    var tint: Color = Palette.lavenderDeep

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.lavenderSoft)
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * CGFloat(min(1, value)))
                    .animation(.easeOut(duration: 0.5), value: value)
            }
        }
    }
}

// MARK: - Log expense sheet

struct LogExpenseSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedId: String = SpendCategory.seed[0].id
    @State private var amountText: String = ""

    var body: some View {
        GradientBackground {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("Log expense").font(Typo.h2).foregroundStyle(Palette.ink)
                    Spacer()
                    Button("Cancel") { dismiss() }.foregroundStyle(Palette.lavenderDeep)
                }

                Eyebrow(text: "Category")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                          spacing: 8) {
                    ForEach(app.categories) { cat in
                        Button {
                            selectedId = cat.id
                        } label: {
                            VStack(spacing: 4) {
                                Text(cat.emoji).font(.system(size: 28))
                                Text(cat.name).font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Palette.ink)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, minHeight: 76)
                            .padding(.horizontal, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(selectedId == cat.id ? Palette.lavenderSoft : Color.white.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(selectedId == cat.id ? Palette.lavenderDeep : Palette.glassBorder,
                                                    lineWidth: selectedId == cat.id ? 2 : 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Eyebrow(text: "Amount").padding(.top, Spacing.sm)
                HStack {
                    Text(AppCurrency.current.currencySymbol)
                        .font(Typo.display).foregroundStyle(Palette.ink)
                    TextField("0", text: $amountText)
                        .keyboardType(.numberPad)
                        .font(Typo.display)
                        .foregroundStyle(Palette.ink)
                }
                .padding(.bottom, 4)
                Rectangle().fill(Palette.lavenderDeep).frame(height: 2)

                Spacer()

                Button {
                    if let amt = Double(amountText.filter("0123456789.".contains)), amt > 0 {
                        app.logExpense(categoryId: selectedId, amount: amt)
                        dismiss()
                    }
                } label: {
                    Text("Log expense").font(Typo.bodyBold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Capsule().fill(Palette.lavenderDeep))
                }
                .disabled(amountText.isEmpty)
                .opacity(amountText.isEmpty ? 0.4 : 1)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
    }
}

// MARK: - Add goal sheet

struct AddGoalSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var emoji: String = "✨"
    @State private var name: String = ""
    @State private var targetText: String = ""
    @State private var monthlyText: String = ""

    private let emojiChoices = ["🚗", "✈️", "🏠", "💍", "🎓", "📱", "🛋️", "🎮", "💻", "🛡️", "👶", "✨"]

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
        guard let m = monthsPreview else { return "Add a monthly amount to see the timeline." }
        if m < 12 { return "~\(m) months to reach it." }
        let years = m / 12
        let leftover = m % 12
        if leftover == 0 { return "~\(years) year\(years == 1 ? "" : "s") to reach it." }
        return "~\(years) year\(years == 1 ? "" : "s") and \(leftover) mo."
    }

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack {
                        Text("New goal").font(Typo.h2).foregroundStyle(Palette.ink)
                        Spacer()
                        Button("Cancel") { dismiss() }.foregroundStyle(Palette.lavenderDeep)
                    }

                    Eyebrow(text: "Icon")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                              spacing: 8) {
                        ForEach(emojiChoices, id: \.self) { e in
                            Button {
                                emoji = e
                            } label: {
                                Text(e).font(.system(size: 28))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(emoji == e ? Palette.lavenderSoft : Color.white.opacity(0.6))
                                            .overlay(Circle().stroke(emoji == e ? Palette.lavenderDeep : Palette.glassBorder,
                                                                     lineWidth: emoji == e ? 2 : 1))
                                    )
                            }.buttonStyle(.plain)
                        }
                    }

                    Eyebrow(text: "Name").padding(.top, Spacing.sm)
                    TextField("Dream car", text: $name)
                        .font(Typo.h3).foregroundStyle(Palette.ink)
                        .padding(.bottom, 4)
                    Rectangle().fill(Palette.lavenderDeep).frame(height: 2)

                    Eyebrow(text: "Target amount").padding(.top, Spacing.sm)
                    HStack {
                        Text(AppCurrency.current.currencySymbol).font(Typo.h1).foregroundStyle(Palette.ink)
                        TextField("25000", text: $targetText)
                            .keyboardType(.numberPad).font(Typo.h1).foregroundStyle(Palette.ink)
                    }
                    .padding(.bottom, 4)
                    Rectangle().fill(Palette.lavenderDeep).frame(height: 2)

                    Eyebrow(text: "Monthly contribution").padding(.top, Spacing.sm)
                    HStack {
                        Text(AppCurrency.current.currencySymbol).font(Typo.h1).foregroundStyle(Palette.ink)
                        TextField("300", text: $monthlyText)
                            .keyboardType(.numberPad).font(Typo.h1).foregroundStyle(Palette.ink)
                    }
                    .padding(.bottom, 4)
                    Rectangle().fill(Palette.lavenderDeep).frame(height: 2)

                    HStack(spacing: 8) {
                        Image(systemName: monthsPreview != nil ? "clock.fill" : "info.circle.fill")
                            .foregroundStyle(Palette.lavenderDeep)
                        Text(paceLine)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Palette.inkSoft)
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Palette.lavenderSoft.opacity(0.6))
                    )

                    Spacer().frame(height: Spacing.md)

                    Button {
                        guard !name.isEmpty, target > 0 else { return }
                        let goal = SavingGoal(id: UUID().uuidString, emoji: emoji, name: name,
                                              target: target, current: 0,
                                              monthlyTarget: monthly,
                                              isActive: app.activeGoal == nil)
                        app.addGoal(goal)
                        dismiss()
                    } label: {
                        Text("Create goal").font(Typo.bodyBold).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Capsule().fill(Palette.lavenderDeep))
                    }
                    .disabled(name.isEmpty || target <= 0)
                    .opacity((name.isEmpty || target <= 0) ? 0.4 : 1)
                    .buttonStyle(.plain)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}
